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
from app.routers import auth, wallet, campaigns, tasks, kyc, admin, notifications, rewards
from app.routers import admin_audit, admin_mfa
from app.services.audit_service import record as record_audit
from app.services.auth_service import decode_token
from app.services.rate_limit import check_rate_limit

logger = logging.getLogger("nanoclick.api")

app = FastAPI(
    title="NanoClick API",
    description="Backend for Nano Influencers (advertiser) and Click Workers (worker) apps.",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def request_observability(request: Request, call_next):
    request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
    request.state.request_id = request_id
    started = time.perf_counter()
    try:
        response = await call_next(request)
    except Exception:
        logger.exception(
            "request_failed method=%s path=%s request_id=%s",
            request.method,
            request.url.path,
            request_id,
        )
        raise
    duration_ms = (time.perf_counter() - started) * 1000
    response.headers["X-Request-ID"] = request_id
    logger.info(
        "request_complete method=%s path=%s status=%s duration_ms=%.2f request_id=%s",
        request.method,
        request.url.path,
        response.status_code,
        duration_ms,
        request_id,
    )
    return response


@app.middleware("http")
async def sensitive_endpoint_rate_limit(request: Request, call_next):
    path = request.url.path
    rules = {
        "/auth/login": ("auth-login", 10, 900),
        "/auth/register": ("auth-register", 5, 3600),
        "/auth/refresh": ("auth-refresh", 30, 900),
        "/auth/forgot-password": ("auth-forgot-password", 5, 3600),
        "/auth/reset-password": ("auth-reset-password", 5, 3600),
        "/auth/change-password": ("auth-change-password", 5, 3600),
        "/auth/oauth/exchange": ("auth-oauth-exchange", 20, 900),
        "/wallet/withdraw": ("wallet-withdraw", 10, 3600),
        "/wallet/deposit": ("wallet-deposit", 20, 3600),
        "/wallet/resolve-account": ("wallet-resolve-account", 30, 900),
    }
    rule = rules.get(path)
    if rule:
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
            await record_audit(
                db,
                request,
                action=f"{request.method} {path}",
                actor_user_id=actor_uuid,
                resource_type="http_endpoint",
                resource_id=path,
                metadata={"status_code": response.status_code},
            )
            await db.commit()
    except Exception:
        logger.exception("sensitive_action_audit_failed path=%s", path)
    return response


app.include_router(auth.router)
app.include_router(wallet.router)
app.include_router(campaigns.router)
app.include_router(tasks.router)
app.include_router(kyc.router)
app.include_router(admin_mfa.router)
app.include_router(admin.router)
app.include_router(admin_audit.router)
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
    return JSONResponse(
        status_code=200 if ready else 503,
        content={"status": "ok" if ready else "degraded", "checks": checks},
    )
