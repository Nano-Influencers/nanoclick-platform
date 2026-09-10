import uuid

import pytest
from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import Campaign
from app.models.task import Submission, Task
from app.models.user import User
from app.models.wallet import Wallet
from app.services import wallet_service


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
async def test_task_payout_consumes_client_price_and_preserves_margin(db: AsyncSession):
    advertiser = await _user(db, "advertiser", "advertiser")
    worker = await _user(db, "worker", "worker")
    db.add(Wallet(user_id=advertiser.id, balance_kobo=100_000))
    db.add(Wallet(user_id=worker.id, balance_kobo=0))
    await db.flush()

    campaign = Campaign(
        owner_id=advertiser.id,
        title="Escrow test",
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
    )
    db.add(task)
    await db.flush()

    submission = Submission(
        task_id=task.id,
        worker_id=worker.id,
        acceptance_id=uuid.uuid4(),
        status="pending",
        proof_urls=[],
    )
    # The FK to task_acceptances is required by the schema, so create a valid
    # acceptance row for the submission.
    from app.models.task import TaskAcceptance
    acceptance = TaskAcceptance(
        id=submission.acceptance_id,
        task_id=task.id,
        worker_id=worker.id,
        expires_at=campaign.created_at,
        status="submitted",
    )
    db.add(acceptance)
    db.add(submission)
    await db.flush()

    await wallet_service.lock_escrow(db, advertiser.id, 10_000, reference=str(campaign.id))
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
    adv_wallet = (await db.execute(select(Wallet).where(Wallet.user_id == advertiser.id))).scalar_one()
    worker_wallet = (await db.execute(select(Wallet).where(Wallet.user_id == worker.id))).scalar_one()

    assert campaign.escrow_kobo == 9_000
    assert adv_wallet.escrow_kobo == 9_000
    assert adv_wallet.balance_kobo == 90_000
    assert worker_wallet.balance_kobo == 600


@pytest.mark.asyncio
async def test_task_payout_rejects_insufficient_campaign_escrow(db: AsyncSession):
    advertiser = await _user(db, "advertiser", "advertiser")
    worker = await _user(db, "worker", "worker")
    db.add(Wallet(user_id=advertiser.id, balance_kobo=10_000))
    db.add(Wallet(user_id=worker.id, balance_kobo=0))
    await db.flush()

    campaign = Campaign(
        owner_id=advertiser.id,
        title="Insufficient escrow",
        platform="instagram",
        action_type="like",
        tni_service_type="single_one_time",
        cw_task_category="one_off_single",
        client_budget_kobo=500,
        client_price_per_action_kobo=1_000,
        worker_pay_per_action_kobo=600,
        escrow_kobo=500,
        slots_total=1,
        status="active",
    )
    db.add(campaign)
    await db.flush()

    with pytest.raises(HTTPException) as exc:
        await wallet_service.release_escrow_to_worker(
            db,
            advertiser.id,
            worker.id,
            600,
            click_points=0,
            task_category="one_off_single",
            reference=str(uuid.uuid4()),
            client_charge_kobo=1_000,
        )
    assert exc.value.status_code in (400, 409)
