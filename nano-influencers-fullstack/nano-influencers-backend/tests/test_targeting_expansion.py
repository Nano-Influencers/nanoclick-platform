from types import SimpleNamespace

from app.services.targeting_eligibility import (
    _expanded_age_matches,
    _expanded_gender_matches,
    _expanded_location_matches,
    _expanded_marital_matches,
)


def profile(**overrides):
    values = dict(
        primary_city="lagos",
        primary_state="lagos",
        secondary_locations=[],
        occupation_location=None,
        study_location=None,
        trade_school_niche=None,
        group_descriptions=[],
        majority_follower_location=None,
        state_of_origin=None,
        town_of_origin=None,
        languages_spoken=[],
        ethnicity_tribe=None,
        gender="male",
        gender_group_membership=None,
        age_bracket="25-34",
        marital_status="single",
        marital_group_keywords=[],
    )
    values.update(overrides)
    return SimpleNamespace(**values)


def targeting(**overrides):
    values = dict(
        target_cities=["abuja"],
        target_states=["fct"],
    )
    values.update(overrides)
    return SimpleNamespace(**values)


def test_location_tier_one_rejects_non_primary_location():
    assert not _expanded_location_matches(profile(), targeting(), 1)


def test_location_tier_two_accepts_secondary_location():
    p = profile(secondary_locations=["abuja"])
    assert _expanded_location_matches(p, targeting(), 2)


def test_location_tier_three_accepts_occupation_location():
    p = profile(occupation_location="abuja")
    assert _expanded_location_matches(p, targeting(), 3)


def test_gender_tier_two_accepts_group_membership():
    p = profile(gender="female", gender_group_membership="male_group")
    assert _expanded_gender_matches(p, {"male"}, 2)


def test_age_tier_two_accepts_adjacent_bracket():
    assert _expanded_age_matches("18-24", {"25-34"}, 2)


def test_marital_tier_three_accepts_adjacent_status():
    assert _expanded_marital_matches(profile(marital_status="widowed"), {"married"}, 3)



def test_try_for_free_tasks_are_unpaid_but_award_click_points():
    from app.services.clickpoints import calculate_click_points, calculate_worker_pay_kobo

    assert calculate_worker_pay_kobo(10_000, "like", tni_service_type="try_for_free") == 0
    assert calculate_click_points("unpaid", 0) == 500
