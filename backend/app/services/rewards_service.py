"""
Gamification features inferred from click-workers' Firestore-based UI
(lib/Mobile/Rewards/*.dart), reimplemented server-authoritative instead of
letting the client write its own earnings/progress directly.

Grit / Gratis achievement tracks
---------------------------------
Read directly from grit_achievements.dart / gratis_achievements.dart:
  - "Grit": 10 levels, each requiring 20 approved *difficult*-difficulty
    tasks (Task.difficulty == "difficult"). Reaching Level 10 wins "a share
    of ₦1,000,000" — a pooled prize, not a fixed per-user payout.
  - "Gratis": 10 levels, each requiring 100 approved *unpaid*-category
    tasks (Task.cw_task_category == "unpaid"). Same Level 10 pool mechanic.

Because "a share of" implies splitting a pool among everyone who qualifies
in a period (not a fixed individual amount), progress/eligibility is fully
computed here, but the actual payout is an admin-triggered pool split
(see distribute_reward_pool) rather than an automatic instant claim — this
mirrors how the rest of the app handles admin-adjudicated payouts (report
rewards, campaign refunds) rather than inventing an unfounded fixed amount.

Spin-to-win / daily check-in
-----------------------------
No concrete prize table exists anywhere in the client (only a running
earnings *summary* display, not the wheel's own definition), so these use
conservative, clearly-labelled constants in app.config that can be retuned
without a code change — see config.py.
"""
import random
import uuid
from datetime import datetime, timedelta

from fastapi import HTTPException
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.models.task import Submission, Task
from app.models.user import User
from app.models.wallet import Wallet
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
    """Admin-triggered: split pool_kobo equally among every worker who has
    reached Level 10 on `track` ('grit' or 'gratis') and hasn't already been
    paid from this pool."""
    if track not in ("grit", "gratis"):
        raise HTTPException(400, "track must be 'grit' or 'gratis'")
    reward_key = f"{track}_level10_pool"

    # Every worker who has ever submitted, filtered down to Level-10 reachers.
    workers_result = await db.execute(select(User.id).where(User.role == "worker"))
    eligible: list[uuid.UUID] = []
    for (worker_id,) in workers_result.all():
        progress = await get_progress(db, worker_id)
        reached = progress[f"{track}_level10_reached"]
        claimed = progress[f"{track}_level10_pool_claimed"]
        if reached and not claimed:
            eligible.append(worker_id)

    if not eligible:
        return {"message": "No newly-eligible workers for this pool.", "recipients": 0, "each_kobo": 0}

    share_kobo = pool_kobo // len(eligible)
    for worker_id in eligible:
        await wallet_service.credit(
            db, worker_id, share_kobo, "reward_tier_bonus",
            description=f"{track.capitalize()} Level {10} pool reward",
            reference=f"{reward_key}_{worker_id}",
        )
        db.add(RewardClaim(user_id=worker_id, reward_key=reward_key, amount_kobo=share_kobo))
        await notify(db, worker_id, "reward_tier_unlocked",
                     f"{track.capitalize()} Level 10 reward!",
                     f"You reached Level 10 on the {track.capitalize()} track and received ₦{share_kobo/100:,.2f} from the prize pool.")

    return {"message": "Pool distributed", "recipients": len(eligible), "each_kobo": share_kobo}


async def spin(db: AsyncSession, user_id: uuid.UUID) -> dict:
    result = await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(404, "Wallet not found")
    now = datetime.utcnow()
    if wallet.last_spin_at and now - wallet.last_spin_at < timedelta(hours=settings.SPIN_COOLDOWN_HOURS):
        next_at = wallet.last_spin_at + timedelta(hours=settings.SPIN_COOLDOWN_HOURS)
        raise HTTPException(429, f"You've already spun today. Next spin available at {next_at.isoformat()}Z")

    # Weighted outcomes: mostly click points, occasionally a small cash prize.
    outcomes = [
        {"kind": "click_points", "value": 10, "weight": 40},
        {"kind": "click_points", "value": 25, "weight": 25},
        {"kind": "click_points", "value": 50, "weight": 15},
        {"kind": "cash_kobo", "value": 5000, "weight": 12},   # ₦50
        {"kind": "cash_kobo", "value": 10000, "weight": 6},   # ₦100
        {"kind": "cash_kobo", "value": 50000, "weight": 2},   # ₦500 jackpot
    ]
    chosen = random.choices(outcomes, weights=[o["weight"] for o in outcomes], k=1)[0]

    wallet.last_spin_at = now
    if chosen["kind"] == "click_points":
        wallet.click_points += chosen["value"]
        tx = None
        from app.models.wallet import Transaction
        tx = Transaction(wallet_id=wallet.id, type="spin_win", amount_kobo=0,
                          click_points_awarded=chosen["value"], status="completed",
                          description="Spin to Win — click points")
        db.add(tx)
    else:
        wallet.balance_kobo += chosen["value"]
        from app.models.wallet import Transaction
        tx = Transaction(wallet_id=wallet.id, type="spin_win", amount_kobo=chosen["value"],
                          status="completed", description="Spin to Win — cash prize")
        db.add(tx)

    return {"kind": chosen["kind"], "value": chosen["value"],
            "next_spin_at": (now + timedelta(hours=settings.SPIN_COOLDOWN_HOURS)).isoformat() + "Z"}


async def checkin(db: AsyncSession, user_id: uuid.UUID) -> dict:
    result = await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(404, "Wallet not found")
    now = datetime.utcnow()
    if wallet.last_checkin_at and now - wallet.last_checkin_at < timedelta(hours=24):
        next_at = wallet.last_checkin_at + timedelta(hours=24)
        raise HTTPException(429, f"You've already checked in today. Next check-in available at {next_at.isoformat()}Z")

    # Streak continues if the previous check-in was within the last 48h
    # (i.e. yesterday), otherwise it resets to day 1.
    if wallet.last_checkin_at and now - wallet.last_checkin_at < timedelta(hours=48):
        wallet.checkin_streak = min(wallet.checkin_streak + 1, settings.CHECKIN_STREAK_CAP_DAYS)
    else:
        wallet.checkin_streak = 1

    reward_kobo = settings.CHECKIN_BASE_REWARD_KOBO + settings.CHECKIN_STREAK_STEP_KOBO * (wallet.checkin_streak - 1)
    wallet.last_checkin_at = now
    wallet.balance_kobo += reward_kobo

    from app.models.wallet import Transaction
    db.add(Transaction(wallet_id=wallet.id, type="checkin_reward", amount_kobo=reward_kobo,
                        status="completed", description=f"Daily check-in — day {wallet.checkin_streak} streak"))

    return {"streak_day": wallet.checkin_streak, "reward_kobo": reward_kobo, "reward_ngn": reward_kobo / 100}


async def award_referral_bonus_if_first_approval(db: AsyncSession, worker_id: uuid.UUID) -> None:
    """Called right after a submission is approved (human review or
    auto-approve). If this is the worker's first-ever approved submission
    and they were referred by someone, pay the referrer a flat bonus.

    Gating on "first *approved* submission" (rather than registration or KYC
    approval alone) is a deliberate anti-fraud choice: it requires the
    referred user to actually complete real, paid work before the referrer
    is rewarded."""
    approved_count = await _approved_count(db, worker_id)
    if approved_count != 1:
        return  # not their first approval
    worker_r = await db.execute(select(User).where(User.id == worker_id))
    worker = worker_r.scalar_one_or_none()
    if not worker or not worker.referred_by:
        return
    await wallet_service.credit(
        db, worker.referred_by, settings.REFERRAL_BONUS_KOBO, "referral_bonus",
        description=f"Referral bonus — {worker.full_name}'s first approved task",
        reference=f"referral_{worker_id}",
    )
    await notify(db, worker.referred_by, "referral_bonus", "Referral bonus earned!",
                 f"{worker.full_name} completed their first task — you earned ₦{settings.REFERRAL_BONUS_KOBO/100:,.2f}.")
