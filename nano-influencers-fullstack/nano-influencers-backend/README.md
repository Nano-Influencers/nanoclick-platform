# Nano Influencers Backend

Complete FastAPI backend for the **Nano Influencers** advertiser frontend.

This backend is based on the NanoClick platform reference and implements all endpoints expected by the frontend (`src/api.js`):

- Authentication (register, login, refresh via cookie, logout, password reset, OAuth Google/Facebook)
- Wallet & deposits (Paystack integration)
- Campaigns (create, list, status updates, audience preview, reports)
- Notifications
- Supporting services (KYC, rewards, admin tools, background workers)

## Tech Stack

- **FastAPI** + Uvicorn/Gunicorn
- **PostgreSQL** (async via asyncpg + SQLAlchemy)
- **Redis** + Celery (background jobs: auto-approve, payouts, notifications)
- **Alembic** migrations
- **Paystack** for payments
- Optional S3/R2 for file storage

## Quick Start (Docker)

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set at least:
   - `SECRET_KEY` (long random string)
   - `PAYSTACK_SECRET_KEY` / `PAYSTACK_PUBLIC_KEY` (test keys)
   - `FRONTEND_ORIGINS` (include `http://localhost:5173`)

3. Start everything:
   ```bash
   docker compose up --build
   ```

4. The API will be available at `http://localhost:8000`.
   - Docs (dev only): `http://localhost:8000/docs`

5. Run migrations (if not auto-applied):
   ```bash
   docker compose exec api alembic upgrade head
   ```

## Running the Frontend Against This Backend

In the Nano Influencers frontend directory:

```bash
# .env or .env.local
VITE_API_URL=http://localhost:8000
```

Then `npm run dev`. The frontend's `api.js` is already configured to talk to this backend.

## Key Endpoints Used by the Frontend

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/auth/register` | Create advertiser account |
| POST | `/auth/login` | Login |
| POST | `/auth/refresh` | Refresh token (cookie) |
| GET | `/auth/me` | Current user |
| POST | `/auth/logout` | Logout |
| GET | `/wallet/balance` | Wallet balance |
| GET | `/wallet/transactions` | Transaction history |
| POST | `/wallet/deposit/initialize` | Start Paystack deposit |
| GET | `/campaigns` | List campaigns |
| POST | `/campaigns` | Create campaign |
| PATCH | `/campaigns/{id}/status` | Pause / resume / etc. |
| GET | `/campaigns/{id}/report` | Campaign performance |
| GET | `/notifications` | Notifications |

## Database

Migrations live in `alembic/versions/`. On first run with Docker, the database is created empty and you should run `alembic upgrade head`.

## Development

```bash
# Local (requires Postgres + Redis running)
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

## Notes

- The backend still contains Click Workers (tasker) functionality from the reference platform. It is fully compatible with the Nano Influencers advertiser frontend and can be used as-is.
- Payment callback is configured via `PAYSTACK_CALLBACK_URL` (defaults to the frontend's `payment-return.html`).
- Set `APP_ENV=production` to disable OpenAPI docs.
- CORS is controlled by `FRONTEND_ORIGINS`.

