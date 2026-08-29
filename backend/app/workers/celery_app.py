from celery import Celery
from celery.schedules import crontab
from app.config import settings

celery_app = Celery(
    "nanoclick",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=[
        "app.workers.submission_tasks",
        "app.workers.payout_tasks",
        "app.workers.targeting_tasks",
        "app.workers.leaderboard_tasks",
        "app.workers.notification_tasks",
    ],
)

celery_app.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="Africa/Lagos",
    enable_utc=True,
    task_routes={
        "app.workers.submission_tasks.*":  {"queue": "auto_approve"},
        "app.workers.payout_tasks.*":      {"queue": "payouts"},
        "app.workers.notification_tasks.*":{"queue": "notifications"},
        "app.workers.targeting_tasks.*":   {"queue": "default"},
        "app.workers.leaderboard_tasks.*": {"queue": "default"},
    },
    beat_schedule={
        "auto-approve-submissions": {
            "task": "app.workers.submission_tasks.auto_approve_old_submissions",
            "schedule": crontab(minute=0),
        },
        "expire-stale-acceptances": {
            "task": "app.workers.submission_tasks.expire_stale_acceptances",
            "schedule": crontab(minute="*/5"),
        },
        "expand-targeting-tiers": {
            "task": "app.workers.targeting_tasks.expand_targeting_tiers",
            "schedule": crontab(minute=0, hour="*/6"),
        },
        "recompute-weekly-leaderboard": {
            "task": "app.workers.leaderboard_tasks.recompute_weekly_leaderboard",
            "schedule": crontab(minute=5, hour=0, day_of_week=1),
        },
        "recompute-monthly-leaderboard": {
            "task": "app.workers.leaderboard_tasks.recompute_monthly_leaderboard",
            "schedule": crontab(minute=10, hour=0, day_of_month=1),
        },
        "reset-daily-wallet-counters": {
            "task": "app.workers.payout_tasks.reset_daily_wallet_counters",
            "schedule": crontab(minute=0, hour=0),
        },
    },
)
