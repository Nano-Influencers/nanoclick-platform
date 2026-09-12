import uuid
from datetime import datetime, timedelta

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import Campaign
from app.models.task import Submission, Task, TaskAcceptance
from app.models.user import User
from app.models.wallet import Wallet
from app.routers.tasks import accept_task, submit_task
from app.schemas.task import SubmissionCreate
from app.services import wallet_service


async def _user(db: AsyncSession, role: str, name: str) -> User:
    user = User(
        email=f"{name}-{uuid.uuid4()}@example.com",
        full_name=name,
        role=role,
        referral_code=str(uuid.uuid4())[:12],
    )
    db.add(user)
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_accept_submit_and_payout_preserves_task_capacity_and_escrow(db: AsyncSession):
    advertiser = await _user(db, "advertiser", "flow-advertiser")
    worker = await _user(db, "worker", "flow-worker")
    db.add(Wallet(user_id=advertiser.id, balance_kobo=100_000))
    db.add(Wallet(user_id=worker.id, balance_kobo=0))

    campaign = Campaign(
        owner_id=advertiser.id,
        title="End-to-end flow",
        platform="instagram",
        action_type="like",
        tni_service_type="single_one_time",
        cw_task_category="one_off_single",
        client_budget_kobo=2_000,
        client_price_per_action_kobo=1_000,
        worker_pay_per_action_kobo=600,
        escrow_kobo=2_000,
        slots_total=2,
        status="active",
    )
    db.add(campaign)
    await db.flush()

    task = Task(
        campaign_id=campaign.id,
        title="Like a post",
        platform="instagram",
        action_type="like",
        cw_task_category="one_off_single",
        pay_kobo=600,
        slots_total=2,
        status="available",
    )
    db.add(task)
    await db.flush()

    await wallet_service.lock_escrow(
        db, advertiser.id, 2_000, reference=str(campaign.id)
    )

    accepted = await accept_task(task.id, worker, db)
    assert accepted.task_id == task.id

    await db.refresh(task)
    assert task.slots_filled == 0
    reservation_count = await db.execute(
        select(TaskAcceptance).where(
            TaskAcceptance.task_id == task.id,
            TaskAcceptance.status == "active",
        )
    )
    assert len(reservation_count.scalars().all()) == 1

    acceptance = (
        await db.execute(
            select(TaskAcceptance).where(
                TaskAcceptance.task_id == task.id,
                TaskAcceptance.worker_id == worker.id,
                TaskAcceptance.status == "active",
            )
        )
    ).scalar_one()
    # The normal submission path flags unrealistically fast submissions for review.
    # Move the acceptance clock forward so this financial-flow test exercises the
    # ordinary pending -> payout path instead of the anti-abuse branch.
    acceptance.accepted_at = datetime.utcnow() - timedelta(minutes=5)
    await db.flush()

    submitted = await submit_task(
        task.id,
        SubmissionCreate(proof_urls=[], proof_link="https://example.com/proof"),
        worker,
        db,
    )
    assert submitted.status == "pending"

    submission = (
        await db.execute(select(Submission).where(Submission.id == uuid.UUID(submitted.id)))
    ).scalar_one()
    acceptance = (
        await db.execute(
            select(TaskAcceptance).where(TaskAcceptance.id == submission.acceptance_id)
        )
    ).scalar_one()
    assert acceptance.status == "submitted"

    await wallet_service.release_escrow_to_worker(
        db,
        advertiser.id,
        worker.id,
        600,
        click_points=0,
        task_category="one_off_single",
        reference=str(submission.id),
    )
    await db.commit()

    await db.refresh(campaign)
    await db.refresh(task)
    advertiser_wallet = (
        await db.execute(select(Wallet).where(Wallet.user_id == advertiser.id))
    ).scalar_one()
    worker_wallet = (
        await db.execute(select(Wallet).where(Wallet.user_id == worker.id))
    ).scalar_one()

    assert campaign.escrow_kobo == 1_000
    assert advertiser_wallet.escrow_kobo == 1_000
    assert advertiser_wallet.balance_kobo == 98_000
    assert worker_wallet.balance_kobo == 600
    assert task.slots_filled == 0


@pytest.mark.asyncio
async def test_expired_acceptance_cannot_submit(db: AsyncSession):
    worker = await _user(db, "worker", "expired-worker")
    advertiser = await _user(db, "advertiser", "expired-advertiser")
    db.add(Wallet(user_id=advertiser.id, balance_kobo=100_000))
    db.add(Wallet(user_id=worker.id, balance_kobo=0))
    campaign = Campaign(
        owner_id=advertiser.id,
        title="Expired acceptance",
        platform="instagram",
        action_type="like",
        tni_service_type="single_one_time",
        cw_task_category="one_off_single",
        client_budget_kobo=1_000,
        client_price_per_action_kobo=500,
        worker_pay_per_action_kobo=300,
        escrow_kobo=1_000,
        slots_total=1,
        status="active",
    )
    db.add(campaign)
    await db.flush()
    task = Task(
        campaign_id=campaign.id,
        title="Expired task",
        platform="instagram",
        action_type="like",
        cw_task_category="one_off_single",
        pay_kobo=300,
        slots_total=1,
        status="available",
    )
    db.add(task)
    await db.flush()
    acceptance = TaskAcceptance(
        task_id=task.id,
        worker_id=worker.id,
        accepted_at=datetime.utcnow() - timedelta(hours=1),
        expires_at=datetime.utcnow() - timedelta(minutes=1),
        status="active",
    )
    db.add(acceptance)
    await db.flush()

    with pytest.raises(Exception):
        await submit_task(
            task.id,
            SubmissionCreate(proof_urls=[], proof_link="https://example.com/proof"),
            worker,
            db,
        )
