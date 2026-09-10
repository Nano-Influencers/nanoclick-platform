import uuid

import pytest
from sqlalchemy import select

from app.models.wallet import Transaction, Wallet
from app.models.withdrawal import Withdrawal
from app.workers import payout_tasks


@pytest.mark.asyncio
async def test_reconciliation_keeps_provider_success_processing(db_factory, monkeypatch):
    user_id = uuid.uuid4()
    reference = "wdw_reconcile_success"

    async with db_factory() as db:
        db.add(Wallet(user_id=user_id, balance_kobo=50_000))
        db.add(
            Withdrawal(
                user_id=user_id,
                reference=reference,
                amount_kobo=20_000,
                account_number="0123456789",
                bank_code="058",
                account_name="Test Worker",
                status="processing",
            )
        )
        await db.commit()

    async def verify_transfer(_reference):
        return {"status": "success", "transfer_code": "TRF_test_001", "reference": reference}

    monkeypatch.setattr(payout_tasks.paystack, "verify_transfer", verify_transfer)

    result = await payout_tasks._reconcile_provider_transfer(reference)
    assert result is True

    async with db_factory() as db:
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        assert withdrawal.status == "processing"
        assert withdrawal.provider_reference == "TRF_test_001"


@pytest.mark.asyncio
async def test_reconciliation_failure_refunds_once(db_factory, monkeypatch):
    user_id = uuid.uuid4()
    reference = "wdw_reconcile_failed"

    async with db_factory() as db:
        wallet = Wallet(user_id=user_id, balance_kobo=10_000)
        db.add(wallet)
        await db.flush()
        db.add(
            Transaction(
                wallet_id=wallet.id,
                type="withdrawal",
                amount_kobo=10_000,
                status="completed",
                reference=reference,
            )
        )
        db.add(
            Withdrawal(
                user_id=user_id,
                reference=reference,
                amount_kobo=10_000,
                account_number="0123456789",
                bank_code="058",
                account_name="Test Worker",
                status="processing",
            )
        )
        wallet.balance_kobo = 0
        await db.commit()

    async def verify_transfer(_reference):
        return {"status": "failed", "transfer_code": "TRF_failed_001", "reference": reference, "failures": "Bank rejected transfer"}

    async def notify(*_args, **_kwargs):
        return None

    monkeypatch.setattr(payout_tasks.paystack, "verify_transfer", verify_transfer)
    monkeypatch.setattr(payout_tasks, "notify", notify, raising=False)

    result = await payout_tasks._reconcile_provider_transfer(reference)
    assert result is True

    async with db_factory() as db:
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        reversals = (await db.execute(select(Transaction).where(Transaction.reference == f"{reference}:reversal"))).scalars().all()

        assert withdrawal.status == "failed"
        assert wallet.balance_kobo == 10_000
        assert len(reversals) == 1


@pytest.mark.asyncio
async def test_reconciliation_is_idempotent_after_failure(db_factory, monkeypatch):
    user_id = uuid.uuid4()
    reference = "wdw_reconcile_idempotent"

    async with db_factory() as db:
        wallet = Wallet(user_id=user_id, balance_kobo=0)
        db.add(wallet)
        await db.flush()
        db.add(
            Transaction(
                wallet_id=wallet.id,
                type="withdrawal",
                amount_kobo=5_000,
                status="completed",
                reference=reference,
            )
        )
        db.add(
            Withdrawal(
                user_id=user_id,
                reference=reference,
                amount_kobo=5_000,
                account_number="0123456789",
                bank_code="058",
                account_name="Test Worker",
                status="failed",
            )
        )
        await db.commit()

    calls = 0

    async def verify_transfer(_reference):
        nonlocal calls
        calls += 1
        return {"status": "failed", "transfer_code": "TRF_failed_002", "reference": reference}

    monkeypatch.setattr(payout_tasks.paystack, "verify_transfer", verify_transfer)

    assert await payout_tasks._reconcile_provider_transfer(reference) is True
    assert calls == 1

    async with db_factory() as db:
        reversals = (await db.execute(select(Transaction).where(Transaction.reference == f"{reference}:reversal"))).scalars().all()
        assert len(reversals) == 0
