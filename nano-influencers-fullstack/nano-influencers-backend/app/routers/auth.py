import hashlib
import hmac
import logging
import secrets
import uuid
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response
from fastapi.responses import RedirectResponse
from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.database import get_db
from app.dependencies import get_current_user
from app.models.auth_session import AuthSession, OAuthCode, OAuthState
from app.models.email_otp import EmailOTP
from app.models.password_reset import PasswordResetToken
from app.models.user import User
from app.models.wallet import Wallet
from app.schemas.auth import ChangePasswordRequest, ForgotPasswordRequest, LoginRequest, RefreshRequest, RegisterRequest, ResetPasswordRequest, TokenResponse, UserResponse, SendOTPRequest, VerifyOTPRequest, UpdateProfileRequest
from app.services.auth_service import create_access_token, create_refresh_token, decode_token, generate_referral_code, hash_password, hash_token_identifier, new_oauth_state, token_jti, verify_password
from app.services.email_service import send_password_reset_email, send_verification_otp
from app.services.pending_registration import (acquire_pending_lock, delete_pending_registration, load_pending_registration, release_pending_lock, save_pending_registration)
from app.services.oauth_service import exchange_facebook_code, exchange_google_code, facebook_auth_url, google_auth_url

router = APIRouter(prefix="/auth", tags=["auth"])
logger = logging.getLogger(__name__)
_COOKIE_NAME = "nanoclick_refresh"
_COOKIE_PATH = "/auth"


def _validate_redirect_uri(redirect_uri: str | None) -> str | None:
    if not redirect_uri:
        return None
    allowed = [o.strip().rstrip("/") for o in settings.OAUTH_ALLOWED_WEB_REDIRECTS.split(",") if o.strip()]
    for origin in allowed:
        if redirect_uri == origin or redirect_uri.startswith(origin + "/") or redirect_uri.startswith(origin + "?"):
            return redirect_uri
    return None


def _is_web_platform(platform: str) -> bool:
    return platform.strip().lower() == "web"


def _set_refresh_cookie(response: Response, refresh_token: str) -> None:
    response.set_cookie(key=_COOKIE_NAME, value=refresh_token, max_age=settings.REFRESH_TOKEN_EXPIRE_DAYS * 86400, httponly=True, secure=settings.AUTH_COOKIE_SECURE, samesite=settings.AUTH_COOKIE_SAMESITE.lower(), path=_COOKIE_PATH)


def _clear_refresh_cookie(response: Response) -> None:
    response.delete_cookie(key=_COOKIE_NAME, path=_COOKIE_PATH)


async def _create_refresh_session(db: AsyncSession, user_id: uuid.UUID, refresh_token: str) -> None:
    jti = token_jti(refresh_token)
    if not jti:
        raise HTTPException(500, "Failed to create authentication session")
    payload = decode_token(refresh_token)
    db.add(AuthSession(user_id=user_id, token_jti_hash=hash_token_identifier(jti), expires_at=datetime.utcfromtimestamp(payload["exp"])))


async def _issue_tokens(db: AsyncSession, user: User) -> TokenResponse:
    access = create_access_token(str(user.id), user.role)
    refresh = create_refresh_token(str(user.id))
    await _create_refresh_session(db, user.id, refresh)
    return TokenResponse(access_token=access, refresh_token=refresh)


async def _revoke_user_sessions(db: AsyncSession, user_id: uuid.UUID) -> None:
    await db.execute(update(AuthSession).where(AuthSession.user_id == user_id, AuthSession.revoked_at.is_(None)).values(revoked_at=datetime.utcnow()))


async def _upsert_oauth_user(db: AsyncSession, provider_data, role="worker"):
    if not provider_data.get("email") or not provider_data.get("email_verified"):
        raise HTTPException(403, "A verified email address is required for social login")
    result = await db.execute(select(User).where(User.oauth_provider == provider_data["provider"], User.oauth_provider_id == provider_data["provider_id"]))
    user = result.scalar_one_or_none()
    if user:
        if not user.is_active:
            raise HTTPException(403, "Account disabled")
        return user
    result = await db.execute(select(User).where(User.email == provider_data["email"]))
    user = result.scalar_one_or_none()
    if user:
        if not user.is_active:
            raise HTTPException(403, "Account disabled")
        user.email_verified = True
        user.oauth_provider = provider_data["provider"]
        user.oauth_provider_id = provider_data["provider_id"]
        return user
    user = User(email=provider_data["email"], password_hash=None, full_name=provider_data.get("full_name") or provider_data["email"].split("@")[0], role=role, referral_code=generate_referral_code(), oauth_provider=provider_data["provider"], oauth_provider_id=provider_data["provider_id"], email_verified=True)
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id))
    return user


async def _begin_oauth(db: AsyncSession, role: str, platform: str, redirect_uri: str | None) -> str:
    state = new_oauth_state()
    db.add(OAuthState(nonce_hash=hash_token_identifier(state), role=role, platform=platform, redirect_uri=redirect_uri, expires_at=datetime.utcnow() + timedelta(minutes=10)))
    await db.flush()
    return state


async def _consume_oauth_state(db: AsyncSession, state: str) -> OAuthState:
    if not state:
        raise HTTPException(400, "Missing OAuth state")
    result = await db.execute(select(OAuthState).where(OAuthState.nonce_hash == hash_token_identifier(state)).with_for_update())
    record = result.scalar_one_or_none()
    if not record or record.consumed_at is not None or record.expires_at < datetime.utcnow():
        raise HTTPException(400, "Invalid or expired OAuth state")
    record.consumed_at = datetime.utcnow()
    return record


async def _oauth_redirect(db: AsyncSession, user: User, platform: str, redirect_uri: str | None):
    code = secrets.token_urlsafe(32)
    db.add(OAuthCode(code_hash=hash_token_identifier(code), user_id=user.id, redirect_uri=redirect_uri, expires_at=datetime.utcnow() + timedelta(minutes=2)))
    await db.flush()
    base = redirect_uri or settings.OAUTH_WEB_REDIRECT_URL if platform == "web" else "nanoclick://oauth"
    sep = "&" if "?" in base else "?"
    return RedirectResponse(url=f"{base}{sep}oauth_code={code}", status_code=302)


@router.post("/register", status_code=202)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    """Stage a registration in Redis; create no database user until OTP succeeds."""
    email = str(body.email).strip()
    full_name = body.full_name.strip()
    existing = await db.execute(select(User).where(func.lower(User.email) == email.lower()))
    if existing.scalar_one_or_none():
        raise HTTPException(409, "Email already registered")

    referred_by = None
    if body.referral_code:
        ref = await db.execute(select(User).where(User.referral_code == body.referral_code))
        referral_user = ref.scalar_one_or_none()
        if referral_user:
            referred_by = str(referral_user.id)

    code = f"{secrets.randbelow(1_000_000):06d}"
    await save_pending_registration(email, {
        "email": email,
        "full_name": full_name,
        "password_hash": hash_password(body.password),
        "role": body.role,
        "referred_by": referred_by,
        "otp_hash": _otp_digest(code, email),
        "attempts": 0,
    })
    email_sent = True
    try:
        await send_verification_otp(email, code)
    except Exception:
        # Keep the temporary registration so the user can retry delivery.
        email_sent = False
        logger.exception("Registration OTP delivery failed")
    return {
        "detail": "Registration is pending email verification.",
        "email_sent": email_sent,
    }


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, response: Response, platform: str = Query("app"), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if not user: raise HTTPException(401, "Invalid credentials")
    if user.password_hash is None: raise HTTPException(400, f"This account uses {user.oauth_provider or 'social'} login")
    if not verify_password(body.password, user.password_hash): raise HTTPException(401, "Invalid credentials")
    if not user.is_active: raise HTTPException(403, "Account disabled")
    if not user.email_verified: raise HTTPException(403, "Please verify your email before signing in")
    tokens = await _issue_tokens(db, user)
    if _is_web_platform(platform):
        _set_refresh_cookie(response, tokens.refresh_token)
        tokens.refresh_token = None
    return tokens


@router.post("/refresh", response_model=TokenResponse)
async def refresh(request: Request, response: Response, body: RefreshRequest | None = None, platform: str = Query("app"), db: AsyncSession = Depends(get_db)):
    supplied_refresh = body.refresh_token if body else None
    refresh_token = supplied_refresh or request.cookies.get(_COOKIE_NAME)
    if not refresh_token: raise HTTPException(401, "Refresh token required")
    payload = decode_token(refresh_token)
    if not payload or payload.get("type") != "refresh" or not payload.get("jti"): raise HTTPException(401, "Invalid refresh token")
    result = await db.execute(select(AuthSession).where(AuthSession.token_jti_hash == hash_token_identifier(payload["jti"])).with_for_update())
    session = result.scalar_one_or_none()
    if not session or session.revoked_at is not None or session.expires_at < datetime.utcnow(): raise HTTPException(401, "Refresh session expired or revoked")
    try: user_id = uuid.UUID(payload["sub"])
    except (ValueError, TypeError): raise HTTPException(401, "Invalid refresh token")
    if session.user_id != user_id: raise HTTPException(401, "Invalid refresh session")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active: raise HTTPException(401, "User not found")
    session.revoked_at = datetime.utcnow(); session.last_used_at = datetime.utcnow()
    tokens = await _issue_tokens(db, user)
    new_jti = token_jti(tokens.refresh_token)
    session.replaced_by_jti_hash = hash_token_identifier(new_jti) if new_jti else None
    if _is_web_platform(platform) or not supplied_refresh:
        _set_refresh_cookie(response, tokens.refresh_token); tokens.refresh_token = None
    return tokens


@router.post("/logout")
async def logout(request: Request, response: Response, body: RefreshRequest | None = None, platform: str = Query("app"), db: AsyncSession = Depends(get_db)):
    refresh_token = (body.refresh_token if body else None) or request.cookies.get(_COOKIE_NAME)
    if refresh_token:
        payload = decode_token(refresh_token); jti = payload.get("jti") if payload and payload.get("type") == "refresh" else None
        if jti:
            result = await db.execute(select(AuthSession).where(AuthSession.token_jti_hash == hash_token_identifier(jti)).with_for_update())
            session = result.scalar_one_or_none()
            if session and session.revoked_at is None: session.revoked_at = datetime.utcnow()
    if _is_web_platform(platform) or request.cookies.get(_COOKIE_NAME): _clear_refresh_cookie(response)
    return {"message": "Logged out"}


@router.post("/oauth/exchange", response_model=TokenResponse)
async def exchange_oauth_code(response: Response, code: str = Query(..., min_length=20, max_length=200), platform: str = Query("app"), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(OAuthCode).where(OAuthCode.code_hash == hash_token_identifier(code)).with_for_update())
    record = result.scalar_one_or_none()
    if not record or record.used_at is not None or record.expires_at < datetime.utcnow(): raise HTTPException(401, "Invalid or expired OAuth code")
    user_result = await db.execute(select(User).where(User.id == record.user_id)); user = user_result.scalar_one_or_none()
    if not user or not user.is_active: raise HTTPException(401, "User not found")
    record.used_at = datetime.utcnow(); tokens = await _issue_tokens(db, user)
    if _is_web_platform(platform): _set_refresh_cookie(response, tokens.refresh_token); tokens.refresh_token = None
    return tokens


@router.get("/me", response_model=UserResponse)
async def me(current_user: User = Depends(get_current_user)): return current_user


@router.patch("/me/profile", response_model=UserResponse)
async def update_my_profile(
    body: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
):
    changes = body.model_dump(exclude_unset=True)
    if "full_name" in changes:
        current_user.full_name = changes["full_name"]
    if "phone_number" in changes:
        current_user.phone_number = changes["phone_number"]
    return current_user


@router.post("/change-password")
async def change_password(body: ChangePasswordRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    if current_user.password_hash is None: raise HTTPException(400, f"This account uses {current_user.oauth_provider or 'social'} login and has no password to change")
    if not verify_password(body.current_password, current_user.password_hash): raise HTTPException(401, "Current password is incorrect")
    if len(body.new_password) < 8: raise HTTPException(400, "New password must be at least 8 characters")
    current_user.password_hash = hash_password(body.new_password); await _revoke_user_sessions(db, current_user.id)
    return {"message": "Password changed; please sign in again"}


@router.post("/forgot-password")
async def forgot_password(body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if user and user.password_hash is not None:
        token = secrets.token_urlsafe(32)
        db.add(PasswordResetToken(user_id=user.id, token=hash_token_identifier(token), expires_at=datetime.utcnow() + timedelta(hours=1)))
        await db.flush()
        try:
            await send_password_reset_email(user.email, token)
        except Exception:
            # Keep the external response identical to the unknown-account path
            # so SMTP outages cannot become an account-enumeration oracle.
            # The exception is logged server-side without exposing provider details.
            logger.exception("Password reset email delivery failed")
    return {"message": "If that email is registered, a password reset link has been sent."}


@router.post("/reset-password")
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(PasswordResetToken).where(PasswordResetToken.token == hash_token_identifier(body.token)).with_for_update())
    reset_token = result.scalar_one_or_none()
    if not reset_token or reset_token.used or reset_token.expires_at < datetime.utcnow(): raise HTTPException(400, "This reset link is invalid or has expired")
    if len(body.new_password) < 8: raise HTTPException(400, "New password must be at least 8 characters")
    user_result = await db.execute(select(User).where(User.id == reset_token.user_id)); user = user_result.scalar_one_or_none()
    if not user: raise HTTPException(404, "Account no longer exists")
    user.password_hash = hash_password(body.new_password); reset_token.used = True; await _revoke_user_sessions(db, user.id)
    return {"message": "Password reset — you can now log in with your new password"}


@router.delete("/me")
async def delete_my_account(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    current_user.is_active = False; await _revoke_user_sessions(db, current_user.id)
    return {"message": "Account deactivated"}


@router.get("/google/login")
async def google_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str | None = None, db: AsyncSession = Depends(get_db)):
    if role not in ("worker", "advertiser"): raise HTTPException(400, "Invalid role")
    if platform == "web":
        safe_redirect = _validate_redirect_uri(redirect_uri or settings.OAUTH_WEB_REDIRECT_URL)
        if not safe_redirect: raise HTTPException(400, "Invalid redirect URI")
    else: safe_redirect = None
    state = await _begin_oauth(db, role, platform, safe_redirect)
    return RedirectResponse(url=google_auth_url(state, role=role, redirect_uri=safe_redirect))


@router.get("/facebook/login")
async def facebook_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str | None = None, db: AsyncSession = Depends(get_db)):
    if role not in ("worker", "advertiser"): raise HTTPException(400, "Invalid role")
    if platform == "web":
        safe_redirect = _validate_redirect_uri(redirect_uri or settings.OAUTH_WEB_REDIRECT_URL)
        if not safe_redirect: raise HTTPException(400, "Invalid redirect URI")
    else: safe_redirect = None
    state = await _begin_oauth(db, role, platform, safe_redirect)
    return RedirectResponse(url=facebook_auth_url(state, role=role, redirect_uri=safe_redirect))


@router.get("/google/callback")
async def google_callback(code: str, state: str, db: AsyncSession = Depends(get_db)):
    record = await _consume_oauth_state(db, state)
    provider_data = await exchange_google_code(code, redirect_uri=record.redirect_uri)
    user = await _upsert_oauth_user(db, provider_data, role=record.role)
    return await _oauth_redirect(db, user, record.platform, record.redirect_uri)


@router.get("/facebook/callback")
async def facebook_callback(code: str, state: str, db: AsyncSession = Depends(get_db)):
    record = await _consume_oauth_state(db, state)
    provider_data = await exchange_facebook_code(code, redirect_uri=record.redirect_uri)
    user = await _upsert_oauth_user(db, provider_data, role=record.role)
    return await _oauth_redirect(db, user, record.platform, record.redirect_uri)


# Email verification OTPs
def _otp_digest(code: str, email: str | None = None) -> str:
    # New registrations bind the OTP to the exact email address. The
    # email=None form remains for compatibility with legacy EmailOTP rows.
    value = f"{email.strip().lower()}:{code}" if email else code
    return hmac.new(settings.SECRET_KEY.encode(), value.encode(), hashlib.sha256).hexdigest()


async def _issue_email_otp(db: AsyncSession, user: User) -> str:
    code = f"{secrets.randbelow(1_000_000):06d}"
    now = datetime.utcnow()
    await db.execute(
        update(EmailOTP).where(EmailOTP.user_id == user.id, EmailOTP.used.is_(False)).values(used=True)
    )
    db.add(EmailOTP(
        user_id=user.id,
        code_hash=_otp_digest(code),
        expires_at=now + timedelta(minutes=10),
        attempts=0,
    ))
    await db.commit()
    return code


async def _send_otp_for_email(db: AsyncSession, email: str) -> None:
    pending = await load_pending_registration(email)
    if pending:
        code = f"{secrets.randbelow(1_000_000):06d}"
        pending["otp_hash"] = _otp_digest(code, pending["email"])
        pending["attempts"] = 0
        await save_pending_registration(email, pending)
        await send_verification_otp(pending["email"], code)
        return

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    # Legacy unverified accounts remain supported during migration.
    if not user or user.email_verified:
        return
    code = await _issue_email_otp(db, user)
    await send_verification_otp(user.email, code)


@router.post("/otp/send")
async def send_otp(body: SendOTPRequest, db: AsyncSession = Depends(get_db)):
    try:
        await _send_otp_for_email(db, body.email)
    except Exception:
        logger.exception("Verification OTP send failed")
        raise HTTPException(503, "Unable to send verification email right now")
    return {"detail": "If the account exists and needs verification, a code has been sent."}


@router.post("/otp/resend")
async def resend_otp(body: SendOTPRequest, db: AsyncSession = Depends(get_db)):
    return await send_otp(body, db)


@router.post("/otp/verify")
async def verify_otp(body: VerifyOTPRequest, db: AsyncSession = Depends(get_db)):
    if len(body.code) != 6 or not body.code.isdigit():
        raise HTTPException(400, "Invalid or expired verification code")

    email = str(body.email).strip()
    pending = await load_pending_registration(email)
    if pending:
        lock_token = secrets.token_urlsafe(24)
        if not await acquire_pending_lock(email, lock_token):
            raise HTTPException(409, "Verification is already being processed. Please try again.")
        try:
            pending = await load_pending_registration(email)
            if not pending or pending.get("email", "").lower() != email.lower():
                raise HTTPException(400, "Invalid or expired verification code")
            if int(pending.get("attempts", 0)) >= 5:
                raise HTTPException(400, "Invalid or expired verification code")
            if not hmac.compare_digest(_otp_digest(body.code, pending["email"]), pending["otp_hash"]):
                pending["attempts"] = int(pending.get("attempts", 0)) + 1
                await save_pending_registration(email, pending)
                raise HTTPException(400, "Invalid or expired verification code")

            duplicate = await db.execute(select(User).where(func.lower(User.email) == email.lower()).with_for_update())
            if duplicate.scalar_one_or_none():
                raise HTTPException(409, "Email already registered")
            referred_by = uuid.UUID(pending["referred_by"]) if pending.get("referred_by") else None
            user = User(
                email=pending["email"],
                password_hash=pending["password_hash"],
                full_name=pending["full_name"],
                role=pending["role"],
                referral_code=generate_referral_code(),
                referred_by=referred_by,
                email_verified=True,
            )
            db.add(user)
            await db.flush()
            db.add(Wallet(user_id=user.id))
            await db.commit()
            await delete_pending_registration(email)
            return {"detail": "Email verified and account created successfully."}
        finally:
            await release_pending_lock(email, lock_token)

    # Compatibility path for accounts created before OTP-first registration.
    result = await db.execute(select(User).where(User.email == body.email).with_for_update())
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(400, "Invalid or expired verification code")
    otp_result = await db.execute(
        select(EmailOTP)
        .where(EmailOTP.user_id == user.id, EmailOTP.used.is_(False))
        .order_by(EmailOTP.created_at.desc())
        .limit(1)
        .with_for_update()
    )
    otp = otp_result.scalar_one_or_none()
    if not otp or otp.expires_at < datetime.utcnow() or otp.attempts >= 5:
        raise HTTPException(400, "Invalid or expired verification code")
    otp.attempts += 1
    if not hmac.compare_digest(_otp_digest(body.code), otp.code_hash):
        await db.commit()
        raise HTTPException(400, "Invalid or expired verification code")
    otp.used = True
    user.email_verified = True
    await db.execute(
        update(EmailOTP).where(EmailOTP.user_id == user.id, EmailOTP.id != otp.id, EmailOTP.used.is_(False)).values(used=True)
    )
    await db.commit()
    return {"detail": "Email verified successfully."}
