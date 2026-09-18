import asyncio
from datetime import datetime
from app.workers.celery_app import celery_app

def _run(coro):
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()

@celery_app.task(name="app.workers.targeting_tasks.expand_targeting_tiers")
def expand_targeting_tiers():
    _run(_expand())

async def _expand():
    from app.database import AsyncSessionLocal
    from app.models.campaign import Campaign, CampaignTargeting
    from sqlalchemy import select, and_
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(Campaign).where(and_(
            Campaign.status=="active", Campaign.slots_filled < Campaign.slots_total)))
        for campaign in result.scalars().all():
            if not campaign.targeting: continue
            t = campaign.targeting
            if t.current_expansion_tier < 9:
                t.current_expansion_tier += 1
                t.last_expanded_at = datetime.utcnow()
                # Re-evaluate the now-expanded audience and notify workers who
                # are eligible under the newly unlocked tier. The targeting
                # engine remains authoritative for all hard constraints.
                from app.services.targeting import get_eligible_worker_ids
                from app.workers.notification_tasks import notify_new_tasks_available
                worker_ids = await get_eligible_worker_ids(
                    t, campaign.slots_total, db, current_tier=t.current_expansion_tier
                )
                if worker_ids:
                    notify_new_tasks_available.delay(
                        [str(worker_id) for worker_id in worker_ids], campaign.title
                    )
        await db.commit()
