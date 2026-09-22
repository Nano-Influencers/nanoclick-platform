"""Reward lifecycle regression/contract tests.

These tests run without a live PostgreSQL instance and protect invariants
that make the async DB integration safe under retries and concurrency.
"""
import inspect
from pathlib import Path
from sqlalchemy import UniqueConstraint
from app.models.wallet import Transaction
from app.models.gifts import GiftEntry, GiftWinner
from app.models.treasure import TreasureParticipation
from app.models.rewards import RewardClaim
from app.services import rewards_service, treasure_service, gifts_service

def _unique_constraint_names(model):
    return {c.name for c in model.__table__.constraints if isinstance(c, UniqueConstraint)}

def test_reward_ledger_has_idempotent_wallet_reference_key():
    assert "uq_transaction_wallet_type_reference" in _unique_constraint_names(Transaction)

def test_one_time_reward_and_entry_models_are_unique_per_user():
    assert "uq_reward_claim_user_reward" in _unique_constraint_names(RewardClaim)
    assert "uq_gift_campaign_user" in _unique_constraint_names(GiftEntry)
    assert "uq_gift_campaign_winner" in _unique_constraint_names(GiftWinner)
    assert "uq_treasure_campaign_user" in _unique_constraint_names(TreasureParticipation)

def test_cash_reward_flows_use_reward_pool_before_worker_wallet():
    source = inspect.getsource(rewards_service)
    for function_name in ("_funded_cash_credit", "spin", "checkin"):
        start = source.index(f"async def {function_name}")
        body = source[start:]
        pool = body.index("await _lock_reward_pool(db)")
        wallet = body.index("select(Wallet).where(Wallet.user_id == user_id).with_for_update()")
        assert pool < wallet

def test_treasure_mutations_lock_participation_before_state_change():
    source = inspect.getsource(treasure_service)
    for function_name in ("use_hint", "claim"):
        body = source[source.index(f"async def {function_name}"):]
        lock = body.index("TreasureParticipation.id == participation.id).with_for_update()")
        assert body.index("participation.", lock) >= lock

def test_gift_entry_locks_campaign_before_charging_points():
    source = inspect.getsource(gifts_service)
    body = source[source.index("async def enter"):]
    assert body.index("GiftCampaign.id == campaign_id).with_for_update()") < body.index(
        "wallet.click_points -= campaign.entry_cost_points"
    )

def test_publishers_lock_before_active_campaign_check():
    root = Path(__file__).resolve().parents[1]
    treasure = (root / "app" / "routers" / "admin_rewards.py").read_text()
    gifts = (root / "app" / "routers" / "admin_gifts.py").read_text()
    t = treasure[treasure.index("async def publish_treasure"):]
    g = gifts[gifts.index("async def publish_gift"):]
    assert t.index("pg_advisory_xact_lock") < t.index('TreasureCampaign.status == "active"')
    assert g.index("pg_advisory_xact_lock") < g.index('GiftCampaign.status == "active"')


def test_unpaid_task_settlement_is_zero_cash_but_still_ledgered():
    from app.services import wallet_service
    source = inspect.getsource(wallet_service.release_escrow_to_worker)
    assert 'amount_kobo < 0 or (amount_kobo == 0 and task_category != "unpaid")' in source
    assert 'type="task_earning"' in source
    assert 'click_points_awarded=click_points' in source


def test_reward_actions_use_stable_transaction_references():
    rewards = inspect.getsource(rewards_service)
    treasure = inspect.getsource(treasure_service)
    gifts = inspect.getsource(gifts_service)

    assert 'reference = f"spin:{user_id}:{now.isoformat()}"' in rewards
    assert 'reference = f"checkin:{user_id}:{now.date().isoformat()}"' in rewards
    assert 'reference = f"referral_{worker_id}"' in rewards
    assert 'ref = f"treasure-hint:{campaign.id}:{user_id}:{now.date().isoformat()}"' in treasure
    assert 'ref = f"treasure-reward:{campaign.id}:{user_id}"' in treasure
    assert 'gift-entry:{campaign.id}:{user_id}' in gifts
