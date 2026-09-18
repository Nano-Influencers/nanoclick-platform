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
from app.services.targeting_data import AGE_BRACKETS_ORDERED, ETHNICITY_LOCATIONS, FEMALE_GROUP_KEYWORDS, LANGUAGE_LOCATIONS, MALE_GROUP_KEYWORDS, MARITAL_ADJACENT, MARITAL_GROUP_KEYWORDS, NEIGHBOURING_LOCATIONS


def _array_matches(column, values: list[str]) -> object | None:
    """Return PostgreSQL ARRAY overlap for normalized values."""
    cleaned = [v.strip().lower() for v in (values or []) if v and v.strip()]
    if not cleaned:
        return None
    return column.op("&&")(cleaned)


def _text_in(column, values: list[str]) -> object | None:
    cleaned = [v.strip().lower() for v in (values or []) if v and v.strip()]
    return func.lower(column).in_(cleaned) if cleaned else None


def _clean(values):
    return [v.strip().lower() for v in (values or []) if v and v.strip()]

def _expanded_location_matches(p, t, tier):
    cities, states = _clean(t.target_cities), _clean(t.target_states)
    if not cities and not states: return True
    city, state = (p.primary_city or '').lower(), (p.primary_state or '').lower()
    if city in cities or state in states: return True
    scopes = set(cities + states)
    if tier >= 2 and any(str(x).strip().lower() in scopes for x in (p.secondary_locations or [])): return True
    if tier >= 3 and any(str(x).strip().lower() in scopes for x in (p.occupation_location, p.study_location, p.trade_school_niche) if x): return True
    if tier >= 4 and any(x in ' '.join(p.group_descriptions or []).lower() for x in scopes): return True
    if tier >= 5 and (p.majority_follower_location or '').lower() in cities: return True
    if tier >= 6 and ((p.state_of_origin or '').lower() in states or (p.town_of_origin or '').lower() in cities): return True
    if tier >= 7 and city in {n.lower() for c in cities for n in NEIGHBOURING_LOCATIONS.get(c, [])}: return True
    if tier >= 8:
        langs = {lang.lower() for scope in scopes for lang, locs in LANGUAGE_LOCATIONS.items() if scope in {x.lower() for x in locs}}
        if langs & {str(x).lower() for x in (p.languages_spoken or [])}: return True
    if tier >= 9:
        eths = {eth.lower() for scope in scopes for eth, locs in ETHNICITY_LOCATIONS.items() if scope in {x.lower() for x in locs}}
        if (p.ethnicity_tribe or '').lower() in eths: return True
    return False

def _expanded_gender_matches(p, targets, tier):
    if not targets: return True
    g = (p.gender or '').lower()
    if g in targets: return True
    if tier < 2: return False
    group, desc = (p.gender_group_membership or '').lower(), ' '.join(p.group_descriptions or []).lower()
    for target in targets:
        if target == 'male' and (group == 'male_group' or any(k.lower() in desc for k in MALE_GROUP_KEYWORDS)): return True
        if target == 'female' and (group == 'female_group' or any(k.lower() in desc for k in FEMALE_GROUP_KEYWORDS)): return True
    return tier >= 3 and bool(g)

def _expanded_age_matches(value, targets, tier):
    if not targets: return True
    value = (value or '').lower()
    if value in targets: return True
    if tier < 2 or value not in {x.lower() for x in AGE_BRACKETS_ORDERED}: return False
    idx = [x.lower() for x in AGE_BRACKETS_ORDERED].index(value)
    adjacent = set()
    if idx: adjacent.add(AGE_BRACKETS_ORDERED[idx - 1].lower())
    if idx < len(AGE_BRACKETS_ORDERED)-1: adjacent.add(AGE_BRACKETS_ORDERED[idx + 1].lower())
    return bool(adjacent & set(targets))

def _expanded_marital_matches(p, targets, tier):
    if not targets: return True
    status = (p.marital_status or '').lower()
    if status in targets: return True
    if tier >= 2:
        keys = {k.lower() for t in targets for k in MARITAL_GROUP_KEYWORDS.get(t, [])}
        if keys & set(' '.join(p.marital_group_keywords or []).lower().split()): return True
    if tier >= 3 and status in {x.lower() for t in targets for x in MARITAL_ADJACENT.get(t, [])}: return True
    return False

async def is_worker_eligible_for_campaign(db: AsyncSession, worker_id: uuid.UUID, targeting: CampaignTargeting) -> bool:
    user_result = await db.execute(select(User).where(User.id == worker_id))
    user = user_result.scalar_one_or_none()
    if user is None or not user.is_active or not user.kyc_verified: return False
    profile_result = await db.execute(select(KycProfile).where(KycProfile.user_id == worker_id))
    p = profile_result.scalar_one_or_none()
    if p is None: return False
    for name, value in [('target_income_ranges', p.monthly_income_range), ('target_religions', p.religion), ('target_races', p.race), ('target_countries', p.primary_country), ('target_industries', p.occupation_industry)]:
        targets = set(_clean(getattr(targeting, name, [])))
        if targets and (value or '').lower() not in targets: return False
    for name, values in [('target_languages', p.languages_spoken), ('target_skills', p.skills), ('target_interests', p.interests_hobbies)]:
        targets = set(_clean(getattr(targeting, name, [])))
        if targets and not targets.intersection({str(x).lower() for x in (values or [])}): return False
    if targeting.min_follower_count and p.follower_count < targeting.min_follower_count: return False
    if targeting.min_avg_story_views and p.avg_story_views < targeting.min_avg_story_views: return False
    tier = max(1, min(int(targeting.current_expansion_tier or 1), 9))
    return (_expanded_location_matches(p, targeting, tier) and _expanded_gender_matches(p, set(_clean(targeting.target_genders)), tier) and _expanded_age_matches(p.age_bracket, set(_clean(targeting.target_age_brackets)), tier) and _expanded_marital_matches(p, set(_clean(targeting.target_marital_statuses)), tier) and (not targeting.target_ethnicities or (p.ethnicity_tribe or '').lower() in _clean(targeting.target_ethnicities)))

async def is_worker_eligible(db: AsyncSession, worker_id: uuid.UUID, targeting: CampaignTargeting) -> bool:
    return await is_worker_eligible_for_campaign(db, worker_id, targeting)
