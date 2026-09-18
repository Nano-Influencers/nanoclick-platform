import hashlib, uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.database import get_db
from app.dependencies import require_admin
from app.models.user import User
from app.models.treasure import TreasureCampaign
from app.schemas.treasure import TreasureCreateRequest

router = APIRouter(prefix="/admin/rewards/treasure", tags=["admin-rewards"])

@router.post("")
async def create_treasure(payload: TreasureCreateRequest, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    if payload.ends_at <= payload.starts_at:
        raise HTTPException(400, "Treasure end time must be after start time")
    campaign = TreasureCampaign(
        name=payload.name, details=payload.details, image_url=payload.image_url,
        starts_at=payload.starts_at, ends_at=payload.ends_at,
        hint_options=payload.hint_options,
        claim_code_hash=hashlib.sha256(payload.claim_code.strip().encode("utf-8")).hexdigest(),
        reward_kobo=payload.reward_kobo, reward_click_points=payload.reward_click_points,
        max_winners=payload.max_winners, status="draft",
    )
    db.add(campaign)
    await db.commit()
    return {"id": str(campaign.id), "status": "draft"}

@router.post("/{treasure_id}/publish")
async def publish_treasure(treasure_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    await db.execute(text("SELECT pg_advisory_xact_lock(hashtext('nanoclick:active_treasure'))"))
    campaign = (await db.execute(select(TreasureCampaign).where(TreasureCampaign.id == treasure_id).with_for_update())).scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Treasure not found")
    if campaign.ends_at <= campaign.starts_at:
        raise HTTPException(400, "Invalid treasure schedule")
    active = (await db.execute(select(TreasureCampaign).where(
        TreasureCampaign.status == "active",
        TreasureCampaign.id != treasure_id,
    ))).scalar_one_or_none()
    if active:
        raise HTTPException(409, "Another treasure is already active")
    campaign.status = "active"
    await db.commit()
    return {"id": str(campaign.id), "status": campaign.status}

@router.post("/{treasure_id}/close")
async def close_treasure(treasure_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    campaign = (await db.execute(select(TreasureCampaign).where(TreasureCampaign.id == treasure_id).with_for_update())).scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Treasure not found")
    campaign.status = "closed"
    await db.commit()
    return {"id": str(campaign.id), "status": campaign.status}
