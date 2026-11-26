"""
Persisted notification feed. Both apps previously had no real notification
storage: click-workers relied on ad-hoc Firestore documents, and
nano-influencers rendered a hardcoded static list. This gives both a single
backend-owned feed, polled via GET /notifications.

Real-time push (SSE/WebSocket) is a natural next step once this is wired up,
but is out of scope here — see docs/architecture.md.
"""
import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.rewards import Notification
from app.models.user import User
from sqlalchemy import select


def notification_preference_keys(notification_type: str) -> tuple[str, ...]:
    kind = (notification_type or "").lower()
    if any(token in kind for token in ("deposit", "withdraw", "wallet", "payment", "refund")):
        return ("emailWallet", "pushWallet", "smsCritical")
    if any(token in kind for token in ("message", "chat", "support")):
        return ("pushMessages",)
    if any(token in kind for token in ("campaign", "task", "submission", "proof", "cashback", "worker")):
        return ("emailCampaign", "pushCampaign")
    if any(token in kind for token in ("marketing", "promotion", "newsletter")):
        return ("emailMarketing",)
    return ()


def notification_is_enabled(notification_type: str, preferences: dict | None) -> bool:
    keys = notification_preference_keys(notification_type)
    return bool(keys and preferences and any(preferences.get(key) is True for key in keys))


async def notify(
    db: AsyncSession,
    user_id: uuid.UUID,
    type: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> Notification | None:
    user = await db.scalar(select(User).where(User.id == user_id))
    if not user or not notification_is_enabled(type, user.notification_preferences):
        return None
    n = Notification(user_id=user_id, type=type, title=title, body=body, data=data)
    db.add(n)
    return n
