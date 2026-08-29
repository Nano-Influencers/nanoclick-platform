from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User
from app.services import rewards_service
from app.schemas.rewards import RewardProgressResponse

router = APIRouter(prefix="/rewards", tags=["rewards"])


@router.get("/progress", response_model=RewardProgressResponse)
async def reward_progress(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    """Grit/Gratis achievement-track progress, computed from approved
    submissions (see app/services/rewards_service.py for the inferred
    Level thresholds and the rationale for the pooled Level-10 payout)."""
    return await rewards_service.get_progress(db, current_user.id)
