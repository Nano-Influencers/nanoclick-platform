import asyncio
from datetime import datetime
from app.workers.celery_app import celery_app

def _run(coro):
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()

@celery_app.task(name="app.workers.payout_tasks.process_withdrawal", queue="payouts")
def process_withdrawal(user_id: str, amount_kobo: int, reference: str, account_number: str, bank_code: str, account_name: str):
    _run(_do_withdrawal(user_id, amount_kobo, reference, account_number, bank_code, account_name))

async def _do_withdrawal(user_id, amount_kobo, reference, account_number, bank_code, account_name):
    import uuid
    from app.database import AsyncSessionLocal
    from app.services import paystack, wallet_service
    async with AsyncSessionLocal() as db:
        try:
            # Paystack transfers require a registered recipient_code — a raw
            # account number is not a valid transfer target.
            recipient_code = await paystack.create_transfer_recipient(account_number, bank_code, account_name)
            await paystack.initiate_transfer(amount_kobo, recipient_code, reference)
        except Exception as e:
            await wallet_service.credit(db, uuid.UUID(user_id), amount_kobo,
                tx_type="withdrawal_reversal",
                description=f"Withdrawal failed: {str(e)[:100]}", reference=reference)
            await db.commit()

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
