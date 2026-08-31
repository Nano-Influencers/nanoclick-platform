import uuid, secrets, base64, json
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.wallet import Wallet
from app.models.password_reset import PasswordResetToken
from app.schemas.auth import (
    RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, UserResponse,
    ChangePasswordRequest, ForgotPasswordRequest, ResetPasswordRequest,
)
from app.services.auth_service import hash_password, verify_password, generate_referral_code, create_access_token, create_refresh_token, decode_token
from app.services.oauth_service import google_auth_url, exchange_google_code, facebook_auth_url, exchange_facebook_code
from app.config import settings
from datetime import datetime, timedelta

router = APIRouter(prefix="/auth", tags=["auth"])

def _pack_state(role: str, platform: str, redirect_uri: str | None) -> str:
    """State is a CSRF token plus a base64url-encoded JSON payload — JSON
    rather than colon-delimited fields because a redirect_uri is itself a
    URL and would break any simple delimiter-based split."""
    payload = base64.urlsafe_b64encode(json.dumps({"role": role, "platform": platform, "redirect_uri": redirect_uri}).encode()).decode()
    return f"{secrets.token_urlsafe(16)}:{payload}"

def _parse_state(state: str) -> tuple[str, str, str | None]:
    """Returns (role, platform, redirect_uri). Falls back to safe defaults
    for older-format states (pre-redirect_uri support: '{token}:{role}:{platform}')
    so in-flight logins started before a deploy don't break."""
    try:
        _, payload_b64 = state.split(":", 1)
        payload = json.loads(base64.urlsafe_b64decode(payload_b64.encode()).decode())
        role = payload.get("role") if payload.get("role") in ("advertiser", "worker") else "worker"
        platform = payload.get("platform") if payload.get("platform") in ("app", "web") else "app"
        return role, platform, payload.get("redirect_uri")
    except Exception:
        parts = state.split(":")
        role = parts[1] if len(parts) > 1 and parts[1] in ("advertiser", "worker") else "worker"
        platform = parts[2] if len(parts) > 2 and parts[2] in ("app", "web") else "app"
        return role, platform, None

def _validate_redirect_uri(redirect_uri: str | None) -> str | None:
    """Only allow redirecting to an explicitly configured origin — an
    unvalidated redirect_uri would let anyone mint a link that hands a
    freshly-issued access/refresh token to an attacker-controlled page."""
    if not redirect_uri:
        return None
    allowed = [o.strip().rstrip("/") for o in settings.OAUTH_ALLOWED_WEB_REDIRECTS.split(",") if o.strip()]
    for origin in allowed:
        if redirect_uri == origin or redirect_uri.startswith(origin + "/") or redirect_uri.startswith(origin + "?"):
            return redirect_uri
    return None

async def _upsert_oauth_user(db, provider_data, role="worker"):
    if not provider_data.get("email"):
        raise HTTPException(400, "No email from OAuth provider")
    result = await db.execute(select(User).where(User.oauth_provider==provider_data["provider"], User.oauth_provider_id==provider_data["provider_id"]))
    user = result.scalar_one_or_none()
    if user: return user
    result = await db.execute(select(User).where(User.email==provider_data["email"]))
    user = result.scalar_one_or_none()
    if user:
        user.oauth_provider = provider_data["provider"]
        user.oauth_provider_id = provider_data["provider_id"]
        return user
    user = User(email=provider_data["email"], password_hash=None,
                full_name=provider_data.get("full_name") or provider_data["email"].split("@")[0],
                role=role, referral_code=generate_referral_code(),
                oauth_provider=provider_data["provider"], oauth_provider_id=provider_data["provider_id"])
    db.add(user); await db.flush()
    db.add(Wallet(user_id=user.id))
    return user

def _oauth_redirect(user, platform: str = "app", redirect_uri: str | None = None):
    a = create_access_token(str(user.id), user.role)
    r = create_refresh_token(str(user.id))
    if platform == "web":
        # click-workers is a web-only Flutter build (no Android/iOS Firebase
        # config exists) — a nanoclick:// deep link is meaningless in a
        # browser tab, so redirect to a real page instead. Multiple web
        # frontends (nano-influencers, click-workers) run on different
        # origins, so the caller can supply its own callback via
        # redirect_uri (validated against OAUTH_ALLOWED_WEB_REDIRECTS);
        # OAUTH_WEB_REDIRECT_URL remains the default for backward
        # compatibility with callers that don't pass one.
        base = redirect_uri or settings.OAUTH_WEB_REDIRECT_URL
        sep = "&" if "?" in base else "?"
        url = f"{base}{sep}access_token={a}&refresh_token={r}&role={user.role}"
    else:
        url = f"nanoclick://oauth?access_token={a}&refresh_token={r}&role={user.role}"
    return RedirectResponse(url=url, status_code=302)

@router.post("/register", response_model=UserResponse, status_code=201)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    if body.role not in ("advertiser","worker"):
        raise HTTPException(400, "role must be advertiser or worker")
    ex = await db.execute(select(User).where(User.email==body.email))
    if ex.scalar_one_or_none(): raise HTTPException(400, "Email already registered")
    referred_by = None
    if body.referral_code:
        ref = await db.execute(select(User).where(User.referral_code==body.referral_code))
        r = ref.scalar_one_or_none()
        if r: referred_by = r.id
    user = User(email=body.email, password_hash=hash_password(body.password),
                full_name=body.full_name, role=body.role,
                referral_code=generate_referral_code(), referred_by=referred_by)
    db.add(user); await db.flush()
    db.add(Wallet(user_id=user.id))
    return user

@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email==body.email))
    user = result.scalar_one_or_none()
    if not user: raise HTTPException(401, "Invalid credentials")
    if user.password_hash is None:
        raise HTTPException(400, f"This account uses {user.oauth_provider or 'social'} login")
    if not verify_password(body.password, user.password_hash): raise HTTPException(401, "Invalid credentials")
    if not user.is_active: raise HTTPException(403, "Account disabled")
    return TokenResponse(access_token=create_access_token(str(user.id), user.role),
                         refresh_token=create_refresh_token(str(user.id)))

@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(body.refresh_token)
    if not payload or payload.get("type") != "refresh": raise HTTPException(401, "Invalid refresh token")
    result = await db.execute(select(User).where(User.id==uuid.UUID(payload["sub"])))
    user = result.scalar_one_or_none()
    if not user or not user.is_active: raise HTTPException(401, "User not found")
    return TokenResponse(access_token=create_access_token(str(user.id), user.role),
                         refresh_token=create_refresh_token(str(user.id)))

@router.get("/me", response_model=UserResponse)
async def me(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/change-password")
async def change_password(body: ChangePasswordRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    if current_user.password_hash is None:
        raise HTTPException(400, f"This account uses {current_user.oauth_provider or 'social'} login and has no password to change")
    if not verify_password(body.current_password, current_user.password_hash):
        raise HTTPException(401, "Current password is incorrect")
    if len(body.new_password) < 8:
        raise HTTPException(400, "New password must be at least 8 characters")
    current_user.password_hash = hash_password(body.new_password)
    return {"message": "Password changed"}

@router.post("/forgot-password")
async def forgot_password(body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    # Always return the same response whether or not the email exists, so
    # this endpoint can't be used to enumerate registered accounts.
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if user and user.password_hash is not None:
        token = secrets.token_urlsafe(32)
        db.add(PasswordResetToken(user_id=user.id, token=token, expires_at=datetime.utcnow() + timedelta(hours=1)))
        # No email provider is configured in this backend yet (see the
        # docstring on PasswordResetToken) — logging the link is a stand-in
        # for actually emailing it. Wire up SMTP/SendGrid/SES and replace
        # this with a real send before relying on this in production.
        reset_link = f"{settings.OAUTH_WEB_REDIRECT_URL.rsplit('/', 1)[0]}/reset-password?token={token}"
        print(f"[password reset — email delivery not configured] {user.email}: {reset_link}")
    return {"message": "If that email is registered, a password reset link has been sent."}

@router.post("/reset-password")
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(PasswordResetToken).where(PasswordResetToken.token == body.token))
    reset_token = result.scalar_one_or_none()
    if not reset_token or reset_token.used or reset_token.expires_at < datetime.utcnow():
        raise HTTPException(400, "This reset link is invalid or has expired")
    if len(body.new_password) < 8:
        raise HTTPException(400, "New password must be at least 8 characters")
    user_result = await db.execute(select(User).where(User.id == reset_token.user_id))
    user = user_result.scalar_one_or_none()
    if not user: raise HTTPException(404, "Account no longer exists")
    user.password_hash = hash_password(body.new_password)
    reset_token.used = True
    return {"message": "Password reset — you can now log in with your new password"}

@router.delete("/me")
async def delete_my_account(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Soft-delete: deactivates the account rather than removing rows, since
    a worker's completed submissions/transactions and an advertiser's
    campaigns are financial/audit records other parties (workers who were
    paid, admins reviewing history) still legitimately need after the
    account holder leaves."""
    current_user.is_active = False
    return {"message": "Account deactivated"}

@router.get("/google/login")
async def google_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str = Query(None)):
    if not settings.GOOGLE_CLIENT_ID: raise HTTPException(503, "Google OAuth not configured")
    if role not in ("advertiser","worker"): role = "worker"
    if platform not in ("app","web"): platform = "app"
    validated_redirect = _validate_redirect_uri(redirect_uri)
    if redirect_uri and not validated_redirect:
        raise HTTPException(400, "redirect_uri is not in the allowed list")
    return RedirectResponse(google_auth_url(_pack_state(role, platform, validated_redirect)), 302)

@router.get("/google/callback", include_in_schema=False)
async def google_callback(code: str = Query(...), state: str = Query(""), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error: raise HTTPException(400, f"Google login denied: {error}")
    try: provider_data = await exchange_google_code(code)
    except Exception: raise HTTPException(400, "Failed to verify Google login")
    role, platform, redirect_uri = _parse_state(state)
    user = await _upsert_oauth_user(db, provider_data, role)
    await db.commit()
    return _oauth_redirect(user, platform, redirect_uri)

@router.get("/facebook/login")
async def facebook_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str = Query(None)):
    if not settings.FACEBOOK_CLIENT_ID: raise HTTPException(503, "Facebook OAuth not configured")
    if role not in ("advertiser","worker"): role = "worker"
    if platform not in ("app","web"): platform = "app"
    validated_redirect = _validate_redirect_uri(redirect_uri)
    if redirect_uri and not validated_redirect:
        raise HTTPException(400, "redirect_uri is not in the allowed list")
    return RedirectResponse(facebook_auth_url(_pack_state(role, platform, validated_redirect)), 302)

@router.get("/facebook/callback", include_in_schema=False)
async def facebook_callback(code: str = Query(None), state: str = Query(""), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error or not code: raise HTTPException(400, f"Facebook login denied: {error or 'no code'}")
    try: provider_data = await exchange_facebook_code(code)
    except Exception: raise HTTPException(400, "Failed to verify Facebook login")
    role, platform, redirect_uri = _parse_state(state)
    user = await _upsert_oauth_user(db, provider_data, role)
    await db.commit()
    return _oauth_redirect(user, platform, redirect_uri)
