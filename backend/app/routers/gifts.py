from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User
from app.schemas.gifts import GiftEntryResponse, GiftWinnerResponse
from app.services import gifts_service

router = APIRouter(prefix="/rewards/gifts", tags=["rewards-gifts"])

@router.get("")
async def list_active_gifts(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    campaigns, entered = await gifts_service.active(db, current_user.id)
    return {"gifts": [{"id": str(c.id), "title": c.title, "description": c.description, "image_url": c.image_url,
        "prize_name": c.prize_name, "starts_at": c.starts_at, "ends_at": c.ends_at,
        "entry_cost_points": c.entry_cost_points, "max_winners": c.max_winners, "entered": c.id in entered, "status": c.status} for c in campaigns]}

@router.post("/{campaign_id}/enter", response_model=GiftEntryResponse)
async def enter_gift(campaign_id: str, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    import uuid
    response = await gifts_service.enter(db, current_user.id, uuid.UUID(campaign_id))
    await db.commit()
    return response

@router.get("/my-wins", response_model=list[GiftWinnerResponse])
async def my_gift_wins(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    return await gifts_service.winners(db, current_user.id)
