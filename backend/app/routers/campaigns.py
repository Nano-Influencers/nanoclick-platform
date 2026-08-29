import uuid, math
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_advertiser
from app.models.campaign import Campaign, CampaignTargeting, TaskAllocationGroup, TNI_TO_CW_CATEGORY
from app.models.task import Task
from app.models.user import User
from app.schemas.campaign import CampaignCreate, CampaignResponse
from app.services import wallet_service
from app.services.clickpoints import calculate_worker_pay_kobo
from app.services.targeting import get_eligible_workers_with_metadata
from app.config import settings

router = APIRouter(prefix="/campaigns", tags=["campaigns"])

@router.post("", response_model=CampaignResponse, status_code=201)
async def create_campaign(body: CampaignCreate, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    if body.tni_service_type not in TNI_TO_CW_CATEGORY:
        raise HTTPException(400, f"Unknown tni_service_type: {body.tni_service_type}")
    cw_category = TNI_TO_CW_CATEGORY[body.tni_service_type]
    client_price_kobo  = int(body.client_price_per_action_ngn * 100)
    client_budget_kobo = int(body.client_budget_ngn * 100)
    has_targeting = False
    if body.targeting and any([body.targeting.target_genders, body.targeting.target_cities,
        body.targeting.target_states, body.targeting.target_industries,
        body.targeting.target_age_brackets, body.targeting.target_marital_statuses]):
        client_budget_kobo = int(client_budget_kobo * 1.5)
        client_price_kobo  = int(client_price_kobo * 1.5)
        has_targeting = True
    if body.has_instructions and body.instructions:
        client_budget_kobo = int(client_budget_kobo * 1.2)
    if client_price_kobo <= 0: raise HTTPException(400, "Price per action must be > 0")
    worker_pay_kobo = calculate_worker_pay_kobo(client_price_per_action_kobo=client_price_kobo,
        action_type=body.action_type, comment_subtype=body.comment_subtype,
        video_subtype=body.video_subtype, tni_service_type=body.tni_service_type)
    slots_total = client_budget_kobo // client_price_kobo
    if slots_total < 1: raise HTTPException(400, "Budget too low for even one slot")
    campaign = Campaign(owner_id=current_user.id, title=body.title, platform=body.platform,
        action_type=body.action_type, tni_service_type=body.tni_service_type,
        cw_task_category=cw_category, description=body.description, target_url=body.target_url,
        client_budget_kobo=client_budget_kobo, client_price_per_action_kobo=client_price_kobo,
        worker_pay_per_action_kobo=worker_pay_kobo, escrow_kobo=client_budget_kobo,
        slots_total=slots_total, status="pending_admin", is_urgent=body.is_urgent,
        has_instructions=body.has_instructions, instructions=body.instructions,
        has_targeting=has_targeting, expires_at=body.expires_at)
    db.add(campaign); await db.flush()
    await wallet_service.lock_escrow(db, current_user.id, client_budget_kobo, reference=str(campaign.id))
    if has_targeting and body.targeting:
        t = body.targeting
        db.add(CampaignTargeting(campaign_id=campaign.id, target_genders=t.target_genders,
            target_age_brackets=t.target_age_brackets, target_marital_statuses=t.target_marital_statuses,
            target_income_ranges=t.target_income_ranges, target_religions=t.target_religions,
            target_ethnicities=t.target_ethnicities, target_races=t.target_races,
            target_languages=t.target_languages, target_cities=t.target_cities,
            target_states=t.target_states, target_countries=t.target_countries,
            target_industries=t.target_industries, target_skills=t.target_skills,
            target_interests=t.target_interests, min_follower_count=t.min_follower_count,
            min_avg_story_views=t.min_avg_story_views))
    if body.allocation_groups:
        total_pct = sum(g.percentage for g in body.allocation_groups)
        if abs(total_pct - 100.0) > 0.1: raise HTTPException(400, "Allocation percentages must sum to 100")
        for g in body.allocation_groups:
            db.add(TaskAllocationGroup(campaign_id=campaign.id, action_label=g.action_label,
                percentage=g.percentage, slots_allocated=math.floor(slots_total*g.percentage/100)))
    db.add(Task(campaign_id=campaign.id, title=body.title, description=body.description,
        link=body.target_url, instructions=body.instructions, platform=body.platform,
        action_type=body.action_type, cw_task_category=cw_category,
        difficulty="difficult" if worker_pay_kobo >= 50_000 else "simple",
        is_high_earning=worker_pay_kobo >= 50_000, is_urgent=body.is_urgent,
        pay_kobo=worker_pay_kobo, slots_total=slots_total,
        accept_timeout_minutes=settings.DEFAULT_TASK_ACCEPT_MINUTES,
        expires_at=body.expires_at, status="pending_admin"))
    return campaign

@router.get("", response_model=list[CampaignResponse])
async def list_campaigns(current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Campaign).where(Campaign.owner_id==current_user.id).order_by(Campaign.created_at.desc()))
    return r.scalars().all()

@router.get("/{campaign_id}", response_model=CampaignResponse)
async def get_campaign(campaign_id: uuid.UUID, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Campaign).where(Campaign.id==campaign_id, Campaign.owner_id==current_user.id))
    c = r.scalar_one_or_none()
    if not c: raise HTTPException(404, "Campaign not found")
    return c

@router.patch("/{campaign_id}/status")
async def update_status(campaign_id: uuid.UUID, new_status: str, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    if new_status not in {"paused","cancelled"}: raise HTTPException(400, "Status must be paused or cancelled")
    r = await db.execute(select(Campaign).where(Campaign.id==campaign_id, Campaign.owner_id==current_user.id))
    campaign = r.scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Campaign not found")
    if campaign.status in ("completed","cancelled"): raise HTTPException(400, f"Cannot change a {campaign.status} campaign")
    if new_status == "cancelled" and campaign.escrow_kobo > 0:
        await wallet_service.credit(db, current_user.id, campaign.escrow_kobo, "escrow_release",
            description="Campaign cancelled — budget refunded", reference=str(campaign_id))
        campaign.escrow_kobo = 0
    campaign.status = new_status
    return {"status": new_status, "campaign_id": str(campaign_id)}

@router.get("/{campaign_id}/audience")
async def preview_audience(campaign_id: uuid.UUID, current_user: User = Depends(require_advertiser), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Campaign).where(Campaign.id==campaign_id, Campaign.owner_id==current_user.id))
    campaign = r.scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Campaign not found")
    if not campaign.targeting:
        return {"message": "No targeting set — visible to all KYC-verified workers", "estimated_reach": "all"}
    expansion = await get_eligible_workers_with_metadata(campaign.targeting, campaign.slots_total, db)
    return {"desired_quantity": expansion.desired_quantity, "found_quantity": expansion.found_quantity,
        "fulfillment_percentage": expansion.fulfillment_percentage, "stop_reason": expansion.stop_reason,
        "expansion_path": expansion.expansion_path, "tiers_executed": expansion.tiers_executed,
        "tier_contribution_breakdown": expansion.tier_contribution_breakdown,
        "neighbouring_locations_used": expansion.neighbouring_locations_used}
