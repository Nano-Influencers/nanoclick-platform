import uuid

import pytest
from sqlalchemy import select, func

from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.services.wallet_service import credit


@pytest.mark.asyncio
async def test_credit_same_reference_only_applies_once(db):
    user = User(
        email=f"credit-{uuid.uuid4()}@example.com",
        full_name="Credit Test",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id, balance_kobo=0))
    await db.flush()

    first = await credit(
        db, user.id, 5000, "referral_bonus", reference="referral_test_1"
    )
    second = await credit(
        db, user.id, 5000, "referral_bonus", reference="referral_test_1"
    )
    await db.flush()

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user.id))).scalar_one()
    tx_count = await db.execute(
        select(func.count(Transaction.id)).where(
            Transaction.wallet_id == wallet.id,
            Transaction.type == "referral_bonus",
            Transaction.reference == "referral_test_1",
        )
    )

    assert first.id == second.id
    assert wallet.balance_kobo == 5000
    assert tx_count.scalar_one() == 1


@pytest.mark.asyncio
async def test_credit_rejects_conflicting_reference_amount(db):
    user = User(
        email=f"credit-conflict-{uuid.uuid4()}@example.com",
        full_name="Credit Conflict Test",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id, balance_kobo=0))
    await db.flush()

    await credit(db, user.id, 5000, "referral_bonus", reference="referral_conflict")

    with pytest.raises(Exception) as exc_info:
        await credit(db, user.id, 6000, "referral_bonus", reference="referral_conflict")

    assert getattr(exc_info.value, "status_code", None) == 409
