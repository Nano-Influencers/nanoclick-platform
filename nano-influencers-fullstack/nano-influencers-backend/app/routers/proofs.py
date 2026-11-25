import uuid

from fastapi import APIRouter, Depends, HTTPException, Query

from app.dependencies import require_worker
from app.models.user import User
from app.services.storage import generate_presigned_download_url, validate_uploaded_object

router = APIRouter(prefix="/tasks", tags=["task-proofs"])


@router.get("/proof-url")
async def get_proof_download_url(
    file_key: str = Query(..., min_length=1, max_length=500),
    current_user: User = Depends(require_worker),
):
    """Return a short-lived signed URL for a worker-owned proof object."""
    required_prefix = f"proofs/{uuid.UUID(str(current_user.id))}"
    try:
        validate_uploaded_object(file_key, required_prefix)
        return generate_presigned_download_url(file_key, expires_in=300)
    except ValueError as exc:
        raise HTTPException(403, str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(503, str(exc)) from exc
