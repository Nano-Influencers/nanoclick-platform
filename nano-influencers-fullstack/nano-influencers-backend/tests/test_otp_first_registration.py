import uuid

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.dependencies import get_db
from app.main import app
from app.models.email_otp import EmailOTP
from app.models.user import User
from app.models.wallet import Wallet
from app.routers import auth as auth_router
from app.services.auth_service import create_access_token


@pytest.mark.asyncio
async def test_registration_does_not_write_user_until_email_otp_is_verified(db, monkeypatch):
    pending = {}
    sent_codes = {}
    locks = set()

    async def save_pending(email, payload):
        pending[email.lower()] = dict(payload)

    async def load_pending(email):
        value = pending.get(email.lower())
        return dict(value) if value else None

    async def delete_pending(email):
        pending.pop(email.lower(), None)

    async def acquire_lock(email, token):
        key = email.lower()
        if key in locks:
            return False
        locks.add(key)
        return True

    async def release_lock(email, token):
        locks.discard(email.lower())

    async def send_email(email, code):
        sent_codes[email.lower()] = code

    monkeypatch.setattr(auth_router, "save_pending_registration", save_pending)
    monkeypatch.setattr(auth_router, "load_pending_registration", load_pending)
    monkeypatch.setattr(auth_router, "delete_pending_registration", delete_pending)
    monkeypatch.setattr(auth_router, "acquire_pending_lock", acquire_lock)
    monkeypatch.setattr(auth_router, "release_pending_lock", release_lock)
    monkeypatch.setattr(auth_router, "send_verification_otp", send_email)

    async def override_db():
        yield db

    app.dependency_overrides[get_db] = override_db
    email = f"otp-first-{uuid.uuid4().hex}@example.com"
    try:
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            registration = await client.post("/auth/register", json={
                "email": email,
                "password": "correct-horse-battery",
                "full_name": "Adaeze Okafor",
                "role": "advertiser",
            })
            assert registration.status_code == 202
            assert registration.json()["email_sent"] is True

            # The pending registration exists only in the temporary store.
            assert email.lower() in pending
            assert (await db.execute(select(User).where(User.email == email))).scalar_one_or_none() is None
            assert (await db.execute(select(EmailOTP))).scalars().all() == []

            # The OTP cannot be verified against another email address.
            wrong_email = await client.post("/auth/otp/verify", json={
                "email": f"other-{uuid.uuid4().hex}@example.com",
                "code": sent_codes[email.lower()],
            })
            assert wrong_email.status_code == 400
            assert (await db.execute(select(User).where(User.email == email))).scalar_one_or_none() is None

            verified = await client.post("/auth/otp/verify", json={
                "email": email,
                "code": sent_codes[email.lower()],
            })
            assert verified.status_code == 200
            user = (await db.execute(select(User).where(User.email == email))).scalar_one()
            assert user.email == email
            assert user.full_name == "Adaeze Okafor"
            assert user.email_verified is True
            assert (await db.execute(select(Wallet).where(Wallet.user_id == user.id))).scalar_one_or_none() is not None
            assert email.lower() not in pending

            # A consumed OTP cannot be replayed.
            replay = await client.post("/auth/otp/verify", json={
                "email": email,
                "code": sent_codes[email.lower()],
            })
            assert replay.status_code == 400
    finally:
        app.dependency_overrides.pop(get_db, None)


@pytest.mark.asyncio
async def test_profile_phone_update_requires_auth_and_persists_name_and_phone(db):
    user = User(
        email=f"profile-{uuid.uuid4().hex}@example.com",
        password_hash="test-password-hash",
        full_name="Original Name",
        role="advertiser",
        referral_code=f"REF{uuid.uuid4().hex[:10]}",
    )
    db.add(user)
    db.add(Wallet(user_id=user.id))
    await db.flush()
    token = create_access_token(str(user.id), user.role)

    async def override_db():
        yield db

    app.dependency_overrides[get_db] = override_db
    try:
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            unauthenticated = await client.patch("/auth/me/profile", json={"phone_number": "+2348012345678"})
            assert unauthenticated.status_code == 401

            updated = await client.patch(
                "/auth/me/profile",
                headers={"Authorization": f"Bearer {token}"},
                json={"full_name": "New Profile Name", "phone_number": "+2348012345678"},
            )
            assert updated.status_code == 200
            assert updated.json()["full_name"] == "New Profile Name"
            assert updated.json()["phone_number"] == "+2348012345678"

            invalid_phone = await client.patch(
                "/auth/me/profile",
                headers={"Authorization": f"Bearer {token}"},
                json={"phone_number": "not-a-phone"},
            )
            assert invalid_phone.status_code == 422
    finally:
        app.dependency_overrides.pop(get_db, None)
