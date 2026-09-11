import uuid

import pytest
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.payment import Deposit
from app.models.user import User
from app.models.withdrawal import Withdrawal


async def _user(db: AsyncSession) -> User:
    user = User(
        email=f"idempotency-test-{uuid.uuid4()}@example.com",
        full_name="Idempotency Test User",
        role="worker",
        referral_code=f"it{uuid.uuid4().hex[:16]}",
    )
    db.add(user)
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_deposit_idempotency_key_is_unique_per_user(db: AsyncSession):
    user = await _user(db)
    db.add(Deposit(
        user_id=user.id,
        reference="dep_idempotency_001",
        amount_kobo=10_000,
        status="pending",
        idempotency_key="deposit-key-1",
    ))
    await db.commit()

    db.add(Deposit(
        user_id=user.id,
        reference="dep_idempotency_002",
        amount_kobo=10_000,
        status="pending",
        idempotency_key="deposit-key-1",
    ))
    with pytest.raises(IntegrityError):
        await db.commit()
    await db.rollback()


@pytest.mark.asyncio
async def test_withdrawal_idempotency_key_is_unique_per_user(db: AsyncSession):
    user = await _user(db)
    db.add(Withdrawal(
        user_id=user.id,
        reference="wdw_idempotency_001",
        amount_kobo=50_000,
        account_number="0123456789",
        bank_code="058",
        account_name="Idempotency Test User",
        status="requested",
        idempotency_key="withdrawal-key-1",
    ))
    await db.commit()

    db.add(Withdrawal(
        user_id=user.id,
        reference="wdw_idempotency_002",
        amount_kobo=50_000,
        account_number="0123456789",
        bank_code="058",
        account_name="Idempotency Test User",
        status="requested",
        idempotency_key="withdrawal-key-1",
    ))
    with pytest.raises(IntegrityError):
        await db.commit()
    await db.rollback()


@pytest.mark.asyncio
async def test_same_idempotency_key_can_be_used_by_different_users(db: AsyncSession):
    first = await _user(db)
    second = await _user(db)
    db.add_all([
        Deposit(
            user_id=first.id,
            reference="dep_idempotency_user_1",
            amount_kobo=10_000,
            status="pending",
            idempotency_key="shared-key",
        ),
        Deposit(
            user_id=second.id,
            reference="dep_idempotency_user_2",
            amount_kobo=10_000,
            status="pending",
            idempotency_key="shared-key",
        ),
    ])
    await db.commit()
