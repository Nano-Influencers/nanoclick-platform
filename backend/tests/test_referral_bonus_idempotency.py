import uuid

import pytest
from sqlalchemy import select, func

from app.config import settings
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.services import rewards_service


@pytest.mark.asyncio
async def test_referral_bonus_is_financially_and_notification_idempotent(db, monkeypatch):
    referrer = User(
        email=f"referrer-{uuid.uuid4()}@example.com",
        full_name="Referrer Test",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    worker = User(
        email=f"referred-{uuid.uuid4()}@example.com",
        full_name="Referred Test",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
        referred_by=referrer.id,
    )
    db.add(referrer)
    await db.flush()
    worker.referred_by = referrer.id
    db.add(worker)
    await db.flush()
    db.add_all([
        Wallet(user_id=referrer.id, balance_kobo=0),
        Wallet(user_id=worker.id, balance_kobo=0),
    ])
    await db.flush()

    async def approved_count(*args, **kwargs):
        return 1

    notifications = []

    async def fake_notify(*args, **kwargs):
        notifications.append((args, kwargs))

    monkeypatch.setattr(rewards_service, "_approved_count", approved_count)
    monkeypatch.setattr(rewards_service, "notify", fake_notify)

    await rewards_service.award_referral_bonus_if_first_approval(db, worker.id)
    await rewards_service.award_referral_bonus_if_first_approval(db, worker.id)
    await db.flush()

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == referrer.id))).scalar_one()
    tx_count = await db.execute(
        select(func.count(Transaction.id)).where(
            Transaction.wallet_id == wallet.id,
            Transaction.type == "referral_bonus",
            Transaction.reference == f"referral_{worker.id}",
        )
    )

    assert wallet.balance_kobo == settings.REFERRAL_BONUS_KOBO
    assert tx_count.scalar_one() == 1
    assert len(notifications) == 1
