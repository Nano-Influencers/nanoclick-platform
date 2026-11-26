from pydantic import BaseModel, Field, EmailStr
from fastapi import APIRouter, Depends, HTTPException
from app.config import settings
from app.dependencies import get_current_user
from app.models.user import User
from app.services.email_service import send_support_message

router = APIRouter(prefix="/support", tags=["support"])


class SupportContactRequest(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    message: str = Field(min_length=10, max_length=5000)


@router.post("/contact", status_code=202)
async def contact_support(body: SupportContactRequest, current_user: User = Depends(get_current_user)):
    recipient = settings.SUPPORT_EMAIL.strip()
    if not recipient:
        raise HTTPException(503, "Support contact is temporarily unavailable.")
    try:
        await send_support_message(recipient, body.name.strip(), body.email.strip().lower(), body.message.strip())
    except Exception:
        raise HTTPException(503, "Unable to send your support request right now.")
    return {"detail": "Your support request has been sent."}
