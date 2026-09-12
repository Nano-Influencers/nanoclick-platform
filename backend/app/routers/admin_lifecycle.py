import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_admin
from app.models.user import User
from app.models.task import Submission, Task
from app.models.campaign import Campaign
from app.services import wallet_service
from app.services.clickpoints import calculate_click_points

router = APIRouter(prefix="/admin", tags=["admin"])


@router.post("/campaigns/{campaign_id}/approve")
async def approve_campaign_lifecycle(campaign_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    result = await db.execute(select(Campaign).where(Campaign.id == campaign_id).with_for_update())
    campaign = result.scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Campaign not found")
    if campaign.status != "pending_admin":
        raise HTTPException(400, f"Campaign is already '{campaign.status}'")
    task_result = await db.execute(select(Task).where(Task.campaign_id == campaign_id).with_for_update())
    tasks = task_result.scalars().all()
    if not tasks:
        raise HTTPException(409, "Campaign has no executable tasks")
    campaign.status = "active"
    for task in tasks:
        if task.slots_filled < task.slots_total:
            task.status = "available"
    from app.services.notification_service import notify
    await notify(db, campaign.owner_id, "campaign_approved", "Campaign is live",
                 f'"{campaign.title}" was approved and is now live for workers.')
    return {"message": "Campaign approved and tasks are now live", "campaign_id": str(campaign_id), "tasks_activated": len(tasks)}


@router.post("/campaigns/{campaign_id}/reject")
async def reject_campaign_lifecycle(campaign_id: uuid.UUID, reason: str,
                                    db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    result = await db.execute(select(Campaign).where(Campaign.id == campaign_id).with_for_update())
    campaign = result.scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Campaign not found")
    if campaign.status in ("cancelled", "completed"):
        raise HTTPException(400, f"Campaign is already '{campaign.status}'")
    task_result = await db.execute(select(Task).where(Task.campaign_id == campaign_id).with_for_update())
    tasks = task_result.scalars().all()
    if campaign.escrow_kobo > 0:
        refund_kobo = campaign.escrow_kobo
        await wallet_service.refund_escrow(db, campaign.owner_id, refund_kobo,
            reference=f"{campaign_id}:admin_reject", description=f"Campaign rejected: {reason}")
        campaign.escrow_kobo = 0
    for task in tasks:
        if task.status in ("pending_admin", "available", "paused"):
            task.status = "cancelled"
    campaign.status = "cancelled"
    from app.services.notification_service import notify
    await notify(db, campaign.owner_id, "campaign_rejected", "Campaign rejected",
                 f'"{campaign.title}" was rejected: {reason}. Your budget has been refunded.')
    return {"message": "Campaign rejected and budget refunded", "campaign_id": str(campaign_id)}


@router.post("/submissions/{submission_id}/approve")
async def approve_submission_lifecycle(submission_id: uuid.UUID, client_rating: float = 5.0,
                                       db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    sub_result = await db.execute(select(Submission).where(Submission.id == submission_id).with_for_update())
    sub = sub_result.scalar_one_or_none()
    if not sub:
        raise HTTPException(404, "Submission not found")
    if sub.status not in ("pending", "under_review", "queried"):
        raise HTTPException(400, f"Cannot approve status '{sub.status}'")
    task_result = await db.execute(select(Task).where(Task.id == sub.task_id).with_for_update())
    task = task_result.scalar_one_or_none()
    if not task:
        raise HTTPException(404, "Task not found")
    if task.slots_filled >= task.slots_total:
        raise HTTPException(409, "Task has no remaining slots")
    campaign_result = await db.execute(select(Campaign).where(Campaign.id == task.campaign_id).with_for_update())
    campaign = campaign_result.scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Campaign not found")
    if campaign.status != "active":
        raise HTTPException(409, f"Campaign is {campaign.status} and cannot settle this submission")
    client_charge = campaign.client_price_per_action_kobo
    if campaign.escrow_kobo < client_charge:
        raise HTTPException(409, "Campaign escrow is insufficient")
    click_points = calculate_click_points(cw_task_category=task.cw_task_category,
        worker_pay_kobo=task.pay_kobo, is_urgent=task.is_urgent, submitted_at=sub.submitted_at)
    await wallet_service.release_escrow_to_worker(db=db, advertiser_id=campaign.owner_id,
        worker_id=sub.worker_id, amount_kobo=task.pay_kobo, click_points=click_points,
        task_category=task.cw_task_category, reference=str(sub.id),
        client_charge_kobo=client_charge)

    # release_escrow_to_worker updates the advertiser wallet escrow and records
    # the platform margin. Campaign.escrow_kobo is the campaign-level mirror,
    # so keep it synchronized in the same transaction.
    campaign.escrow_kobo -= client_charge
    if campaign.escrow_kobo < 0:
        raise HTTPException(409, "Campaign escrow would become negative")

    sub.status = "approved"
    sub.reviewed_at = datetime.utcnow()
    sub.client_rating = max(0.0, min(5.0, client_rating))
    task.slots_filled += 1
    task.status = "completed" if task.slots_filled >= task.slots_total else "available"
    campaign.slots_filled += 1
    if campaign.slots_filled >= campaign.slots_total:
        campaign.slots_filled = campaign.slots_total
        campaign.status = "completed"
    from app.services import rewards_service
    from app.services.notification_service import notify
    await rewards_service.award_referral_bonus_if_first_approval(db, sub.worker_id)
    await notify(db, sub.worker_id, "task_approved", "Task approved!",
                 f'"{task.title}" was approved — you earned ₦{task.pay_kobo / 100:,.2f}.')
    return {"message": "Approved", "click_points_awarded": click_points, "amount_ngn": task.pay_kobo / 100,
            "campaign_slots_filled": campaign.slots_filled, "campaign_slots_total": campaign.slots_total,
            "campaign_status": campaign.status}
