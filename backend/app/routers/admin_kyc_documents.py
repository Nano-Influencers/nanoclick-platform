import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_admin
from app.models.user import KycProfile, User
from app.services.storage import generate_presigned_download_url

router = APIRouter(prefix="/admin/kyc", tags=["admin-kyc"])


@router.get("/{user_id}/document-url")
async def kyc_document_url(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Issue a short-lived private URL for an authorized KYC review."""
    result = await db.execute(
        select(KycProfile).where(KycProfile.user_id == user_id)
    )
    kyc = result.scalar_one_or_none()
    if not kyc or not kyc.document_url:
        raise HTTPException(404, "KYC document not found")

    if not kyc.document_url.startswith(f"kyc/{user_id}/"):
        raise HTTPException(500, "Stored KYC document has an invalid ownership key")

    try:
        signed = generate_presigned_download_url(kyc.document_url, expires_in=300)
    except ValueError as exc:
        raise HTTPException(400, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(503, detail=str(exc)) from exc

    return {"user_id": str(user_id), **signed}
