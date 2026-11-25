import uuid

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import CampaignTargeting
from app.models.task import Task
from app.models.user import User
from app.models.wallet import Wallet
from app.routers.campaigns import create_campaign
from app.schemas.campaign import CampaignCreate, CampaignTargetingCreate


async def _user(db: AsyncSession) -> User:
    user = User(
        email=f"campaign-targeting-{uuid.uuid4()}@example.com",
        full_name="Campaign targeting advertiser",
        role="advertiser",
        referral_code=str(uuid.uuid4())[:12],
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id, balance_kobo=2_000_000))
    await db.flush()
    return user


@pytest.mark.asyncio
async def test_interest_only_targeting_is_marked_and_priced_as_targeted(db: AsyncSession):
    advertiser = await _user(db)
    body = CampaignCreate(
        title="Interest targeting",
        platform="instagram",
        action_type="follow",
        tni_service_type="custom",
        client_budget_ngn=10_000,
        client_price_per_action_ngn=1_000,
        targeting=CampaignTargetingCreate(target_interests=["technology"]),
    )

    campaign = await create_campaign(body, advertiser, db)
    await db.commit()

    assert campaign.has_targeting is True
    assert campaign.client_budget_kobo == 1_500_000
    assert campaign.client_price_per_action_kobo == 150_000
    assert campaign.slots_total == 10

    targeting = (
        await db.execute(select(CampaignTargeting).where(CampaignTargeting.campaign_id == campaign.id))
    ).scalar_one()
    assert targeting.target_interests == ["technology"]

    task = (await db.execute(select(Task).where(Task.campaign_id == campaign.id))).scalar_one()
    assert task.slots_total == 10

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == advertiser.id))).scalar_one()
    assert wallet.balance_kobo == 500_000
