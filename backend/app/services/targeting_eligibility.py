"""Strict worker eligibility checks for targeted tasks.

Audience expansion is useful for estimating/expanding a campaign audience, but it
must never silently turn an advertiser's explicit targeting constraints into an
OR/unrestricted match. This module performs a deterministic AND-across-dimensions
eligibility check for the worker who is about to view/accept a targeted task.
"""

from __future__ import annotations

import uuid

from sqlalchemy import and_, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import CampaignTargeting
from app.models.user import KycProfile, User


def _array_matches(column, values: list[str]) -> object | None:
    """Return PostgreSQL ARRAY overlap for normalized values."""
    cleaned = [v.strip().lower() for v in (values or []) if v and v.strip()]
    if not cleaned:
        return None
    return column.op("&&")(cleaned)


def _text_in(column, values: list[str]) -> object | None:
    cleaned = [v.strip().lower() for v in (values or []) if v and v.strip()]
    return func.lower(column).in_(cleaned) if cleaned else None


async def is_worker_eligible(
    db: AsyncSession,
    worker_id: uuid.UUID,
    targeting: CampaignTargeting,
) -> bool:
    """Return True only when the worker satisfies every configured constraint."""
    user_result = await db.execute(select(User).where(User.id == worker_id))
    user = user_result.scalar_one_or_none()
    if user is None or not user.is_active or not user.kyc_verified:
        return False

    profile_result = await db.execute(select(KycProfile).where(KycProfile.user_id == worker_id))
    profile = profile_result.scalar_one_or_none()
    if profile is None:
        return False

    conditions = []
    scalar_fields = (
        ("target_genders", KycProfile.gender),
        ("target_age_brackets", KycProfile.age_bracket),
        ("target_marital_statuses", KycProfile.marital_status),
        ("target_income_ranges", KycProfile.monthly_income_range),
        ("target_religions", KycProfile.religion),
        ("target_ethnicities", KycProfile.ethnicity_tribe),
        ("target_races", KycProfile.race),
        ("target_countries", KycProfile.primary_country),
        ("target_industries", KycProfile.occupation_industry),
    )
    for field_name, column in scalar_fields:
        condition = _text_in(column, getattr(targeting, field_name, []) or [])
        if condition is not None:
            conditions.append(condition)

    for field_name, column in (
        ("target_languages", KycProfile.languages_spoken),
        ("target_skills", KycProfile.skills),
        ("target_interests", KycProfile.interests_hobbies),
    ):
        condition = _array_matches(column, getattr(targeting, field_name, []) or [])
        if condition is not None:
            conditions.append(condition)

    city_values = [v.strip().lower() for v in (targeting.target_cities or []) if v and v.strip()]
    state_values = [v.strip().lower() for v in (targeting.target_states or []) if v and v.strip()]
    if city_values or state_values:
        location_conditions = []
        if city_values:
            location_conditions.append(func.lower(KycProfile.primary_city).in_(city_values))
        if state_values:
            location_conditions.append(func.lower(KycProfile.primary_state).in_(state_values))
        conditions.append(or_(*location_conditions))

    if targeting.min_follower_count and profile.follower_count < targeting.min_follower_count:
        return False
    if targeting.min_avg_story_views and profile.avg_story_views < targeting.min_avg_story_views:
        return False

    if not conditions:
        return True

    result = await db.execute(
        select(KycProfile.user_id).where(
            KycProfile.user_id == worker_id,
            and_(*conditions),
        )
    )
    return result.scalar_one_or_none() is not None
