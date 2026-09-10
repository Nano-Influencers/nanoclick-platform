import uuid, secrets, hashlib
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.wallet import Wallet
from app.models.password_reset import PasswordResetToken
from app.models.oauth_state import OAuthState
from app.models.oauth_code import OAuthCode
from app.models.refresh_session import RefreshSession
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, UserResponse, ChangePasswordRequest, ForgotPasswordRequest, ResetPasswordRequest
from app.services.auth_service import hash_password, verify_password, generate_referral_code, create_access_token, create_refresh_token, decode_token
from app.services.oauth_service import google_auth_url, exchange_google_code, facebook_auth_url, exchange_facebook_code
from app.config import settings
from datetime import datetime, timedelta

router = APIRouter(prefix="/auth", tags=["auth"])


def _hash_secret(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _validate_redirect_uri(redirect_uri: str | None) -> str | None:
    if not redirect_uri: return None
    allowed = [o.strip().rstrip("/") for o in settings.OAUTH_ALLOWED_WEB_REDIRECTS.split(",") if o.strip()]
    return redirect_uri if any(redirect_uri == o or redirect_uri.startswith(o + "/") or redirect_uri.startswith(o + "?") for o in allowed) else None


async def _issue_tokens(db, user: User) -> TokenResponse:
    access = create_access_token(str(user.id), user.role)
    refresh = create_refresh_token(str(user.id))
    payload = decode_token(refresh)
    db.add(RefreshSession(jti=payload["jti"], user_id=user.id, expires_at=datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)))
    await db.flush()
    return TokenResponse(access_token=access, refresh_token=refresh)


async def _create_oauth_state(db, provider: str, role: str, platform: str, redirect_uri: str | None) -> str:
    raw = secrets.token_urlsafe(32)
    db.add(OAuthState(state_hash=_hash_secret(raw), provider=provider, role=role, platform=platform, redirect_uri=redirect_uri, expires_at=datetime.utcnow() + timedelta(minutes=10)))
    await db.commit()
    return raw


async def _consume_oauth_state(db, raw_state: str, provider: str):
    if not raw_state: raise HTTPException(400, "Missing OAuth state")
    result = await db.execute(select(OAuthState).where(OAuthState.state_hash == _hash_secret(raw_state)).with_for_update())
    state = result.scalar_one_or_none()
    if not state or state.provider != provider or state.used_at or state.expires_at < datetime.utcnow(): raise HTTPException(400, "Invalid or expired OAuth state")
    state.used_at = datetime.utcnow()
    return state


async def _upsert_oauth_user(db, provider_data, role="worker"):
    if not provider_data.get("email"): raise HTTPException(400, "No email from OAuth provider")
    result = await db.execute(select(User).where(User.oauth_provider==provider_data["provider"], User.oauth_provider_id==provider_data["provider_id"]))
    user = result.scalar_one_or_none()
    if user: return user
    result = await db.execute(select(User).where(User.email==provider_data["email"]))
    user = result.scalar_one_or_none()
    if user:
        user.oauth_provider = provider_data["provider"]; user.oauth_provider_id = provider_data["provider_id"]; return user
    user = User(email=provider_data["email"], password_hash=None, full_name=provider_data.get("full_name") or provider_data["email"].split("@")[0], role=role, referral_code=generate_referral_code(), oauth_provider=provider_data["provider"], oauth_provider_id=provider_data["provider_id"])
    db.add(user); await db.flush(); db.add(Wallet(user_id=user.id)); return user


async def _oauth_redirect(db, user, platform="app", redirect_uri=None):
    raw_code = secrets.token_urlsafe(32)
    db.add(OAuthCode(code_hash=_hash_secret(raw_code), user_id=user.id, expires_at=datetime.utcnow() + timedelta(minutes=2)))
    await db.commit()
    if platform == "web":
        base = redirect_uri or settings.OAUTH_WEB_REDIRECT_URL
        sep = "&" if "?" in base else "?"
        return RedirectResponse(f"{base}{sep}code={raw_code}", 302)
    return RedirectResponse(f"nanoclick://oauth?code={raw_code}", 302)


@router.post("/oauth/exchange", response_model=TokenResponse)
async def exchange_oauth_code(code: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(OAuthCode).where(OAuthCode.code_hash == _hash_secret(code)).with_for_update())
    row = result.scalar_one_or_none()
    if not row or row.used_at or row.expires_at < datetime.utcnow(): raise HTTPException(400, "Invalid or expired OAuth code")
    user_result = await db.execute(select(User).where(User.id == row.user_id)); user = user_result.scalar_one_or_none()
    if not user or not user.is_active: raise HTTPException(401, "User not found")
    row.used_at = datetime.utcnow()
    tokens = await _issue_tokens(db, user); await db.commit(); return tokens


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    if body.role not in ("advertiser", "worker"): raise HTTPException(400, "role must be advertiser or worker")
    ex = await db.execute(select(User).where(User.email==body.email))
    if ex.scalar_one_or_none(): raise HTTPException(400, "Email already registered")
    referred_by = None
    if body.referral_code:
        ref = await db.execute(select(User).where(User.referral_code==body.referral_code)); r = ref.scalar_one_or_none(); referred_by = r.id if r else None
    user = User(email=body.email, password_hash=hash_password(body.password), full_name=body.full_name, role=body.role, referral_code=generate_referral_code(), referred_by=referred_by)
    db.add(user); await db.flush(); db.add(Wallet(user_id=user.id)); return user


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email==body.email)); user = result.scalar_one_or_none()
    if not user: raise HTTPException(401, "Invalid credentials")
    if user.password_hash is None: raise HTTPException(400, f"This account uses {user.oauth_provider or 'social'} login")
    if not verify_password(body.password, user.password_hash): raise HTTPException(401, "Invalid credentials")
    if not user.is_active: raise HTTPException(403, "Account disabled")
    tokens = await _issue_tokens(db, user); await db.commit(); return tokens


@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(body.refresh_token)
    if not payload or payload.get("type") != "refresh" or not payload.get("jti"): raise HTTPException(401, "Invalid refresh token")
    try: user_id = uuid.UUID(payload["sub"])
    except (KeyError, ValueError): raise HTTPException(401, "Invalid refresh token")
    session_result = await db.execute(select(RefreshSession).where(RefreshSession.jti == payload["jti"]).with_for_update()); session = session_result.scalar_one_or_none()
    if not session or session.revoked_at or session.expires_at < datetime.utcnow(): raise HTTPException(401, "Refresh session revoked or expired")
    result = await db.execute(select(User).where(User.id == user_id)); user = result.scalar_one_or_none()
    if not user or not user.is_active: raise HTTPException(401, "User not found")
    session.revoked_at = datetime.utcnow()
    tokens = await _issue_tokens(db, user); await db.commit(); return tokens


@router.post("/logout")
async def logout(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(body.refresh_token)
    if payload.get("jti"):
        result = await db.execute(select(RefreshSession).where(RefreshSession.jti == payload["jti"]).with_for_update())
        session = result.scalar_one_or_none()
        if session and not session.revoked_at: session.revoked_at = datetime.utcnow()
    await db.commit(); return {"message": "Logged out"}


@router.get("/me", response_model=UserResponse)
async def me(current_user: User = Depends(get_current_user)): return current_user


@router.post("/change-password")
async def change_password(body: ChangePasswordRequest, current_user: User = Depends(get_current_user)):
    if current_user.password_hash is None: raise HTTPException(400, f"This account uses {current_user.oauth_provider or 'social'} login and has no password to change")
    if not verify_password(body.current_password, current_user.password_hash): raise HTTPException(401, "Current password is incorrect")
    if len(body.new_password) < 8: raise HTTPException(400, "New password must be at least 8 characters")
    current_user.password_hash = hash_password(body.new_password); return {"message": "Password changed"}


@router.post("/forgot-password")
async def forgot_password(body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email)); user = result.scalar_one_or_none()
    if user and user.password_hash is not None:
        db.add(PasswordResetToken(user_id=user.id, token=secrets.token_urlsafe(32), expires_at=datetime.utcnow() + timedelta(hours=1)))
    return {"message": "If that email is registered, a password reset link has been sent."}


@router.post("/reset-password")
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(PasswordResetToken).where(PasswordResetToken.token == body.token).with_for_update()); reset_token = result.scalar_one_or_none()
    if not reset_token or reset_token.used or reset_token.expires_at < datetime.utcnow(): raise HTTPException(400, "This reset link is invalid or has expired")
    if len(body.new_password) < 8: raise HTTPException(400, "New password must be at least 8 characters")
    user_result = await db.execute(select(User).where(User.id == reset_token.user_id)); user = user_result.scalar_one_or_none()
    if not user: raise HTTPException(404, "Account no longer exists")
    user.password_hash = hash_password(body.new_password); reset_token.used = True; await db.commit(); return {"message": "Password reset — you can now log in with your new password"}


@router.delete("/me")
async def delete_my_account(current_user: User = Depends(get_current_user)): current_user.is_active = False; return {"message": "Account deactivated"}


@router.get("/google/login")
async def google_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str = Query(None), db: AsyncSession = Depends(get_db)):
    if not settings.GOOGLE_CLIENT_ID: raise HTTPException(503, "Google OAuth not configured")
    role = role if role in ("advertiser", "worker") else "worker"; platform = platform if platform in ("app", "web") else "app"
    validated = _validate_redirect_uri(redirect_uri)
    if redirect_uri and not validated: raise HTTPException(400, "redirect_uri is not in the allowed list")
    return RedirectResponse(google_auth_url(await _create_oauth_state(db, "google", role, platform, validated)), 302)


@router.get("/google/callback", include_in_schema=False)
async def google_callback(code: str = Query(...), state: str = Query(""), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error: raise HTTPException(400, f"Google login denied: {error}")
    state_row = await _consume_oauth_state(db, state, "google")
    try: provider_data = await exchange_google_code(code)
    except Exception: raise HTTPException(400, "Failed to verify Google login")
    user = await _upsert_oauth_user(db, provider_data, state_row.role); return await _oauth_redirect(db, user, state_row.platform, state_row.redirect_uri)


@router.get("/facebook/login")
async def facebook_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str = Query(None), db: AsyncSession = Depends(get_db)):
    if not settings.FACEBOOK_CLIENT_ID: raise HTTPException(503, "Facebook OAuth not configured")
    role = role if role in ("advertiser", "worker") else "worker"; platform = platform if platform in ("app", "web") else "app"
    validated = _validate_redirect_uri(redirect_uri)
    if redirect_uri and not validated: raise HTTPException(400, "redirect_uri is not in the allowed list")
    return RedirectResponse(facebook_auth_url(await _create_oauth_state(db, "facebook", role, platform, validated)), 302)


@router.get("/facebook/callback", include_in_schema=False)
async def facebook_callback(code: str = Query(None), state: str = Query(""), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error or not code: raise HTTPException(400, f"Facebook login denied: {error or 'no code'}")
    state_row = await _consume_oauth_state(db, state, "facebook")
    try: provider_data = await exchange_facebook_code(code)
    except Exception: raise HTTPException(400, "Failed to verify Facebook login")
    user = await _upsert_oauth_user(db, provider_data, state_row.role); return await _oauth_redirect(db, user, state_row.platform, state_row.redirect_uri)
