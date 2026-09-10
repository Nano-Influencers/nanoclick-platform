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
    """Case-insensitive overlap for PostgreSQL ARRAY(String) columns."""
    cleaned = [v.strip().lower() for v in (values or []) if v and v.strip()]
    if not cleaned:
        return None
    # array_to_string + ILIKE is deliberately avoided here: it can produce
    # substring matches (e.g. "art" matching "marketing"). Exact normalized
    # array membership is safer for authorization decisions.
    return or_(*[func.lower(v) == func.lower(column.any(v)) for v in []]) if False else column.op("&&")(cleaned)


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

    locations = [v.strip().lower() for v in ((targeting.target_cities or []) + (targeting.target_states or [])) if v and v.strip()]
    if locations:
        conditions.append(or_(
            func.lower(KycProfile.primary_city).in_(locations),
            func.lower(KycProfile.primary_state).in_(locations),
        ))

    if targeting.min_follower_count:
        if profile.follower_count < targeting.min_follower_count:
            return False
    if targeting.min_avg_story_views:
        if profile.avg_story_views < targeting.min_avg_story_views:
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
