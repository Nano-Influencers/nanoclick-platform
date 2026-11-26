import json
import logging
import time
import uuid

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from redis.asyncio import Redis
from sqlalchemy import text
from app.config import settings
from app.database import AsyncSessionLocal, engine
from app.routers import auth, wallet, campaigns, tasks, kyc, admin, notifications, rewards, support
from app.routers import admin_audit, admin_mfa, admin_kyc_documents, campaign_reports, submission_revisions, admin_lifecycle, proofs, admin_rewards, admin_gifts, gifts
from app.services.audit_service import record as record_audit
from app.services.auth_service import decode_token
from app.services.rate_limit import check_rate_limit

logger = logging.getLogger("nano-influencers.api")
_is_production = settings.APP_ENV.strip().lower() in {"production", "prod"}

app = FastAPI(
    title="Nano Influencers API",
    description="Backend for Nano Influencers (advertiser) and Click Workers (worker) apps.",
    version="2.0.0",
    openapi_url=None if _is_production else "/openapi.json",
    docs_url=None if _is_production else "/docs",
    redoc_url=None if _is_production else "/redoc",
)

@app.middleware("http")
async def request_size_limit(request: Request, call_next):
    raw_length = request.headers.get("content-length")
    if raw_length:
        try:
            if int(raw_length) > settings.MAX_REQUEST_BODY_BYTES:
                return JSONResponse(status_code=413, content={"detail": "Request body exceeds the configured size limit."})
        except ValueError:
            return JSONResponse(status_code=400, content={"detail": "Invalid Content-Length header."})
    return await call_next(request)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Idempotency-Key", "X-Request-ID", "X-Admin-MFA-Code"],
    expose_headers=["WWW-Authenticate", "X-Request-ID"],
)

@app.middleware("http")
async def security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    if request.url.path.startswith(("/auth/", "/wallet/", "/kyc/", "/admin/", "/campaigns/drafts", "/support/")):
        response.headers["Cache-Control"] = "no-store"
    if _is_production:
        response.headers["Content-Security-Policy-Report-Only"] = "default-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https:; font-src 'self' data: https:; connect-src 'self' https:"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    if _is_production:
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response

@app.middleware("http")
async def request_observability(request: Request, call_next):
    request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
    request.state.request_id = request_id
    started = time.perf_counter()
    try:
        response = await call_next(request)
    except Exception:
        logger.exception("request_failed method=%s path=%s request_id=%s", request.method, request.url.path, request_id)
        raise
    duration_ms = (time.perf_counter() - started) * 1000
    response.headers["X-Request-ID"] = request_id
    logger.info("request_complete method=%s path=%s status=%s duration_ms=%.2f request_id=%s", request.method, request.url.path, response.status_code, duration_ms, request_id)
    return response

@app.middleware("http")
async def sensitive_endpoint_rate_limit(request: Request, call_next):
    path = request.url.path
    rules = {
        "/auth/login": ("auth-login", 10, 900),
        "/auth/register": ("auth-register", 5, 3600),
        "/auth/otp/send": ("auth-otp-send", 3, 900),
        "/auth/otp/resend": ("auth-otp-resend", 3, 900),
        "/auth/otp/verify": ("auth-otp-verify", 10, 900),
        "/auth/refresh": ("auth-refresh", 30, 900),
        "/auth/forgot-password": ("auth-forgot-password", 5, 3600),
        "/auth/reset-password": ("auth-reset-password", 5, 3600),
        "/auth/change-password": ("auth-change-password", 5, 3600),
        "/auth/me/avatar": ("profile-avatar-upload", 10, 3600),
        "/auth/me/avatar/upload-url": ("profile-avatar-presign", 10, 3600),
        "/auth/me/avatar/confirm": ("profile-avatar-confirm", 10, 3600),
        "/auth/oauth/exchange": ("auth-oauth-exchange", 20, 900),
        "/wallet/withdraw": ("wallet-withdraw", 10, 3600),
        "/wallet/deposit/initialize": ("wallet-deposit", 10, 3600),
        "/wallet/resolve-account": ("wallet-resolve-account", 30, 900),
        "/support/contact": ("support-contact", 5, 3600),
        "/campaigns/creative-upload-url": ("campaign-creative-upload", 20, 3600),
        "/campaigns/creative-confirm": ("campaign-creative-confirm", 30, 3600),
        "/campaigns/drafts": ("campaign-draft-write", 30, 3600),
    }
    rule = rules.get(path)
    if path.startswith("/campaigns/drafts/"):
        rule = ("campaign-draft-access", 60, 3600)
    if rule:
        authorization = request.headers.get("authorization", "")
        if authorization.lower().startswith("bearer "):
            payload = decode_token(authorization[7:].strip())
            if payload:
                request.state.rate_limit_identity = payload.get("sub")
        elif request.method == "POST" and path.startswith("/auth/"):
            raw = await request.body()
            try:
                identity_data = json.loads(raw or b"{}")
                request.state.rate_limit_identity = identity_data.get("email")
            except (ValueError, AttributeError):
                request.state.rate_limit_identity = None
            async def receive():
                return {"type": "http.request", "body": raw, "more_body": False}
            request._receive = receive
        await check_rate_limit(request, *rule)
    return await call_next(request)

@app.middleware("http")
async def sensitive_action_audit(request: Request, call_next):
    path = request.url.path
    sensitive_prefixes = ("/admin/", "/wallet/withdraw", "/wallet/deposit", "/kyc/")
    is_sensitive = request.method in {"POST", "PATCH", "PUT", "DELETE"} and path.startswith(sensitive_prefixes)
    response = await call_next(request)
    if not is_sensitive:
        return response
    actor_id = None
    authorization = request.headers.get("authorization", "")
    if authorization.lower().startswith("bearer "):
        payload = decode_token(authorization[7:].strip())
        if payload:
            actor_id = payload.get("sub")
    try:
        actor_uuid = uuid.UUID(actor_id) if actor_id else None
        async with AsyncSessionLocal() as db:
            await record_audit(db, request, action=f"{request.method} {path}", actor_user_id=actor_uuid, resource_type="http_endpoint", resource_id=path, metadata={"status_code": response.status_code})
            await db.commit()
    except Exception:
        logger.exception("sensitive_action_audit_failed path=%s", path)
    return response

app.include_router(auth.router)
app.include_router(support.router)
app.include_router(wallet.router)
app.include_router(campaigns.router)
app.include_router(campaign_reports.router)
app.include_router(submission_revisions.router)
# Register static proof routes before the dynamic /tasks/{task_id} routes.
app.include_router(proofs.router)
app.include_router(tasks.router)
app.include_router(kyc.router)
app.include_router(admin_mfa.router)
# Lifecycle handlers are registered before the legacy admin router so the synchronized campaign/submission implementations win for duplicate paths.
app.include_router(admin_lifecycle.router)
app.include_router(admin.router)
app.include_router(admin_kyc_documents.router)
app.include_router(admin_audit.router)
app.include_router(admin_rewards.router)
app.include_router(admin_gifts.router)
app.include_router(gifts.router)
app.include_router(notifications.router)
app.include_router(rewards.router)

@app.get("/health", tags=["meta"])
async def health():
    return {"status": "ok", "env": settings.APP_ENV, "version": "2.0.0"}

@app.get("/health/live", tags=["meta"])
async def liveness():
    return {"status": "ok"}

@app.get("/health/ready", tags=["meta"])
async def readiness():
    checks = {"database": False, "redis": False}
    try:
        async with engine.connect() as connection:
            await connection.execute(text("SELECT 1"))
        checks["database"] = True
    except Exception:
        logger.exception("readiness_database_failed")
    redis = Redis.from_url(settings.REDIS_URL, socket_connect_timeout=2, socket_timeout=2)
    try:
        await redis.ping()
        checks["redis"] = True
    except Exception:
        logger.exception("readiness_redis_failed")
    finally:
        await redis.aclose()
    ready = all(checks.values())
    return JSONResponse(status_code=200 if ready else 503, content={"status": "ok" if ready else "degraded", "checks": checks})