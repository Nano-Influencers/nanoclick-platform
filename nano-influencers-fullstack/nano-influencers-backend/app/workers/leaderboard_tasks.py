import asyncio
from datetime import datetime, timedelta
from app.workers.celery_app import celery_app

def _run(coro):
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()

@celery_app.task(name="app.workers.leaderboard_tasks.recompute_weekly_leaderboard")
def recompute_weekly_leaderboard():
    now = datetime.utcnow()
    _run(_recompute(now - timedelta(weeks=1), now, "weekly"))

@celery_app.task(name="app.workers.leaderboard_tasks.recompute_monthly_leaderboard")
def recompute_monthly_leaderboard():
    now = datetime.utcnow()
    _run(_recompute(now.replace(day=1, hour=0, minute=0, second=0), now, "monthly"))

async def _recompute(period_start, period_end, period):
    from app.database import AsyncSessionLocal
    from app.models.task import Submission, Task, LeaderboardScore
    from app.services.leaderboard import WorkerStats, score_worker_pool
    from sqlalchemy import select, and_

    CAT_INDEX = {"one_off_single":0,"one_off_grouped":1,"repeating_single":2,
                 "repeating_grouped":3,"trend_push":4,"skill_based":5,"unpaid":6}

    async with AsyncSessionLocal() as db:
        subs_r = await db.execute(select(Submission).where(and_(
            Submission.submitted_at >= period_start, Submission.submitted_at <= period_end,
            Submission.status.in_(["approved","rejected"]))))
        subs = subs_r.scalars().all()

        worker_map: dict[str, dict] = {}
        for sub in subs:
            wid = str(sub.worker_id)
            if wid not in worker_map:
                worker_map[wid] = {"speeds":[],"ratings":[],"approved":0,"rejected":0,"cats":[0]*7}
            s = worker_map[wid]
            if sub.task_speed_minutes is not None: s["speeds"].append(sub.task_speed_minutes)
            if sub.client_rating is not None: s["ratings"].append(sub.client_rating)
            if sub.status == "approved": s["approved"] += 1
            else: s["rejected"] += 1

        for sub in subs:
            if sub.status != "approved": continue
            task_r = await db.execute(select(Task).where(Task.id==sub.task_id))
            task = task_r.scalar_one_or_none()
            if task and task.cw_task_category in CAT_INDEX:
                worker_map[str(sub.worker_id)]["cats"][CAT_INDEX[task.cw_task_category]] += 1

        stats = [WorkerStats(
            worker_id=wid,
            avg_speed_minutes=sum(s["speeds"])/len(s["speeds"]) if s["speeds"] else 0,
            avg_client_rating=sum(s["ratings"])/len(s["ratings"]) if s["ratings"] else 0,
            tasks_approved=s["approved"], tasks_rejected=s["rejected"],
            tasks_completed=s["approved"]+s["rejected"], cat_counts=s["cats"])
            for wid, s in worker_map.items()]

        for row in score_worker_pool(stats):
            db.add(LeaderboardScore(
                worker_id=row["worker_id"], period=period,
                period_start=period_start, period_end=period_end,
                ts_score=row["ts_score"], cr_score=row["cr_score"],
                ar_score=row["ar_score"], tq_score=row["tq_score"],
                td_score=row["td_score"], total_score=row["total_score"],
                rank=row["rank"], computed_at=datetime.utcnow()))
        await db.commit()
