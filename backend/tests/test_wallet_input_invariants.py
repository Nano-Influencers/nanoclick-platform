import uuid

import pytest
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.models.wallet import Wallet
from app.services import wallet_service


async def _user_with_wallet(db: AsyncSession, balance_kobo: int = 1_000):
    user = User(
        email=f"wallet-invariant-{uuid.uuid4()}@example.com",
        full_name="Wallet Invariant Test",
        role="worker",
        referral_code=str(uuid.uuid4())[:12],
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id, balance_kobo=balance_kobo))
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_credit_rejects_negative_amount_before_mutation(db: AsyncSession):
    user = await _user_with_wallet(db)

    with pytest.raises(HTTPException) as exc:
        await wallet_service.credit(db, user.id, -1, "test_credit")

    assert exc.value.status_code == 400


@pytest.mark.asyncio
async def test_credit_rejects_negative_click_points_before_mutation(db: AsyncSession):
    user = await _user_with_wallet(db)

    with pytest.raises(HTTPException) as exc:
        await wallet_service.credit(db, user.id, 0, "test_credit", click_points=-1)

    assert exc.value.status_code == 400


@pytest.mark.asyncio
async def test_debit_rejects_zero_and_negative_amounts_before_mutation(db: AsyncSession):
    user = await _user_with_wallet(db)

    for amount in (0, -1):
        with pytest.raises(HTTPException) as exc:
            await wallet_service.debit(db, user.id, amount, "test_debit")
        assert exc.value.status_code == 400


@pytest.mark.asyncio
async def test_lock_escrow_rejects_zero_and_negative_amounts_before_mutation(db: AsyncSession):
    user = await _user_with_wallet(db)

    for amount in (0, -1):
        with pytest.raises(HTTPException) as exc:
            await wallet_service.lock_escrow(db, user.id, amount)
        assert exc.value.status_code == 400
