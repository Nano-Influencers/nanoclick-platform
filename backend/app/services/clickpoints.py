"""
ClickPoints calculation engine.
All formulas from New_Click_Points.docx and Click_Points.docx.
"""
from datetime import datetime, timezone, timedelta

WAT = timezone(timedelta(hours=1))

_BASE_MULTIPLIER: dict[str, int] = {
    "one_off_single":    2,
    "one_off_grouped":   2,
    "repeating_grouped": 200,
    "repeating_single":  500,
    "trend_push":        1000,
    "skill_based":       50,
    "unpaid":            0,
}

UNPAID_FLAT_CPS = 500


def is_midnight_window(dt: datetime | None = None) -> bool:
    """True if the datetime falls in the midnight bonus window (00:00–05:00 WAT)."""
    from app.config import settings
    now_wat = (dt or datetime.now(timezone.utc)).astimezone(WAT)
    return settings.MIDNIGHT_START_HOUR <= now_wat.hour < settings.MIDNIGHT_END_HOUR


def calculate_click_points(
    cw_task_category: str,
    worker_pay_kobo: int,
    is_urgent: bool = False,
    submitted_at: datetime | None = None,
) -> int:
    midnight = is_midnight_window(submitted_at)

    if cw_task_category == "unpaid":
        return UNPAID_FLAT_CPS * (3 if midnight else 1)

    amount_ngn = worker_pay_kobo / 100
    base_multiplier = _BASE_MULTIPLIER.get(cw_task_category, 2)
    base_cps = amount_ngn * base_multiplier

    if is_urgent and midnight:
        return int(base_cps * 15)
    if is_urgent:
        return int(base_cps * 5)
    if midnight:
        return int(base_cps * 3)
    return int(base_cps)


def calculate_worker_pay_kobo(
    client_price_per_action_kobo: int,
    action_type: str,
    comment_subtype: str | None = None,
    video_subtype: str | None = None,
    tni_service_type: str | None = None,
) -> int:
    # Twitter Trend: flat ₦3 (300 kobo) regardless of client price
    if tni_service_type == "trend_on_x" or action_type == "trend":
        return 300

    if action_type == "comment":
        if comment_subtype == "personalized":
            return int(client_price_per_action_kobo * 0.30)
        if comment_subtype in ("premium", "interactive"):
            return int(client_price_per_action_kobo * 0.20)

    if video_subtype in (
        "personalized_video_tip", "premium_video_tip",
        "personalized_duet_tip",  "premium_duet_tip",
        "personalized_stitch_tip","premium_stitch_tip",
        "personalized_collab_tip","premium_collab_tip",
    ):
        return int(client_price_per_action_kobo * 0.30)

    if action_type == "quote_tweet":
        if video_subtype == "personalized_writeup":
            return int(client_price_per_action_kobo * 0.30)
        if video_subtype == "premium_writeup":
            return int(client_price_per_action_kobo * 0.20)

    return int(client_price_per_action_kobo * 0.40)
