import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_admin
from app.models.user import User, KycProfile
from app.models.task import Submission, Task, TaskReport, LeaderboardScore
from app.models.campaign import Campaign
from app.models.wallet import Wallet
from app.services import wallet_service
from app.services.clickpoints import calculate_click_points

router = APIRouter(prefix="/admin", tags=["admin"])

@router.get("/submissions/pending")
async def list_pending(db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    r = await db.execute(select(Submission).where(Submission.status.in_(["pending","under_review"])).order_by(Submission.submitted_at.asc()).limit(100))
    return [{"id": str(s.id), "task_id": str(s.task_id), "worker_id": str(s.worker_id),
             "status": s.status, "proof_urls": s.proof_urls, "speed_min": s.task_speed_minutes,
             "submitted_at": s.submitted_at} for s in r.scalars()]

@router.post("/submissions/{submission_id}/approve")
async def approve_submission(submission_id: uuid.UUID, client_rating: float = 5.0,
    db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    sub_r = await db.execute(select(Submission).where(Submission.id==submission_id).with_for_update())
    sub = sub_r.scalar_one_or_none()
    if not sub: raise HTTPException(404, "Submission not found")
    if sub.status not in ("pending","under_review","queried"): raise HTTPException(400, f"Cannot approve status '{sub.status}'")
    task_r = await db.execute(select(Task).where(Task.id==sub.task_id))
    task = task_r.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not found")
    campaign_r = await db.execute(select(Campaign).where(Campaign.id==task.campaign_id))
    campaign = campaign_r.scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Campaign not found")
    cps = calculate_click_points(cw_task_category=task.cw_task_category, worker_pay_kobo=task.pay_kobo,
        is_urgent=task.is_urgent, submitted_at=sub.submitted_at)
    await wallet_service.release_escrow_to_worker(db=db, advertiser_id=campaign.owner_id,
        worker_id=sub.worker_id, amount_kobo=task.pay_kobo, click_points=cps,
        task_category=task.cw_task_category, reference=str(sub.id))
    sub.status = "approved"; sub.reviewed_at = datetime.utcnow()
    sub.client_rating = max(0.0, min(5.0, client_rating))
    task.slots_filled = min(task.slots_filled + 1, task.slots_total)
    if task.slots_filled >= task.slots_total: task.status = "completed"
    from app.services import rewards_service
    from app.services.notification_service import notify
    await rewards_service.award_referral_bonus_if_first_approval(db, sub.worker_id)
    await notify(db, sub.worker_id, "task_approved", "Task approved!",
                 f"\"{task.title}\" was approved — you earned ₦{task.pay_kobo/100:,.2f}.")
    from app.workers.notification_tasks import notify_task_approved
    notify_task_approved.delay(str(sub.worker_id), task.title, task.pay_kobo/100)
    return {"message": "Approved", "click_points_awarded": cps, "amount_ngn": task.pay_kobo/100}

@router.post("/submissions/{submission_id}/reject")
async def reject_submission(submission_id: uuid.UUID, reason: str,
    db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    sub_r = await db.execute(select(Submission).where(Submission.id==submission_id).with_for_update())
    sub = sub_r.scalar_one_or_none()
    if not sub: raise HTTPException(404, "Submission not found")
    if sub.status not in ("pending","under_review","queried"): raise HTTPException(400, f"Cannot reject status '{sub.status}'")
    sub.status = "rejected"; sub.rejection_reason = reason; sub.reviewed_at = datetime.utcnow()
    from app.services.notification_service import notify
    from app.workers.notification_tasks import notify_task_rejected
    task_r = await db.execute(select(Task).where(Task.id==sub.task_id))
    task = task_r.scalar_one_or_none()
    if task:
        await notify(db, sub.worker_id, "task_rejected", "Task rejected",
                     f"\"{task.title}\" was rejected: {reason}")
        notify_task_rejected.delay(str(sub.worker_id), task.title, reason)
    return {"message": "Rejected", "reason": reason}

@router.post("/submissions/{submission_id}/query")
async def query_submission(submission_id: uuid.UUID, query_reason: str,
    db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    sub_r = await db.execute(select(Submission).where(Submission.id==submission_id))
    sub = sub_r.scalar_one_or_none()
    if not sub or sub.status != "pending": raise HTTPException(400, "Submission not in pending state")
    sub.status = "queried"; sub.query_reason = query_reason
    return {"message": "Submission queried"}

@router.get("/campaigns/pending")
async def list_pending_campaigns(db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    r = await db.execute(select(Campaign).where(Campaign.status == "pending_admin").order_by(Campaign.created_at.asc()).limit(100))
    return [{"id": str(c.id), "owner_id": str(c.owner_id), "title": c.title, "platform": c.platform,
             "action_type": c.action_type, "tni_service_type": c.tni_service_type,
             "client_budget_kobo": c.client_budget_kobo, "slots_total": c.slots_total,
             "created_at": c.created_at} for c in r.scalars()]

@router.post("/campaigns/{campaign_id}/approve")
async def approve_campaign(campaign_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    r = await db.execute(select(Campaign).options(selectinload(Campaign.targeting)).where(Campaign.id==campaign_id))
    campaign = r.scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Campaign not found")
    if campaign.status != "pending_admin": raise HTTPException(400, f"Campaign is already '{campaign.status}'")
    campaign.status = "active"
    tasks_r = await db.execute(select(Task).where(Task.campaign_id==campaign_id))
    for task in tasks_r.scalars(): task.status = "available"
    from app.services.notification_service import notify
    await notify(db, campaign.owner_id, "campaign_approved", "Campaign is live",
                 f"\"{campaign.title}\" was approved and is now live for workers.")

    # For a *targeted* campaign, proactively notify the specific workers it
    # matches — an untargeted campaign is already visible to everyone via
    # the normal task feed (GET /tasks), so a mass notification there would
    # just be spam with no new information.
    if campaign.targeting:
        from app.services.targeting import get_eligible_worker_ids
        worker_ids = await get_eligible_worker_ids(campaign.targeting, campaign.slots_total, db)
        if worker_ids:
            from app.workers.notification_tasks import notify_new_tasks_available
            notify_new_tasks_available.delay([str(w) for w in worker_ids], campaign.title)

    return {"message": "Campaign approved and tasks are now live"}

@router.post("/campaigns/{campaign_id}/reject")
async def reject_campaign(campaign_id: uuid.UUID, reason: str,
    db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    r = await db.execute(select(Campaign).where(Campaign.id==campaign_id))
    campaign = r.scalar_one_or_none()
    if not campaign: raise HTTPException(404, "Campaign not found")
    campaign.status = "cancelled"
    if campaign.escrow_kobo > 0:
        await wallet_service.credit(db=db, user_id=campaign.owner_id, amount_kobo=campaign.escrow_kobo,
            tx_type="escrow_release", description=f"Campaign rejected: {reason}", reference=str(campaign_id))
        campaign.escrow_kobo = 0
    from app.services.notification_service import notify
    await notify(db, campaign.owner_id, "campaign_rejected", "Campaign rejected",
                 f"\"{campaign.title}\" was rejected: {reason}. Your budget has been refunded.")
    return {"message": "Campaign rejected and budget refunded"}

@router.get("/reports/pending")
async def list_pending_reports(db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    r = await db.execute(select(TaskReport).where(TaskReport.status=="pending").order_by(TaskReport.created_at.asc()))
    return [{"id": str(rp.id), "task_id": str(rp.task_id), "reporter_id": str(rp.reporter_id),
             "reason": rp.reason, "created_at": rp.created_at} for rp in r.scalars()]

@router.post("/reports/{report_id}/uphold")
async def uphold_report(report_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    rp_r = await db.execute(select(TaskReport).where(TaskReport.id==report_id))
    report = rp_r.scalar_one_or_none()
    if not report or report.status != "pending": raise HTTPException(404, "Report not found or already reviewed")
    task_r = await db.execute(select(Task).where(Task.id==report.task_id))
    task = task_r.scalar_one_or_none()
    if not task: raise HTTPException(404, "Task not found")
    campaign_r = await db.execute(select(Campaign).where(Campaign.id==task.campaign_id))
    campaign = campaign_r.scalar_one_or_none()
    task.status = "reported_removed"
    if campaign:
        campaign.status = "reported"
        if campaign.escrow_kobo > 0:
            await wallet_service.credit(db=db, user_id=campaign.owner_id, amount_kobo=campaign.escrow_kobo,
                tx_type="escrow_release", description="Campaign removed — ToS violation. Full refund.", reference=str(campaign.id))
            campaign.escrow_kobo = 0
    w_r = await db.execute(select(Wallet).where(Wallet.user_id==report.reporter_id).with_for_update())
    w = w_r.scalar_one_or_none()
    CP_REWARD = 250
    if w: w.click_points += CP_REWARD
    report.status = "upheld"; report.reviewed_at = datetime.utcnow(); report.cp_reward_given = True
    return {"message": "Report upheld. Task removed, advertiser refunded, reporter rewarded.", "cp_reward": CP_REWARD}

@router.post("/reports/{report_id}/dismiss")
async def dismiss_report(report_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    rp_r = await db.execute(select(TaskReport).where(TaskReport.id==report_id))
    report = rp_r.scalar_one_or_none()
    if not report or report.status != "pending": raise HTTPException(404, "Report not found or already reviewed")
    report.status = "dismissed"; report.reviewed_at = datetime.utcnow()
    return {"message": "Report dismissed"}

@router.get("/kyc/pending")
async def list_pending_kyc(db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    r = await db.execute(
        select(KycProfile, User.full_name)
        .join(User, User.id == KycProfile.user_id)
        .where(KycProfile.status == "pending")
        .order_by(KycProfile.submitted_at.asc()).limit(100)
    )
    return [{"id": str(k.id), "user_id": str(k.user_id), "full_name": full_name,
             "document_type": k.document_type, "submitted_at": k.submitted_at} for k, full_name in r.all()]

@router.post("/kyc/{user_id}/approve")
async def approve_kyc(user_id: uuid.UUID, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    kyc_r = await db.execute(select(KycProfile).where(KycProfile.user_id==user_id))
    kyc = kyc_r.scalar_one_or_none()
    if not kyc: raise HTTPException(404, "KYC not found")
    kyc.status = "approved"; kyc.reviewed_at = datetime.utcnow()
    user_r = await db.execute(select(User).where(User.id==user_id))
    user = user_r.scalar_one_or_none()
    if user:
        user.kyc_verified = True
        from app.services.notification_service import notify
        await notify(db, user.id, "kyc_approved", "KYC approved",
                     "Your identity verification was approved — you now have access to targeted campaigns.")
    return {"message": "KYC approved"}

@router.post("/kyc/{user_id}/reject")
async def reject_kyc(user_id: uuid.UUID, reason: str, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    kyc_r = await db.execute(select(KycProfile).where(KycProfile.user_id==user_id))
    kyc = kyc_r.scalar_one_or_none()
    if not kyc: raise HTTPException(404, "KYC not found")
    kyc.status = "rejected"; kyc.reviewed_at = datetime.utcnow()
    from app.services.notification_service import notify
    await notify(db, user_id, "kyc_rejected", "KYC rejected", reason)
    return {"message": "KYC rejected", "reason": reason}

@router.post("/rewards/distribute-pool")
async def distribute_reward_pool(track: str, pool_ngn: float, db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    """Split a pooled prize (e.g. the 'share of ₦1,000,000' promised to
    Level-10 Grit/Gratis achievers) equally among every worker who has
    reached Level 10 on that track and hasn't already been paid from it."""
    from app.services import rewards_service
    return await rewards_service.distribute_reward_pool(db, track, int(pool_ngn * 100))

@router.get("/stats")
async def platform_stats(db: AsyncSession = Depends(get_db), _: User = Depends(require_admin)):
    from sqlalchemy import func
    users_r  = await db.execute(select(func.count(User.id)))
    camp_r   = await db.execute(select(func.count(Campaign.id)).where(Campaign.status=="active"))
    subs_r   = await db.execute(select(func.count(Submission.id)).where(Submission.status=="pending"))
    kyc_r    = await db.execute(select(func.count(KycProfile.id)).where(KycProfile.status=="pending"))
    return {"total_users": users_r.scalar(), "active_campaigns": camp_r.scalar(),
            "pending_submissions": subs_r.scalar(), "pending_kyc": kyc_r.scalar()}
