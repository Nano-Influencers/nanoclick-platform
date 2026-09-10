import asyncio
from datetime import datetime

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
    if tx:
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
    """Reconcile an ambiguous Paystack transfer request by stable reference.

    Returns True when the provider has a definitive record and the withdrawal
    was updated. Returns False when Paystack has no visible transfer yet, so the
    caller can safely retry the original request with the same reference.
    """
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
            await _mark_provider_failure(
                db,
                withdrawal,
                provider.get("failures") or f"Paystack transfer {status}",
            )
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
    """Serialize payout attempts for the same stable provider reference.

    Celery can redeliver the same task concurrently. A withdrawal row lock is
    not sufficient because it must be released before the external Paystack
    request. A PostgreSQL session advisory lock closes that race without
    relying on a process-local mutex.
    """
    from sqlalchemy import text

    await db.execute(
        text("SELECT pg_advisory_lock(hashtextextended(:reference, 0))"),
        {"reference": reference},
    )


async def _release_reference_lock(db, reference: str):
    from sqlalchemy import text

    await db.execute(
        text("SELECT pg_advisory_unlock(hashtextextended(:reference, 0))"),
        {"reference": reference},
    )


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

        # The DB row lock above protects state changes, but cannot be held
        # across an external network call. Serialize same-reference payout
        # attempts with a PostgreSQL advisory lock instead.
        await _acquire_reference_lock(db, reference)
        try:
            # A previous Celery delivery may already have reached Paystack
            # while this delivery was waiting for the advisory lock. Reconcile
            # before creating another transfer.
            try:
                provider = await paystack.verify_transfer(reference)
            except Exception:
                provider = None

            if provider:
                status = (provider.get("status") or "").lower()
                async with AsyncSessionLocal() as reconcile_db:
                    current = await reconcile_db.execute(
                        select(Withdrawal).where(Withdrawal.reference == reference).with_for_update()
                    )
                    current_withdrawal = current.scalar_one_or_none()
                    if current_withdrawal and current_withdrawal.status not in ("successful", "failed", "reversed"):
                        current_withdrawal.provider_reference = (
                            provider.get("transfer_code") or provider.get("reference") or reference
                        )
                        if status == "success":
                            current_withdrawal.status = "processing"
                        elif status in ("failed", "reversed"):
                            await _mark_provider_failure(
                                reconcile_db,
                                current_withdrawal,
                                provider.get("failures") or f"Paystack transfer {status}",
                            )
                        else:
                            current_withdrawal.status = "processing"
                        await reconcile_db.commit()
                return

            recipient_code = withdrawal.recipient_code
            if not recipient_code:
                recipient_code = await paystack.create_transfer_recipient(account_number, bank_code, account_name)
                async with AsyncSessionLocal() as save_db:
                    saved = await save_db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                    saved_withdrawal = saved.scalar_one_or_none()
                    if saved_withdrawal and saved_withdrawal.status not in ("successful", "failed", "reversed"):
                        saved_withdrawal.recipient_code = recipient_code
                        await save_db.commit()

            try:
                result = await paystack.initiate_transfer(amount_kobo, recipient_code, reference)
            except httpx.HTTPStatusError as exc:
                found = await _reconcile_provider_transfer(reference)
                if found:
                    return
                if 400 <= exc.response.status_code < 500:
                    async with AsyncSessionLocal() as fail_db:
                        failed = await fail_db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                        failed_withdrawal = failed.scalar_one_or_none()
                        if failed_withdrawal and failed_withdrawal.status not in ("successful", "failed", "reversed"):
                            await _mark_provider_failure(fail_db, failed_withdrawal, f"Paystack rejected transfer ({exc.response.status_code})")
                            await fail_db.commit()
                    return
                raise
            except Exception:
                if await _reconcile_provider_transfer(reference):
                    return
                raise

            provider_reference = result.get("transfer_code") or result.get("reference") or reference
            async with AsyncSessionLocal() as save_db:
                saved = await save_db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                saved_withdrawal = saved.scalar_one_or_none()
                if saved_withdrawal:
                    saved_withdrawal.provider_reference = provider_reference
                    saved_withdrawal.status = "processing"
                    await save_db.commit()
        finally:
            await _release_reference_lock(db, reference)


@celery_app.task(name="app.workers.payout_tasks.reconcile_withdrawal", queue="payouts")
def reconcile_withdrawal(reference: str):
    return _run(_reconcile_provider_transfer(reference))


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
