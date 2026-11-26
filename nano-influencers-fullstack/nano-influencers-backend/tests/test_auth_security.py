import uuid
from datetime import datetime, timedelta

import pytest
from fastapi import HTTPException
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.main import app
from app.models.auth_session import AuthSession, OAuthCode, OAuthState
from app.models.user import User
from app.models.wallet import Wallet
from app.routers.auth import _consume_oauth_state, _create_refresh_session, _set_refresh_cookie
from app.config import settings
from app.services.auth_service import (
    create_access_token,
    create_refresh_token,
    hash_token_identifier,
    new_oauth_state,
    token_jti,
    hash_password,
)


async def _add_user(db, role: str = "worker") -> User:
    user = User(
        id=uuid.uuid4(),
        email=f"auth-{uuid.uuid4().hex}@example.com",
        password_hash="test-password-hash",
        full_name="Auth Test User",
        role=role,
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    db.add(Wallet(user_id=user.id))
    await db.flush()
    return user


def _client() -> AsyncClient:
    return AsyncClient(transport=ASGITransport(app=app), base_url="http://test")


@pytest.mark.asyncio
async def test_refresh_token_rotates_and_replay_is_rejected(db_factory):
    async with db_factory() as db:
        user = await _add_user(db)
        refresh_token = create_refresh_token(str(user.id))
        await _create_refresh_session(db, user.id, refresh_token)
        await db.commit()

    async with _client() as client:
        response = await client.post("/auth/refresh", json={"refresh_token": refresh_token})
        assert response.status_code == 200
        replacement = response.json()["refresh_token"]
        assert replacement != refresh_token

        replay = await client.post("/auth/refresh", json={"refresh_token": refresh_token})
        assert replay.status_code == 401

    async with db_factory() as db:
        sessions = (await db.execute(select(AuthSession).where(AuthSession.user_id == user.id))).scalars().all()
        assert len(sessions) == 2
        original = next(s for s in sessions if s.token_jti_hash == hash_token_identifier(token_jti(refresh_token)))
        replacement_jti = token_jti(replacement)
        assert original.revoked_at is not None
        assert original.replaced_by_jti_hash == hash_token_identifier(replacement_jti)


@pytest.mark.asyncio
async def test_web_refresh_uses_httponly_cookie_and_hides_rotated_token(db_factory):
    async with db_factory() as db:
        user = await _add_user(db)
        refresh_token = create_refresh_token(str(user.id))
        await _create_refresh_session(db, user.id, refresh_token)
        await db.commit()

    async with _client() as client:
        # Match the host/path used by ASGITransport so the Set-Cookie replaces
        # the seeded refresh cookie rather than creating a second cookie entry.
        client.cookies.set("nanoclick_refresh", refresh_token, domain="test.local", path="/auth")
        response = await client.post("/auth/refresh", params={"platform": "web"})

        assert response.status_code == 200
        payload = response.json()
        assert payload["access_token"]
        assert payload["refresh_token"] is None
        set_cookie = response.headers["set-cookie"]
        assert "nanoclick_refresh=" in set_cookie
        assert "HttpOnly" in set_cookie
        assert "Path=/auth" in set_cookie
        rotated_cookie = client.cookies.get("nanoclick_refresh", domain="test.local", path="/auth")
        assert rotated_cookie != refresh_token

        replay = await client.post("/auth/refresh", json={"refresh_token": refresh_token})
        assert replay.status_code == 401


@pytest.mark.asyncio
async def test_logout_revokes_refresh_session(db_factory):
    async with db_factory() as db:
        user = await _add_user(db)
        refresh_token = create_refresh_token(str(user.id))
        await _create_refresh_session(db, user.id, refresh_token)
        await db.commit()

    async with _client() as client:
        response = await client.post("/auth/logout", json={"refresh_token": refresh_token})
        assert response.status_code == 200
        replay = await client.post("/auth/refresh", json={"refresh_token": refresh_token})
        assert replay.status_code == 401

    async with db_factory() as db:
        session = (await db.execute(select(AuthSession).where(AuthSession.user_id == user.id))).scalar_one()
        assert session.revoked_at is not None


@pytest.mark.asyncio
async def test_oauth_state_is_single_use_and_mismatch_is_rejected(db_factory):
    state = new_oauth_state()
    async with db_factory() as db:
        db.add(OAuthState(
            nonce_hash=hash_token_identifier(state),
            role="worker",
            platform="web",
            redirect_uri="http://localhost:5173/oauth-callback",
            expires_at=datetime.utcnow() + timedelta(minutes=10),
        ))
        await db.commit()

    async with db_factory() as db:
        consumed = await _consume_oauth_state(db, state)
        assert consumed.consumed_at is not None
        await db.commit()

    async with db_factory() as db:
        with pytest.raises(HTTPException, match="Invalid or expired OAuth state"):
            await _consume_oauth_state(db, state)
        with pytest.raises(HTTPException, match="Invalid or expired OAuth state"):
            await _consume_oauth_state(db, "wrong-state-value")


@pytest.mark.asyncio
async def test_expired_oauth_state_is_rejected(db_factory):
    state = new_oauth_state()
    async with db_factory() as db:
        db.add(OAuthState(
            nonce_hash=hash_token_identifier(state),
            role="worker",
            platform="web",
            redirect_uri=None,
            expires_at=datetime.utcnow() - timedelta(seconds=1),
        ))
        await db.commit()

    async with db_factory() as db:
        with pytest.raises(HTTPException, match="Invalid or expired OAuth state"):
            await _consume_oauth_state(db, state)


@pytest.mark.asyncio
async def test_oauth_code_is_single_use(db_factory):
    async with db_factory() as db:
        user = await _add_user(db)
        code = "oauth-test-code-" + uuid.uuid4().hex
        db.add(OAuthCode(
            code_hash=hash_token_identifier(code),
            user_id=user.id,
            redirect_uri="http://localhost:5173/oauth-callback",
            expires_at=datetime.utcnow() + timedelta(minutes=2),
        ))
        await db.commit()

    async with _client() as client:
        first = await client.post("/auth/oauth/exchange", params={"code": code})
        assert first.status_code == 200
        assert first.json()["access_token"]

        second = await client.post("/auth/oauth/exchange", params={"code": code})
        assert second.status_code == 401

    async with db_factory() as db:
        record = (await db.execute(select(OAuthCode).where(OAuthCode.code_hash == hash_token_identifier(code)))).scalar_one()
        assert record.used_at is not None


@pytest.mark.asyncio
async def test_expired_oauth_code_is_rejected(db_factory):
    async with db_factory() as db:
        user = await _add_user(db)
        code = "oauth-expired-code-" + uuid.uuid4().hex
        db.add(OAuthCode(
            code_hash=hash_token_identifier(code),
            user_id=user.id,
            redirect_uri="http://localhost:5173/oauth-callback",
            expires_at=datetime.utcnow() - timedelta(seconds=1),
        ))
        await db.commit()

    async with _client() as client:
        response = await client.post("/auth/oauth/exchange", params={"code": code})
        assert response.status_code == 401


@pytest.mark.asyncio
async def test_login_matches_email_case_insensitively_and_rejects_wrong_password(db_factory):
    password = "Correct-Horse-123!"
    async with db_factory() as db:
        user = await _add_user(db, role="advertiser")
        user.email = user.email.lower()
        user.password_hash = hash_password(password)
        user.email_verified = True
        await db.commit()
        login_email = user.email.upper()

    async with _client() as client:
        success = await client.post("/auth/login?platform=app", json={"email": login_email, "password": password})
        assert success.status_code == 200
        assert success.json()["access_token"]

        wrong_password = await client.post("/auth/login?platform=app", json={"email": login_email, "password": "Definitely-Wrong-123!"})
        assert wrong_password.status_code == 401
        assert wrong_password.json()["detail"] == "Invalid credentials"



def test_secure_refresh_cookie_supports_cross_site_web_frontend(monkeypatch):
    monkeypatch.setattr(settings, "AUTH_COOKIE_SECURE", True)
    response = __import__("starlette.responses", fromlist=["Response"]).Response()
    _set_refresh_cookie(response, "refresh-token-test")
    cookie = response.headers["set-cookie"].lower()
    assert "samesite=none" in cookie
    assert "secure" in cookie
    assert "httponly" in cookie


@pytest.mark.asyncio
async def test_profile_avatar_key_persists_and_is_returned_by_me(db_factory, monkeypatch):
    import app.routers.auth as auth_router

    async with db_factory() as db:
        user = await _add_user(db, role="advertiser")
        await db.commit()
        user_id = user.id
        access_token = await _test_access_token(db, user)

    monkeypatch.setattr(
        auth_router,
        "validate_uploaded_image",
        lambda file_key, required_prefix: {
            "file_key": file_key,
            "size": 1234,
            "content_type": "image/png",
            "extension": "png",
        },
    )
    monkeypatch.setattr(
        auth_router,
        "generate_presigned_download_url",
        lambda file_key, expires_in=300: {"download_url": "https://storage.example/avatar.png"},
    )

    avatar_key = f"avatars/{user_id}/avatar.png"
    async with _client() as client:
        response = await client.post(
            "/auth/me/avatar/confirm",
            json={"file_key": avatar_key},
            headers={"Authorization": f"Bearer {access_token}"},
        )
        assert response.status_code == 200
        assert response.json()["avatar_url"] == "https://storage.example/avatar.png"

        profile = await client.get(
            "/auth/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )
        assert profile.status_code == 200
        assert profile.json()["avatar_url"] == "https://storage.example/avatar.png"

    async with db_factory() as db:
        stored_user = await db.get(User, user_id)
        assert stored_user.avatar_key == avatar_key



@pytest.mark.asyncio
async def test_profile_avatar_upload_uses_backend_storage_and_persists(db_factory, monkeypatch):
    import app.routers.auth as auth_router

    async with db_factory() as db:
        user = await _add_user(db, role="advertiser")
        await db.commit()
        user_id = user.id
        access_token = await _test_access_token(db, user)

    monkeypatch.setattr(
        auth_router,
        "store_profile_avatar",
        lambda file_bytes, owner_id: f"avatars/{owner_id}/saved-avatar.png",
    )
    monkeypatch.setattr(
        auth_router,
        "generate_presigned_download_url",
        lambda file_key, expires_in=300: {"download_url": "https://storage.example/saved-avatar.png"},
    )

    async with _client() as client:
        response = await client.post(
            "/auth/me/avatar",
            files={"file": ("avatar.png", b"validated-by-storage-test", "image/png")},
            headers={"Authorization": f"Bearer {access_token}"},
        )
        assert response.status_code == 200
        assert response.json()["avatar_url"] == "https://storage.example/saved-avatar.png"

    async with db_factory() as db:
        stored_user = await db.get(User, user_id)
        assert stored_user.avatar_key == f"avatars/{user_id}/saved-avatar.png"


@pytest.mark.asyncio
async def test_notification_and_regional_settings_are_persisted(db_factory):
    async with db_factory() as db:
        user = await _add_user(db, role="advertiser")
        await db.commit()
        user_id = user.id
        access_token = create_access_token(str(user.id), user.role)

    async with _client() as client:
        response = await client.patch(
            "/auth/me/settings",
            json={
                "notification_preferences": {"emailCampaign": False, "smsCritical": True},
                "regional_preferences": {
                    "currency": "US Dollar ($)",
                    "timezone": "UTC",
                    "language": "English",
                    "autoRenew": False,
                },
            },
            headers={"Authorization": f"Bearer {access_token}"},
        )
        assert response.status_code == 200
        assert response.json()["notification_preferences"]["emailCampaign"] is False
        assert response.json()["regional_preferences"]["currency"] == "US Dollar ($)"

        profile = await client.get(
            "/auth/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )
        assert profile.status_code == 200
        assert profile.json()["notification_preferences"]["smsCritical"] is True
        assert profile.json()["regional_preferences"]["autoRenew"] is False

    async with db_factory() as db:
        stored_user = await db.get(User, user_id)
        assert stored_user.notification_preferences["emailCampaign"] is False
        assert stored_user.regional_preferences["timezone"] == "UTC"
