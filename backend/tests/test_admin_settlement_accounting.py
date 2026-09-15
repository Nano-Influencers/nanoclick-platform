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


async def _approval_fixture(db: AsyncSession, *, budget_kobo: int, price_kobo: int, slots: int):
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
        client_budget_kobo=budget_kobo,
        client_price_per_action_kobo=price_kobo,
        worker_pay_per_action_kobo=600,
        escrow_kobo=budget_kobo,
        slots_total=slots,
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
        slots_total=slots,
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
        db, advertiser.id, budget_kobo, reference=str(campaign.id)
    )
    return advertiser, worker, campaign, task, submission


@pytest.mark.asyncio
async def test_admin_submission_approval_decrements_campaign_escrow_once(
    db: AsyncSession, monkeypatch
):
    advertiser, worker, campaign, task, submission = await _approval_fixture(
        db, budget_kobo=10_000, price_kobo=1_000, slots=10
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


@pytest.mark.asyncio
async def test_admin_final_submission_refunds_unused_campaign_remainder(
    db: AsyncSession, monkeypatch
):
    # 10,050 kobo funds 10 x 1,000-kobo slots, leaving a 50-kobo remainder
    # that must return to the advertiser when the final slot is settled.
    advertiser, worker, campaign, task, submission = await _approval_fixture(
        db, budget_kobo=10_050, price_kobo=1_000, slots=10
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

    # Pre-set counters to the final slot so this approval exercises the
    # completion/refund branch without needing nine separate submissions.
    campaign.slots_filled = 9
    task.slots_filled = 9
    await approve_submission_lifecycle(submission.id, db=db, _=advertiser)
    await db.commit()

    await db.refresh(campaign)
    advertiser_wallet = (
        await db.execute(select(Wallet).where(Wallet.user_id == advertiser.id))
    ).scalar_one()

    assert campaign.status == "completed"
    assert campaign.slots_filled == campaign.slots_total == 10
    assert campaign.escrow_kobo == 0
    assert advertiser_wallet.escrow_kobo == 0
    # Initial 20,000 balance - 10,050 escrow lock + 50 remainder refund.
    assert advertiser_wallet.balance_kobo == 10_000
    assert advertiser_wallet.total_spent_kobo == 10_000
