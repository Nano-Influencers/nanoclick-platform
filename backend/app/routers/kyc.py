from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User, KycProfile

router = APIRouter(prefix="/kyc", tags=["kyc"])

@router.post("/submit", status_code=201)
async def submit_kyc(body: dict, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    ex = await db.execute(select(KycProfile).where(KycProfile.user_id==current_user.id))
    if ex.scalar_one_or_none(): raise HTTPException(400, "KYC already submitted")
    safe_fields = {k: v for k, v in body.items() if hasattr(KycProfile, k) and k not in ("id","user_id","status","submitted_at","reviewed_at")}
    db.add(KycProfile(user_id=current_user.id, **safe_fields))
    return {"message": "KYC submitted for review"}

@router.get("/status")
async def kyc_status(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(KycProfile).where(KycProfile.user_id==current_user.id))
    profile = r.scalar_one_or_none()
    return {"status": "not_submitted" if not profile else profile.status}
