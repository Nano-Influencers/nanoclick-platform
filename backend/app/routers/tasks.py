import uuid
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, and_, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user, require_worker
from app.models.user import User
from app.models.task import Task, TaskAcceptance, Submission, TaskReport, LeaderboardScore
from app.models.campaign import Campaign, CampaignTargeting
from app.schemas.task import TaskResponse, AcceptTaskResponse, SubmissionCreate, SubmissionResponse, SubmissionWithTaskResponse, TaskReportCreate, PresignedUrlRequest, PresignedUrlResponse, LeaderboardEntryResponse
from app.services.storage import generate_presigned_upload_url, compute_image_hash, validate_uploaded_object
from app.services.targeting_eligibility import is_worker_eligible

router = APIRouter(prefix="/tasks", tags=["tasks"])

async def _enforce_task_visibility(task_id: uuid.UUID, current_user: User, db: AsyncSession) -> None:
    if current_user.kyc_verified:
        targeted = await db.execute(select(CampaignTargeting).join(Task, Task.campaign_id == CampaignTargeting.campaign_id).where(Task.id == task_id))
        targeting = targeted.scalar_one_or_none()
        if targeting is not None and not await is_worker_eligible(db, current_user.id, targeting):
            raise HTTPException(403, "You do not match this task's targeting criteria")
        return
    targeted = await db.execute(select(CampaignTargeting.campaign_id).join(Task, Task.campaign_id == CampaignTargeting.campaign_id).where(Task.id == task_id))
    if targeted.scalar_one_or_none() is not None:
        raise HTTPException(403, "KYC verification required to access targeted tasks")

async def _require_active_campaign(task: Task, db: AsyncSession) -> Campaign:
    campaign_r = await db.execute(select(Campaign).where(Campaign.id == task.campaign_id).with_for_update())
    campaign = campaign_r.scalar_one_or_none()
    if not campaign:
        raise HTTPException(404, "Campaign not found")
    now = datetime.utcnow()
    if campaign.status != "active":
        raise HTTPException(409, f"Campaign is {campaign.status} and is not accepting task activity")
    if campaign.expires_at and campaign.expires_at <= now:
        raise HTTPException(409, "Campaign has expired")
    if task.expires_at and task.expires_at <= now:
        raise HTTPException(409, "Task has expired")
    return campaign

async def _validate_proofs(proof_keys: list[str], worker_id: uuid.UUID) -> None:
    prefix = f"proofs/{worker_id}"
    for key in proof_keys:
        try:
            validate_uploaded_object(key, prefix)
        except ValueError as exc:
            raise HTTPException(400, str(exc)) from exc

@router.get("", response_model=list[TaskResponse])
async def list_tasks(category: str = Query(None), difficulty: str = Query(None), is_high_earning: bool = Query(None), is_urgent: bool = Query(None), platform: str = Query(None), limit: int = Query(50, ge=1, le=100), offset: int = Query(0, ge=0), current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    conds = [Task.status == "available", Task.slots_filled < Task.slots_total]
    if not current_user.kyc_verified:
        conds.append(Task.campaign_id.not_in(select(CampaignTargeting.campaign_id).scalar_subquery()))
    if category: conds.append(Task.cw_task_category == category)
    if difficulty: conds.append(Task.difficulty == difficulty)
    if is_high_earning is not None: conds.append(Task.is_high_earning == is_high_earning)
    if is_urgent is not None: conds.append(Task.is_urgent == is_urgent)
    if platform: conds.append(Task.platform == platform)
    accepted_result = await db.execute(select(TaskAcceptance.task_id).where(TaskAcceptance.worker_id == current_user.id, TaskAcceptance.status.in_(["active", "submitted"])))
    accepted_ids = list(accepted_result.scalars())
    if accepted_ids: conds.append(Task.id.not_in(accepted_ids))

    candidate_offset = 0
    scan_size = max(limit, 100)
    eligible_seen = 0
    visible = []
    targeting_cache: dict[uuid.UUID, CampaignTargeting | None] = {}

    while len(visible) < limit:
        result = await db.execute(
            select(Task)
            .join(Campaign, Campaign.id == Task.campaign_id)
            .where(and_(*conds, Campaign.status == "active"))
            .order_by(Task.is_urgent.desc(), Task.created_at.desc(), Task.id.desc())
            .offset(candidate_offset)
            .limit(scan_size)
        )
        tasks = result.scalars().all()
        if not tasks:
            break

        for task in tasks:
            if task.campaign_id not in targeting_cache:
                targeting_result = await db.execute(select(CampaignTargeting).where(CampaignTargeting.campaign_id == task.campaign_id))
                targeting_cache[task.campaign_id] = targeting_result.scalar_one_or_none()
            targeting = targeting_cache[task.campaign_id]
            if targeting is not None and not await is_worker_eligible(db, current_user.id, targeting):
                continue
            if eligible_seen < offset:
                eligible_seen += 1
                continue
            visible.append({**{c.name: getattr(task, c.name) for c in task.__table__.columns}, "id": str(task.id), "pay_ngn": task.pay_kobo/100})
            eligible_seen += 1
            if len(visible) >= limit:
                break

        candidate_offset += len(tasks)
        if len(tasks) < scan_size:
            break

    return visible

@router.get("/my-stats")
async def my_task_stats(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    ongoing_r = await db.execute(select(func.count(TaskAcceptance.id)).where(TaskAcceptance.worker_id == current_user.id, TaskAcceptance.status == "active"))
    completed_r = await db.execute(select(func.count(Submission.id)).where(Submission.worker_id == current_user.id, Submission.status == "approved"))
    missed_r = await db.execute(select(func.count(TaskAcceptance.id)).where(TaskAcceptance.worker_id == current_user.id, TaskAcceptance.status == "expired"))
    return {"ongoing_tasks": ongoing_r.scalar() or 0, "completed_tasks": completed_r.scalar() or 0, "missed_tasks": missed_r.scalar() or 0}

@router.get("/my-submissions", response_model=list[SubmissionWithTaskResponse])
async def my_submissions(task_id: uuid.UUID | None = Query(None), status: str = Query(None), limit: int = Query(50, ge=1, le=100), offset: int = Query(0, ge=0), current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    conds = [Submission.worker_id == current_user.id]
    if task_id is not None: conds.append(Submission.task_id == task_id)
    if status: conds.append(Submission.status == status)
    result = await db.execute(select(Submission, Task.title, Task.pay_kobo).join(Task, Task.id == Submission.task_id).where(and_(*conds)).order_by(Submission.submitted_at.desc(), Submission.id.desc()).offset(offset).limit(limit))
    return [SubmissionWithTaskResponse(id=sub.id, task_id=sub.task_id, task_title=title, status=sub.status, proof_urls=sub.proof_urls, rejection_reason=sub.rejection_reason, query_reason=sub.query_reason, client_rating=sub.client_rating, pay_ngn=pay_kobo / 100, submitted_at=sub.submitted_at, reviewed_at=sub.reviewed_at) for sub, title, pay_kobo in result.all()]

@router.post("/{task_id}/accept", response_model=AcceptTaskResponse)
async def accept_task(task_id: uuid.UUID, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    await _enforce_task_visibility(task_id, current_user, db)
    result = await db.execute(select(Task).where(Task.id == task_id, Task.status == "available").with_for_update())
    task = result.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not available")
    await _require_active_campaign(task, db)
    if task.slots_filled >= task.slots_total: raise HTTPException(409, "Task fully claimed")
    reserved_r = await db.execute(select(func.count(TaskAcceptance.id)).where(TaskAcceptance.task_id == task_id, TaskAcceptance.status.in_(["active", "submitted"])))
    if task.slots_filled + (reserved_r.scalar() or 0) >= task.slots_total: raise HTTPException(409, "All task slots are currently reserved")
    ex = await db.execute(select(TaskAcceptance).where(TaskAcceptance.task_id == task_id, TaskAcceptance.worker_id == current_user.id, TaskAcceptance.status.in_(["active", "submitted"])))
    if ex.scalar_one_or_none(): raise HTTPException(409, "Already accepted or submitted this task")
    expires_at = datetime.utcnow() + timedelta(minutes=task.accept_timeout_minutes)
    acceptance = TaskAcceptance(task_id=task_id, worker_id=current_user.id, expires_at=expires_at)
    db.add(acceptance)
    await db.flush()
    return AcceptTaskResponse(acceptance_id=str(acceptance.id), task_id=str(task_id), expires_at=expires_at, message=f"You have {task.accept_timeout_minutes} minutes to submit proof.")

@router.post("/{task_id}/submit", response_model=SubmissionResponse)
async def submit_task(task_id: uuid.UUID, body: SubmissionCreate, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    acc_r = await db.execute(select(TaskAcceptance).where(TaskAcceptance.task_id == task_id, TaskAcceptance.worker_id == current_user.id).order_by(TaskAcceptance.accepted_at.desc()).with_for_update())
    acceptance = acc_r.scalars().first()
    if not acceptance:
        raise HTTPException(400, "No acceptance for this task")
    if acceptance.status == "submitted":
        existing_r = await db.execute(select(Submission).where(Submission.acceptance_id == acceptance.id).order_by(Submission.submitted_at.desc(), Submission.id.desc()))
        existing = existing_r.scalars().first()
        if existing:
            return existing
        raise HTTPException(409, "Submission is being finalized; please retry shortly")
    if acceptance.status != "active":
        raise HTTPException(400, f"Acceptance is {acceptance.status} and cannot accept a submission")
    now = datetime.utcnow()
    if acceptance.expires_at <= now:
        acceptance.status = "expired"
        raise HTTPException(400, "Acceptance window expired")
    task_r = await db.execute(select(Task).where(Task.id == task_id).with_for_update())
    task = task_r.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not found")
    await _require_active_campaign(task, db)
    await _enforce_task_visibility(task_id, current_user, db)
    await _validate_proofs(body.proof_urls, current_user.id)
    speed_minutes = (now - acceptance.accepted_at).total_seconds() / 60
    flagged = speed_minutes < 2.0
    image_hash = await compute_image_hash(body.proof_urls[0]) if body.proof_urls else None
    sub = Submission(task_id=task_id, worker_id=current_user.id, acceptance_id=acceptance.id, status="under_review" if flagged else "pending", proof_urls=body.proof_urls, proof_link=body.proof_link, proof_image_hash=image_hash, task_speed_minutes=speed_minutes)
    if flagged: sub.rejection_reason = "Submitted too quickly — flagged for review"
    db.add(sub)
    acceptance.status = "submitted"
    await db.flush()
    if image_hash:
        from app.workers.submission_tasks import check_duplicate_screenshot
        check_duplicate_screenshot.delay(str(sub.id), image_hash)
    return sub

@router.post("/{task_id}/report", status_code=201)
async def report_task(task_id: uuid.UUID, body: TaskReportCreate, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    await _enforce_task_visibility(task_id, current_user, db)
    task_r = await db.execute(select(Task).where(Task.id == task_id))
    if not task_r.scalar_one_or_none(): raise HTTPException(404, "Task not found")
    db.add(TaskReport(task_id=task_id, reporter_id=current_user.id, reason=body.reason))
    return {"message": "Report submitted. Thank you for keeping the platform safe."}

@router.post("/{task_id}/cancel", status_code=200)
async def cancel_acceptance(task_id: uuid.UUID, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    acc_r = await db.execute(select(TaskAcceptance).where(TaskAcceptance.task_id == task_id, TaskAcceptance.worker_id == current_user.id, TaskAcceptance.status == "active").with_for_update())
    acceptance = acc_r.scalar_one_or_none()
    if not acceptance: raise HTTPException(404, "No active acceptance for this task to cancel")
    acceptance.status = "cancelled"
    return {"message": "Acceptance cancelled — the task is available again."}

@router.post("/upload-url", response_model=PresignedUrlResponse)
async def get_upload_url(body: PresignedUrlRequest, current_user: User = Depends(require_worker)):
    try:
        return generate_presigned_upload_url(body.file_extension, folder=f"proofs/{current_user.id}")
    except ValueError as exc: raise HTTPException(400, str(exc)) from exc
    except RuntimeError as exc: raise HTTPException(503, str(exc)) from exc

@router.get("/leaderboard/{period}", response_model=list[LeaderboardEntryResponse])
async def get_leaderboard(period: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    if period not in ("weekly", "monthly"): raise HTTPException(400, "period must be weekly or monthly")
    result = await db.execute(select(LeaderboardScore).where(LeaderboardScore.period == period).order_by(LeaderboardScore.total_score.desc()).limit(100))
    entries = []
    for s in result.scalars():
        ur = await db.execute(select(User).where(User.id == s.worker_id))
        u = ur.scalar_one_or_none()
        entries.append({"rank": s.rank or 0, "worker_id": str(s.worker_id), "full_name": u.full_name if u else "Unknown", "total_score": s.total_score, "ts_score": s.ts_score, "cr_score": s.cr_score, "ar_score": s.ar_score, "tq_score": s.tq_score, "td_score": s.td_score})
    return entries

@router.get("/{task_id}", response_model=TaskResponse)
async def get_task_detail(task_id: uuid.UUID, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    await _enforce_task_visibility(task_id, current_user, db)
    result = await db.execute(select(Task).where(Task.id == task_id))
    task = result.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not found")
    return {**{c.name: getattr(task, c.name) for c in task.__table__.columns}, "id": str(task.id), "pay_ngn": task.pay_kobo / 100}