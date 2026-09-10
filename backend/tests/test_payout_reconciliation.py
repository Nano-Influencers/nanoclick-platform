import uuid

import pytest
from sqlalchemy import select

from app.models.user import User
from app.models.wallet import Transaction, Wallet
from app.models.withdrawal import Withdrawal
from app.services import paystack
from app.services import notification_service
from app.workers import payout_tasks


async def _user(db, user_id):
    user = User(
        id=user_id,
        email=f"payout-{uuid.uuid4().hex}@example.com",
        password_hash="test",
        full_name="Payout Test User",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_reconciliation_keeps_provider_success_processing(db_factory, monkeypatch):
    user_id = uuid.uuid4()
    reference = "wdw_reconcile_success"

    async with db_factory() as db:
        await _user(db, user_id)
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

    monkeypatch.setattr(paystack, "verify_transfer", verify_transfer)

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
        await _user(db, user_id)
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

    monkeypatch.setattr(paystack, "verify_transfer", verify_transfer)
    monkeypatch.setattr(notification_service, "notify", notify)

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
        await _user(db, user_id)
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

    monkeypatch.setattr(paystack, "verify_transfer", verify_transfer)

    assert await payout_tasks._reconcile_provider_transfer(reference) is True
    assert calls == 1

    async with db_factory() as db:
        reversals = (await db.execute(select(Transaction).where(Transaction.reference == f"{reference}:reversal"))).scalars().all()
        assert len(reversals) == 0


@pytest.mark.asyncio
async def test_duplicate_worker_delivery_reconciles_before_second_transfer(db_factory, monkeypatch):
    user_id = uuid.uuid4()
    reference = "wdw_duplicate_delivery_001"

    async with db_factory() as db:
        await _user(db, user_id)
        db.add(
            Withdrawal(
                user_id=user_id,
                reference=reference,
                amount_kobo=6_000,
                account_number="0123456789",
                bank_code="058",
                account_name="Test Worker",
                status="requested",
            )
        )
        await db.commit()

    initiate_calls = 0
    verify_calls = 0

    async def create_recipient(*_args):
        return "RCP_duplicate_test"

    async def initiate_transfer(_amount, _recipient, _reference):
        nonlocal initiate_calls
        initiate_calls += 1
        return {"status": "pending", "transfer_code": "TRF_duplicate_test", "reference": reference}

    async def verify_transfer(_reference):
        nonlocal verify_calls
        verify_calls += 1
        if verify_calls == 1:
            raise RuntimeError("transfer not visible yet")
        return {"status": "success", "transfer_code": "TRF_duplicate_test", "reference": reference}

    monkeypatch.setattr(paystack, "create_transfer_recipient", create_recipient)
    monkeypatch.setattr(paystack, "initiate_transfer", initiate_transfer)
    monkeypatch.setattr(paystack, "verify_transfer", verify_transfer)

    await payout_tasks._do_withdrawal(
        str(user_id), 6_000, reference, "0123456789", "058", "Test Worker"
    )
    await payout_tasks._do_withdrawal(
        str(user_id), 6_000, reference, "0123456789", "058", "Test Worker"
    )

    assert initiate_calls == 1
    assert verify_calls == 2

    async with db_factory() as db:
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        assert withdrawal.status == "processing"
        assert withdrawal.provider_reference == "TRF_duplicate_test"
