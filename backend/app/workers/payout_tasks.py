import asyncio
from datetime import datetime, timedelta

from app.workers.celery_app import celery_app


def _run(coro):
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()


@celery_app.task(
    name="app.workers.payout_tasks.process_withdrawal",
    queue="payouts",
    autoretry_for=(Exception,),
    retry_backoff=True,
    retry_backoff_max=300,
    retry_kwargs={"max_retries": 5},
)
def process_withdrawal(user_id: str, amount_kobo: int, reference: str, account_number: str, bank_code: str, account_name: str):
    _run(_do_withdrawal(user_id, amount_kobo, reference, account_number, bank_code, account_name))


async def _mark_provider_failure(db, withdrawal, reason: str):
    """Refund a withdrawal only after the provider confirms it failed/reversed."""
    from app.models.wallet import Transaction
    from app.services import wallet_service
    from sqlalchemy import select

    tx_result = await db.execute(
        select(Transaction)
        .where(Transaction.reference == withdrawal.reference, Transaction.type == "withdrawal")
        .with_for_update()
    )
    tx = tx_result.scalar_one_or_none()
    if not tx:
        raise RuntimeError(
            f"Withdrawal ledger entry missing for {withdrawal.reference}; "
            "refusing to mark provider failure without a refund"
        )

    await wallet_service.credit(
        db,
        withdrawal.user_id,
        tx.amount_kobo,
        "withdrawal_reversal",
        description="Withdrawal failed at provider — funds returned",
        reference=f"{withdrawal.reference}:reversal",
    )
    withdrawal.status = "failed"
    withdrawal.failure_reason = reason[:255]
    withdrawal.completed_at = datetime.utcnow()


async def _reconcile_provider_transfer(reference: str):
    """Reconcile an ambiguous Paystack transfer request by stable reference."""
    from app.database import AsyncSessionLocal
    from app.models.withdrawal import Withdrawal
    from app.services import paystack
    from app.services.notification_service import notify
    from sqlalchemy import select

    try:
        provider = await paystack.verify_transfer(reference)
    except Exception:
        return False

    status = (provider.get("status") or "").lower()
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
        withdrawal = result.scalar_one_or_none()
        if not withdrawal or withdrawal.status in ("successful", "failed", "reversed"):
            return True

        withdrawal.provider_reference = provider.get("transfer_code") or provider.get("reference") or reference

        if status == "success":
            withdrawal.status = "processing"
        elif status in ("failed", "reversed"):
            await _mark_provider_failure(db, withdrawal, provider.get("failures") or f"Paystack transfer {status}")
            await notify(
                db,
                withdrawal.user_id,
                "withdrawal_processed",
                "Withdrawal failed",
                f"Your withdrawal of ₦{withdrawal.amount_kobo/100:,.2f} could not be completed and was refunded to your wallet.",
            )
        else:
            withdrawal.status = "processing"

        await db.commit()
    return True


async def _acquire_reference_lock(db, reference: str):
    """Serialize payout attempts for the same stable provider reference."""
    from sqlalchemy import text

    await db.execute(text("SELECT pg_advisory_lock(hashtextextended(:reference, 0))"), {"reference": reference})


async def _release_reference_lock(db, reference: str):
    from sqlalchemy import text

    await db.execute(text("SELECT pg_advisory_unlock(hashtextextended(:reference, 0))"), {"reference": reference})


async def _do_withdrawal(user_id, amount_kobo, reference, account_number, bank_code, account_name):
    import httpx
    from app.database import AsyncSessionLocal
    from app.models.withdrawal import Withdrawal
    from app.services import paystack
    from sqlalchemy import select

    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
        withdrawal = result.scalar_one_or_none()
        if not withdrawal:
            return
        if withdrawal.status in ("successful", "failed", "reversed"):
            return

        withdrawal.status = "processing"
        await db.commit()

        await _acquire_reference_lock(db, reference)
        try:
            current_result = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
            withdrawal = current_result.scalar_one_or_none()
            if not withdrawal or withdrawal.status in ("successful", "failed", "reversed"):
                return

            try:
                provider = await paystack.verify_transfer(reference)
            except Exception:
                provider = None

            if provider:
                status = (provider.get("status") or "").lower()
                withdrawal.provider_reference = provider.get("transfer_code") or provider.get("reference") or reference
                if status == "success":
                    withdrawal.status = "processing"
                elif status in ("failed", "reversed"):
                    await _mark_provider_failure(db, withdrawal, provider.get("failures") or f"Paystack transfer {status}")
                else:
                    withdrawal.status = "processing"
                await db.commit()
                return

            recipient_code = withdrawal.recipient_code
            if not recipient_code:
                recipient_code = await paystack.create_transfer_recipient(account_number, bank_code, account_name)
                withdrawal.recipient_code = recipient_code
                await db.commit()

            try:
                result = await paystack.initiate_transfer(amount_kobo, recipient_code, reference)
            except httpx.HTTPStatusError as exc:
                found = await _reconcile_provider_transfer(reference)
                if found:
                    return
                if 400 <= exc.response.status_code < 500:
                    failed = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                    failed_withdrawal = failed.scalar_one_or_none()
                    if failed_withdrawal and failed_withdrawal.status not in ("successful", "failed", "reversed"):
                        await _mark_provider_failure(db, failed_withdrawal, f"Paystack rejected transfer ({exc.response.status_code})")
                        await db.commit()
                    return
                raise
            except Exception:
                if await _reconcile_provider_transfer(reference):
                    return
                raise

            provider_reference = result.get("transfer_code") or result.get("reference") or reference
            saved = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
            saved_withdrawal = saved.scalar_one_or_none()
            if saved_withdrawal:
                saved_withdrawal.provider_reference = provider_reference
                saved_withdrawal.status = "processing"
                await db.commit()
        finally:
            await _release_reference_lock(db, reference)


@celery_app.task(name="app.workers.payout_tasks.reconcile_withdrawal", queue="payouts")
def reconcile_withdrawal(reference: str):
    return _run(_reconcile_provider_transfer(reference))


async def _reconcile_stale_withdrawals():
    """Find withdrawals stranded by a worker/broker crash and reconcile them.

    The API commits the wallet debit before queueing the payout. If the process
    dies between those two operations, the withdrawal remains requested. This
    sweep makes that state recoverable without creating a second transfer: the
    stable withdrawal reference is always checked with Paystack first.
    """
    from app.database import AsyncSessionLocal
    from app.models.withdrawal import Withdrawal
    from sqlalchemy import select

    cutoff = datetime.utcnow() - timedelta(minutes=10)
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(Withdrawal.reference)
            .where(
                Withdrawal.status.in_(["requested", "processing"]),
                Withdrawal.updated_at < cutoff,
            )
            .order_by(Withdrawal.updated_at.asc())
            .limit(100)
        )
        references = [row[0] for row in result.all()]

    for reference in references:
        reconcile_withdrawal.delay(reference)

    return len(references)


@celery_app.task(name="app.workers.payout_tasks.reconcile_stale_withdrawals", queue="payouts")
def reconcile_stale_withdrawals():
    return _run(_reconcile_stale_withdrawals())


@celery_app.task(name="app.workers.payout_tasks.reset_daily_wallet_counters")
def reset_daily_wallet_counters():
    _run(_reset())


async def _reset():
    from app.database import AsyncSessionLocal
    from app.models.wallet import Wallet
    from sqlalchemy import update
    async with AsyncSessionLocal() as db:
        await db.execute(update(Wallet).values(
            daily_one_off_single_kobo=0, daily_one_off_grouped_kobo=0,
            daily_repeating_single_kobo=0, daily_repeating_grouped_kobo=0,
            daily_trend_push_kobo=0, daily_skill_based_kobo=0, daily_unpaid_kobo=0,
            daily_one_off_single_cps=0, daily_one_off_grouped_cps=0,
            daily_repeating_single_cps=0, daily_repeating_grouped_cps=0,
            daily_trend_push_cps=0, daily_skill_based_cps=0, daily_unpaid_cps=0,
            daily_reset_at=datetime.utcnow()))
        await db.commit()
