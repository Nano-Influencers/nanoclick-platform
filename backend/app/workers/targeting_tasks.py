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
        await db.commit()
