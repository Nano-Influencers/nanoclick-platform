import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_advertiser
from app.models.campaign import Campaign
from app.models.task import Submission, Task, TaskAcceptance
from app.models.user import User

router = APIRouter(prefix="/campaigns", tags=["campaign reporting"])


@router.get("/{campaign_id}/report")
async def campaign_report(
    campaign_id: uuid.UUID,
    current_user: User = Depends(require_advertiser),
    db: AsyncSession = Depends(get_db),
):
    campaign_result = await db.execute(
        select(Campaign).where(
            Campaign.id == campaign_id,
            Campaign.owner_id == current_user.id,
        )
    )
    campaign = campaign_result.scalar_one_or_none()
    if campaign is None:
        raise HTTPException(404, "Campaign not found")

    task_result = await db.execute(
        select(Task).where(Task.campaign_id == campaign.id)
    )
    tasks = task_result.scalars().all()
    task_ids = [task.id for task in tasks]

    empty = {
        "campaign_id": str(campaign.id),
        "status": campaign.status,
        "budget_kobo": campaign.client_budget_kobo,
        "escrow_kobo": campaign.escrow_kobo,
        "slots_total": campaign.slots_total,
        "slots_filled": campaign.slots_filled,
        "completion_percentage": round((campaign.slots_filled / campaign.slots_total) * 100, 2) if campaign.slots_total else 0,
        "tasks": {"total": len(tasks), "available": 0, "completed": 0},
        "submissions": {"total": 0, "pending": 0, "under_review": 0, "approved": 0, "rejected": 0},
        "accepted": 0,
        "spent_kobo": 0,
    }
    if not task_ids:
        return empty

    task_status_result = await db.execute(
        select(Task.status, func.count(Task.id)).where(Task.id.in_(task_ids)).group_by(Task.status)
    )
    task_statuses = {status: count for status, count in task_status_result.all()}

    submission_result = await db.execute(
        select(Submission.status, func.count(Submission.id)).where(Submission.task_id.in_(task_ids)).group_by(Submission.status)
    )
    submission_statuses = {status: count for status, count in submission_result.all()}

    accepted_result = await db.execute(
        select(func.count(TaskAcceptance.id)).where(
            TaskAcceptance.task_id.in_(task_ids),
            TaskAcceptance.status.in_(["active", "submitted"]),
        )
    )
    accepted = accepted_result.scalar() or 0

    approved_result = await db.execute(
        select(func.coalesce(func.sum(Task.pay_kobo), 0))
        .join(Submission, Submission.task_id == Task.id)
        .where(Task.id.in_(task_ids), Submission.status == "approved")
    )
    spent_kobo = approved_result.scalar() or 0

    return {
        "campaign_id": str(campaign.id),
        "status": campaign.status,
        "budget_kobo": campaign.client_budget_kobo,
        "escrow_kobo": campaign.escrow_kobo,
        "slots_total": campaign.slots_total,
        "slots_filled": campaign.slots_filled,
        "completion_percentage": round((campaign.slots_filled / campaign.slots_total) * 100, 2) if campaign.slots_total else 0,
        "tasks": {
            "total": len(tasks),
            "available": task_statuses.get("available", 0),
            "completed": task_statuses.get("completed", 0),
        },
        "submissions": {
            "total": sum(submission_statuses.values()),
            "pending": submission_statuses.get("pending", 0),
            "under_review": submission_statuses.get("under_review", 0),
            "approved": submission_statuses.get("approved", 0),
            "rejected": submission_statuses.get("rejected", 0),
        },
        "accepted": accepted,
        "spent_kobo": spent_kobo,
    }
