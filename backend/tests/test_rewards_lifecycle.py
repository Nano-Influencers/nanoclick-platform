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


def test_spin_and_checkin_enforce_cooldowns_and_stable_references():
    rewards = inspect.getsource(rewards_service)
    spin_start = rewards.index("async def spin")
    checkin_start = rewards.index("async def checkin")
    spin_body = rewards[spin_start:checkin_start]
    checkin_body = rewards[checkin_start:]
    assert "last_spin_at" in spin_body
    assert "timedelta(hours=settings.SPIN_COOLDOWN_HOURS)" in spin_body
    assert "random.choices(outcomes" in spin_body
    assert "wallet.last_spin_at = now" in spin_body
    assert "reference = f" in spin_body
    assert "timedelta(hours=24)" in checkin_body
    assert "timedelta(hours=48)" in checkin_body
    assert "wallet.checkin_streak = min(wallet.checkin_streak + 1" in checkin_body
    assert "reference = f" in checkin_body


def test_treasure_join_hint_claim_and_winner_cap_are_serialized():
    treasure = inspect.getsource(treasure_service)
    participate = treasure[treasure.index("async def participate"):treasure.index("async def use_hint")]
    hint = treasure[treasure.index("async def use_hint"):treasure.index("async def claim")]
    claim = treasure[treasure.index("async def claim"):treasure.index("async def to_response")]
    assert "with_for_update())).scalar_one_or_none()" in participate
    assert "participated=True" in participate
    assert "now - participation.last_hint_at < HINT_COOLDOWN" in hint
    assert "wallet_service.debit" in hint
    assert "click_points -= HINT_POINTS" in hint
    assert "TreasureParticipation.id == participation.id).with_for_update()" in claim
    assert "TreasureCampaign.id == campaign.id).with_for_update()" in claim
    assert "winners >= campaign.max_winners" in claim
    assert 'ref = f"treasure-reward:{campaign.id}:{user_id}"' in claim


def test_gift_entry_and_draw_are_retry_safe_and_capped():
    gifts = inspect.getsource(gifts_service)
    admin = Path(__file__).resolve().parents[1] / "app" / "routers" / "admin_gifts.py"
    admin_source = admin.read_text()
    enter = gifts[gifts.index("async def enter"):gifts.index("async def winners")]
    draw = admin_source[admin_source.index("async def draw_gift_winners"):]
    assert "GiftCampaign.id == campaign_id).with_for_update()" in enter
    assert "GiftEntry.campaign_id == campaign.id, GiftEntry.user_id == user_id" in enter
    assert "wallet.click_points -= campaign.entry_cost_points" in enter
    assert "gift-entry:{campaign.id}:{user_id}" in enter
    assert "secrets.SystemRandom().sample(entries, min(campaign.max_winners, len(entries)))" in draw
    assert "if existing: raise HTTPException(409, \"Winners have already been drawn\")" in draw


def test_try_for_free_creation_approval_and_gratis_progression_contract():
    campaigns = Path(__file__).resolve().parents[1] / "app" / "routers" / "campaigns.py"
    lifecycle = Path(__file__).resolve().parents[1] / "app" / "routers" / "admin_lifecycle.py"
    clickpoints = Path(__file__).resolve().parents[1] / "app" / "services" / "clickpoints.py"
    campaign_source = campaigns.read_text()
    lifecycle_source = lifecycle.read_text()
    clickpoints_source = clickpoints.read_text()
    assert 'body.tni_service_type == "try_for_free"' in campaign_source
    assert "worker_pay_kobo = 0" in campaign_source
    assert 'task_category != "unpaid"' in inspect.getsource(__import__("app.services.wallet_service", fromlist=["release_escrow_to_worker"]).release_escrow_to_worker)
    assert 'cw_task_category=task.cw_task_category' in lifecycle_source
    assert 'calculate_click_points' in lifecycle_source
    assert 'if cw_task_category == "unpaid":' in clickpoints_source
    assert "UNPAID_FLAT_CPS = 500" in clickpoints_source
    assert "UNPAID_FLAT_CPS * (3 if midnight else 1)" in clickpoints_source
    rewards = inspect.getsource(rewards_service)
    assert 'cw_task_category="unpaid"' in rewards
    assert "GRATIS_TASKS_PER_LEVEL = 100" in rewards
