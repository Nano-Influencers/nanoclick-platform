import random
import uuid
from datetime import datetime
from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.gifts import GiftCampaign, GiftEntry, GiftWinner
from app.models.wallet import Wallet\nfrom app.schemas.gifts import GiftEntryResponse, GiftWinnerResponse
from app.services import wallet_service

async def active(db: AsyncSession, user_id: uuid.UUID):
    now = datetime.utcnow()
    campaigns = (await db.execute(select(GiftCampaign).where(
        GiftCampaign.status == "active",
        GiftCampaign.starts_at <= now,
        GiftCampaign.ends_at > now,
    ).order_by(GiftCampaign.starts_at.desc()))).scalars().all()
    entries = (await db.execute(select(GiftEntry).where(
        GiftEntry.user_id == user_id,
        GiftEntry.campaign_id.in_([c.id for c in campaigns]),
    ))).scalars().all() if campaigns else []
    entered = {e.campaign_id for e in entries}
    return campaigns, entered

async def enter(db: AsyncSession, user_id: uuid.UUID, campaign_id: uuid.UUID):
    campaign = (await db.execute(select(GiftCampaign).where(GiftCampaign.id == campaign_id).with_for_update())).scalar_one_or_none()
    if not campaign or campaign.status != "active":
        raise HTTPException(404, "Gift campaign is not active")
    now = datetime.utcnow()
    if not (campaign.starts_at <= now < campaign.ends_at):
        raise HTTPException(409, "Gift campaign is outside its entry window")
    existing = (await db.execute(select(GiftEntry).where(
        GiftEntry.campaign_id == campaign.id, GiftEntry.user_id == user_id
    ).with_for_update())).scalar_one_or_none()
    if existing:
        return GiftEntryResponse(status="already_entered", campaign_id=str(campaign.id))
    if campaign.entry_cost_points:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())).scalar_one_or_none()
        if not wallet or wallet.click_points < campaign.entry_cost_points:
            raise HTTPException(400, "Insufficient click points")
        wallet.click_points -= campaign.entry_cost_points
        from app.models.wallet import Transaction
        db.add(Transaction(wallet_id=wallet.id, type="gift_entry", amount_kobo=0, click_points_awarded=0,
                           reference=f"gift-entry:{campaign.id}:{user_id}", description=f"Gift entry — {campaign.entry_cost_points} click points spent"))
    entry = GiftEntry(campaign_id=campaign.id, user_id=user_id)
    db.add(entry)
    await db.flush()
    return GiftEntryResponse(status="entered", campaign_id=str(campaign.id))

async def winners(db: AsyncSession, user_id: uuid.UUID):
    rows = (await db.execute(select(GiftWinner, GiftCampaign).join(
        GiftCampaign, GiftCampaign.id == GiftWinner.campaign_id
    ).where(GiftWinner.user_id == user_id).order_by(GiftWinner.selected_at.desc()))).all()
    return [GiftWinnerResponse(campaign_id=str(w.campaign_id), prize_name=c.prize_name, status=w.status,
                                selected_at=w.selected_at, fulfilled_at=w.fulfilled_at) for w,c in rows]
