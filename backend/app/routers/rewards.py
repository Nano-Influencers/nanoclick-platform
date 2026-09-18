from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User
from app.services import rewards_service
from app.schemas.rewards import RewardProgressResponse
from app.schemas.treasure import TreasureClaimRequest, TreasureHintResponse

router = APIRouter(prefix="/rewards", tags=["rewards"])


@router.get("/progress", response_model=RewardProgressResponse)
async def reward_progress(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    """Grit/Gratis achievement-track progress, computed from approved
    submissions (see app/services/rewards_service.py for the inferred
    Level thresholds and the rationale for the pooled Level-10 payout)."""
    return await rewards_service.get_progress(db, current_user.id)


@router.get("/treasure")
async def active_treasure(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    result = await treasure_service.get_active(db, current_user.id)
    if not result:
        return {"active": False}
    campaign, participation = result
    return {"active": True, "treasure": (await treasure_service.to_response(db, campaign, participation)).model_dump()}

@router.post("/treasure/participate")
async def participate_treasure(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    campaign, _ = await treasure_service.participate(db, current_user.id)
    await db.commit()
    return {"status": "participating", "treasure_id": str(campaign.id)}

@router.post("/treasure/hint", response_model=TreasureHintResponse)
async def treasure_hint(use_earnings: bool = False, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    response = await treasure_service.use_hint(db, current_user.id, use_earnings)
    await db.commit()
    return response

@router.post("/treasure/claim")
async def claim_treasure(payload: TreasureClaimRequest, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    response = await treasure_service.claim(db, current_user.id, payload.claim_code)
    await db.commit()
    return response
