from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_worker
from app.models.user import User, KycProfile
from app.schemas.kyc import KycSubmitRequest, KycStatusResponse
from app.services.storage import generate_presigned_upload_url

router = APIRouter(prefix="/kyc", tags=["kyc"])


def validate_kyc_document_ownership(user_id, document_key: str | None) -> None:
    """Reject KYC object keys that were not issued under the authenticated worker."""
    if document_key and not document_key.startswith(f"kyc/{user_id}/"):
        raise HTTPException(status_code=403, detail="KYC document does not belong to this account")


@router.post("/upload-url")
async def kyc_upload_url(
    file_extension: str,
    current_user: User = Depends(require_worker),
):
    """Issue a short-lived private upload URL for the current worker's KYC document."""
    try:
        result = generate_presigned_upload_url(
            file_extension,
            folder=f"kyc/{current_user.id}",
        )
        # Never expose a public object URL for an identity document.
        return {
            "upload_url": result["upload_url"],
            "file_key": result["file_key"],
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
