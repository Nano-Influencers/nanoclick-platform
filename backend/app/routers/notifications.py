import uuid
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, update, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.rewards import Notification
from app.schemas.notification import NotificationResponse, UnreadCountResponse

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationResponse])
async def list_notifications(unread_only: bool = Query(False), current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    conds = [Notification.user_id == current_user.id]
    if unread_only:
        conds.append(Notification.is_read == False)  # noqa: E712
    result = await db.execute(select(Notification).where(*conds).order_by(Notification.created_at.desc()).limit(100))
    return list(result.scalars())


@router.get("/unread-count", response_model=UnreadCountResponse)
async def unread_count(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(func.count(Notification.id)).where(
        Notification.user_id == current_user.id, Notification.is_read == False))  # noqa: E712
    return UnreadCountResponse(count=result.scalar() or 0)


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
