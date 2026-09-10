import uuid

import pytest
from sqlalchemy import select

from app.models.wallet import Transaction, Wallet
from app.services import wallet_service
from app.workers.celery_app import celery_app


@pytest.mark.asyncio
async def test_escrow_release_is_idempotent_for_duplicate_task_delivery(db_factory):
    advertiser_id = uuid.uuid4()
    worker_id = uuid.uuid4()
    reference = f"submission_{uuid.uuid4()}"

    async with db_factory() as db:
        advertiser = Wallet(user_id=advertiser_id, balance_kobo=0, escrow_kobo=50_000)
        worker = Wallet(user_id=worker_id, balance_kobo=0)
        db.add_all([advertiser, worker])
        await db.commit()

    async with db_factory() as db:
        first_adv_tx, first_worker_tx = await wallet_service.release_escrow_to_worker(
            db=db,
            advertiser_id=advertiser_id,
            worker_id=worker_id,
            amount_kobo=10_000,
            click_points=25,
            task_category="one_off_single",
            reference=reference,
        )
        await db.commit()
        assert first_adv_tx.reference == reference
        assert first_worker_tx.reference == reference

    async with db_factory() as db:
        second_adv_tx, second_worker_tx = await wallet_service.release_escrow_to_worker(
            db=db,
            advertiser_id=advertiser_id,
            worker_id=worker_id,
            amount_kobo=10_000,
            click_points=25,
            task_category="one_off_single",
            reference=reference,
        )
        await db.commit()
        assert second_adv_tx.id == first_adv_tx.id
        assert second_worker_tx.id == first_worker_tx.id

    async with db_factory() as db:
        advertiser = (await db.execute(select(Wallet).where(Wallet.user_id == advertiser_id))).scalar_one()
        worker = (await db.execute(select(Wallet).where(Wallet.user_id == worker_id))).scalar_one()
        escrow_releases = (await db.execute(select(Transaction).where(
            Transaction.reference == reference,
            Transaction.type == "escrow_release",
        ))).scalars().all()
        earnings = (await db.execute(select(Transaction).where(
            Transaction.reference == reference,
            Transaction.type == "task_earning",
        ))).scalars().all()

        assert advertiser.escrow_kobo == 40_000
        assert worker.balance_kobo == 10_000
        assert worker.total_earned_kobo == 10_000
        assert worker.click_points == 25
        assert len(escrow_releases) == 1
        assert len(earnings) == 1


def test_celery_delivery_is_configured_for_safe_redelivery():
    assert celery_app.conf.task_acks_late is True
    assert celery_app.conf.task_reject_on_worker_lost is True
    assert celery_app.conf.worker_prefetch_multiplier == 1
    assert celery_app.conf.task_time_limit == 900
    assert celery_app.conf.task_soft_time_limit == 840
    assert celery_app.conf.broker_transport_options["visibility_timeout"] == 3600
