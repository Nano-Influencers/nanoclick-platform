import uuid

import pytest
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from app.models.rewards import RewardClaim
from app.models.user import User


@pytest.mark.asyncio
async def test_reward_claim_is_unique_per_worker_and_track(db):
    user = User(
        email=f"reward-{uuid.uuid4()}@example.com",
        full_name="Reward Claim Test",
        role="worker",
        referral_code=f"ref{uuid.uuid4().hex[:12]}",
    )
    db.add(user)
    await db.flush()

    db.add(RewardClaim(user_id=user.id, reward_key="grit_level10_pool", amount_kobo=50000))
    await db.flush()

    db.add(RewardClaim(user_id=user.id, reward_key="grit_level10_pool", amount_kobo=50000))
    with pytest.raises(IntegrityError):
        await db.flush()
    await db.rollback()

    claims = await db.execute(select(RewardClaim).where(RewardClaim.user_id == user.id))
    assert claims.scalars().all() == []
