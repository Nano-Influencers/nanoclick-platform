import uuid
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.user import User
from app.models.auth_session import AuthSession
from app.services.auth_service import hash_token_identifier
from datetime import datetime
from app.services.auth_service import decode_token
import pyotp
from app.services.secret_encryption import decrypt_secret, encrypt_secret, is_encrypted

bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    payload = decode_token(credentials.credentials)
    if not payload or payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        user_id = uuid.UUID(payload["sub"])
    except (ValueError, TypeError, KeyError):
        raise HTTPException(status_code=401, detail="Invalid authentication subject", headers={"WWW-Authenticate": "Bearer"})
    session_jti = payload.get("sid")
    if session_jti:
        session_result = await db.execute(select(AuthSession).where(AuthSession.token_jti_hash == hash_token_identifier(str(session_jti))))
        session = session_result.scalar_one_or_none()
        if not session or session.revoked_at is not None or session.expires_at <= datetime.utcnow():
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session revoked or expired", headers={"WWW-Authenticate": "Bearer"})
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found", headers={"WWW-Authenticate": "Bearer"})
    return user


async def require_advertiser(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in ("advertiser", "admin"):
        raise HTTPException(status_code=403, detail="Advertiser access required")
    return current_user


async def require_worker(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in ("worker", "admin"):
        raise HTTPException(status_code=403, detail="Worker access required")
    return current_user


async def require_kyc(current_user: User = Depends(require_worker)) -> User:
    if not current_user.kyc_verified:
        raise HTTPException(status_code=403, detail="KYC verification required to access targeted tasks")
    return current_user


async def require_admin(request: Request, current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    # MFA enrollment is the only administrative operation allowed before MFA
    # is enabled. Once enabled, every other admin endpoint requires a valid
    # six-digit TOTP code in X-Admin-MFA-Code.
    if request.url.path in {"/admin/mfa/setup", "/admin/mfa/enable"}:
        return current_user
    if not current_user.mfa_enabled or not current_user.mfa_secret:
        raise HTTPException(status_code=403, detail="Admin MFA must be enabled before using this endpoint")
    code = request.headers.get("X-Admin-MFA-Code", "").strip()
    stored_secret = decrypt_secret(current_user.mfa_secret)\n    if not is_encrypted(current_user.mfa_secret):\n        current_user.mfa_secret = encrypt_secret(stored_secret)\n    if not code or not pyotp.TOTP(stored_secret).verify(code, valid_window=1):
        raise HTTPException(status_code=401, detail="Valid admin MFA code required")
    return current_user
