"""
Targeting Engine v2 — Hierarchical Tier-Based Audience Expansion.

CONSTRAINT: This enhances the existing engine without modifying:
  - Campaign creation
  - User management / auth
  - Database schema
  - API contracts
  - CampaignTargeting model

Architecture:
  - TierResult        : dataclass capturing one tier's output
  - ExpansionResult   : full run result with audit metadata
  - TierExpander      : per-dimension expansion runner
  - TargetingEngine   : orchestrates all dimensions + neighbour ripple
  - get_eligible_worker_ids() : backward-compatible public entry point
"""

from __future__ import annotations

import logging
import uuid
from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional

from sqlalchemy import and_, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.campaign import CampaignTargeting
from app.models.user import KycProfile, User
from app.services.targeting_data import (
    AGE_BRACKETS_ORDERED,
    ETHNICITY_LOCATIONS,
    FEMALE_GROUP_KEYWORDS,
    LANGUAGE_LOCATIONS,
    MALE_GROUP_KEYWORDS,
    MARITAL_ADJACENT,
    MARITAL_GROUP_KEYWORDS,
    NEIGHBOURING_LOCATIONS,
)

log = logging.getLogger("targeting")

# ─────────────────────────────────────────────────────────────────────────────
# Data structures
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class TierResult:
    tier: int
    dimension: str          # "location" | "gender" | "age" | "marital" | etc.
    new_ids: list[uuid.UUID]
    cumulative_total: int
    location_context: Optional[str] = None   # which city this tier ran against


@dataclass
class ExpansionResult:
    worker_ids: list[uuid.UUID]
    expansion_path: list[str]                         # human-readable steps
    tiers_executed: list[dict]                        # [{dimension, tier, count}]
    tier_contribution_breakdown: dict[str, int]       # "location:tier1" → count
    fulfillment_percentage: float
    stop_reason: str                                  # "fulfilled" | "exhausted"
    neighbouring_locations_used: list[str]
    desired_quantity: int
    found_quantity: int


# ─────────────────────────────────────────────────────────────────────────────
# Helper: build base KYC query conditions (hard demographic filters)
# These never expand — applied to every query regardless of tier
# ─────────────────────────────────────────────────────────────────────────────

def _hard_filters(t: CampaignTargeting) -> list:
    """
    Demographic hard constraints from Pillars 4–8 (religion, income, language,
    industry, reach minimums). These are always applied; they do not expand.
    """
    f: list = []

    if t.target_religions:
        f.append(func.lower(KycProfile.religion).in_([r.lower() for r in t.target_religions]))

    if t.target_income_ranges:
        f.append(func.lower(KycProfile.monthly_income_range).in_([i.lower() for i in t.target_income_ranges]))

    if t.target_languages:
        f.append(or_(*[
            func.array_to_string(KycProfile.languages_spoken, ",").ilike(f"%{lang}%")
            for lang in t.target_languages
        ]))

    if t.target_industries:
        f.append(or_(*[
            KycProfile.occupation_industry.ilike(f"%{ind}%")
            for ind in t.target_industries
        ]))

    if t.min_follower_count:
        f.append(KycProfile.follower_count >= t.min_follower_count)

    if t.min_avg_story_views:
        f.append(KycProfile.avg_story_views >= t.min_avg_story_views)

    return f


# ─────────────────────────────────────────────────────────────────────────────
# Core DB query
# ─────────────────────────────────────────────────────────────────────────────

async def _run_query(
    db: AsyncSession,
    extra_filters: list,
    hard_filters: list,
    exclude: set[uuid.UUID],
    limit: int = 20_000,
) -> list[uuid.UUID]:
    """
    Single DB round-trip. Applies hard_filters + extra_filters, excludes
    already-seen IDs, returns list of new user UUIDs.
    Avoids N+1 — all logic is pushed into one SQL statement.
    """
    conditions = [
        User.is_active == True,
        User.kyc_verified == True,
    ]
    if exclude:
        conditions.append(KycProfile.user_id.not_in(list(exclude)))
    conditions.extend(hard_filters)
    conditions.extend(extra_filters)

    stmt = (
        select(KycProfile.user_id)
        .join(User, User.id == KycProfile.user_id)
        .where(and_(*conditions))
        .limit(limit)
    )
    result = await db.execute(stmt)
    return list(result.scalars().all())


# ─────────────────────────────────────────────────────────────────────────────
# Per-dimension tier expanders
# ─────────────────────────────────────────────────────────────────────────────

class LocationExpander:
    """
    9-tier location expansion + neighbouring-city ripple.

    Tier 1  Primary resident city/state
    Tier 2  Secondary / commuter location
    Tier 3  Occupation / study / trade-school location
    Tier 4  Digital community — group chat descriptions mention the city
    Tier 5  Audience reach — majority follower location
    Tier 6  Heritage / origin
    Tier 7  Physical proximity — neighbouring cities (from NEIGHBOURING_LOCATIONS)
    Tier 8  Language affinity (LANGUAGE_LOCATIONS lookup)
    Tier 9  Ethnicity / race (ETHNICITY_LOCATIONS lookup)
    """

    MAX_TIERS = 9

    def __init__(self, target_cities: list[str], target_states: list[str], target_ethnicities: list[str]):
        self.cities   = [c.lower() for c in (target_cities or [])]
        self.states   = [s.lower() for s in (target_states or [])]
        self.ethnicities = [e.lower() for e in (target_ethnicities or [])]

    def has_targets(self) -> bool:
        return bool(self.cities or self.states)

    def _tier_filter(self, tier: int, cities: list[str], states: list[str]) -> list:
        """Returns SQLAlchemy filter list for the given tier and city/state scope."""
        if tier == 1:
            conds = []
            if cities:
                conds.append(func.lower(KycProfile.primary_city).in_(cities))
            if states:
                conds.append(func.lower(KycProfile.primary_state).in_(states))
            return [or_(*conds)] if conds else []

        if tier == 2:
            conds = [
                func.array_to_string(KycProfile.secondary_locations, ",").ilike(f"%{loc}%")
                for loc in cities + states
            ]
            return [or_(*conds)] if conds else []

        if tier == 3:
            conds = []
            if cities:
                conds += [
                    func.lower(KycProfile.occupation_location).in_(cities),
                    func.lower(KycProfile.study_location).in_(cities),
                    func.lower(KycProfile.trade_school_niche).in_(cities),
                ]
            return [or_(*conds)] if conds else []

        if tier == 4:
            # Group description mentions the city/state
            conds = [
                func.array_to_string(KycProfile.group_descriptions, " ").ilike(f"%{loc}%")
                for loc in cities + states
            ]
            return [or_(*conds)] if conds else []

        if tier == 5:
            if cities:
                return [func.lower(KycProfile.majority_follower_location).in_(cities)]
            return []

        if tier == 6:
            conds = []
            if states:
                conds.append(func.lower(KycProfile.state_of_origin).in_(states))
            if cities:
                conds.append(func.lower(KycProfile.town_of_origin).in_(cities))
            return [or_(*conds)] if conds else []

        if tier == 7:
            # Neighbouring cities — expand city list to include neighbours
            neighbour_cities: set[str] = set()
            for city in cities:
                neighbour_cities.update(NEIGHBOURING_LOCATIONS.get(city, []))
            neighbour_cities -= set(cities)  # exclude already-used
            if neighbour_cities:
                return [func.lower(KycProfile.primary_city).in_(list(neighbour_cities))]
            return []

        if tier == 8:
            # Language affinity — find languages spoken in target cities
            langs: set[str] = set()
            for city in cities + states:
                for lang, locs in LANGUAGE_LOCATIONS.items():
                    if city in locs:
                        langs.add(lang)
            if langs:
                return [or_(*[
                    func.array_to_string(KycProfile.languages_spoken, ",").ilike(f"%{lang}%")
                    for lang in langs
                ])]
            return []

        if tier == 9:
            # Ethnicity / race affinity
            ethnicities: set[str] = set()
            for city in cities + states:
                for eth, locs in ETHNICITY_LOCATIONS.items():
                    if city in locs:
                        ethnicities.add(eth)
            # Also include explicitly targeted ethnicities
            ethnicities.update(self.ethnicities)
            if ethnicities:
                return [func.lower(KycProfile.ethnicity_tribe).in_(list(ethnicities))]
            return []

        return []

    async def expand(
        self,
        db: AsyncSession,
        hard_filters: list,
        seen: set[uuid.UUID],
        desired: int,
    ) -> tuple[list[TierResult], list[str]]:
        """
        Runs Tiers 1–9 for the primary targets, then ripples into
        neighbouring locations if still unfulfilled.
        Returns (tier_results, neighbouring_locations_used).
        """
        results: list[TierResult] = []
        neighbouring_used: list[str] = []
        cumulative = len(seen)

        # Primary target loop: Tiers 1–9
        for tier in range(1, self.MAX_TIERS + 1):
            filters = self._tier_filter(tier, self.cities, self.states)
            if not filters:
                continue

            new_ids = await _run_query(db, filters, hard_filters, seen)
            for uid in new_ids:
                seen.add(uid)
            cumulative += len(new_ids)

            log.info(
                "Location tier=%d cities=%s new=%d cumulative=%d target=%d",
                tier, self.cities, len(new_ids), cumulative, desired,
            )

            results.append(TierResult(
                tier=tier,
                dimension="location",
                new_ids=new_ids,
                cumulative_total=cumulative,
                location_context=str(self.cities),
            ))

            if cumulative >= desired:
                return results, neighbouring_used

        # Neighbour ripple — only if still unfulfilled after all 9 tiers
        ripple_cities: list[str] = []
        for city in self.cities:
            ripple_cities.extend(NEIGHBOURING_LOCATIONS.get(city, []))
        # Deduplicate, exclude already-targeted cities
        ripple_cities = list(dict.fromkeys(
            c for c in ripple_cities if c not in self.cities
        ))

        for neighbour in ripple_cities:
            if cumulative >= desired:
                break

            log.info("Neighbour ripple: starting tiers for city=%s", neighbour)
            neighbouring_used.append(neighbour)

            for tier in range(1, 7):   # Tiers 1–6 for neighbours (stop before language/ethnicity)
                filters = self._tier_filter(tier, [neighbour], [])
                if not filters:
                    continue

                new_ids = await _run_query(db, filters, hard_filters, seen)
                for uid in new_ids:
                    seen.add(uid)
                cumulative += len(new_ids)

                log.info(
                    "Neighbour city=%s tier=%d new=%d cumulative=%d",
                    neighbour, tier, len(new_ids), cumulative,
                )

                results.append(TierResult(
                    tier=tier,
                    dimension="location:neighbour",
                    new_ids=new_ids,
                    cumulative_total=cumulative,
                    location_context=neighbour,
                ))

                if cumulative >= desired:
                    break

        return results, neighbouring_used


class GenderExpander:
    """
    Tier 1  Exact gender match
    Tier 2  Gender-related group chat membership
    Tier 3  Broad (both genders — only if client allows)
    """
    MAX_TIERS = 3

    def __init__(self, target_genders: list[str]):
        self.genders = [g.lower() for g in (target_genders or [])]

    def has_targets(self) -> bool:
        return bool(self.genders)

    async def expand(
        self,
        db: AsyncSession,
        hard_filters: list,
        seen: set[uuid.UUID],
        desired: int,
    ) -> list[TierResult]:
        results: list[TierResult] = []
        cumulative = len(seen)

        for tier in range(1, self.MAX_TIERS + 1):
            filters = self._tier_filter(tier)
            if not filters:
                continue

            new_ids = await _run_query(db, filters, hard_filters, seen)
            for uid in new_ids:
                seen.add(uid)
            cumulative += len(new_ids)

            log.info("Gender tier=%d new=%d cumulative=%d", tier, len(new_ids), cumulative)

            results.append(TierResult(
                tier=tier, dimension="gender",
                new_ids=new_ids, cumulative_total=cumulative,
            ))
            if cumulative >= desired:
                break

        return results

    def _tier_filter(self, tier: int) -> list:
        if tier == 1:
            return [func.lower(KycProfile.gender).in_(self.genders)]
        if tier == 2:
            conds = []
            for g in self.genders:
                if g == "male":
                    conds.append(KycProfile.gender_group_membership == "male_group")
                    conds.extend([
                        func.array_to_string(KycProfile.group_descriptions, " ").ilike(f"%{kw}%")
                        for kw in MALE_GROUP_KEYWORDS[:5]
                    ])
                elif g == "female":
                    conds.append(KycProfile.gender_group_membership == "female_group")
                    conds.extend([
                        func.array_to_string(KycProfile.group_descriptions, " ").ilike(f"%{kw}%")
                        for kw in FEMALE_GROUP_KEYWORDS[:5]
                    ])
            return [or_(*conds)] if conds else []
        if tier == 3:
            # Broad — both genders
            return [KycProfile.gender.isnot(None)]
        return []


class AgeExpander:
    """
    Tier 1  Exact bracket(s)
    Tier 2  Adjacent brackets (one above and one below each target bracket)
    """
    MAX_TIERS = 2

    def __init__(self, target_brackets: list[str]):
        self.brackets = target_brackets or []

    def has_targets(self) -> bool:
        return bool(self.brackets)

    def _adjacent(self) -> list[str]:
        adj: set[str] = set()
        for b in self.brackets:
            if b in AGE_BRACKETS_ORDERED:
                idx = AGE_BRACKETS_ORDERED.index(b)
                if idx > 0:
                    adj.add(AGE_BRACKETS_ORDERED[idx - 1])
                if idx < len(AGE_BRACKETS_ORDERED) - 1:
                    adj.add(AGE_BRACKETS_ORDERED[idx + 1])
        return list(adj - set(self.brackets))

    async def expand(
        self,
        db: AsyncSession,
        hard_filters: list,
        seen: set[uuid.UUID],
        desired: int,
    ) -> list[TierResult]:
        results: list[TierResult] = []
        cumulative = len(seen)

        # Tier 1 — exact
        new_ids = await _run_query(
            db, [KycProfile.age_bracket.in_(self.brackets)], hard_filters, seen
        )
        for uid in new_ids:
            seen.add(uid)
        cumulative += len(new_ids)
        results.append(TierResult(1, "age", new_ids, cumulative))
        log.info("Age tier=1 brackets=%s new=%d cumulative=%d", self.brackets, len(new_ids), cumulative)

        if cumulative >= desired:
            return results

        # Tier 2 — adjacent
        adj = self._adjacent()
        if adj:
            new_ids = await _run_query(
                db, [KycProfile.age_bracket.in_(adj)], hard_filters, seen
            )
            for uid in new_ids:
                seen.add(uid)
            cumulative += len(new_ids)
            results.append(TierResult(2, "age", new_ids, cumulative))
            log.info("Age tier=2 adj=%s new=%d cumulative=%d", adj, len(new_ids), cumulative)

        return results


class MaritalExpander:
    """
    Tier 1  Exact marital status
    Tier 2a Group chat / community keywords for that status
    Tier 2b Adjacent statuses (e.g. Married → Widowed/Separated)
    """
    MAX_TIERS = 3

    def __init__(self, target_statuses: list[str]):
        self.statuses = [s.lower() for s in (target_statuses or [])]

    def has_targets(self) -> bool:
        return bool(self.statuses)

    async def expand(
        self,
        db: AsyncSession,
        hard_filters: list,
        seen: set[uuid.UUID],
        desired: int,
    ) -> list[TierResult]:
        results: list[TierResult] = []
        cumulative = len(seen)

        # Tier 1 — exact
        new_ids = await _run_query(
            db, [func.lower(KycProfile.marital_status).in_(self.statuses)], hard_filters, seen
        )
        for uid in new_ids:
            seen.add(uid)
        cumulative += len(new_ids)
        results.append(TierResult(1, "marital", new_ids, cumulative))
        log.info("Marital tier=1 new=%d cumulative=%d", len(new_ids), cumulative)
        if cumulative >= desired:
            return results

        # Tier 2a — group keyword match
        kw_conds = []
        for s in self.statuses:
            for kw in MARITAL_GROUP_KEYWORDS.get(s, []):
                kw_conds.append(
                    func.array_to_string(KycProfile.marital_group_keywords, " ").ilike(f"%{kw}%")
                )
        if kw_conds:
            new_ids = await _run_query(db, [or_(*kw_conds)], hard_filters, seen)
            for uid in new_ids:
                seen.add(uid)
            cumulative += len(new_ids)
            results.append(TierResult(2, "marital:group_keywords", new_ids, cumulative))
            log.info("Marital tier=2a (keywords) new=%d cumulative=%d", len(new_ids), cumulative)
            if cumulative >= desired:
                return results

        # Tier 2b — adjacent statuses
        adj: set[str] = set()
        for s in self.statuses:
            adj.update(MARITAL_ADJACENT.get(s, []))
        adj -= set(self.statuses)
        if adj:
            new_ids = await _run_query(
                db, [func.lower(KycProfile.marital_status).in_(list(adj))], hard_filters, seen
            )
            for uid in new_ids:
                seen.add(uid)
            cumulative += len(new_ids)
            results.append(TierResult(3, "marital:adjacent", new_ids, cumulative))
            log.info("Marital tier=2b (adjacent=%s) new=%d cumulative=%d", adj, len(new_ids), cumulative)

        return results


# ─────────────────────────────────────────────────────────────────────────────
# Main orchestrator
# ─────────────────────────────────────────────────────────────────────────────

class TargetingEngine:
    """
    Orchestrates all dimension expanders with:
      - Global deduplication across all tiers and dimensions
      - Audit logging per tier
      - Structured ExpansionResult metadata
    """

    def __init__(self, targeting: CampaignTargeting, desired: int):
        self.targeting = targeting
        self.desired = desired
        self.seen: set[uuid.UUID] = set()
        self._tier_results: list[TierResult] = []

    async def run(self, db: AsyncSession) -> ExpansionResult:
        t = self.targeting
        hard = _hard_filters(t)
        neighbouring_used: list[str] = []

        log.info(
            "TargetingEngine.run campaign_id=%s desired=%d cities=%s states=%s genders=%s",
            t.campaign_id, self.desired,
            t.target_cities, t.target_states, t.target_genders,
        )

        # ── Location (largest expansion surface — run first) ──────────────────
        if t.target_cities or t.target_states:
            expander = LocationExpander(
                t.target_cities or [],
                t.target_states or [],
                t.target_ethnicities or [],
            )
            loc_results, neighbouring_used = await expander.expand(
                db, hard, self.seen, self.desired
            )
            self._tier_results.extend(loc_results)
            if len(self.seen) >= self.desired:
                return self._build_result("fulfilled", neighbouring_used)

        # ── Gender ────────────────────────────────────────────────────────────
        if t.target_genders:
            expander = GenderExpander(t.target_genders)
            self._tier_results.extend(
                await expander.expand(db, hard, self.seen, self.desired)
            )
            if len(self.seen) >= self.desired:
                return self._build_result("fulfilled", neighbouring_used)

        # ── Age ───────────────────────────────────────────────────────────────
        if t.target_age_brackets:
            expander = AgeExpander(t.target_age_brackets)
            self._tier_results.extend(
                await expander.expand(db, hard, self.seen, self.desired)
            )
            if len(self.seen) >= self.desired:
                return self._build_result("fulfilled", neighbouring_used)

        # ── Marital status ────────────────────────────────────────────────────
        if t.target_marital_statuses:
            expander = MaritalExpander(t.target_marital_statuses)
            self._tier_results.extend(
                await expander.expand(db, hard, self.seen, self.desired)
            )
            if len(self.seen) >= self.desired:
                return self._build_result("fulfilled", neighbouring_used)

        # ── Fallback: ethnicities only (no location set) ──────────────────────
        if t.target_ethnicities and not (t.target_cities or t.target_states):
            new_ids = await _run_query(
                db,
                [func.lower(KycProfile.ethnicity_tribe).in_([e.lower() for e in t.target_ethnicities])],
                hard,
                self.seen,
            )
            for uid in new_ids:
                self.seen.add(uid)
            self._tier_results.append(TierResult(9, "ethnicity", new_ids, len(self.seen)))
            if len(self.seen) >= self.desired:
                return self._build_result("fulfilled", neighbouring_used)

        stop = "fulfilled" if len(self.seen) >= self.desired else "exhausted"
        return self._build_result(stop, neighbouring_used)

    def _build_result(self, stop_reason: str, neighbouring_used: list[str]) -> ExpansionResult:
        all_ids: list[uuid.UUID] = []
        seen_local: set[uuid.UUID] = set()
        for tr in self._tier_results:
            for uid in tr.new_ids:
                if uid not in seen_local:
                    seen_local.add(uid)
                    all_ids.append(uid)

        found = len(all_ids)
        pct = round((found / self.desired * 100), 2) if self.desired else 0.0

        # Build path log
        path: list[str] = []
        breakdown: dict[str, int] = {}
        tiers_exec: list[dict] = []
        for tr in self._tier_results:
            key = f"{tr.dimension}:tier{tr.tier}"
            if tr.location_context and "neighbour" in tr.dimension:
                key = f"neighbour:{tr.location_context}:tier{tr.tier}"
            breakdown[key] = breakdown.get(key, 0) + len(tr.new_ids)
            if len(tr.new_ids) > 0:
                path.append(f"{key} → +{len(tr.new_ids)} (total {tr.cumulative_total})")
                tiers_exec.append({
                    "dimension": tr.dimension,
                    "tier": tr.tier,
                    "new_count": len(tr.new_ids),
                    "cumulative": tr.cumulative_total,
                    "location_context": tr.location_context,
                })

        log.info(
            "TargetingEngine complete: found=%d desired=%d fulfillment=%.1f%% stop=%s neighbours=%s",
            found, self.desired, pct, stop_reason, neighbouring_used,
        )

        return ExpansionResult(
            worker_ids=all_ids[: self.desired],
            expansion_path=path,
            tiers_executed=tiers_exec,
            tier_contribution_breakdown=breakdown,
            fulfillment_percentage=pct,
            stop_reason=stop_reason,
            neighbouring_locations_used=neighbouring_used,
            desired_quantity=self.desired,
            found_quantity=found,
        )


# ─────────────────────────────────────────────────────────────────────────────
# Public API — backward-compatible entry point
# ─────────────────────────────────────────────────────────────────────────────

async def get_eligible_worker_ids(
    targeting: CampaignTargeting,
    desired: int,
    db: AsyncSession,
    current_tier: int = 1,          # kept for API compatibility; ignored internally
) -> list[uuid.UUID]:
    """
    Drop-in replacement for the original function.
    Returns a flat list of eligible worker UUIDs (trimmed to desired).
    """
    engine = TargetingEngine(targeting, desired)
    result = await engine.run(db)
    return result.worker_ids


async def get_eligible_workers_with_metadata(
    targeting: CampaignTargeting,
    desired: int,
    db: AsyncSession,
) -> ExpansionResult:
    """
    Extended entry point — returns the full ExpansionResult with audit metadata.
    Called by the campaigns analytics endpoint.
    """
    engine = TargetingEngine(targeting, desired)
    return await engine.run(db)
