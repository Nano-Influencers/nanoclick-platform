import pyotp
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_admin
from app.models.user import User

router = APIRouter(prefix="/admin/mfa", tags=["admin-mfa"])


@router.post("/setup")
async def setup_mfa(current_user: User = Depends(require_admin), db: AsyncSession = Depends(get_db)):
    if current_user.mfa_enabled:
        raise HTTPException(400, "Admin MFA is already enabled")
    secret = pyotp.random_base32()
    current_user.mfa_secret = secret
    issuer = "NanoClick"
    uri = pyotp.TOTP(secret).provisioning_uri(name=current_user.email, issuer_name=issuer)
    return {
        "message": "Scan the provisioning URI with an authenticator app, then confirm with a current code.",
        "secret": secret,
        "otpauth_uri": uri,
    }


@router.post("/enable")
async def enable_mfa(code: str, current_user: User = Depends(require_admin), db: AsyncSession = Depends(get_db)):
    if not current_user.mfa_secret:
        raise HTTPException(400, "Run MFA setup first")
    if not pyotp.TOTP(current_user.mfa_secret).verify(code.strip(), valid_window=1):
        raise HTTPException(401, "Invalid MFA code")
    current_user.mfa_enabled = True
    return {"message": "Admin MFA enabled"}
