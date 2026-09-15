from pathlib import PurePosixPath

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User, KycProfile
from app.schemas.kyc import KycSubmitRequest, KycStatusResponse
from app.services.storage import generate_presigned_upload_url, validate_uploaded_object

router = APIRouter(prefix="/kyc", tags=["kyc"])

KYC_DOCUMENT_EXTENSIONS = {"jpg", "jpeg", "png", "webp", "pdf"}


def validate_kyc_document_ownership(user_id, document_key: str) -> None:
    if not document_key.startswith(f"kyc/{user_id}/"):
        raise HTTPException(status_code=403, detail="KYC document does not belong to this account")
    ext = PurePosixPath(document_key).suffix.lower().lstrip(".")
    if ext not in KYC_DOCUMENT_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Unsupported KYC document type")


@router.post("/upload-url")
async def kyc_upload_url(
    file_extension: str = Query(..., min_length=2, max_length=5),
    current_user: User = Depends(require_worker),
):
    extension = file_extension.strip().lower().lstrip(".")
    if extension not in KYC_DOCUMENT_EXTENSIONS:
        raise HTTPException(status_code=400, detail="KYC documents must be JPG, JPEG, PNG, WEBP or PDF")
    try:
        result = generate_presigned_upload_url(extension, folder=f"kyc/{current_user.id}")
        return {
            "upload_url": result["upload_url"],
            "file_key": result["file_key"],
            "content_type": result["content_type"],
            "expires_in_seconds": result["expires_in_seconds"],
        }
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

    validate_kyc_document_ownership(current_user.id, body.document_url)
    try:
        validate_uploaded_object(body.document_url, f"kyc/{current_user.id}")
    except ValueError as exc:
        raise HTTPException(400, str(exc)) from exc

    db.add(KycProfile(user_id=current_user.id, **body.model_dump()))
    try:
        await db.flush()
    except IntegrityError as exc:
        await db.rollback()
        raise HTTPException(409, "KYC already submitted") from exc
    return {"message": "KYC submitted for review"}


@router.get("/status", response_model=KycStatusResponse)
async def kyc_status(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(KycProfile).where(KycProfile.user_id == current_user.id))
    profile = r.scalar_one_or_none()
    return KycStatusResponse(status="not_submitted" if not profile else profile.status)
