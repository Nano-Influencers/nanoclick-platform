from app.workers.celery_app import celery_app
from app.workers.payout_tasks import process_withdrawal, reconcile_withdrawal
from app.workers.submission_tasks import (
    auto_approve_old_submissions,
    expire_stale_acceptances,
)


def test_celery_delivery_safety_configuration():
    conf = celery_app.conf

    assert conf.task_serializer == "json"
    assert conf.result_serializer == "json"
    assert conf.accept_content == ["json"]
    assert conf.task_acks_late is True
    assert conf.task_reject_on_worker_lost is True
    assert conf.worker_prefetch_multiplier == 1
    assert conf.task_track_started is True
    assert conf.task_soft_time_limit == 840
    assert conf.task_time_limit == 900
    assert conf.broker_transport_options["visibility_timeout"] >= conf.task_time_limit


def test_money_changing_tasks_have_dedicated_routes():
    routes = celery_app.conf.task_routes

    assert routes["app.workers.payout_tasks.*"]["queue"] == "payouts"
    assert routes["app.workers.submission_tasks.*"]["queue"] == "auto_approve"
    assert routes["app.workers.notification_tasks.*"]["queue"] == "notifications"


def test_critical_tasks_are_registered_with_stable_names():
    assert auto_approve_old_submissions.name == (
        "app.workers.submission_tasks.auto_approve_old_submissions"
    )
    assert expire_stale_acceptances.name == (
        "app.workers.submission_tasks.expire_stale_acceptances"
    )
    assert process_withdrawal.name == "app.workers.payout_tasks.process_withdrawal"
    assert reconcile_withdrawal.name == "app.workers.payout_tasks.reconcile_withdrawal"


def test_withdrawal_task_retries_transient_failures():
    assert process_withdrawal.autoretry_for == (Exception,)
    assert process_withdrawal.retry_backoff is True
    assert process_withdrawal.retry_backoff_max == 300
    assert process_withdrawal.retry_kwargs["max_retries"] == 5


def test_beat_schedule_covers_financial_and_expiry_recovery_jobs():
    schedule = celery_app.conf.beat_schedule

    assert schedule["auto-approve-submissions"]["task"] == auto_approve_old_submissions.name
    assert schedule["expire-stale-acceptances"]["task"] == expire_stale_acceptances.name
    assert schedule["reset-daily-wallet-counters"]["task"] == (
        "app.workers.payout_tasks.reset_daily_wallet_counters"
    )
