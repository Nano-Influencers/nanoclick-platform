import uuid
import secrets
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_admin
from app.models.user import User
from app.models.gifts import GiftCampaign, GiftEntry, GiftWinner
from app.models.rewards import Notification
from app.schemas.gifts import GiftCreateRequest
from datetime import datetime

router = APIRouter(prefix="/admin/rewards/gifts", tags=["admin-rewards"])

@router.post("")
async def create_gift(payload: GiftCreateRequest, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    if payload.ends_at <= payload.starts_at:
        raise HTTPException(400, "Gift campaign end time must be after start time")
    campaign = GiftCampaign(**payload.model_dump(), status="draft")
    db.add(campaign); await db.commit()
    return {"id": str(campaign.id), "status": "draft"}

@router.post("/{campaign_id}/publish")
async def publish_gift(campaign_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    campaign = (await db.execute(select(GiftCampaign).where(GiftCampaign.id == campaign_id).with_for_update())).scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Gift campaign not found")
    if campaign.ends_at <= campaign.starts_at: raise HTTPException(400, "Invalid gift campaign schedule")
    if campaign.ends_at <= datetime.utcnow(): raise HTTPException(409, "Gift campaign has already ended")
    active = (await db.execute(select(GiftCampaign).where(GiftCampaign.status == "active", GiftCampaign.id != campaign_id))).scalar_one_or_none()
    if active: raise HTTPException(409, "Another gift campaign is already active")
    campaign.status = "active"; await db.commit()
    return {"id": str(campaign.id), "status": campaign.status}

@router.post("/{campaign_id}/draw")
async def draw_gift_winners(campaign_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    campaign = (await db.execute(select(GiftCampaign).where(GiftCampaign.id == campaign_id).with_for_update())).scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Gift campaign not found")
    if campaign.status not in ("active", "closed"): raise HTTPException(409, "Gift campaign is not ready for a draw")
    if campaign.status == "active" and campaign.ends_at > datetime.utcnow(): raise HTTPException(409, "Gift campaign is still active; close it before drawing")
    entries = (await db.execute(select(GiftEntry).where(GiftEntry.campaign_id == campaign.id))).scalars().all()
    if not entries: raise HTTPException(409, "No gift entries")
    existing = (await db.execute(select(GiftWinner).where(GiftWinner.campaign_id == campaign.id))).scalars().all()
    if existing: raise HTTPException(409, "Winners have already been drawn")
    winners = secrets.SystemRandom().sample(entries, min(campaign.max_winners, len(entries)))
    for entry in winners:
        entry.status = "winner"
        db.add(GiftWinner(campaign_id=campaign.id, user_id=entry.user_id))
        db.add(Notification(user_id=entry.user_id, type="gift_winner", title="You won a gift!", body=f"You were selected for {campaign.prize_name}.", data={"campaign_id": str(campaign.id), "prize_name": campaign.prize_name}))
    campaign.status = "drawn"; await db.commit()
    return {"campaign_id": str(campaign.id), "winner_count": len(winners)}

@router.post("/{campaign_id}/close")
async def close_gift(campaign_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    campaign = (await db.execute(select(GiftCampaign).where(GiftCampaign.id == campaign_id).with_for_update())).scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Gift campaign not found")
    campaign.status = "closed"; await db.commit()
    return {"id": str(campaign.id), "status": campaign.status}

@router.post("/{campaign_id}/winners/{user_id}/fulfill")
async def fulfill_gift(campaign_id: uuid.UUID, user_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    winner = (await db.execute(select(GiftWinner).where(
        GiftWinner.campaign_id == campaign_id, GiftWinner.user_id == user_id
    ).with_for_update())).scalar_one_or_none()
    if not winner: raise HTTPException(404, "Gift winner not found")
    if winner.status == "fulfilled": return {"status": "already_fulfilled"}
    winner.status = "fulfilled"; winner.fulfilled_at = datetime.utcnow()
    await db.commit()
    return {"status": "fulfilled"}\n    await db.execute(text("SELECT pg_advisory_xact_lock(hashtext('nanoclick:active_gift'))"))
