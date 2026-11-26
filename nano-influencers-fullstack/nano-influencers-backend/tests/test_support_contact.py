import uuid

import httpx
import pytest
from httpx import ASGITransport

from app.config import settings
from app.dependencies import get_current_user
from app.main import app
from app.models.user import User
from app.routers import support as support_router


@pytest.mark.asyncio
async def test_support_contact_delivers_authenticated_message(db, monkeypatch):
    user = User(
        email=f"support-{uuid.uuid4().hex}@example.com",
        full_name="Support User",
        role="worker",
        referral_code=f"su{uuid.uuid4().hex[:14]}",
    )
    db.add(user)
    await db.flush()
    sent = []

    async def current_user():
        return user

    async def fake_send(recipient, name, email, message):
        sent.append((recipient, name, email, message))

    monkeypatch.setattr(settings, "SUPPORT_EMAIL", "support@example.test")
    monkeypatch.setattr(support_router, "send_support_message", fake_send)
    app.dependency_overrides[get_current_user] = current_user
    try:
        async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/support/contact", json={
                "name": "Support User",
                "email": user.email.upper(),
                "message": "Please help me understand my wallet transaction.",
            })
        assert response.status_code == 202
        assert sent == [("support@example.test", "Support User", user.email.lower(), "Please help me understand my wallet transaction.")]
    finally:
        app.dependency_overrides.pop(get_current_user, None)


@pytest.mark.asyncio
async def test_support_contact_fails_closed_when_no_inbox_is_configured(db, monkeypatch):
    user = User(
        email=f"support-off-{uuid.uuid4().hex}@example.com",
        full_name="Support User",
        role="worker",
        referral_code=f"so{uuid.uuid4().hex[:14]}",
    )
    db.add(user)
    await db.flush()

    async def current_user():
        return user

    monkeypatch.setattr(settings, "SUPPORT_EMAIL", "")
    app.dependency_overrides[get_current_user] = current_user
    try:
        async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/support/contact", json={
                "name": "Support User", "email": user.email,
                "message": "I need help with my account please.",
            })
        assert response.status_code == 503
    finally:
        app.dependency_overrides.pop(get_current_user, None)
