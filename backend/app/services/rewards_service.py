"""
Gamification features inferred from click-workers' Firestore-based UI
(lib/Mobile/Rewards/*.dart), reimplemented server-authoritative instead of
letting the client write its own earnings/progress directly.
"""
import random
import uuid
from datetime import datetime, timedelta

from fastapi import HTTPException
from sqlalchemy import select, func, and_
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.task import Submission, Task
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.models.rewards import RewardClaim
from app.services import wallet_service
from app.services.notification_service import notify

GRIT_TASKS_PER_LEVEL = 20
GRIT_MAX_LEVEL = 10
GRATIS_TASKS_PER_LEVEL = 100
GRATIS_MAX_LEVEL = 10


async def _approved_count(db: AsyncSession, worker_id: uuid.UUID, **task_filters) -> int:
    conds = [Submission.worker_id == worker_id, Submission.status == "approved"]
    q = select(func.count(Submission.id)).join(Task, Task.id == Submission.task_id).where(and_(*conds))
    for col, val in task_filters.items():
        q = q.where(getattr(Task, col) == val)
    result = await db.execute(q)
    return result.scalar() or 0


async def get_progress(db: AsyncSession, worker_id: uuid.UUID) -> dict:
    grit_count = await _approved_count(db, worker_id, difficulty="difficult")
    gratis_count = await _approved_count(db, worker_id, cw_task_category="unpaid")
    grit_level = min(GRIT_MAX_LEVEL, grit_count // GRIT_TASKS_PER_LEVEL + 1)
    gratis_level = min(GRATIS_MAX_LEVEL, gratis_count // GRATIS_TASKS_PER_LEVEL + 1)

    grit_claimed = await db.execute(select(RewardClaim).where(
        RewardClaim.user_id == worker_id, RewardClaim.reward_key == "grit_level10_pool"))
    gratis_claimed = await db.execute(select(RewardClaim).where(
        RewardClaim.user_id == worker_id, RewardClaim.reward_key == "gratis_level10_pool"))

    return {
        "grit_level": grit_level,
        "grit_difficult_tasks_approved": grit_count,
        "grit_tasks_to_next_level": max(0, GRIT_TASKS_PER_LEVEL * min(grit_level, GRIT_MAX_LEVEL) - grit_count) if grit_level < GRIT_MAX_LEVEL else 0,
        "grit_level10_reached": grit_count >= GRIT_TASKS_PER_LEVEL * GRIT_MAX_LEVEL,
        "grit_level10_pool_claimed": grit_claimed.scalar_one_or_none() is not None,
        "gratis_level": gratis_level,
        "gratis_unpaid_tasks_approved": gratis_count,
        "gratis_tasks_to_next_level": max(0, GRATIS_TASKS_PER_LEVEL * min(gratis_level, GRATIS_MAX_LEVEL) - gratis_count) if gratis_level < GRATIS_MAX_LEVEL else 0,
        "gratis_level10_reached": gratis_count >= GRATIS_TASKS_PER_LEVEL * GRATIS_MAX_LEVEL,
        "gratis_level10_pool_claimed": gratis_claimed.scalar_one_or_none() is not None,
    }


async def distribute_reward_pool(db: AsyncSession, track: str, pool_kobo: int) -> dict:
    """Admin-triggered pool split with database-enforced one-time claims."""
    if track not in ("grit", "gratis"):
        raise HTTPException(400, "track must be 'grit' or 'gratis'")
    if pool_kobo <= 0:
        raise HTTPException(400, "pool amount must be greater than zero")

    reward_key = f"{track}_level10_pool"
    workers_result = await db.execute(select(User.id).where(User.role == "worker"))
    eligible: list[uuid.UUID] = []
    for (worker_id,) in workers_result.all():
        progress = await get_progress(db, worker_id)
        if progress[f"{track}_level10_reached"] and not progress[f"{track}_level10_pool_claimed"]:
            eligible.append(worker_id)

    if not eligible:
        return {"message": "No newly-eligible workers for this pool.", "recipients": 0, "each_kobo": 0}

    share_kobo = pool_kobo // len(eligible)
    if share_kobo <= 0:
        raise HTTPException(400, "pool is too small to pay an eligible worker")

    paid = 0
    for worker_id in eligible:
        claim = await db.execute(
            pg_insert(RewardClaim)
            .values(user_id=worker_id, reward_key=reward_key, amount_kobo=share_kobo)
            .on_conflict_do_nothing(index_elements=["user_id", "reward_key"])
            .returning(RewardClaim.id)
        )
        if claim.scalar_one_or_none() is None:
            continue

        await wallet_service.credit(
            db, worker_id, share_kobo, "reward_tier_bonus",
            description=f"{track.capitalize()} Level 10 pool reward",
            reference=f"{reward_key}_{worker_id}",
        )
        await notify(db, worker_id, "reward_tier_unlocked",
                     f"{track.capitalize()} Level 10 reward!",
                     f"You reached Level 10 on the {track.capitalize()} track and received ₦{share_kobo/100:,.2f} from the prize pool.")
        paid += 1

    return {"message": "Pool distributed", "recipients": paid, "each_kobo": share_kobo}


async def spin(db: AsyncSession, user_id: uuid.UUID) -> dict:
    """Award a spin result through the centralized wallet ledger."""
    result = await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(404, "Wallet not found")
    now = datetime.utcnow()
    if wallet.last_spin_at and now - wallet.last_spin_at < timedelta(hours=settings.SPIN_COOLDOWN_HOURS):
        next_at = wallet.last_spin_at + timedelta(hours=settings.SPIN_COOLDOWN_HOURS)
        raise HTTPException(429, f"You've already spun today. Next spin available at {next_at.isoformat()}Z")

    outcomes = [
        {"kind": "click_points", "value": 10, "weight": 40},
        {"kind": "click_points", "value": 25, "weight": 25},
        {"kind": "click_points", "value": 50, "weight": 15},
        {"kind": "cash_kobo", "value": 5000, "weight": 12},
        {"kind": "cash_kobo", "value": 10000, "weight": 6},
        {"kind": "cash_kobo", "value": 50000, "weight": 2},
    ]
    chosen = random.choices(outcomes, weights=[o["weight"] for o in outcomes], k=1)[0]
    wallet.last_spin_at = now
    reference = f"spin:{user_id}:{now.isoformat()}"
    if chosen["kind"] == "click_points":
        await wallet_service.credit(
            db, user_id, 0, "spin_win",
            description="Spin to Win — click points",
            reference=reference,
            click_points=chosen["value"],
        )
    else:
        await wallet_service.credit(
            db, user_id, chosen["value"], "spin_win",
            description="Spin to Win — cash prize",
            reference=reference,
        )

    return {"kind": chosen["kind"], "value": chosen["value"],
            "next_spin_at": (now + timedelta(hours=settings.SPIN_COOLDOWN_HOURS)).isoformat() + "Z"}


async def checkin(db: AsyncSession, user_id: uuid.UUID) -> dict:
    """Award the daily check-in reward through the centralized wallet ledger."""
    result = await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(404, "Wallet not found")
    now = datetime.utcnow()
    if wallet.last_checkin_at and now - wallet.last_checkin_at < timedelta(hours=24):
        next_at = wallet.last_checkin_at + timedelta(hours=24)
        raise HTTPException(429, f"You've already checked in today. Next check-in available at {next_at.isoformat()}Z")
    if wallet.last_checkin_at and now - wallet.last_checkin_at < timedelta(hours=48):
        wallet.checkin_streak = min(wallet.checkin_streak + 1, settings.CHECKIN_STREAK_CAP_DAYS)
    else:
        wallet.checkin_streak = 1
    reward_kobo = settings.CHECKIN_BASE_REWARD_KOBO + settings.CHECKIN_STREAK_STEP_KOBO * (wallet.checkin_streak - 1)
    wallet.last_checkin_at = now
    reference = f"checkin:{user_id}:{now.date().isoformat()}"
    await wallet_service.credit(
        db, user_id, reward_kobo, "checkin_reward",
        description=f"Daily check-in — day {wallet.checkin_streak} streak",
        reference=reference,
    )
    return {"streak_day": wallet.checkin_streak, "reward_kobo": reward_kobo, "reward_ngn": reward_kobo / 100}


async def award_referral_bonus_if_first_approval(db: AsyncSession, worker_id: uuid.UUID) -> None:
    approved_count = await _approved_count(db, worker_id)
    if approved_count != 1:
        return
    worker_r = await db.execute(select(User).where(User.id == worker_id))
    worker = worker_r.scalar_one_or_none()
    if not worker or not worker.referred_by:
        return
    reference = f"referral_{worker_id}"
    referrer_wallet_result = await db.execute(
        select(Wallet).where(Wallet.user_id == worker.referred_by).with_for_update()
    )
    referrer_wallet = referrer_wallet_result.scalar_one_or_none()
    if not referrer_wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    existing_result = await db.execute(select(Transaction).where(
        Transaction.wallet_id == referrer_wallet.id,
        Transaction.type == "referral_bonus",
        Transaction.reference == reference,
    ))
    if existing_result.scalar_one_or_none():
        return
    await wallet_service.credit(
        db, worker.referred_by, settings.REFERRAL_BONUS_KOBO, "referral_bonus",
        description=f"Referral bonus — {worker.full_name}'s first approved task",
        reference=reference,
    )
    await notify(db, worker.referred_by, "referral_bonus", "Referral bonus earned!",
                 f"{worker.full_name} completed their first task — you earned ₦{settings.REFERRAL_BONUS_KOBO/100:,.2f}.")
