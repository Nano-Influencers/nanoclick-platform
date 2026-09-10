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
            # Paystack's initiate/verify response can report success while the
            # bank transfer is still progressing. Keep the local state in
            # processing until transfer.success webhook confirms completion.
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
            # pending / otp / other non-terminal states are safe to wait on.
            withdrawal.status = "processing"

        await db.commit()
    return True


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

        try:
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
                # A 4xx response is a definite provider rejection unless the
                # transfer already exists. Always reconcile first because the
                # provider can reject a duplicate reference for an already
                # accepted transfer.
                found = await _reconcile_provider_transfer(reference)
                if found:
                    return
                if exc.response.status_code >= 400 and exc.response.status_code < 500:
                    async with AsyncSessionLocal() as fail_db:
                        failed = await fail_db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                        failed_withdrawal = failed.scalar_one_or_none()
                        if failed_withdrawal and failed_withdrawal.status not in ("successful", "failed", "reversed"):
                            await _mark_provider_failure(fail_db, failed_withdrawal, f"Paystack rejected transfer ({exc.response.status_code})")
                            await fail_db.commit()
                    return
                raise
            except Exception:
                # Network timeouts and 5xx responses are ambiguous: Paystack
                # may have accepted the transfer even though our POST failed.
                # Never mark the wallet withdrawal failed or blindly create a
                # new transfer. Reconcile the stable reference first; if it is
                # not visible yet, raise so Celery retries the same reference.
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
        except Exception:
            # Do not convert an ambiguous payout failure into a local refund.
            # The stable Paystack reference plus reconciliation makes retries
            # safe without risking a second transfer or premature refund.
            raise


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
