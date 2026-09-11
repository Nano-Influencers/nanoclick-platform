import uuid

import httpx
import pytest
from httpx import ASGITransport

from app.dependencies import get_db
from app.main import app
from app.models.user import User
from app.models.wallet import Wallet
from app.services.auth_service import hash_password


@pytest.mark.asyncio
async def test_web_login_uses_httponly_refresh_cookie_without_returning_refresh_token(db):
    user = User(
        email=f"cookie-{uuid.uuid4()}@example.com",
        password_hash=hash_password("correct-password"),
        full_name="Cookie Test",
        role="worker",
        referral_code=f"REF{uuid.uuid4().hex[:8]}",
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id))
    await db.commit()

    async def override_db():
        yield db

    app.dependency_overrides[get_db] = override_db
    try:
        async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            login = await client.post(
                "/auth/login?platform=web",
                json={"email": user.email, "password": "correct-password"},
            )
            assert login.status_code == 200
            payload = login.json()
            assert payload["access_token"]
            assert payload.get("refresh_token") is None

            set_cookie = login.headers.get("set-cookie", "")
            assert "nanoclick_refresh=" in set_cookie
            assert "HttpOnly" in set_cookie
            assert "Path=/auth" in set_cookie

            refresh = await client.post("/auth/refresh?platform=web")
            assert refresh.status_code == 200
            assert refresh.json()["access_token"]
            assert refresh.json().get("refresh_token") is None

            logout = await client.post("/auth/logout?platform=web")
            assert logout.status_code == 200
            assert "nanoclick_refresh=" in logout.headers.get("set-cookie", "")
    finally:
        app.dependency_overrides.pop(get_db, None)
