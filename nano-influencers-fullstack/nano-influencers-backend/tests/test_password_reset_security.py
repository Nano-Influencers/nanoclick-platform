import uuid

import httpx
import pytest
from httpx import ASGITransport
from sqlalchemy import select

from app.dependencies import get_db
from app.main import app
from app.models.password_reset import PasswordResetToken
from app.models.user import User
from app.routers import auth as auth_router
from app.services.auth_service import hash_password, hash_token_identifier


@pytest.mark.asyncio
async def test_password_reset_uses_high_entropy_token_and_invalidates_previous(db, monkeypatch):
    user = User(
        email=f"reset-{uuid.uuid4()}@example.com",
        password_hash=hash_password("old-password"),
        full_name="Reset User",
        role="advertiser",
        referral_code=f"R{uuid.uuid4().hex[:10]}",
        email_verified=True,
    )
    db.add(user)
    await db.commit()
    sent = []

    async def capture_email(recipient, token):
        sent.append((recipient, token))

    monkeypatch.setattr(auth_router, "send_password_reset_email", capture_email)

    async def override_db():
        yield db

    app.dependency_overrides[get_db] = override_db
    try:
        async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            first = await client.post("/auth/forgot-password", json={"email": user.email.upper()})
            assert first.status_code == 200
            first_token = sent[-1][1]
            assert len(first_token) >= 40

            second = await client.post("/auth/forgot-password", json={"email": user.email})
            assert second.status_code == 200
            second_token = sent[-1][1]
            assert second_token != first_token

            stale = await client.post("/auth/reset-password", json={
                "token": first_token, "email": user.email, "new_password": "new-password-1"
            })
            assert stale.status_code == 400

            mismatch = await client.post("/auth/reset-password", json={
                "token": second_token, "email": "other@example.com", "new_password": "new-password-2"
            })
            assert mismatch.status_code == 400

            success = await client.post("/auth/reset-password", json={
                "token": second_token, "email": user.email.upper(), "new_password": "new-password-2"
            })
            assert success.status_code == 200
    finally:
        app.dependency_overrides.pop(get_db, None)

    rows = (await db.execute(select(PasswordResetToken).where(PasswordResetToken.user_id == user.id))).scalars().all()
    assert rows and all(row.used for row in rows)
    latest = next(row for row in rows if row.token == hash_token_identifier(second_token))
    assert latest.attempts == 2
