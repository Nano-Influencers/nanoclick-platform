import uuid
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import RedirectResponse
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.database import get_db
from app.dependencies import get_current_user
from app.models.auth_session import AuthSession, OAuthState
from app.models.password_reset import PasswordResetToken
from app.models.user import User
from app.models.wallet import Wallet
from app.schemas.auth import (
    ChangePasswordRequest,
    ForgotPasswordRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
    UserResponse,
)
from app.services.auth_service import (
    create_access_token,
    create_refresh_token,
    decode_token,
    generate_referral_code,
    hash_password,
    hash_token_identifier,
    new_oauth_state,
    token_jti,
    verify_password,
)
from app.services.oauth_service import (
    exchange_facebook_code,
    exchange_google_code,
    facebook_auth_url,
    google_auth_url,
)

router = APIRouter(prefix="/auth", tags=["auth"])


def _validate_redirect_uri(redirect_uri: str | None) -> str | None:
    """Only allow redirects to explicitly configured web origins."""
    if not redirect_uri:
        return None
    allowed = [o.strip().rstrip("/") for o in settings.OAUTH_ALLOWED_WEB_REDIRECTS.split(",") if o.strip()]
    for origin in allowed:
        if redirect_uri == origin or redirect_uri.startswith(origin + "/") or redirect_uri.startswith(origin + "?"):
            return redirect_uri
    return None


async def _create_refresh_session(db: AsyncSession, user_id: uuid.UUID, refresh_token: str) -> None:
    jti = token_jti(refresh_token)
    if not jti:
        raise HTTPException(500, "Failed to create authentication session")
    payload = decode_token(refresh_token)
    db.add(
        AuthSession(
            user_id=user_id,
            token_jti_hash=hash_token_identifier(jti),
            expires_at=datetime.utcfromtimestamp(payload["exp"]),
        )
    )


async def _issue_tokens(db: AsyncSession, user: User) -> TokenResponse:
    access = create_access_token(str(user.id), user.role)
    refresh = create_refresh_token(str(user.id))
    await _create_refresh_session(db, user.id, refresh)
    return TokenResponse(access_token=access, refresh_token=refresh)


async def _revoke_user_sessions(db: AsyncSession, user_id: uuid.UUID) -> None:
    await db.execute(
        update(AuthSession)
        .where(AuthSession.user_id == user_id, AuthSession.revoked_at.is_(None))
        .values(revoked_at=datetime.utcnow())
    )


async def _upsert_oauth_user(db: AsyncSession, provider_data, role="worker"):
    if not provider_data.get("email"):
        raise HTTPException(400, "No email from OAuth provider")

    result = await db.execute(
        select(User).where(
            User.oauth_provider == provider_data["provider"],
            User.oauth_provider_id == provider_data["provider_id"],
        )
    )
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
        user.oauth_provider = provider_data["provider"]
        user.oauth_provider_id = provider_data["provider_id"]
        return user

    user = User(
        email=provider_data["email"],
        password_hash=None,
        full_name=provider_data.get("full_name") or provider_data["email"].split("@")[0],
        role=role,
        referral_code=generate_referral_code(),
        oauth_provider=provider_data["provider"],
        oauth_provider_id=provider_data["provider_id"],
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id))
    return user


async def _begin_oauth(db: AsyncSession, role: str, platform: str, redirect_uri: str | None) -> str:
    state = new_oauth_state()
    db.add(
        OAuthState(
            nonce_hash=hash_token_identifier(state),
            role=role,
            platform=platform,
            redirect_uri=redirect_uri,
            expires_at=datetime.utcnow() + timedelta(minutes=10),
        )
    )
    await db.flush()
    return state


async def _consume_oauth_state(db: AsyncSession, state: str) -> OAuthState:
    if not state:
        raise HTTPException(400, "Missing OAuth state")
    result = await db.execute(
        select(OAuthState)
        .where(OAuthState.nonce_hash == hash_token_identifier(state))
        .with_for_update()
    )
    record = result.scalar_one_or_none()
    if not record or record.consumed_at is not None or record.expires_at < datetime.utcnow():
        raise HTTPException(400, "Invalid or expired OAuth state")
    record.consumed_at = datetime.utcnow()
    return record


def _oauth_redirect(user: User, platform: str, redirect_uri: str | None, tokens: TokenResponse):
    """Return a short-lived code-less redirect only for the native deep link.

    Web OAuth intentionally does not put bearer tokens in the URL. The web
    client must use the normal login endpoint/session flow instead. Native
    deep-link support is retained for the Flutter application.
    """
    if platform == "web":
        # A production web OAuth callback must exchange a one-time server-side
        # code. Do not leak bearer tokens into browser history/referrers.
        base = redirect_uri or settings.OAUTH_WEB_REDIRECT_URL
        sep = "&" if "?" in base else "?"
        return RedirectResponse(url=f"{base}{sep}oauth_error=web_oauth_requires_code_exchange", status_code=302)

    return RedirectResponse(
        url=f"nanoclick://oauth?access_token={tokens.access_token}&refresh_token={tokens.refresh_token}&role={user.role}",
        status_code=302,
    )


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    if body.role not in ("advertiser", "worker"):
        raise HTTPException(400, "role must be advertiser or worker")
    ex = await db.execute(select(User).where(User.email == body.email))
    if ex.scalar_one_or_none():
        raise HTTPException(400, "Email already registered")
    referred_by = None
    if body.referral_code:
        ref = await db.execute(select(User).where(User.referral_code == body.referral_code))
        r = ref.scalar_one_or_none()
        if r:
            referred_by = r.id
    user = User(
        email=body.email,
        password_hash=hash_password(body.password),
        full_name=body.full_name,
        role=body.role,
        referral_code=generate_referral_code(),
        referred_by=referred_by,
    )
    db.add(user)
    await db.flush()
    db.add(Wallet(user_id=user.id))
    return user


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(401, "Invalid credentials")
    if user.password_hash is None:
        raise HTTPException(400, f"This account uses {user.oauth_provider or 'social'} login")
    if not verify_password(body.password, user.password_hash):
        raise HTTPException(401, "Invalid credentials")
    if not user.is_active:
        raise HTTPException(403, "Account disabled")
    return await _issue_tokens(db, user)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(body.refresh_token)
    if not payload or payload.get("type") != "refresh" or not payload.get("jti"):
        raise HTTPException(401, "Invalid refresh token")

    jti_hash = hash_token_identifier(payload["jti"])
    result = await db.execute(
        select(AuthSession).where(AuthSession.token_jti_hash == jti_hash).with_for_update()
    )
    session = result.scalar_one_or_none()
    if not session or session.revoked_at is not None or session.expires_at < datetime.utcnow():
        raise HTTPException(401, "Refresh session expired or revoked")

    try:
        user_id = uuid.UUID(payload["sub"])
    except (ValueError, TypeError):
        raise HTTPException(401, "Invalid refresh token")
    if session.user_id != user_id:
        raise HTTPException(401, "Invalid refresh session")

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(401, "User not found")

    session.revoked_at = datetime.utcnow()
    session.last_used_at = datetime.utcnow()
    tokens = await _issue_tokens(db, user)
    new_jti = token_jti(tokens.refresh_token)
    session.replaced_by_jti_hash = hash_token_identifier(new_jti) if new_jti else None
    return tokens


@router.post("/logout")
async def logout(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(body.refresh_token)
    jti = payload.get("jti") if payload.get("type") == "refresh" else None
    if jti:
        result = await db.execute(
            select(AuthSession).where(AuthSession.token_jti_hash == hash_token_identifier(jti)).with_for_update()
        )
        session = result.scalar_one_or_none()
        if session and session.revoked_at is None:
            session.revoked_at = datetime.utcnow()
    return {"message": "Logged out"}


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
    await _revoke_user_sessions(db, current_user.id)
    return {"message": "Password changed; please sign in again"}


@router.post("/forgot-password")
async def forgot_password(body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if user and user.password_hash is not None:
        token = __import__("secrets").token_urlsafe(32)
        db.add(PasswordResetToken(user_id=user.id, token=token, expires_at=datetime.utcnow() + timedelta(hours=1)))
        # TODO: replace development logging with a real transactional email provider before launch.
        reset_link = f"{settings.OAUTH_WEB_REDIRECT_URL.rsplit('/', 1)[0]}/reset-password?token={token}"
        print(f"[password reset — email delivery not configured] {user.email}: {reset_link}")
    return {"message": "If that email is registered, a password reset link has been sent."}


@router.post("/reset-password")
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(PasswordResetToken).where(PasswordResetToken.token == body.token).with_for_update())
    reset_token = result.scalar_one_or_none()
    if not reset_token or reset_token.used or reset_token.expires_at < datetime.utcnow():
        raise HTTPException(400, "This reset link is invalid or has expired")
    if len(body.new_password) < 8:
        raise HTTPException(400, "New password must be at least 8 characters")
    user_result = await db.execute(select(User).where(User.id == reset_token.user_id))
    user = user_result.scalar_one_or_none()
    if not user:
        raise HTTPException(404, "Account no longer exists")
    user.password_hash = hash_password(body.new_password)
    reset_token.used = True
    await _revoke_user_sessions(db, user.id)
    return {"message": "Password reset — you can now log in with your new password"}


@router.delete("/me")
async def delete_my_account(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    current_user.is_active = False
    await _revoke_user_sessions(db, current_user.id)
    return {"message": "Account deactivated"}


@router.get("/google/login")
async def google_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str = Query(None), db: AsyncSession = Depends(get_db)):
    if not settings.GOOGLE_CLIENT_ID:
        raise HTTPException(503, "Google OAuth not configured")
    if role not in ("advertiser", "worker"):
        role = "worker"
    if platform not in ("app", "web"):
        platform = "app"
    validated_redirect = _validate_redirect_uri(redirect_uri)
    if redirect_uri and not validated_redirect:
        raise HTTPException(400, "redirect_uri is not in the allowed list")
    state = await _begin_oauth(db, role, platform, validated_redirect)
    return RedirectResponse(google_auth_url(state), 302)


@router.get("/google/callback", include_in_schema=False)
async def google_callback(code: str = Query(...), state: str = Query(...), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error:
        raise HTTPException(400, f"Google login denied: {error}")
    oauth_state = await _consume_oauth_state(db, state)
    try:
        provider_data = await exchange_google_code(code)
    except Exception:
        raise HTTPException(400, "Failed to verify Google login")
    user = await _upsert_oauth_user(db, provider_data, oauth_state.role)
    tokens = await _issue_tokens(db, user)
    return _oauth_redirect(user, oauth_state.platform, oauth_state.redirect_uri, tokens)


@router.get("/facebook/login")
async def facebook_login(role: str = Query("worker"), platform: str = Query("app"), redirect_uri: str = Query(None), db: AsyncSession = Depends(get_db)):
    if not settings.FACEBOOK_CLIENT_ID:
        raise HTTPException(503, "Facebook OAuth not configured")
    if role not in ("advertiser", "worker"):
        role = "worker"
    if platform not in ("app", "web"):
        platform = "app"
    validated_redirect = _validate_redirect_uri(redirect_uri)
    if redirect_uri and not validated_redirect:
        raise HTTPException(400, "redirect_uri is not in the allowed list")
    state = await _begin_oauth(db, role, platform, validated_redirect)
    return RedirectResponse(facebook_auth_url(state), 302)


@router.get("/facebook/callback", include_in_schema=False)
async def facebook_callback(code: str = Query(None), state: str = Query(...), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error or not code:
        raise HTTPException(400, f"Facebook login denied: {error or 'no code'}")
    oauth_state = await _consume_oauth_state(db, state)
    try:
        provider_data = await exchange_facebook_code(code)
    except Exception:
        raise HTTPException(400, "Failed to verify Facebook login")
    user = await _upsert_oauth_user(db, provider_data, oauth_state.role)
    tokens = await _issue_tokens(db, user)
    return _oauth_redirect(user, oauth_state.platform, oauth_state.redirect_uri, tokens)
