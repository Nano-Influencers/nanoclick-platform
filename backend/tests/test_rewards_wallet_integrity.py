import uuid

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.models.wallet import Transaction, Wallet
from app.services import rewards_service


async def _user(db: AsyncSession) -> User:
    user = User(
        email=f"reward-test-{uuid.uuid4()}@example.com",
        full_name="Reward Test User",
        role="worker",
        referral_code=f"rt{uuid.uuid4().hex[:16]}",
    )
    db.add(user)
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_spin_cash_reward_uses_wallet_ledger(db: AsyncSession, monkeypatch):
    user = await _user(db)
    user_id = user.id
    db.add(Wallet(user_id=user_id, balance_kobo=0))
    await db.commit()

    monkeypatch.setattr(
        rewards_service.random,
        "choices",
        lambda *args, **kwargs: [{"kind": "cash_kobo", "value": 5_000, "weight": 1}],
    )

    result = await rewards_service.spin(db, user_id)
    await db.commit()

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
    tx = (await db.execute(
        select(Transaction).where(
            Transaction.wallet_id == wallet.id,
            Transaction.type == "spin_win",
        )
    )).scalar_one()

    assert result["kind"] == "cash_kobo"
    assert wallet.balance_kobo == 5_000
    assert tx.amount_kobo == 5_000
    assert tx.reference.startswith(f"spin:{user_id}:")
    assert tx.status == "completed"


@pytest.mark.asyncio
async def test_spin_points_reward_uses_wallet_ledger(db: AsyncSession, monkeypatch):
    user = await _user(db)
    user_id = user.id
    db.add(Wallet(user_id=user_id, balance_kobo=0, click_points=0))
    await db.commit()

    monkeypatch.setattr(
        rewards_service.random,
        "choices",
        lambda *args, **kwargs: [{"kind": "click_points", "value": 50, "weight": 1}],
    )

    await rewards_service.spin(db, user_id)
    await db.commit()

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
    tx = (await db.execute(
        select(Transaction).where(
            Transaction.wallet_id == wallet.id,
            Transaction.type == "spin_win",
        )
    )).scalar_one()

    assert wallet.balance_kobo == 0
    assert wallet.click_points == 50
    assert tx.amount_kobo == 0
    assert tx.click_points_awarded == 50
    assert tx.reference.startswith(f"spin:{user_id}:")


@pytest.mark.asyncio
async def test_checkin_reward_uses_wallet_ledger(db: AsyncSession):
    user = await _user(db)
    user_id = user.id
    db.add(Wallet(user_id=user_id, balance_kobo=0))
    await db.commit()

    result = await rewards_service.checkin(db, user_id)
    await db.commit()

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
    tx = (await db.execute(
        select(Transaction).where(
            Transaction.wallet_id == wallet.id,
            Transaction.type == "checkin_reward",
        )
    )).scalar_one()

    assert wallet.balance_kobo == result["reward_kobo"]
    assert tx.amount_kobo == result["reward_kobo"]
    assert tx.reference == f"checkin:{user_id}:{wallet.last_checkin_at.date().isoformat()}"
    assert tx.status == "completed"
