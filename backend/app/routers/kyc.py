from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User, KycProfile
from app.schemas.kyc import KycSubmitRequest, KycStatusResponse
from app.services.storage import generate_presigned_upload_url

router = APIRouter(prefix="/kyc", tags=["kyc"])


@router.post("/upload-url")
async def kyc_upload_url(
    file_extension: str,
    current_user: User = Depends(require_worker),
):
    """Issue a short-lived private upload URL for a KYC document.

    The returned object key is always under ``kyc/`` so the submit schema
    cannot be abused to point at arbitrary storage locations.
    """
    try:
        return generate_presigned_upload_url(file_extension, folder="kyc")
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc


@router.post("/submit", status_code=201)
async def submit_kyc(
    body: KycSubmitRequest,
    current_user: User = Depends(require_worker),
    db: AsyncSession = Depends(get_db),
):
    ex = await db.execute(select(KycProfile).where(KycProfile.user_id == current_user.id))
    if ex.scalar_one_or_none():
        raise HTTPException(400, "KYC already submitted")
    db.add(KycProfile(user_id=current_user.id, **body.model_dump()))
    return {"message": "KYC submitted for review"}


@router.get("/status", response_model=KycStatusResponse)
async def kyc_status(
    current_user: User = Depends(require_worker),
    db: AsyncSession = Depends(get_db),
):
    r = await db.execute(select(KycProfile).where(KycProfile.user_id == current_user.id))
    profile = r.scalar_one_or_none()
    return KycStatusResponse(status="not_submitted" if not profile else profile.status)
