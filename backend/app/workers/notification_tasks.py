from app.workers.celery_app import celery_app

@celery_app.task(name="app.workers.notification_tasks.notify_task_approved", queue="notifications")
def notify_task_approved(worker_id: str, task_title: str, amount_ngn: float):
    pass  # Week 3: SSE push

@celery_app.task(name="app.workers.notification_tasks.notify_task_rejected", queue="notifications")
def notify_task_rejected(worker_id: str, task_title: str, reason: str):
    pass  # Week 3: SSE push

@celery_app.task(name="app.workers.notification_tasks.notify_new_tasks_available", queue="notifications")
def notify_new_tasks_available(worker_ids: list, campaign_title: str):
    pass

@celery_app.task(name="app.workers.notification_tasks.notify_campaign_report_upheld", queue="notifications")
def notify_campaign_report_upheld(advertiser_id: str, campaign_id: str):
    pass
