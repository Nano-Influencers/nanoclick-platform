import uuid

import pytest
from sqlalchemy import select

from app.models.platform_wallet import PlatformWallet
from app.models.platform_wallet_transaction import PlatformWalletTransaction
from app.models.rewards import RewardClaim
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.services import rewards_service


async def _worker(db, suffix: str):
    user = User(
        email=f"pool-{suffix}-{uuid.uuid4()}@example.com",
        full_name=f"Pool Worker {suffix}",
        role="worker",
        referral_code=f"pool{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id))
    await db.flush()
    return user


async def _pool_wallet(db, balance_kobo: int = 0):
    wallet = PlatformWallet(wallet_key="reward_pool", balance_kobo=balance_kobo)
    db.add(wallet)
    await db.flush()
    return wallet


@pytest.mark.asyncio
async def test_reward_pool_funding_is_idempotent_and_ledgered(db):
    pool = await _pool_wallet(db)

    first = await rewards_service.fund_reward_pool(db, 100000, "funding:001")
    second = await rewards_service.fund_reward_pool(db, 100000, "funding:001")

    assert first["balance_kobo"] == 100000
    assert second["idempotent"] is True
    assert pool.balance_kobo == 100000

    rows = await db.execute(
        select(PlatformWalletTransaction).where(
            PlatformWalletTransaction.platform_wallet_id == pool.id,
            PlatformWalletTransaction.type == "reward_pool_funding",
            PlatformWalletTransaction.reference == "funding:001",
        )
    )
    entries = rows.scalars().all()
    assert len(entries) == 1
    assert entries[0].amount_kobo == 100000
    assert entries[0].balance_after_kobo == 100000

    with pytest.raises(Exception):
        await rewards_service.fund_reward_pool(db, 90000, "funding:001")


@pytest.mark.asyncio
async def test_reward_pool_distribution_debits_platform_and_credits_workers_atomically(db, monkeypatch):
    pool = await _pool_wallet(db, 100000)
    worker_a = await _worker(db, "a")
    worker_b = await _worker(db, "b")

    async def fake_progress(_db, worker_id):
        return {
            "grit_level10_reached": worker_id in {worker_a.id, worker_b.id},
            "grit_level10_pool_claimed": False,
        }

    async def fake_notify(*_args, **_kwargs):
        return None

    monkeypatch.setattr(rewards_service, "get_progress", fake_progress)
    monkeypatch.setattr(rewards_service, "notify", fake_notify)

    result = await rewards_service.distribute_reward_pool(
        db, "grit", 100000, reference="distribution:001"
    )

    assert result["recipients"] == 2
    assert result["each_kobo"] == 50000
    assert result["total_kobo"] == 100000
    assert pool.balance_kobo == 0

    wallets = await db.execute(select(Wallet).where(Wallet.user_id.in_([worker_a.id, worker_b.id])))
    assert sorted(w.balance_kobo for w in wallets.scalars().all()) == [50000, 50000]

    claims = await db.execute(select(RewardClaim).where(RewardClaim.user_id.in_([worker_a.id, worker_b.id])))
    assert len(claims.scalars().all()) == 2

    txs = await db.execute(select(Transaction).where(Transaction.type == "reward_tier_bonus"))
    assert len(txs.scalars().all()) == 2

    ledger = await db.execute(
        select(PlatformWalletTransaction).where(
            PlatformWalletTransaction.type == "reward_pool_distribution",
            PlatformWalletTransaction.reference == "distribution:001",
        )
    )
    entry = ledger.scalar_one()
    assert entry.amount_kobo == -100000
    assert entry.balance_after_kobo == 0


@pytest.mark.asyncio
async def test_reward_pool_distribution_allocates_remainder_without_leaking_funds(db, monkeypatch):
    pool = await _pool_wallet(db, 100001)
    worker_a = await _worker(db, "remainder-a")
    worker_b = await _worker(db, "remainder-b")
    worker_c = await _worker(db, "remainder-c")

    eligible_ids = {worker_a.id, worker_b.id, worker_c.id}

    async def fake_progress(_db, worker_id):
        return {
            "grit_level10_reached": worker_id in eligible_ids,
            "grit_level10_pool_claimed": False,
        }

    async def fake_notify(*_args, **_kwargs):
        return None

    monkeypatch.setattr(rewards_service, "get_progress", fake_progress)
    monkeypatch.setattr(rewards_service, "notify", fake_notify)

    result = await rewards_service.distribute_reward_pool(
        db, "grit", 100001, reference="distribution:remainder"
    )

    assert result["recipients"] == 3
    assert result["total_kobo"] == 100001
    assert pool.balance_kobo == 0

    wallets = await db.execute(select(Wallet).where(Wallet.user_id.in_(eligible_ids)))
    assert sorted(w.balance_kobo for w in wallets.scalars().all()) == [33333, 33334, 33334]

    ledger = await db.execute(
        select(PlatformWalletTransaction).where(
            PlatformWalletTransaction.type == "reward_pool_distribution",
            PlatformWalletTransaction.reference == "distribution:remainder",
        )
    )
    assert ledger.scalar_one().amount_kobo == -100001

    retry = await rewards_service.distribute_reward_pool(
        db, "grit", 100001, reference="distribution:remainder"
    )
    assert retry["idempotent"] is True

    wallets_after = await db.execute(select(Wallet).where(Wallet.user_id.in_(eligible_ids)))
    assert sorted(w.balance_kobo for w in wallets_after.scalars().all()) == [33333, 33334, 33334]


@pytest.mark.asyncio
async def test_reward_pool_distribution_rejects_insufficient_funding_without_claims(db, monkeypatch):
    pool = await _pool_wallet(db, 50000)
    worker_a = await _worker(db, "insufficient")

    async def fake_progress(_db, worker_id):
        return {
            "grit_level10_reached": worker_id == worker_a.id,
            "grit_level10_pool_claimed": False,
        }

    monkeypatch.setattr(rewards_service, "get_progress", fake_progress)

    with pytest.raises(Exception):
        await rewards_service.distribute_reward_pool(
            db, "grit", 60000, reference="distribution:insufficient"
        )

    await db.rollback()
    pool_check = await db.execute(select(PlatformWallet).where(PlatformWallet.id == pool.id))
    assert pool_check.scalar_one().balance_kobo == 50000
