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


async def _do_withdrawal(user_id, amount_kobo, reference, account_number, bank_code, account_name):
    import uuid
    from app.database import AsyncSessionLocal
    from app.models.withdrawal import Withdrawal
    from app.services import paystack
    from sqlalchemy import select

    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
        withdrawal = result.scalar_one_or_none()
        if not withdrawal:
            return
        # Celery retries must never create a second payout after a successful
        # provider request or re-process a terminal withdrawal.
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

            # Paystack receives our stable reference, making provider-side
            # duplicate protection possible when the same job is retried.
            result = await paystack.initiate_transfer(amount_kobo, recipient_code, reference)
            provider_reference = result.get("reference") or reference
            async with AsyncSessionLocal() as save_db:
                saved = await save_db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                saved_withdrawal = saved.scalar_one_or_none()
                if saved_withdrawal:
                    saved_withdrawal.provider_reference = provider_reference
                    # Do not mark successful until Paystack's transfer.success
                    # webhook confirms settlement.
                    saved_withdrawal.status = "processing"
                    await save_db.commit()
        except Exception as exc:
            # Provider failures before transfer creation can be retried safely.
            # Do not refund here: webhook reconciliation remains the authority
            # once a provider-side transfer may have been created.
            async with AsyncSessionLocal() as save_db:
                saved = await save_db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
                saved_withdrawal = saved.scalar_one_or_none()
                if saved_withdrawal and saved_withdrawal.status == "processing":
                    saved_withdrawal.status = "failed"
                    saved_withdrawal.failure_reason = str(exc)[:255]
                    saved_withdrawal.completed_at = datetime.utcnow()
                    await save_db.commit()
            raise


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
