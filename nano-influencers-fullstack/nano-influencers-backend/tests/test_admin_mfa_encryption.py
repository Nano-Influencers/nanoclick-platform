import uuid

import httpx
import pyotp
import pytest
from httpx import ASGITransport

from app.dependencies import get_current_user, get_db
from app.main import app
from app.models.user import User
from app.services.secret_encryption import decrypt_secret, encrypt_secret


@pytest.mark.asyncio
async def test_admin_mfa_secret_is_encrypted_at_rest_and_verifiable(db):
    secret = pyotp.random_base32()
    admin = User(
        email=f"mfa-{uuid.uuid4().hex}@example.com",
        full_name="MFA Admin",
        role="admin",
        referral_code=f"mfa{uuid.uuid4().hex[:12]}",
        mfa_secret=encrypt_secret(secret),
        mfa_enabled=False,
    )
    assert admin.mfa_secret != secret
    assert decrypt_secret(admin.mfa_secret) == secret
    db.add(admin)
    await db.commit()

    async def current_user():
        return admin

    async def db_session():
        yield db

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[get_db] = db_session
    try:
        async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/admin/mfa/enable", params={"code": pyotp.TOTP(secret).now()})
        assert response.status_code == 200
        assert admin.mfa_enabled is True
        assert admin.mfa_secret != secret
        assert decrypt_secret(admin.mfa_secret) == secret
    finally:
        app.dependency_overrides.pop(get_current_user, None)
        app.dependency_overrides.pop(get_db, None)
