import uuid
from datetime import datetime, timedelta

import pytest
from sqlalchemy import select, func

from app.models.campaign import Campaign
from app.models.task import Submission, Task, TaskAcceptance
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.services import wallet_service
from app.workers import submission_tasks


async def _worker(db, name: str) -> User:
    user = User(
        email=f"{name}-{uuid.uuid4()}@example.com",
        full_name=name,
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    return user


async def _advertiser(db, name: str) -> User:
    user = User(
        email=f"{name}-{uuid.uuid4()}@example.com",
        full_name=name,
        role="advertiser",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_auto_approval_worker_settles_once_and_is_redelivery_safe(db_factory, monkeypatch):
    async with db_factory() as db:
        advertiser = await _advertiser(db, "celery-advertiser")
        worker = await _worker(db, "celery-worker")
        db.add_all([
            Wallet(user_id=advertiser.id, balance_kobo=100_000),
            Wallet(user_id=worker.id, balance_kobo=0),
        ])
        await db.flush()

        campaign = Campaign(
            owner_id=advertiser.id,
            title="Celery auto approval",
            platform="instagram",
            action_type="like",
            tni_service_type="single_one_time",
            cw_task_category="one_off_single",
            client_budget_kobo=2_000,
            client_price_per_action_kobo=1_000,
            worker_pay_per_action_kobo=600,
            escrow_kobo=2_000,
            slots_total=1,
            status="active",
        )
        db.add(campaign)
        await db.flush()
        task = Task(
            campaign_id=campaign.id,
            title="Auto-approved task",
            platform="instagram",
            action_type="like",
            cw_task_category="one_off_single",
            pay_kobo=600,
            slots_total=1,
            status="available",
        )
        db.add(task)
        await db.flush()
        await wallet_service.lock_escrow(db, advertiser.id, 2_000, reference=str(campaign.id))

        acceptance = TaskAcceptance(
            task_id=task.id,
            worker_id=worker.id,
            accepted_at=datetime.utcnow() - timedelta(hours=73),
            expires_at=datetime.utcnow() + timedelta(hours=1),
            status="submitted",
        )
        db.add(acceptance)
        await db.flush()
        submission = Submission(
            task_id=task.id,
            worker_id=worker.id,
            acceptance_id=acceptance.id,
            status="pending",
            proof_urls=[],
            submitted_at=datetime.utcnow() - timedelta(hours=73),
        )
        db.add(submission)
        await db.commit()
        submission_id = submission.id

    async def fake_notify(*_args, **_kwargs):
        return None

    monkeypatch.setattr("app.services.notification_service.notify", fake_notify)

    await submission_tasks._auto_approve()
    await submission_tasks._auto_approve()

    async with db_factory() as db:
        submission = (await db.execute(select(Submission).where(Submission.id == submission_id))).scalar_one()
        task = (await db.execute(select(Task).where(Task.id == submission.task_id))).scalar_one()
        advertiser_wallet = (await db.execute(select(Wallet).where(Wallet.user_id == advertiser.id))).scalar_one()
        worker_wallet = (await db.execute(select(Wallet).where(Wallet.user_id == worker.id))).scalar_one()
        payout_count = await db.execute(select(func.count(Transaction.id)).where(
            Transaction.type == "task_earning",
            Transaction.reference == str(submission_id),
        ))

        assert submission.status == "approved"
        assert submission.was_auto_approved is True
        assert task.slots_filled == 1
        assert task.status == "completed"
        assert advertiser_wallet.escrow_kobo == 1_000
        assert worker_wallet.balance_kobo == 600
        assert payout_count.scalar_one() == 1


@pytest.mark.asyncio
async def test_expire_worker_only_expires_due_active_acceptances(db_factory, monkeypatch):
    async with db_factory() as db:
        worker = await _worker(db, "expiry-worker")
        other_worker = await _worker(db, "active-worker")
        advertiser = await _advertiser(db, "expiry-advertiser")
        campaign = Campaign(
            owner_id=advertiser.id,
            title="Expiry task",
            platform="instagram",
            action_type="like",
            tni_service_type="single_one_time",
            cw_task_category="one_off_single",
            client_budget_kobo=1_000,
            client_price_per_action_kobo=1_000,
            worker_pay_per_action_kobo=600,
            escrow_kobo=0,
            slots_total=1,
            status="active",
        )
        db.add(campaign)
        await db.flush()
        task = Task(
            campaign_id=campaign.id,
            title="Expiry task",
            platform="instagram",
            action_type="like",
            cw_task_category="one_off_single",
            pay_kobo=600,
            slots_total=1,
            status="available",
        )
        db.add(task)
        await db.flush()
        expired = TaskAcceptance(
            task_id=task.id,
            worker_id=worker.id,
            expires_at=datetime.utcnow() - timedelta(minutes=1),
            status="active",
        )
        active = TaskAcceptance(
            task_id=task.id,
            worker_id=other_worker.id,
            expires_at=datetime.utcnow() + timedelta(minutes=10),
            status="active",
        )
        submitted = TaskAcceptance(
            task_id=task.id,
            worker_id=uuid.uuid4(),
            expires_at=datetime.utcnow() - timedelta(minutes=10),
            status="submitted",
        )
        # submitted worker needs an FK-backed user row.
        submitted_worker = await _worker(db, "submitted-worker")
        submitted.worker_id = submitted_worker.id
        db.add_all([expired, active, submitted])
        await db.commit()

    await submission_tasks._expire()

    async with db_factory() as db:
        rows = (await db.execute(select(TaskAcceptance).where(TaskAcceptance.task_id == task.id))).scalars().all()
        statuses = {row.worker_id: row.status for row in rows}
        assert statuses[worker.id] == "expired"
        assert statuses[other_worker.id] == "active"
        assert statuses[submitted_worker.id] == "submitted"
