import asyncio
import json
import uuid

import httpx
import pytest
from sqlalchemy import func, select

from app.database import get_db
from app.dependencies import get_current_user, require_worker
from app.main import app
from app.models.payment import Deposit, PaystackEvent
from app.models.user import User
from app.models.wallet import Transaction, Wallet
from app.models.withdrawal import Withdrawal
from app.services import paystack, wallet_service


async def create_worker(db, balance_kobo=0):
    user = User(
        email=f"integration-{uuid.uuid4().hex}@example.com",
        full_name="Integration Worker",
        role="worker",
        referral_code=f"it{uuid.uuid4().hex[:14]}",
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id, balance_kobo=balance_kobo))
    await db.commit()
    return user


async def client_for(user, db):
    async def current_user():
        return user

    async def worker_user():
        return user

    async def session():
        yield db

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[require_worker] = worker_user
    app.dependency_overrides[get_db] = session
    return httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test")


@pytest.fixture(autouse=True)
def clear_overrides():
    app.dependency_overrides.clear()
    yield
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_deposit_idempotency_prevents_duplicate_provider_initialization(db, monkeypatch):
    user = await create_worker(db)
    calls = 0

    async def initialize(email, amount_kobo, reference):
        nonlocal calls
        calls += 1
        return {"authorization_url": f"https://paystack.test/{reference}"}

    monkeypatch.setattr(paystack, "initialize_transaction", initialize)
    client = await client_for(user, db)
    try:
        first = await client.post("/wallet/deposit/initialize", json={"amount_ngn": "2500.00"}, headers={"Idempotency-Key": "dep-retry"})
        second = await client.post("/wallet/deposit/initialize", json={"amount_ngn": "2500.00"}, headers={"Idempotency-Key": "dep-retry"})
        conflict = await client.post("/wallet/deposit/initialize", json={"amount_ngn": "2600.00"}, headers={"Idempotency-Key": "dep-retry"})
    finally:
        await client.aclose()

    assert first.status_code == second.status_code == 200
    assert first.json() == second.json()
    assert conflict.status_code == 409
    assert calls == 1
    assert await db.scalar(select(func.count(Deposit.id)).where(Deposit.user_id == user.id)) == 1


@pytest.mark.asyncio
async def test_successful_deposit_webhook_credits_once_and_duplicate_event_is_ignored(db, monkeypatch):
    user = await create_worker(db)
    deposit = Deposit(user_id=user.id, reference=f"dep_{uuid.uuid4().hex[:16]}", amount_kobo=500_000, status="pending")
    db.add(deposit)
    await db.commit()

    monkeypatch.setattr(paystack, "verify_webhook_signature", lambda payload, signature: True)
    async def verify(reference):
        return {"status": "success", "amount": 500_000, "currency": "NGN"}
    monkeypatch.setattr(paystack, "verify_transaction", verify)

    client = await client_for(user, db)
    payload = {"event": "charge.success", "data": {"reference": deposit.reference, "amount": 500_000, "currency": "NGN"}}
    headers = {"x-paystack-signature": "test", "x-paystack-event-id": "evt-1"}
    try:
        first = await client.post("/wallet/webhooks/paystack", content=json.dumps(payload), headers=headers)
        duplicate = await client.post("/wallet/webhooks/paystack", content=json.dumps(payload), headers=headers)
    finally:
        await client.aclose()

    assert first.status_code == 200
    assert duplicate.status_code == 200
    assert duplicate.json() == {"status": "duplicate"}
    wallet = await db.scalar(select(Wallet).where(Wallet.user_id == user.id))
    assert wallet.balance_kobo == 500_000
    assert await db.scalar(select(func.count(Transaction.id)).where(Transaction.wallet_id == wallet.id, Transaction.type == "deposit")) == 1
    assert deposit.status == "completed"


@pytest.mark.asyncio
async def test_deposit_webhook_rejects_amount_mismatch_without_crediting(db, monkeypatch):
    user = await create_worker(db)
    deposit = Deposit(user_id=user.id, reference=f"dep_{uuid.uuid4().hex[:16]}", amount_kobo=500_000, status="pending")
    db.add(deposit)
    await db.commit()
    monkeypatch.setattr(paystack, "verify_webhook_signature", lambda payload, signature: True)

    client = await client_for(user, db)
    payload = {"event": "charge.success", "data": {"reference": deposit.reference, "amount": 499_999, "currency": "NGN"}}
    try:
        response = await client.post("/wallet/webhooks/paystack", content=json.dumps(payload), headers={"x-paystack-signature": "test", "x-paystack-event-id": "evt-mismatch"})
    finally:
        await client.aclose()

    assert response.status_code == 400
    wallet = await db.scalar(select(Wallet).where(Wallet.user_id == user.id))
    assert wallet.balance_kobo == 0
    assert deposit.status == "pending"


@pytest.mark.asyncio
async def test_withdrawal_idempotency_debits_only_once(db, monkeypatch):
    user = await create_worker(db, 100_000)

    async def resolve(account_number, bank_code):
        return {"account_number": account_number, "account_name": "Test Worker", "bank_code": bank_code}
    monkeypatch.setattr(paystack, "resolve_account_number", resolve)

    import app.workers.payout_tasks as payout_tasks
    monkeypatch.setattr(payout_tasks.process_withdrawal, "delay", lambda *args, **kwargs: None)

    client = await client_for(user, db)
    request = {"amount_ngn": "500.00", "bank_code": "058", "account_number": "0123456789"}
    headers = {"Idempotency-Key": "wd-retry"}
    try:
        first = await client.post("/wallet/withdraw", json=request, headers=headers)
        second = await client.post("/wallet/withdraw", json=request, headers=headers)
        conflict = await client.post("/wallet/withdraw", json={**request, "amount_ngn": "600.00"}, headers=headers)
    finally:
        await client.aclose()

    assert first.status_code == second.status_code == 200
    assert first.json()["reference"] == second.json()["reference"]
    assert conflict.status_code == 409
    wallet = await db.scalar(select(Wallet).where(Wallet.user_id == user.id))
    assert wallet.balance_kobo == 50_000
    assert await db.scalar(select(func.count(Withdrawal.id)).where(Withdrawal.user_id == user.id)) == 1
    assert await db.scalar(select(func.count(Transaction.id)).where(Transaction.wallet_id == wallet.id, Transaction.type == "withdrawal")) == 1


@pytest.mark.asyncio
async def test_concurrent_debits_cannot_overdraw_wallet(db_factory):
    user_id = uuid.uuid4()
    setup = db_factory()
    setup.add(User(id=user_id, email=f"concurrency-{uuid.uuid4().hex}@example.com", full_name="Concurrency Worker", role="worker", referral_code=f"cc{uuid.uuid4().hex[:14]}"))
    setup.add(Wallet(user_id=user_id, balance_kobo=75_000))
    await setup.commit()
    await setup.close()

    async def attempt(reference):
        session = db_factory()
        try:
            await wallet_service.debit(session, user_id, 50_000, "withdrawal", reference=reference)
            await session.commit()
            return "success"
        except Exception as exc:
            await session.rollback()
            return type(exc).__name__
        finally:
            await session.close()

    results = await asyncio.gather(attempt("concurrent-a"), attempt("concurrent-b"))
    assert results.count("success") == 1
    assert results.count("HTTPException") == 1

    check = db_factory()
    try:
        wallet = await check.scalar(select(Wallet).where(Wallet.user_id == user_id))
        assert wallet.balance_kobo == 25_000
        assert await check.scalar(select(func.count(Transaction.id)).where(Transaction.wallet_id == wallet.id, Transaction.type == "withdrawal")) == 1
    finally:
        await check.close()


@pytest.mark.asyncio
async def test_failed_transfer_reverses_debit_once_even_for_multiple_events(db, monkeypatch):
    user = await create_worker(db)
    wallet = await db.scalar(select(Wallet).where(Wallet.user_id == user.id))
    reference = f"wdw_{uuid.uuid4().hex[:16]}"
    db.add(Withdrawal(user_id=user.id, reference=reference, amount_kobo=75_000, account_number="0123456789", bank_code="058", account_name="Test Worker", status="processing", provider_reference="trf_1"))
    db.add(Transaction(wallet_id=wallet.id, type="withdrawal", amount_kobo=75_000, status="completed", reference=reference, description="Withdrawal"))
    await db.commit()
    monkeypatch.setattr(paystack, "verify_webhook_signature", lambda payload, signature: True)

    client = await client_for(user, db)
    payload = {"event": "transfer.failed", "data": {"reference": reference, "amount": 75_000, "transfer_code": "trf_1", "reason": "Bank rejected transfer"}}
    try:
        first = await client.post("/wallet/webhooks/paystack", content=json.dumps(payload), headers={"x-paystack-signature": "test", "x-paystack-event-id": "evt-fail-1"})
        second = await client.post("/wallet/webhooks/paystack", content=json.dumps(payload), headers={"x-paystack-signature": "test", "x-paystack-event-id": "evt-fail-2"})
    finally:
        await client.aclose()

    assert first.status_code == second.status_code == 200
    await db.refresh(wallet)
    assert wallet.balance_kobo == 75_000
    assert await db.scalar(select(func.count(Transaction.id)).where(Transaction.wallet_id == wallet.id, Transaction.type == "withdrawal_reversal", Transaction.reference == f"{reference}:reversal")) == 1


@pytest.mark.asyncio
async def test_invalid_webhook_signature_has_no_side_effects(db, monkeypatch):
    user = await create_worker(db)
    deposit = Deposit(user_id=user.id, reference=f"dep_{uuid.uuid4().hex[:16]}", amount_kobo=100_000, status="pending")
    db.add(deposit)
    await db.commit()
    monkeypatch.setattr(paystack, "verify_webhook_signature", lambda payload, signature: False)

    client = await client_for(user, db)
    payload = {"event": "charge.success", "data": {"reference": deposit.reference, "amount": 100_000, "currency": "NGN"}}
    try:
        response = await client.post("/wallet/webhooks/paystack", content=json.dumps(payload), headers={"x-paystack-signature": "bad"})
    finally:
        await client.aclose()

    assert response.status_code == 401
    assert await db.scalar(select(func.count(PaystackEvent.id)).where(PaystackEvent.reference == deposit.reference)) == 0
    wallet = await db.scalar(select(Wallet).where(Wallet.user_id == user.id))
    assert wallet.balance_kobo == 0
