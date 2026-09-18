from fastapi import APIRouter, Depends
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from sqlalchemy import select
from app.config import settings
from app.dependencies import require_worker
from app.models.user import User
from app.services import rewards_service, treasure_service
from app.schemas.rewards import RewardProgressResponse, TryForFreeResponse, RewardsDashboardResponse
from app.models.wallet import Wallet
from app.models.task import LeaderboardScore
from app.services import gifts_service
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


@router.get("/try-for-free", response_model=TryForFreeResponse)
async def try_for_free(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    return await rewards_service.get_try_for_free(db, current_user.id)


@router.get("/dashboard", response_model=RewardsDashboardResponse)
async def rewards_dashboard(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    progress = await rewards_service.get_progress(db, current_user.id)
    try_free = await rewards_service.get_try_for_free(db, current_user.id)

    wallet = (await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))).scalar_one_or_none()
    now = datetime.utcnow()
    next_spin = None
    if wallet and wallet.last_spin_at:
        candidate = wallet.last_spin_at + timedelta(hours=settings.SPIN_COOLDOWN_HOURS)
        if candidate > now:
            next_spin = candidate.isoformat() + "Z"

    treasure_result = await treasure_service.get_active(db, current_user.id)
    treasure = None
    if treasure_result:
        campaign, participation = treasure_result
        treasure = await treasure_service.to_response(db, campaign, participation)

    gift_campaigns, entered = await gifts_service.active(db, current_user.id)
    gifts = [{
        "id": str(g.id),
        "title": g.title,
        "description": g.description,
        "image_url": g.image_url,
        "prize_name": g.prize_name,
        "starts_at": g.starts_at,
        "ends_at": g.ends_at,
        "entry_cost_points": g.entry_cost_points,
        "max_winners": g.max_winners,
        "entered": g.id in entered,
        "status": g.status,
    } for g in gift_campaigns]

    scores = (await db.execute(
        select(LeaderboardScore).where(LeaderboardScore.period == "weekly")
        .order_by(LeaderboardScore.total_score.desc()).limit(3)
    )).scalars().all()

    return {
        "progress": progress,
        "spin_available": next_spin is None,
        "next_spin_at": next_spin,
        "try_for_free": try_free,
        "treasure": treasure,
        "gifts": gifts,
        "leaderboard": {
            "period": "weekly",
            "top": [{
                "rank": s.rank or 0,
                "worker_id": str(s.worker_id),
                "total_score": s.total_score,
            } for s in scores],
        },
    }
