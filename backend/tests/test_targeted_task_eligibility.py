import uuid

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import CampaignTargeting
from app.models.user import KycProfile, User
from app.services.targeting_eligibility import is_worker_eligible


async def _worker(db: AsyncSession, *, gender: str, interests: list[str], city: str) -> User:
    user = User(
        email=f"target-worker-{uuid.uuid4()}@example.com",
        full_name="Targeted worker",
        role="worker",
        referral_code=str(uuid.uuid4())[:12],
        kyc_verified=True,
        is_active=True,
    )
    db.add(user)
    await db.flush()
    db.add(KycProfile(
        user_id=user.id,
        gender=gender,
        interests_hobbies=interests,
        primary_city=city,
        primary_country="Nigeria",
        follower_count=1000,
        avg_story_views=500,
    ))
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_targeting_requires_all_configured_dimensions(db: AsyncSession):
    matching = await _worker(db, gender="female", interests=["technology"], city="Abuja")
    wrong_gender = await _worker(db, gender="male", interests=["technology"], city="Abuja")
    wrong_interest = await _worker(db, gender="female", interests=["fashion"], city="Abuja")

    targeting = CampaignTargeting(
        campaign_id=uuid.uuid4(),
        target_genders=["female"],
        target_interests=["technology"],
        target_cities=["Abuja"],
    )
    # The campaign_id is only needed to construct the model here; no campaign
    # row is required because the eligibility query uses the targeting fields.
    assert await is_worker_eligible(db, matching.id, targeting) is True
    assert await is_worker_eligible(db, wrong_gender.id, targeting) is False
    assert await is_worker_eligible(db, wrong_interest.id, targeting) is False


@pytest.mark.asyncio
async def test_targeting_requires_kyc_and_reach_thresholds(db: AsyncSession):
    worker = await _worker(db, gender="female", interests=["technology"], city="Abuja")
    worker.kyc_verified = False
    await db.flush()

    targeting = CampaignTargeting(
        campaign_id=uuid.uuid4(),
        min_follower_count=2000,
        min_avg_story_views=1000,
    )
    assert await is_worker_eligible(db, worker.id, targeting) is False

    worker.kyc_verified = True
    await db.flush()
    assert await is_worker_eligible(db, worker.id, targeting) is False
