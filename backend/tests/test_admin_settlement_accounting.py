import uuid

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import Campaign
from app.models.task import Submission, Task, TaskAcceptance
from app.models.user import User
from app.models.wallet import Wallet
from app.services import wallet_service
from app.routers.admin_lifecycle import approve_submission_lifecycle


async def _user(db: AsyncSession, role: str, suffix: str) -> User:
    user = User(
        email=f"{suffix}-{uuid.uuid4()}@example.com",
        full_name=suffix,
        role=role,
        referral_code=str(uuid.uuid4())[:12],
    )
    db.add(user)
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_admin_submission_approval_decrements_campaign_escrow_once(
    db: AsyncSession, monkeypatch
):
    advertiser = await _user(db, "advertiser", "admin-settlement-advertiser")
    worker = await _user(db, "worker", "admin-settlement-worker")
    db.add(Wallet(user_id=advertiser.id, balance_kobo=20_000))
    db.add(Wallet(user_id=worker.id, balance_kobo=0))
    await db.flush()

    campaign = Campaign(
        owner_id=advertiser.id,
        title="Admin settlement escrow",
        platform="instagram",
        action_type="like",
        tni_service_type="single_one_time",
        cw_task_category="one_off_single",
        client_budget_kobo=10_000,
        client_price_per_action_kobo=1_000,
        worker_pay_per_action_kobo=600,
        escrow_kobo=10_000,
        slots_total=10,
        status="active",
    )
    db.add(campaign)
    await db.flush()

    task = Task(
        campaign_id=campaign.id,
        title="Like",
        platform="instagram",
        action_type="like",
        cw_task_category="one_off_single",
        pay_kobo=600,
        slots_total=10,
        status="available",
    )
    db.add(task)
    await db.flush()

    acceptance = TaskAcceptance(
        id=uuid.uuid4(),
        task_id=task.id,
        worker_id=worker.id,
        expires_at=campaign.created_at,
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
    )
    db.add(submission)
    await db.flush()

    await wallet_service.lock_escrow(
        db, advertiser.id, 10_000, reference=str(campaign.id)
    )

    async def noop_referral(*args, **kwargs):
        return None

    async def noop_notify(*args, **kwargs):
        return None

    monkeypatch.setattr(
        "app.services.rewards_service.award_referral_bonus_if_first_approval",
        noop_referral,
    )
    monkeypatch.setattr("app.services.notification_service.notify", noop_notify)

    await approve_submission_lifecycle(submission.id, db=db, _=advertiser)
    await db.commit()

    await db.refresh(campaign)
    advertiser_wallet = (
        await db.execute(select(Wallet).where(Wallet.user_id == advertiser.id))
    ).scalar_one()

    assert campaign.escrow_kobo == 9_000
    assert advertiser_wallet.escrow_kobo == 9_000
    assert advertiser_wallet.balance_kobo == 10_000
