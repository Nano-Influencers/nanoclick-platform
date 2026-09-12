import uuid

import pytest
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from app.models.user import User
from app.models.withdrawal import Withdrawal


async def _withdrawal(db, status="requested"):
    user = User(
        email=f"state-{uuid.uuid4().hex}@example.com",
        password_hash="test",
        full_name="State Test User",
        role="worker",
        referral_code=f"state{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    withdrawal = Withdrawal(
        user_id=user.id,
        reference=f"wdw_state_{uuid.uuid4().hex[:12]}",
        amount_kobo=10_000,
        account_number="0123456789",
        bank_code="058",
        account_name="State Test User",
        status=status,
    )
    db.add(withdrawal)
    await db.flush()
    return withdrawal


@pytest.mark.asyncio
async def test_withdrawal_status_check_rejects_unknown_value(db):
    withdrawal = await _withdrawal(db)
    withdrawal.status = "unknown"

    with pytest.raises(IntegrityError):
        await db.flush()

    await db.rollback()


@pytest.mark.asyncio
async def test_withdrawal_status_lifecycle_allows_valid_transitions(db):
    withdrawal = await _withdrawal(db)

    withdrawal.status = "processing"
    await db.flush()
    withdrawal.status = "successful"
    await db.flush()

    saved = await db.scalar(
        select(Withdrawal).where(Withdrawal.id == withdrawal.id)
    )
    assert saved.status == "successful"
