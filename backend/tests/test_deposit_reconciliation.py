from datetime import datetime
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.routers import wallet as wallet_router


class _Result:
    def __init__(self, value):
        self.value = value

    def scalar_one_or_none(self):
        return self.value


class _DB:
    def __init__(self, deposit):
        self.deposit = deposit
        self.execute_count = 0
        self.commits = 0

    async def execute(self, _query):
        self.execute_count += 1
        return _Result(self.deposit)

    async def commit(self):
        self.commits += 1


@pytest.mark.asyncio
async def test_deposit_status_returns_completed_without_provider_call(monkeypatch):
    user_id = uuid4()
    completed_at = datetime.utcnow()
    deposit = SimpleNamespace(
        reference="dep_1234567890abcdef",
        user_id=user_id,
        amount_kobo=250000,
        status="completed",
        created_at=datetime.utcnow(),
        completed_at=completed_at,
    )
    db = _DB(deposit)

    async def fail_verify(_reference):
        raise AssertionError("terminal deposits must not call Paystack")

    monkeypatch.setattr(wallet_router.paystack, "verify_transaction", fail_verify)

    response = await wallet_router.get_deposit_status(
        deposit.reference,
        SimpleNamespace(id=user_id),
        db,
    )

    assert response["reference"] == deposit.reference
    assert response["status"] == "completed"
    assert response["amount_ngn"] == 2500
    assert response["completed_at"] == completed_at.isoformat()
    assert db.commits == 0


@pytest.mark.asyncio
async def test_pending_deposit_is_credited_once_when_provider_reports_success(monkeypatch):
    user_id = uuid4()
    deposit = SimpleNamespace(
        reference="dep_1234567890abcdef",
        user_id=user_id,
        amount_kobo=125000,
        status="pending",
        created_at=datetime.utcnow(),
        completed_at=None,
    )
    db = _DB(deposit)
    credits = []

    async def verify(_reference):
        return {"status": "success", "amount": 125000, "currency": "NGN"}

    async def credit(db_arg, user_id_arg, amount_kobo, tx_type, **kwargs):
        credits.append((db_arg, user_id_arg, amount_kobo, tx_type, kwargs["reference"]))

    async def notify(*_args, **_kwargs):
        return None

    monkeypatch.setattr(wallet_router.paystack, "verify_transaction", verify)
    monkeypatch.setattr(wallet_router.wallet_service, "credit", credit)
    monkeypatch.setattr("app.services.notification_service.notify", notify)

    response = await wallet_router.get_deposit_status(
        deposit.reference,
        SimpleNamespace(id=user_id),
        db,
    )

    assert response["status"] == "completed"
    assert deposit.status == "completed"
    assert deposit.completed_at is not None
    assert credits == [(db, user_id, 125000, "deposit", deposit.reference)]
    assert db.commits == 1


@pytest.mark.asyncio
async def test_pending_deposit_stays_pending_when_provider_check_is_unavailable(monkeypatch):
    user_id = uuid4()
    deposit = SimpleNamespace(
        reference="dep_1234567890abcdef",
        user_id=user_id,
        amount_kobo=50000,
        status="pending",
        created_at=datetime.utcnow(),
        completed_at=None,
    )
    db = _DB(deposit)

    async def verify(_reference):
        raise RuntimeError("provider unavailable")

    monkeypatch.setattr(wallet_router.paystack, "verify_transaction", verify)

    response = await wallet_router.get_deposit_status(
        deposit.reference,
        SimpleNamespace(id=user_id),
        db,
    )

    assert response["status"] == "pending"
    assert db.commits == 0
