from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User, KycProfile
from app.schemas.kyc import KycSubmitRequest, KycStatusResponse

router = APIRouter(prefix="/kyc", tags=["kyc"])

@router.post("/submit", status_code=201)
async def submit_kyc(body: KycSubmitRequest, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    ex = await db.execute(select(KycProfile).where(KycProfile.user_id==current_user.id))
    if ex.scalar_one_or_none(): raise HTTPException(400, "KYC already submitted")
    db.add(KycProfile(user_id=current_user.id, **body.model_dump()))
    return {"message": "KYC submitted for review"}

@router.get("/status", response_model=KycStatusResponse)
async def kyc_status(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(KycProfile).where(KycProfile.user_id==current_user.id))
    profile = r.scalar_one_or_none()
    return KycStatusResponse(status="not_submitted" if not profile else profile.status)
