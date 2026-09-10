from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.config import settings
from app.database import engine
from app.routers import auth, wallet, campaigns, tasks, kyc, admin, notifications, rewards
from app.routers import admin_audit
from app.services.rate_limit import check_rate_limit

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
async def sensitive_endpoint_rate_limit(request: Request, call_next):
    """Apply coarse IP limits to high-risk endpoints before request parsing."""
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


app.include_router(auth.router)
app.include_router(wallet.router)
app.include_router(campaigns.router)
app.include_router(tasks.router)
app.include_router(kyc.router)
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
    checks = {"database": False}
    try:
        async with engine.connect() as connection:
            await connection.execute(text("SELECT 1"))
        checks["database"] = True
    except Exception:
        pass
    status = "ok" if all(checks.values()) else "degraded"
    return {"status": status, "checks": checks}
