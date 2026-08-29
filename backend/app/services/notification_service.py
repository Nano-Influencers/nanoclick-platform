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


async def notify(
    db: AsyncSession,
    user_id: uuid.UUID,
    type: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> Notification:
    n = Notification(user_id=user_id, type=type, title=title, body=body, data=data)
    db.add(n)
    return n
