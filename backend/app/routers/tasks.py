import uuid
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user, require_worker
from app.models.user import User
from app.models.task import Task, TaskAcceptance, Submission, TaskReport, LeaderboardScore
from app.schemas.task import TaskResponse, AcceptTaskResponse, SubmissionCreate, SubmissionResponse, TaskReportCreate, PresignedUrlRequest, PresignedUrlResponse, LeaderboardEntryResponse
from app.services import wallet_service
from app.services.clickpoints import calculate_click_points
from app.services.storage import generate_presigned_upload_url, compute_image_hash

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.get("", response_model=list[TaskResponse])
async def list_tasks(category: str = Query(None), difficulty: str = Query(None),
    is_high_earning: bool = Query(None), is_urgent: bool = Query(None), platform: str = Query(None),
    current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    conds = [Task.status == "available", Task.slots_filled < Task.slots_total]
    if not current_user.kyc_verified:
        from app.models.campaign import CampaignTargeting
        conds.append(Task.campaign_id.not_in(select(CampaignTargeting.campaign_id).scalar_subquery()))
    if category: conds.append(Task.cw_task_category == category)
    if difficulty: conds.append(Task.difficulty == difficulty)
    if is_high_earning is not None: conds.append(Task.is_high_earning == is_high_earning)
    if is_urgent is not None: conds.append(Task.is_urgent == is_urgent)
    if platform: conds.append(Task.platform == platform)
    accepted_result = await db.execute(select(TaskAcceptance.task_id).where(and_(
        TaskAcceptance.worker_id == current_user.id, TaskAcceptance.status.in_(["active","submitted"]))))
    accepted_ids = list(accepted_result.scalars())
    if accepted_ids: conds.append(Task.id.not_in(accepted_ids))
    result = await db.execute(select(Task).where(and_(*conds)).order_by(Task.is_urgent.desc(), Task.created_at.desc()).limit(50))
    return [{**{c.name: getattr(t, c.name) for c in t.__table__.columns}, "id": str(t.id), "pay_ngn": t.pay_kobo/100} for t in result.scalars()]

@router.post("/{task_id}/accept", response_model=AcceptTaskResponse)
async def accept_task(task_id: uuid.UUID, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Task).where(Task.id==task_id, Task.status=="available").with_for_update())
    task = result.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not available")
    if task.slots_filled >= task.slots_total: raise HTTPException(409, "Task fully claimed")
    ex = await db.execute(select(TaskAcceptance).where(TaskAcceptance.task_id==task_id, TaskAcceptance.worker_id==current_user.id, TaskAcceptance.status=="active"))
    if ex.scalar_one_or_none(): raise HTTPException(409, "Already accepted this task")
    expires_at = datetime.utcnow() + timedelta(minutes=task.accept_timeout_minutes)
    acceptance = TaskAcceptance(task_id=task_id, worker_id=current_user.id, expires_at=expires_at)
    db.add(acceptance); await db.flush()
    return AcceptTaskResponse(acceptance_id=str(acceptance.id), task_id=str(task_id), expires_at=expires_at,
        message=f"You have {task.accept_timeout_minutes} minutes to submit proof.")

@router.post("/{task_id}/submit", response_model=SubmissionResponse)
async def submit_task(task_id: uuid.UUID, body: SubmissionCreate, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    acc_r = await db.execute(select(TaskAcceptance).where(TaskAcceptance.task_id==task_id,
        TaskAcceptance.worker_id==current_user.id, TaskAcceptance.status=="active").with_for_update())
    acceptance = acc_r.scalar_one_or_none()
    if not acceptance: raise HTTPException(400, "No active acceptance for this task")
    if acceptance.expires_at < datetime.utcnow():
        acceptance.status = "expired"
        raise HTTPException(400, "Acceptance window expired")
    task_r = await db.execute(select(Task).where(Task.id==task_id))
    task = task_r.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not found")
    speed_minutes = (datetime.utcnow() - acceptance.accepted_at).total_seconds() / 60
    flagged = speed_minutes < 2.0
    image_hash = None
    if body.proof_urls:
        image_hash = await compute_image_hash(body.proof_urls[0])
    sub = Submission(task_id=task_id, worker_id=current_user.id, acceptance_id=acceptance.id,
        status="under_review" if flagged else "pending",
        proof_urls=body.proof_urls, proof_link=body.proof_link,
        proof_image_hash=image_hash, task_speed_minutes=speed_minutes)
    if flagged: sub.rejection_reason = "Submitted too quickly — flagged for review"
    db.add(sub); acceptance.status = "submitted"; await db.flush()
    if image_hash:
        from app.workers.submission_tasks import check_duplicate_screenshot
        check_duplicate_screenshot.delay(str(sub.id), image_hash)
    return sub

@router.post("/{task_id}/report", status_code=201)
async def report_task(task_id: uuid.UUID, body: TaskReportCreate, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    task_r = await db.execute(select(Task).where(Task.id==task_id))
    if not task_r.scalar_one_or_none(): raise HTTPException(404, "Task not found")
    db.add(TaskReport(task_id=task_id, reporter_id=current_user.id, reason=body.reason))
    return {"message": "Report submitted. Thank you for keeping the platform safe."}

@router.post("/upload-url", response_model=PresignedUrlResponse)
async def get_upload_url(body: PresignedUrlRequest, current_user: User = Depends(require_worker)):
    try: return generate_presigned_upload_url(body.file_extension)
    except ValueError as e: raise HTTPException(400, str(e))

@router.get("/leaderboard/{period}", response_model=list[LeaderboardEntryResponse])
async def get_leaderboard(period: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    if period not in ("weekly","monthly"): raise HTTPException(400, "period must be weekly or monthly")
    result = await db.execute(select(LeaderboardScore).where(LeaderboardScore.period==period).order_by(LeaderboardScore.total_score.desc()).limit(100))
    entries = []
    for s in result.scalars():
        ur = await db.execute(select(User).where(User.id==s.worker_id))
        u = ur.scalar_one_or_none()
        entries.append({"rank": s.rank or 0, "worker_id": str(s.worker_id),
            "full_name": u.full_name if u else "Unknown", "total_score": s.total_score,
            "ts_score": s.ts_score, "cr_score": s.cr_score, "ar_score": s.ar_score,
            "tq_score": s.tq_score, "td_score": s.td_score})
    return entries
