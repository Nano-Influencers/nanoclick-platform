import uuid
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_worker
from app.models.task import Submission, Task, TaskAcceptance
from app.models.user import User
from app.schemas.task import SubmissionCreate, SubmissionResponse
from app.services.storage import compute_image_hash
from app.services.targeting_eligibility import is_worker_eligible
from app.models.campaign import CampaignTargeting
from app.config import settings

router = APIRouter(prefix="/tasks", tags=["tasks"])


async def _check_visibility(task_id: uuid.UUID, worker: User, db: AsyncSession) -> None:
    targeting_r = await db.execute(
        select(CampaignTargeting)
        .where(CampaignTargeting.campaign_id == select(Task.campaign_id).where(Task.id == task_id).scalar_subquery())
    )
    targeting = targeting_r.scalar_one_or_none()
    if targeting is None:
        return
    if not worker.kyc_verified:
        raise HTTPException(403, "KYC verification required to access targeted tasks")
    if not await is_worker_eligible(db, worker.id, targeting):
        raise HTTPException(403, "You do not match this task's targeting criteria")


@router.post("/{task_id}/resubmit", response_model=SubmissionResponse)
async def resubmit_task(
    task_id: uuid.UUID,
    body: SubmissionCreate,
    current_user: User = Depends(require_worker),
    db: AsyncSession = Depends(get_db),
):
    """Allow a worker to correct a queried/rejected submission without losing the task."""
    await _check_visibility(task_id, current_user, db)

    task_r = await db.execute(select(Task).where(Task.id == task_id).with_for_update())
    task = task_r.scalar_one_or_none()
    if not task:
        raise HTTPException(404, "Task not found")
    if task.status not in ("available", "completed"):
        raise HTTPException(400, "This task is no longer accepting submissions")

    sub_r = await db.execute(
        select(Submission)
        .where(
            Submission.task_id == task_id,
            Submission.worker_id == current_user.id,
            Submission.status.in_(["queried", "rejected"]),
        )
        .order_by(Submission.submitted_at.desc())
        .limit(1)
        .with_for_update()
    )
    submission = sub_r.scalar_one_or_none()
    if not submission:
        raise HTTPException(404, "No queried or rejected submission is available for resubmission")

    acceptance_r = await db.execute(
        select(TaskAcceptance)
        .where(
            TaskAcceptance.id == submission.acceptance_id,
            TaskAcceptance.task_id == task_id,
            TaskAcceptance.worker_id == current_user.id,
        )
        .with_for_update()
    )
    acceptance = acceptance_r.scalar_one_or_none()
    if not acceptance:
        raise HTTPException(409, "The original task acceptance is no longer available")

    if task.slots_filled >= task.slots_total:
        raise HTTPException(409, "Task has no remaining slots")

    now = datetime.utcnow()
    acceptance.status = "active"
    acceptance.accepted_at = now
    acceptance.expires_at = now + timedelta(minutes=settings.DEFAULT_TASK_ACCEPT_MINUTES)

    submission.status = "pending"
    submission.proof_urls = body.proof_urls
    submission.proof_link = body.proof_link
    submission.rejection_reason = None
    submission.query_reason = None
    submission.admin_feedback = None
    submission.submitted_at = now
    submission.reviewed_at = None
    submission.was_auto_approved = False
    submission.task_speed_minutes = 0

    if body.proof_urls:
        submission.proof_image_hash = await compute_image_hash(body.proof_urls[0])
    else:
        submission.proof_image_hash = None

    await db.flush()

    if submission.proof_image_hash:
        from app.workers.submission_tasks import check_duplicate_screenshot
        check_duplicate_screenshot.delay(str(submission.id), submission.proof_image_hash)

    return submission
