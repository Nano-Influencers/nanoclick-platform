import uuid

import httpx
import pyotp
import pytest
from httpx import ASGITransport

from app.dependencies import get_current_user, get_db, require_admin
from app.main import app
from app.models.user import User\nfrom starlette.requests import Request
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
        assert decrypt_secret(admin.mfa_secret) == secret\n        scope = {"type": "http", "method": "GET", "path": "/admin/dashboard", "headers": [(b"x-admin-mfa-code", pyotp.TOTP(secret).now().encode())], "query_string": b"", "scheme": "https", "server": ("api.example.com", 443), "client": ("127.0.0.1", 12345)}\n        authorized = await require_admin(Request(scope), current_user=admin)\n        assert authorized.id == admin.id
    finally:
        app.dependency_overrides.pop(get_current_user, None)
        app.dependency_overrides.pop(get_db, None)
