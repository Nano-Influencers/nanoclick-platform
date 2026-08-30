from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routers import auth, wallet, campaigns, tasks, kyc, admin, notifications, rewards

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
