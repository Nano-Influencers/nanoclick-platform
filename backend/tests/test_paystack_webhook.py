import hashlib
import hmac
import json
import uuid

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.config import settings
from app.main import app
from app.models.payment import Deposit, PaystackEvent
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.models.withdrawal import Withdrawal
from app.services import paystack


def _signature(payload: bytes) -> str:
    return hmac.new(settings.PAYSTACK_SECRET_KEY.encode(), payload, hashlib.sha512).hexdigest()


async def _post_webhook(payload: dict, event_id: str):
    raw = json.dumps(payload).encode()
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        return await client.post(
            "/wallet/webhooks/paystack",
            content=raw,
            headers={
                "content-type": "application/json",
                "x-paystack-signature": _signature(raw),
                "x-paystack-event-id": event_id,
            },
        )


async def _add_user_and_wallet(db, user_id: uuid.UUID, email_prefix: str, balance_kobo: int = 0):
    db.add(User(
        id=user_id,
        email=f"{email_prefix}-{uuid.uuid4().hex}@example.com",
        password_hash="test",
        full_name="Webhook Test User",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    ))
    db.add(Wallet(user_id=user_id, balance_kobo=balance_kobo))
    await db.flush()


@pytest.mark.asyncio
async def test_duplicate_charge_success_credits_wallet_once(db_factory, monkeypatch):
    user_id = uuid.uuid4()
    reference = "dep_webhook_idempotent_001"

    async with db_factory() as db:
        await _add_user_and_wallet(db, user_id, "webhook")
        db.add(Deposit(user_id=user_id, reference=reference, amount_kobo=10_000, status="pending"))
        await db.commit()

    async def verify_transaction(_reference):
        return {"status": "success", "amount": 10_000, "currency": "NGN"}

    monkeypatch.setattr(paystack, "verify_transaction", verify_transaction)

    payload = {
        "event": "charge.success",
        "data": {"reference": reference, "amount": 10_000, "currency": "NGN"},
    }
    first = await _post_webhook(payload, "evt_charge_001")
    second = await _post_webhook(payload, "evt_charge_001")

    assert first.status_code == 200
    assert second.status_code == 200
    assert second.json()["status"] == "duplicate"

    async with db_factory() as db:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        deposit = (await db.execute(select(Deposit).where(Deposit.reference == reference))).scalar_one()
        transactions = (await db.execute(select(Transaction).where(Transaction.reference == reference))).scalars().all()
        events = (await db.execute(select(PaystackEvent).where(PaystackEvent.event_id == "evt_charge_001"))).scalars().all()

        assert wallet.balance_kobo == 10_000
        assert deposit.status == "completed"
        assert len(transactions) == 1
        assert len(events) == 1


@pytest.mark.asyncio
async def test_transfer_success_is_idempotent(db_factory):
    user_id = uuid.uuid4()
    reference = "wdw_webhook_success_001"

    async with db_factory() as db:
        await _add_user_and_wallet(db, user_id, "transfer")
        db.add(Withdrawal(
            user_id=user_id, reference=reference, amount_kobo=5_000,
            account_number="0123456789", bank_code="058", account_name="Test Worker",
            status="processing",
        ))
        await db.commit()

    payload = {
        "event": "transfer.success",
        "data": {"reference": reference, "transfer_code": "TRF_success_001", "amount": 5_000},
    }

    first = await _post_webhook(payload, "evt_transfer_success_001")
    second = await _post_webhook(payload, "evt_transfer_success_002")

    assert first.status_code == 200
    assert second.status_code == 200

    async with db_factory() as db:
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        assert withdrawal.status == "successful"
        assert withdrawal.provider_reference == "TRF_success_001"


@pytest.mark.asyncio
async def test_transfer_failed_refunds_once_even_when_event_repeated(db_factory):
    user_id = uuid.uuid4()
    reference = "wdw_webhook_failed_001"

    async with db_factory() as db:
        await _add_user_and_wallet(db, user_id, "failed")
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        db.add(Transaction(wallet_id=wallet.id, type="withdrawal", amount_kobo=7_500, status="completed", reference=reference))
        db.add(Withdrawal(
            user_id=user_id, reference=reference, amount_kobo=7_500,
            account_number="0123456789", bank_code="058", account_name="Test Worker",
            status="processing",
        ))
        await db.commit()

    payload = {
        "event": "transfer.failed",
        "data": {"reference": reference, "transfer_code": "TRF_failed_001", "amount": 7_500, "reason": "Bank rejected transfer"},
    }

    first = await _post_webhook(payload, "evt_transfer_failed_001")
    second = await _post_webhook(payload, "evt_transfer_failed_002")

    assert first.status_code == 200
    assert second.status_code == 200

    async with db_factory() as db:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        reversals = (await db.execute(select(Transaction).where(Transaction.reference == f"{reference}:reversal"))).scalars().all()

        assert withdrawal.status == "failed"
        assert wallet.balance_kobo == 7_500
        assert len(reversals) == 1


@pytest.mark.asyncio
async def test_transfer_reversed_refunds_once(db_factory):
    user_id = uuid.uuid4()
    reference = "wdw_webhook_reversed_001"

    async with db_factory() as db:
        await _add_user_and_wallet(db, user_id, "reversed")
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        db.add(Transaction(wallet_id=wallet.id, type="withdrawal", amount_kobo=8_000, status="completed", reference=reference))
        db.add(Withdrawal(
            user_id=user_id, reference=reference, amount_kobo=8_000,
            account_number="0123456789", bank_code="058", account_name="Test Worker",
            status="processing",
        ))
        await db.commit()

    payload = {
        "event": "transfer.reversed",
        "data": {"reference": reference, "transfer_code": "TRF_reversed_001", "amount": 8_000},
    }

    response = await _post_webhook(payload, "evt_transfer_reversed_001")
    assert response.status_code == 200

    async with db_factory() as db:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        reversals = (await db.execute(select(Transaction).where(Transaction.reference == f"{reference}:reversal"))).scalars().all()
        assert withdrawal.status == "reversed"
        assert wallet.balance_kobo == 8_000
        assert len(reversals) == 1


@pytest.mark.asyncio
async def test_transfer_reversed_after_success_refunds_once(db_factory):
    user_id = uuid.uuid4()
    reference = "wdw_webhook_success_reversal_001"

    async with db_factory() as db:
        await _add_user_and_wallet(db, user_id, "success-reversal")
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        db.add(Transaction(wallet_id=wallet.id, type="withdrawal", amount_kobo=9_000, status="completed", reference=reference))
        db.add(Withdrawal(
            user_id=user_id, reference=reference, amount_kobo=9_000,
            account_number="0123456789", bank_code="058", account_name="Test Worker",
            status="successful", provider_reference="TRF_success_then_reversed",
        ))
        await db.commit()

    payload = {
        "event": "transfer.reversed",
        "data": {"reference": reference, "transfer_code": "TRF_success_then_reversed", "amount": 9_000},
    }

    first = await _post_webhook(payload, "evt_success_then_reversed_001")
    second = await _post_webhook(payload, "evt_success_then_reversed_002")

    assert first.status_code == 200
    assert second.status_code == 200

    async with db_factory() as db:
        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        withdrawal = (await db.execute(select(Withdrawal).where(Withdrawal.reference == reference))).scalar_one()
        reversals = (await db.execute(select(Transaction).where(Transaction.reference == f"{reference}:reversal"))).scalars().all()

        assert withdrawal.status == "reversed"
        assert wallet.balance_kobo == 9_000
        assert len(reversals) == 1
