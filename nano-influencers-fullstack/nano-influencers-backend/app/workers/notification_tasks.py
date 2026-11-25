"""
These Celery tasks are kept as async fire-and-forget dispatch points (called
via .delay() from request handlers, matching the existing convention in this
codebase -- see submission_tasks.py / payout_tasks.py), but now actually
persist a Notification row instead of the old `pass  # Week 3: SSE push`
stub. Real-time push (SSE/WebSocket) on top of this feed is a natural next
step -- see docs/architecture.md -- but polling GET /notifications already
gives both frontends a working, durable notification feed today.

Note: the synchronous approve/reject code paths in app/routers/admin.py also
write the Notification row directly and inline (so it's visible in the same
request/transaction as the approval itself) -- these Celery tasks remain as a
secondary/fallback delivery path and for the notify_new_tasks_available /
notify_campaign_report_upheld cases that don't have an inline call site.
"""
from app.workers.celery_app import celery_app


def _run(coro):
    import asyncio
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()


@celery_app.task(name="app.workers.notification_tasks.notify_task_approved", queue="notifications")
def notify_task_approved(worker_id: str, task_title: str, amount_ngn: float):
    pass  # already persisted inline by the calling endpoint -- see admin.py / submission_tasks.py


@celery_app.task(name="app.workers.notification_tasks.notify_task_rejected", queue="notifications")
def notify_task_rejected(worker_id: str, task_title: str, reason: str):
    pass  # already persisted inline by the calling endpoint -- see admin.py


@celery_app.task(name="app.workers.notification_tasks.notify_new_tasks_available", queue="notifications")
def notify_new_tasks_available(worker_ids: list, campaign_title: str):
    _run(_notify_many(worker_ids, "new_tasks_available", "New tasks available",
                       f'New tasks from "{campaign_title}" match your profile.'))


@celery_app.task(name="app.workers.notification_tasks.notify_campaign_report_upheld", queue="notifications")
def notify_campaign_report_upheld(advertiser_id: str, campaign_id: str):
    _run(_notify_one(advertiser_id, "campaign_reported", "Campaign removed",
                      "One of your campaigns was removed after a policy violation report was upheld. "
                      "Any remaining budget has been refunded to your wallet."))


async def _notify_one(user_id: str, type_: str, title: str, body: str):
    import uuid
    from app.database import AsyncSessionLocal
    from app.services.notification_service import notify
    async with AsyncSessionLocal() as db:
        await notify(db, uuid.UUID(user_id), type_, title, body)
        await db.commit()


async def _notify_many(user_ids: list, type_: str, title: str, body: str):
    import uuid
    from app.database import AsyncSessionLocal
    from app.services.notification_service import notify
    async with AsyncSessionLocal() as db:
        for uid in user_ids:
            await notify(db, uuid.UUID(uid), type_, title, body)
        await db.commit()
