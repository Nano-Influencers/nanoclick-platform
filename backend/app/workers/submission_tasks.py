import asyncio
import uuid
from datetime import datetime, timedelta
from app.workers.celery_app import celery_app
from app.config import settings

def _run(coro):
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()

@celery_app.task(name="app.workers.submission_tasks.auto_approve_old_submissions")
def auto_approve_old_submissions():
    _run(_auto_approve())

async def _auto_approve():
    from app.database import AsyncSessionLocal
    from app.models.task import Submission, Task
    from app.models.campaign import Campaign
    from app.services import wallet_service, rewards_service
    from app.services.notification_service import notify
    from app.services.clickpoints import calculate_click_points
    from sqlalchemy import select, and_

    cutoff = datetime.utcnow() - timedelta(hours=settings.AUTO_APPROVE_HOURS)
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(Submission).where(and_(
                Submission.status.in_(["pending","under_review"]),
                Submission.submitted_at <= cutoff,
            ))
        )
        for sub in result.scalars().all():
            task_r = await db.execute(select(Task).where(Task.id==sub.task_id))
            task = task_r.scalar_one_or_none()
            if not task: continue
            camp_r = await db.execute(select(Campaign).where(Campaign.id==task.campaign_id))
            campaign = camp_r.scalar_one_or_none()
            if not campaign: continue
            cps = calculate_click_points(task.cw_task_category, task.pay_kobo, task.is_urgent, sub.submitted_at)
            await wallet_service.release_escrow_to_worker(
                db=db, advertiser_id=campaign.owner_id, worker_id=sub.worker_id,
                amount_kobo=task.pay_kobo, click_points=cps,
                task_category=task.cw_task_category, reference=str(sub.id))
            sub.status = "approved"
            sub.was_auto_approved = True
            sub.reviewed_at = datetime.utcnow()
            task.slots_filled = min(task.slots_filled + 1, task.slots_total)
            if task.slots_filled >= task.slots_total:
                task.status = "completed"
            await rewards_service.award_referral_bonus_if_first_approval(db, sub.worker_id)
            await notify(db, sub.worker_id, "task_approved", "Task auto-approved",
                         f"\"{task.title}\" was automatically approved after {settings.AUTO_APPROVE_HOURS}h — you earned ₦{task.pay_kobo/100:,.2f}.")
        await db.commit()

@celery_app.task(name="app.workers.submission_tasks.expire_stale_acceptances")
def expire_stale_acceptances():
    _run(_expire())

async def _expire():
    from app.database import AsyncSessionLocal
    from app.models.task import TaskAcceptance
    from sqlalchemy import select, and_
    now = datetime.utcnow()
    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(TaskAcceptance).where(and_(
                TaskAcceptance.status == "active",
                TaskAcceptance.expires_at <= now,
            ))
        )
        for acc in result.scalars():
            acc.status = "expired"
        await db.commit()

@celery_app.task(name="app.workers.submission_tasks.check_duplicate_screenshot")
def check_duplicate_screenshot(submission_id: str, image_hash: str):
    _run(_check_dup(uuid.UUID(submission_id), image_hash))

async def _check_dup(submission_id, image_hash):
    from app.database import AsyncSessionLocal
    from app.models.task import Submission
    from app.services.storage import hashes_are_duplicate
    from sqlalchemy import select
    async with AsyncSessionLocal() as db:
        sub_r = await db.execute(select(Submission).where(Submission.id==submission_id))
        current = sub_r.scalar_one_or_none()
        if not current: return
        others_r = await db.execute(select(Submission).where(
            Submission.task_id==current.task_id, Submission.id!=submission_id,
            Submission.proof_image_hash.isnot(None)))
        for other in others_r.scalars():
            if other.proof_image_hash and hashes_are_duplicate(image_hash, other.proof_image_hash):
                current.status = "under_review"
                current.rejection_reason = "Duplicate screenshot detected — flagged for admin review"
                await db.commit()
                return
