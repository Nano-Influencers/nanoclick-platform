import uuid

import httpx
import pytest
from httpx import ASGITransport

from app.database import get_db
from app.dependencies import require_advertiser
from app.main import app
from app.models.user import User
from app.routers import campaigns as campaigns_router


async def make_advertiser(db, email=None):
    user = User(
        email=email or f"draft-{uuid.uuid4().hex}@example.com",
        full_name="Campaign Advertiser",
        role="advertiser",
        referral_code=f"dr{uuid.uuid4().hex[:14]}",
    )
    db.add(user)
    await db.commit()
    return user


@pytest.fixture
def reset_overrides():
    app.dependency_overrides.clear()
    yield
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_campaign_draft_create_read_update_delete_is_owner_scoped(db, reset_overrides):
    owner = await make_advertiser(db)
    other = await make_advertiser(db)

    async def current_user():
        return owner

    async def db_session():
        yield db

    app.dependency_overrides[require_advertiser] = current_user
    app.dependency_overrides[get_db] = db_session
    async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        created = await client.post("/campaigns/drafts", json={
            "payload": {"campaignName": "Spring launch", "budget": 2500},
            "creative_key": None,
        })
        assert created.status_code == 200
        draft_id = created.json()["id"]

        read = await client.get(f"/campaigns/drafts/{draft_id}")
        assert read.status_code == 200
        assert read.json()["payload"]["campaignName"] == "Spring launch"

        updated = await client.post("/campaigns/drafts", json={
            "draft_id": draft_id,
            "payload": {"campaignName": "Updated launch", "budget": 3500},
        })
        assert updated.status_code == 200
        assert updated.json()["payload"]["budget"] == 3500

        async def other_user():
            return other

        app.dependency_overrides[require_advertiser] = other_user
        forbidden = await client.get(f"/campaigns/drafts/{draft_id}")
        assert forbidden.status_code == 404

        app.dependency_overrides[require_advertiser] = current_user
        deleted = await client.delete(f"/campaigns/drafts/{draft_id}")
        assert deleted.status_code == 204
        missing = await client.get(f"/campaigns/drafts/{draft_id}")
        assert missing.status_code == 404


@pytest.mark.asyncio
async def test_campaign_creative_upload_and_confirmation_are_owner_scoped(db, monkeypatch, reset_overrides):
    owner = await make_advertiser(db)

    async def current_user():
        return owner

    async def db_session():
        yield db

    app.dependency_overrides[require_advertiser] = current_user
    app.dependency_overrides[get_db] = db_session

    monkeypatch.setattr(campaigns_router, "generate_presigned_upload_url", lambda ext, folder: {
        "upload_url": "https://storage.example/upload", "file_key": f"{folder}/sample.{ext}",
        "content_type": "image/png", "expires_in_seconds": 300,
    })
    monkeypatch.setattr(campaigns_router, "validate_uploaded_object", lambda key, prefix: {
        "file_key": key, "content_type": "image/png", "size": 128, "extension": "png",
    })

    async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        upload = await client.post("/campaigns/creative-upload-url", json={"file_extension": "png"})
        assert upload.status_code == 200
        assert upload.json()["file_key"].startswith(f"campaigns/{owner.id}/")

        confirmed = await client.post("/campaigns/creative-confirm", json={"file_key": upload.json()["file_key"]})
        assert confirmed.status_code == 200
        assert confirmed.json()["size"] == 128

        invalid = await client.post("/campaigns/creative-upload-url", json={"file_extension": "exe"})
        assert invalid.status_code == 400


@pytest.mark.asyncio
async def test_campaign_draft_rejects_attachment_key_from_another_account(db, monkeypatch, reset_overrides):
    owner = await make_advertiser(db)

    async def current_user():
        return owner

    async def db_session():
        yield db

    def validate(key, prefix):
        if not key.startswith(prefix + "/"):
            raise ValueError("Storage object does not belong to this account")
        return {"file_key": key}

    monkeypatch.setattr(campaigns_router, "validate_uploaded_object", validate)
    app.dependency_overrides[require_advertiser] = current_user
    app.dependency_overrides[get_db] = db_session
    async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/campaigns/drafts", json={
            "payload": {"taskMediaKey": f"campaigns/{uuid.uuid4()}/foreign.png"},
        })
    assert response.status_code == 400
    assert "does not belong" in response.json()["detail"]
