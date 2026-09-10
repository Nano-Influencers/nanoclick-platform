from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.config import settings
from app.database import engine
from app.routers import auth, wallet, campaigns, tasks, kyc, admin, notifications, rewards

app = FastAPI(
    title="NanoClick API",
    description="Backend for Nano Influencers (advertiser) and Click Workers (worker) apps.",
    version="2.0.0",
    docs_url="/docs" if settings.APP_ENV != "production" else None,
    redoc_url="/redoc" if settings.APP_ENV != "production" else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)

app.include_router(auth.router)
app.include_router(wallet.router)
app.include_router(campaigns.router)
app.include_router(tasks.router)
app.include_router(kyc.router)
app.include_router(admin.router)
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
    checks = {"database": "ok"}
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
    except Exception:
        checks["database"] = "unavailable"
        raise HTTPException(status_code=503, detail={"status": "not_ready", "checks": checks})
    return {"status": "ready", "checks": checks}
