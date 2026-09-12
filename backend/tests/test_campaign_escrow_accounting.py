import asyncio
import uuid

import pytest
from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import Campaign
from app.models.platform_wallet import PlatformWallet
from app.models.task import Submission, Task, TaskAcceptance
from app.models.user import User
from app.models.wallet import Wallet, Transaction
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

    acceptance_id = uuid.uuid4()
    acceptance = TaskAcceptance(
        id=acceptance_id,
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
        acceptance_id=acceptance_id,
        status="pending",
        proof_urls=[],
    )
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
    revenue_wallet = (await db.execute(
        select(PlatformWallet).where(PlatformWallet.wallet_key == "platform_revenue")
    )).scalar_one()

    assert campaign.escrow_kobo == 9_000
    assert adv_wallet.escrow_kobo == 9_000
    assert adv_wallet.balance_kobo == 90_000
    assert worker_wallet.balance_kobo == 600
    assert revenue_wallet.balance_kobo == 400
    assert adv_wallet.total_spent_kobo == 10_000
    assert worker_wallet.total_earned_kobo == 600


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


@pytest.mark.asyncio
async def test_task_payout_is_idempotent_for_same_reference(db: AsyncSession):
    advertiser = await _user(db, "advertiser", "idempotent-advertiser")
    worker = await _user(db, "worker", "idempotent-worker")
    db.add(Wallet(user_id=advertiser.id, balance_kobo=20_000))
    db.add(Wallet(user_id=worker.id, balance_kobo=0))
    await db.flush()

    await wallet_service.lock_escrow(db, advertiser.id, 10_000, reference=str(uuid.uuid4()))
    reference = str(uuid.uuid4())
    first = await wallet_service.release_escrow_to_worker(
        db, advertiser.id, worker.id, 600, 15, "one_off_single",
        reference=reference, client_charge_kobo=1_000,
    )
    second = await wallet_service.release_escrow_to_worker(
        db, advertiser.id, worker.id, 600, 15, "one_off_single",
        reference=reference, client_charge_kobo=1_000,
    )
    await db.commit()

    assert first[0].id == second[0].id
    assert first[1].id == second[1].id

    worker_wallet = (await db.execute(select(Wallet).where(Wallet.user_id == worker.id))).scalar_one()
    revenue_wallet = (await db.execute(
        select(PlatformWallet).where(PlatformWallet.wallet_key == "platform_revenue")
    )).scalar_one()
    task_transactions = (await db.execute(
        select(Transaction).where(Transaction.wallet_id == worker_wallet.id, Transaction.reference == reference)
    )).scalars().all()

    assert worker_wallet.balance_kobo == 600
    assert worker_wallet.total_earned_kobo == 600
    assert worker_wallet.click_points == 15
    assert revenue_wallet.balance_kobo == 400
    assert len(task_transactions) == 1


@pytest.mark.asyncio
async def test_concurrent_debits_allow_only_one_spend(db_factory):
    async with db_factory() as db:
        user = await _user(db, "worker", "concurrent-debit")
        db.add(Wallet(user_id=user.id, balance_kobo=100))
        await db.commit()
        user_id = user.id

    async def attempt(reference: str):
        async with db_factory() as session:
            try:
                await wallet_service.debit(
                    session, user_id, 100, "withdrawal", reference=reference
                )
                await session.commit()
                return "success"
            except HTTPException as exc:
                await session.rollback()
                return exc.status_code
            except IntegrityError:
                await session.rollback()
                return "integrity_error"

    results = await asyncio.gather(attempt("concurrent-a"), attempt("concurrent-b"))

    assert results.count("success") == 1
    assert results.count(400) == 1

    async with db_factory() as db:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        transactions = (await db.execute(
            select(Transaction).where(Transaction.wallet_id == wallet.id, Transaction.type == "withdrawal")
        )).scalars().all()
        assert wallet.balance_kobo == 0
        assert wallet.total_withdrawn_kobo == 100
        assert len(transactions) == 1


@pytest.mark.asyncio
async def test_wallet_database_rejects_negative_financial_state(db: AsyncSession):
    user = await _user(db, "worker", "negative-invariant")
    wallet = Wallet(user_id=user.id, balance_kobo=0)
    db.add(wallet)
    await db.flush()

    wallet.balance_kobo = -1
    with pytest.raises(IntegrityError):
        await db.flush()
    await db.rollback()
