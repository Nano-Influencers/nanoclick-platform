import pytest
from sqlalchemy import select

from app.models.user import User
from app.models.wallet import Wallet
from app.models.withdrawal import Withdrawal
from app.workers.payout_tasks import _mark_provider_failure


@pytest.mark.asyncio
async def test_provider_failure_refuses_to_finalize_without_debit_ledger(db):
    user = User(
        email="payout-safety@example.com",
        full_name="Payout Safety",
        role="worker",
        referral_code="payoutsafe",
    )
    db.add(user)
    await db.flush()

    wallet = Wallet(user_id=user.id, balance_kobo=0)
    withdrawal = Withdrawal(
        user_id=user.id,
        reference="wdw_missing_ledger",
        amount_kobo=50000,
        account_number="0123456789",
        bank_code="058",
        account_name="Payout Safety",
        status="processing",
    )
    db.add_all([wallet, withdrawal])
    await db.commit()

    with pytest.raises(RuntimeError, match="ledger entry missing"):
        await _mark_provider_failure(db, withdrawal, "provider rejected transfer")

    await db.rollback()

    saved_withdrawal = await db.scalar(
        select(Withdrawal).where(Withdrawal.reference == "wdw_missing_ledger")
    )
    saved_wallet = await db.scalar(select(Wallet).where(Wallet.user_id == user.id))

    assert saved_withdrawal.status == "processing"
    assert saved_withdrawal.completed_at is None
    assert saved_wallet.balance_kobo == 0
