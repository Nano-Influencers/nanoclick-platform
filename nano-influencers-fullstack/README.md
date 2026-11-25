# Nano Influencers — Full Stack

Complete advertiser platform for Nano Influencers.

## Structure

- `nano-influencers-frontend/` — React + Vite frontend
- `nano-influencers-backend/` — Complete FastAPI backend

## Quick Start

### 1. Backend

```bash
cd nano-influencers-backend
cp .env.example .env
# Edit .env — at minimum set SECRET_KEY and Paystack test keys
docker compose up --build
```

API: http://localhost:8000  
Docs: http://localhost:8000/docs

### 2. Frontend

```bash
cd nano-influencers-frontend
npm install
# Optional: create .env with VITE_API_URL=http://localhost:8000
npm run dev
```

Frontend: http://localhost:5173

The frontend's `src/api.js` is already wired to talk to this backend. No frontend changes are required.

## What the Backend Provides

All endpoints used by the frontend:

- Auth (email/password + OAuth)
- Wallet + Paystack deposits
- Campaign CRUD + status + reports + audience preview
- Notifications
- Background workers (Celery) for auto-approval, payouts, etc.

See `nano-influencers-backend/README.md` for full details.
