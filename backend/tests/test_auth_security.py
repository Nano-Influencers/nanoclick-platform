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
from app.routers.auth import _consume_oauth_state, _create_refresh_session
from app.services.auth_service import (
    create_refresh_token,
    hash_token_identifier,
    new_oauth_state,
    token_jti,
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
