import hashlib
import random
import uuid
from datetime import datetime, timedelta
from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.treasure import TreasureCampaign, TreasureParticipation
from app.services import wallet_service
from app.models.wallet import Wallet, Transaction
from app.schemas.treasure import TreasureHintResponse

HINT_EARNINGS_KOBO = 10_000
HINT_POINTS = 500
HINT_COOLDOWN = timedelta(days=7)

def _next_calendar_week(now: datetime) -> datetime:
    start = datetime(now.year, now.month, now.day) - timedelta(days=now.weekday())
    return start + timedelta(days=7)

def _hash_code(code: str) -> str:
    return hashlib.sha256(code.strip().encode("utf-8")).hexdigest()

async def get_active(db: AsyncSession, user_id: uuid.UUID):
    now = datetime.utcnow()
    campaign = (await db.execute(
        select(TreasureCampaign).where(
            TreasureCampaign.status == "active",
            TreasureCampaign.starts_at <= now,
            TreasureCampaign.ends_at > now,
        ).order_by(TreasureCampaign.starts_at.desc()).limit(1)
    )).scalar_one_or_none()
    if not campaign:
        return None
    participation = (await db.execute(select(TreasureParticipation).where(
        TreasureParticipation.campaign_id == campaign.id,
        TreasureParticipation.user_id == user_id,
    ))).scalar_one_or_none()
    if not participation:
        participation = TreasureParticipation(campaign_id=campaign.id, user_id=user_id)
        db.add(participation)
        await db.flush()
    return campaign, participation

async def participate(db: AsyncSession, user_id: uuid.UUID):
    result = await get_active(db, user_id)
    if not result:
        raise HTTPException(404, "No active treasure hunt")
    return result

async def use_hint(db: AsyncSession, user_id: uuid.UUID, use_earnings: bool):
    result = await get_active(db, user_id)
    if not result:
        raise HTTPException(404, "No active treasure hunt")
    campaign, participation = result
    participation = (await db.execute(select(TreasureParticipation).where(TreasureParticipation.id == participation.id).with_for_update())).scalar_one()
    campaign = (await db.execute(select(TreasureCampaign).where(TreasureCampaign.id == campaign.id).with_for_update())).scalar_one()
    now = datetime.utcnow()
    if participation.last_hint_at and participation.last_hint_at.isocalendar()[:2] == now.isocalendar()[:2]:
        raise HTTPException(409, "Only one hint can be used per calendar week")
    if not campaign.hint_options:
        raise HTTPException(409, "No hint is configured for this treasure")
    ref = f"treasure-hint:{campaign.id}:{user_id}:{now.date().isoformat()}"
    if use_earnings:
        await wallet_service.debit(db, user_id, HINT_EARNINGS_KOBO, "treasure_hint", "Treasure Hunt hint", ref)
        participation.spent_earnings_kobo += HINT_EARNINGS_KOBO
    else:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())).scalar_one_or_none()
        if not wallet:
            raise HTTPException(404, "Wallet not found")
        if wallet.click_points < HINT_POINTS:
            raise HTTPException(400, "Insufficient click points")
        wallet.click_points -= HINT_POINTS
        participation.spent_points += HINT_POINTS
        from app.models.wallet import Transaction
        db.add(Transaction(wallet_id=wallet.id, type="treasure_hint", amount_kobo=0, click_points_awarded=0, click_points_spent=HINT_POINTS, reference=ref, description=f"Treasure Hunt hint — {HINT_POINTS} click points spent"))
    participation.hints_used += 1
    participation.last_hint_at = now
    db.add(participation)
    await db.flush()
    return TreasureHintResponse(hint=random.choice(campaign.hint_options), next_hint_at=_next_calendar_week(now),
                                spent_earnings_kobo=participation.spent_earnings_kobo, spent_points=participation.spent_points)

async def claim(db: AsyncSession, user_id: uuid.UUID, claim_code: str):
    result = await get_active(db, user_id)
    if not result:
        raise HTTPException(404, "No active treasure hunt")
    campaign, participation = result
    participation = (await db.execute(select(TreasureParticipation).where(TreasureParticipation.id == participation.id).with_for_update())).scalar_one()
    campaign = (await db.execute(select(TreasureCampaign).where(TreasureCampaign.id == campaign.id).with_for_update())).scalar_one()
    if participation.claimed:
        raise HTTPException(409, "Treasure reward already claimed")
    if _hash_code(claim_code) != campaign.claim_code_hash:
        raise HTTPException(400, "Invalid treasure claim code")
    winners = (await db.execute(select(func.count()).select_from(TreasureParticipation).where(
        TreasureParticipation.campaign_id == campaign.id, TreasureParticipation.claimed == True
    ))).scalar_one()
    if winners >= campaign.max_winners:
        raise HTTPException(409, "Treasure winners limit reached")
    if campaign.reward_kobo == 0 and campaign.reward_click_points == 0:
        raise HTTPException(409, "This treasure has no configured reward")
    ref = f"treasure-reward:{campaign.id}:{user_id}"
    await wallet_service.credit(db, user_id, campaign.reward_kobo, "treasure_reward", "Treasure Hunt reward", ref, campaign.reward_click_points)
    participation.found = True
    participation.hunted_down = True
    participation.claimed = True
    participation.items_won = 1
    participation.claimed_at = datetime.utcnow()
    await db.flush()
    return {"status": "claimed", "reward_kobo": campaign.reward_kobo, "reward_click_points": campaign.reward_click_points}

async def to_response(db: AsyncSession, campaign: TreasureCampaign, participation: TreasureParticipation):
    return TreasureResponse(
        id=str(campaign.id), name=campaign.name, details=campaign.details, image_url=campaign.image_url,
        starts_at=campaign.starts_at, ends_at=campaign.ends_at, status=campaign.status,
        reward_kobo=campaign.reward_kobo, reward_click_points=campaign.reward_click_points,
        max_winners=campaign.max_winners,
        participation={"participated": participation.participated, "found": participation.found,
                       "hunted_down": participation.hunted_down, "claimed": participation.claimed,
                       "hints_used": participation.hints_used, "items_won": participation.items_won,
                       "spent_earnings_kobo": participation.spent_earnings_kobo,
                       "spent_points": participation.spent_points})
