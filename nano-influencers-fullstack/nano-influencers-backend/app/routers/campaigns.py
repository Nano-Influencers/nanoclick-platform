import uuid, math
from datetime import datetime
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_advertiser
from app.models.campaign import Campaign, CampaignTargeting, TaskAllocationGroup, TNI_TO_CW_CATEGORY
from app.models.campaign_draft import CampaignDraft
from app.models.task import Task
from app.models.user import User
from app.schemas.campaign import CampaignCreate, CampaignResponse
from app.services import wallet_service
from app.services.clickpoints import calculate_worker_pay_kobo
from app.services.targeting import get_eligible_workers_with_metadata
from app.config import settings
from app.services.storage import generate_presigned_upload_url, validate_uploaded_object, delete_storage_object

router = APIRouter(prefix="/campaigns", tags=["campaigns"])\n\n# This code gate remains false until server-side pricing and live wallet/payment tests are signed off.\nCAMPAIGN_LAUNCH_VERIFIED = False


def _has_targeting(targeting) -> bool:
    """Return true when any supported targeting constraint is actually set."""
    if targeting is None:
        return False
    list_fields = (
        "target_genders", "target_age_brackets", "target_marital_statuses",
        "target_income_ranges", "target_religions", "target_ethnicities",
        "target_races", "target_languages", "target_cities", "target_states",
        "target_countries", "target_industries", "target_skills", "target_interests",
    )
    return any(getattr(targeting, field, None) for field in list_fields) or any(
        getattr(targeting, field, 0) > 0
        for field in ("min_follower_count", "min_avg_story_views")
    )


def _allocation_slots(slots_total: int, groups) -> list[int]:
    """Allocate every campaign slot exactly once across percentage groups."""
    slots = [math.floor(slots_total * g.percentage / 100) for g in groups]
    remainder = slots_total - sum(slots)
    if remainder:
        order = sorted(range(len(groups)), key=lambda i: (-groups[i].percentage, i))
        for i in range(remainder):
            slots[order[i % len(order)]] += 1
    return slots


def _ngn_to_kobo(amount: Decimal) -> int:
    """Convert a two-decimal NGN amount to integer kobo without float rounding."""
    return int(amount * Decimal("100"))



class CampaignDraftUpsert(BaseModel):
    draft_id: uuid.UUID | None = None
    payload: dict = Field(default_factory=dict)
    creative_key: str | None = Field(default=None, max_length=500)


class CampaignCreativeUploadRequest(BaseModel):
    file_extension: str = Field(min_length=3, max_length=5)


class CampaignCreativeConfirmRequest(BaseModel):
    file_key: str = Field(min_length=1, max_length=500)


@router.post("/creative-upload-url")
async def create_campaign_creative_upload_url(body: CampaignCreativeUploadRequest, current_user: User = Depends(require_advertiser)):
    extension = body.file_extension.lower().lstrip(".")
    if extension not in {"jpg", "jpeg", "png", "webp", "mp4"}:
        raise HTTPException(400, "Campaign creatives must be JPG, PNG, WebP, or MP4")
    try:
        return generate_presigned_upload_url(extension, f"campaigns/{current_user.id}")
    except Exception as exc:
        raise HTTPException(503, "Campaign creative storage is unavailable") from exc


@router.post("/creative-confirm")
async def confirm_campaign_creative(body: CampaignCreativeConfirmRequest, current_user: User = Depends(require_advertiser)):
    try:
        details = validate_uploaded_object(body.file_key, f"campaigns/{current_user.id}")
        return {"file_key": details["file_key"], "content_type": details["content_type"], "size": details["size"]}
    except ValueError as exc:
        raise HTTPException(400, str(exc)) from exc


@router.post("/drafts")
async def upsert_campaign_draft(body: CampaignDraftUpsert, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    if body.creative_key:
        try:
            validate_uploaded_object(body.creative_key, f"campaigns/{current_user.id}")
        except ValueError as exc:
            raise HTTPException(400, str(exc)) from exc
    old_key = None
    if body.draft_id:
        result = await db.execute(select(CampaignDraft).where(CampaignDraft.id == body.draft_id, CampaignDraft.owner_id == current_user.id).with_for_update())
        draft = result.scalar_one_or_none()
        if not draft:
            raise HTTPException(404, "Campaign draft not found")
        old_key = draft.creative_key
        draft.payload = body.payload
        draft.creative_key = body.creative_key
        draft.updated_at = datetime.utcnow()
    else:
        draft = CampaignDraft(owner_id=current_user.id, payload=body.payload, creative_key=body.creative_key)
        db.add(draft)
        await db.flush()
    await db.commit()
    if old_key and old_key != body.creative_key:
        try:
            delete_storage_object(old_key)
        except Exception:
            pass
    return {"id": str(draft.id), "payload": draft.payload, "creative_key": draft.creative_key, "updated_at": draft.updated_at.isoformat()}


@router.get("/drafts/{draft_id}")
async def get_campaign_draft(draft_id: uuid.UUID, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CampaignDraft).where(CampaignDraft.id == draft_id, CampaignDraft.owner_id == current_user.id))
    draft = result.scalar_one_or_none()
    if not draft:
        raise HTTPException(404, "Campaign draft not found")
    return {"id": str(draft.id), "payload": draft.payload, "creative_key": draft.creative_key, "updated_at": draft.updated_at.isoformat()}


@router.delete("/drafts/{draft_id}", status_code=204)
async def delete_campaign_draft(draft_id: uuid.UUID, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CampaignDraft).where(CampaignDraft.id == draft_id, CampaignDraft.owner_id == current_user.id).with_for_update())
    draft = result.scalar_one_or_none()
    if not draft:
        raise HTTPException(404, "Campaign draft not found")
    key = draft.creative_key
    await db.delete(draft)
    await db.commit()
    if key:
        try:
            delete_storage_object(key)
        except Exception:
            pass
    return None


@router.post("", response_model=CampaignResponse, status_code=201)
async def create_campaign(body: CampaignCreate, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    if body.tni_service_type not in TNI_TO_CW_CATEGORY:
        raise HTTPException(400, f"Unknown tni_service_type: {body.tni_service_type}")
    cw_category = TNI_TO_CW_CATEGORY[body.tni_service_type]
    client_price_kobo = _ngn_to_kobo(body.client_price_per_action_ngn)
    client_budget_kobo = _ngn_to_kobo(body.client_budget_ngn)
    has_targeting = _has_targeting(body.targeting)
    if has_targeting:
        client_budget_kobo = int(Decimal(client_budget_kobo) * Decimal("1.5"))
        client_price_kobo = int(Decimal(client_price_kobo) * Decimal("1.5"))
    if body.has_instructions and body.instructions:
        client_budget_kobo = int(Decimal(client_budget_kobo) * Decimal("1.2"))
    if client_price_kobo <= 0:
        raise HTTPException(400, "Price per action must be > 0")
    worker_pay_kobo = 0 if body.tni_service_type == "try_for_free" else calculate_worker_pay_kobo(
        client_price_per_action_kobo=client_price_kobo,
        action_type=body.action_type,
        comment_subtype=body.comment_subtype,
        video_subtype=body.video_subtype,
        tni_service_type=body.tni_service_type,
    )
    slots_total = client_budget_kobo // client_price_kobo
    if slots_total < 1:
        raise HTTPException(400, "Budget too low for even one slot")

    allocation_slots = []
    if body.allocation_groups:
        total_pct = sum(g.percentage for g in body.allocation_groups)
        if abs(total_pct - 100.0) > 0.1:
            raise HTTPException(400, "Allocation percentages must sum to 100")
        allocation_slots = _allocation_slots(slots_total, body.allocation_groups)

    campaign = Campaign(
        owner_id=current_user.id, title=body.title, platform=body.platform,
        action_type=body.action_type, tni_service_type=body.tni_service_type,
        cw_task_category=cw_category, description=body.description, target_url=body.target_url,
        client_budget_kobo=client_budget_kobo, client_price_per_action_kobo=client_price_kobo,
        worker_pay_per_action_kobo=worker_pay_kobo, escrow_kobo=client_budget_kobo,
        slots_total=slots_total, status="pending_admin", is_urgent=body.is_urgent,
        has_instructions=body.has_instructions, instructions=body.instructions,
        has_targeting=has_targeting, expires_at=body.expires_at,
    )
    db.add(campaign)
    await db.flush()
    await wallet_service.lock_escrow(db, current_user.id, client_budget_kobo, reference=str(campaign.id))

    if has_targeting and body.targeting:
        t = body.targeting
        db.add(CampaignTargeting(
            campaign_id=campaign.id, target_genders=t.target_genders,
            target_age_brackets=t.target_age_brackets, target_marital_statuses=t.target_marital_statuses,
            target_income_ranges=t.target_income_ranges, target_religions=t.target_religions,
            target_ethnicities=t.target_ethnicities, target_races=t.target_races,
            target_languages=t.target_languages, target_cities=t.target_cities,
            target_states=t.target_states, target_countries=t.target_countries,
            target_industries=t.target_industries, target_skills=t.target_skills,
            target_interests=t.target_interests, min_follower_count=t.min_follower_count,
            min_avg_story_views=t.min_avg_story_views,
        ))

    common_task = dict(
        campaign_id=campaign.id, title=body.title, description=body.description,
        link=body.target_url, instructions=body.instructions, platform=body.platform,
        action_type=body.action_type, cw_task_category=cw_category,
        difficulty="difficult" if worker_pay_kobo >= 50_000 else "simple",
        is_high_earning=worker_pay_kobo >= 50_000, is_urgent=body.is_urgent,
        pay_kobo=worker_pay_kobo,
        accept_timeout_minutes=settings.DEFAULT_TASK_ACCEPT_MINUTES,
        expires_at=body.expires_at, status="pending_admin",
    )

    if body.allocation_groups:
        for g, group_slots in zip(body.allocation_groups, allocation_slots):
            group = TaskAllocationGroup(
                campaign_id=campaign.id, action_label=g.action_label,
                percentage=g.percentage, slots_allocated=group_slots,
            )
            db.add(group)
            await db.flush()
            if group_slots > 0:
                db.add(Task(**common_task, allocation_group_id=group.id, slots_total=group_slots))
    else:
        db.add(Task(**common_task, slots_total=slots_total))
    return campaign


@router.get("", response_model=list[CampaignResponse])
async def list_campaigns(
    current_user: User = Depends(require_advertiser),
    db: AsyncSession = Depends(get_db),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """Return a bounded, stable page while keeping the existing list response shape."""
    r = await db.execute(
        select(Campaign)
        .where(Campaign.owner_id == current_user.id)
        .order_by(Campaign.created_at.desc(), Campaign.id.desc())
        .offset(offset)
        .limit(limit)
    )
    return r.scalars().all()


@router.get("/{campaign_id}", response_model=CampaignResponse)
async def get_campaign(campaign_id: uuid.UUID, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Campaign).where(Campaign.id == campaign_id, Campaign.owner_id == current_user.id))
    c = r.scalar_one_or_none()
    if not c:
        raise HTTPException(404, "Campaign not found")
    return c


@router.patch("/{campaign_id}/status")
async def update_status(campaign_id: uuid.UUID, new_status: str, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    if new_status not in {"paused", "cancelled", "active"}:
        raise HTTPException(400, "Status must be paused, active (resume), or cancelled")
    r = await db.execute(select(Campaign).where(Campaign.id == campaign_id, Campaign.owner_id == current_user.id).with_for_update())
    campaign = r.scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Campaign not found")
    if campaign.status in ("completed", "cancelled"):
        raise HTTPException(400, f"Cannot change a {campaign.status} campaign")
    if new_status == "active" and campaign.status != "paused":
        raise HTTPException(400, "Only a paused campaign can be resumed")
    if new_status == "paused" and campaign.status not in ("active", "awaiting_workers"):
        raise HTTPException(400, "Only an active campaign can be paused")
    tasks_r = await db.execute(select(Task).where(Task.campaign_id == campaign.id).with_for_update())
    tasks = tasks_r.scalars().all()
    if new_status == "cancelled":
        if campaign.escrow_kobo > 0:
            refund_kobo = campaign.escrow_kobo
            await wallet_service.refund_escrow(
                db, current_user.id, refund_kobo, reference=f"{campaign_id}:cancel",
                description="Campaign cancelled — budget refunded",
            )
            campaign.escrow_kobo = 0
        for task in tasks:
            if task.status in ("pending_admin", "available"):
                task.status = "cancelled"
        campaign.status = "cancelled"
    elif new_status == "paused":
        for task in tasks:
            if task.status == "available":
                task.status = "paused"
        campaign.status = "paused"
    else:
        for task in tasks:
            if task.status == "paused" and task.slots_filled < task.slots_total:
                task.status = "available"
        campaign.status = "active"
    return {"status": new_status, "campaign_id": str(campaign_id)}


@router.get("/{campaign_id}/audience")
async def preview_audience(campaign_id: uuid.UUID, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Campaign).options(selectinload(Campaign.targeting)).where(
        Campaign.id == campaign_id, Campaign.owner_id == current_user.id))
    campaign = r.scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Campaign not found")
    if not campaign.targeting:
        return {"message": "No targeting set — visible to all KYC-verified workers", "estimated_reach": "all"}
    expansion = await get_eligible_workers_with_metadata(campaign.targeting, campaign.slots_total, db)
    return {"desired_quantity": expansion.desired_quantity, "found_quantity": expansion.found_quantity,
        "fulfillment_percentage": expansion.fulfillment_percentage, "stop_reason": expansion.stop_reason,
        "expansion_path": expansion.expansion_path, "tiers_executed": expansion.tiers_executed,
        "tier_contribution_breakdown": expansion.tier_contribution_breakdown,
        "neighbouring_locations_used": expansion.neighbouring_locations_used}
