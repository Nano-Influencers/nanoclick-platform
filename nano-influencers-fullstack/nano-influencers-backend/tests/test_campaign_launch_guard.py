import uuid

import httpx
import pytest
from httpx import ASGITransport
from sqlalchemy import select

from app.config import settings
from app.database import get_db
from app.dependencies import require_advertiser
from app.main import app
from app.models.campaign import Campaign
from app.models.user import User
from app.models.wallet import Wallet
from app.routers import campaigns as campaigns_router


@pytest.mark.asyncio
async def test_campaign_launch_is_server_side_disabled_without_debit(db, monkeypatch):
    monkeypatch.setattr(settings, "CAMPAIGN_LAUNCH_ENABLED", True)
    monkeypatch.setattr(campaigns_router, "CAMPAIGN_LAUNCH_VERIFIED", False)
    user = User(
        email=f"paused-campaign-{uuid.uuid4().hex}@example.com",
        full_name="Advertiser",
        role="advertiser",
        referral_code=f"pc{uuid.uuid4().hex[:14]}",
    )
    db.add(user)
    await db.flush()
    wallet = Wallet(user_id=user.id, balance_kobo=1_000_000)
    db.add(wallet)
    await db.commit()

    async def current_user():
        return user

    async def db_session():
        yield db

    app.dependency_overrides[require_advertiser] = current_user
    app.dependency_overrides[get_db] = db_session
    try:
        async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/campaigns", json={
                "title": "Paused launch",
                "platform": "instagram",
                "action_type": "follow",
                "tni_service_type": "custom",
                "client_budget_ngn": "1000.00",
                "client_price_per_action_ngn": "100.00",
            })
        assert response.status_code == 503
        assert "launch is paused" in response.json()["detail"].lower()
        assert await db.scalar(select(Campaign.id).where(Campaign.owner_id == user.id)) is None
        await db.refresh(wallet)
        assert wallet.balance_kobo == 1_000_000
    finally:
        app.dependency_overrides.pop(require_advertiser, None)
        app.dependency_overrides.pop(get_db, None)
