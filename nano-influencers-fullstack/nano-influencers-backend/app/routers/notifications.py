import uuid
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, update, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.rewards import Notification
from app.schemas.notification import NotificationResponse, UnreadCountResponse
from app.services.notification_service import notification_is_enabled

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationResponse])
async def list_notifications(
    unread_only: bool = Query(False),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    conds = [Notification.user_id == current_user.id]
    if unread_only:
        conds.append(Notification.is_read == False)  # noqa: E712
    result = await db.execute(
        select(Notification)
        .where(*conds)
        .order_by(Notification.created_at.desc(), Notification.id.desc())
    )
    visible = [
        item for item in result.scalars().all()
        if notification_is_enabled(item.type, current_user.notification_preferences)
    ]
    return visible[offset:offset + limit]


@router.get("/unread-count", response_model=UnreadCountResponse)
async def unread_count(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Notification).where(
        Notification.user_id == current_user.id, Notification.is_read == False
    ))  # noqa: E712
    count = sum(
        1 for item in result.scalars().all()
        if notification_is_enabled(item.type, current_user.notification_preferences)
    )
    return UnreadCountResponse(count=count)


@router.post("/{notification_id}/read")
async def mark_read(notification_id: uuid.UUID, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Notification).where(Notification.id == notification_id, Notification.user_id == current_user.id))
    n = result.scalar_one_or_none()
    if not n: raise HTTPException(404, "Notification not found")
    n.is_read = True
    return {"message": "Marked as read"}


@router.post("/read-all")
async def mark_all_read(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    await db.execute(update(Notification).where(Notification.user_id == current_user.id, Notification.is_read == False).values(is_read=True))  # noqa: E712
    return {"message": "All notifications marked as read"}
