from datetime import datetime, timezone, timedelta

from app.services.clickpoints import calculate_click_points, calculate_worker_pay_kobo


def test_worker_pay_default_is_forty_percent():
    assert calculate_worker_pay_kobo(1000, "like") == 400


def test_personalized_comment_is_thirty_percent():
    assert calculate_worker_pay_kobo(1000, "comment", comment_subtype="personalized") == 300


def test_trend_is_flat_rate():
    assert calculate_worker_pay_kobo(1000, "trend", tni_service_type="trend_on_x") == 300


def test_urgent_midnight_multiplier():
    wat = timezone(timedelta(hours=1))
    midnight = datetime(2026, 1, 10, 1, 0, tzinfo=wat)
    assert calculate_click_points("one_off_single", 1000, is_urgent=True, submitted_at=midnight) == 300


def test_unpaid_midnight_bonus():
    wat = timezone(timedelta(hours=1))
    midnight = datetime(2026, 1, 10, 2, 0, tzinfo=wat)
    assert calculate_click_points("unpaid", 0, submitted_at=midnight) == 1500
