import uuid, secrets
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.wallet import Wallet
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, UserResponse
from app.services.auth_service import hash_password, verify_password, generate_referral_code, create_access_token, create_refresh_token, decode_token
from app.services.oauth_service import google_auth_url, exchange_google_code, facebook_auth_url, exchange_facebook_code
from app.config import settings

router = APIRouter(prefix="/auth", tags=["auth"])

def _parse_role(state):
    if ":" in state:
        r = state.split(":", 1)[1]
        if r in ("advertiser","worker"): return r
    return "worker"

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

def _deep_link(user):
    a = create_access_token(str(user.id), user.role)
    r = create_refresh_token(str(user.id))
    return RedirectResponse(url=f"nanoclick://oauth?access_token={a}&refresh_token={r}&role={user.role}", status_code=302)

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

@router.get("/google/login")
async def google_login(role: str = Query("worker")):
    if not settings.GOOGLE_CLIENT_ID: raise HTTPException(503, "Google OAuth not configured")
    if role not in ("advertiser","worker"): role = "worker"
    return RedirectResponse(google_auth_url(f"{secrets.token_urlsafe(16)}:{role}"), 302)

@router.get("/google/callback", include_in_schema=False)
async def google_callback(code: str = Query(...), state: str = Query(""), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error: raise HTTPException(400, f"Google login denied: {error}")
    try: provider_data = await exchange_google_code(code)
    except Exception: raise HTTPException(400, "Failed to verify Google login")
    user = await _upsert_oauth_user(db, provider_data, _parse_role(state))
    await db.commit()
    return _deep_link(user)

@router.get("/facebook/login")
async def facebook_login(role: str = Query("worker")):
    if not settings.FACEBOOK_CLIENT_ID: raise HTTPException(503, "Facebook OAuth not configured")
    if role not in ("advertiser","worker"): role = "worker"
    return RedirectResponse(facebook_auth_url(f"{secrets.token_urlsafe(16)}:{role}"), 302)

@router.get("/facebook/callback", include_in_schema=False)
async def facebook_callback(code: str = Query(None), state: str = Query(""), error: str = Query(None), db: AsyncSession = Depends(get_db)):
    if error or not code: raise HTTPException(400, f"Facebook login denied: {error or 'no code'}")
    try: provider_data = await exchange_facebook_code(code)
    except Exception: raise HTTPException(400, "Failed to verify Facebook login")
    user = await _upsert_oauth_user(db, provider_data, _parse_role(state))
    await db.commit()
    return _deep_link(user)
