# NanoClick Platform

Monorepo for the NanoClick platform: one shared backend serving two apps —
**Click Workers** (the worker-facing task/earnings app) and **Nano Influencers**
(the advertiser-facing campaign app).

```
.
├── backend/           FastAPI + SQLAlchemy(async) + Postgres + Celery/Redis API
├── click-workers/     Flutter (web) app — workers complete tasks and get paid
├── nano-influencers/  React (Vite) app — advertisers run campaigns
└── docs/
    └── architecture.md  Architecture summary, inferred business logic,
                          Firebase-removal plan, and known gaps
```

## Status of this commit

This is the **initial baseline import** of the three existing projects, pushed
as-is (no functional changes) so we have a clean starting point on `main`
before any migration work begins. See `docs/architecture.md` for the full
analysis of what's already built, what's missing, and the plan for removing
Firebase from `click-workers` and finishing `nano-influencers` against the
shared backend.

Two things were intentionally **excluded** from this import rather than
committed and cleaned up later:

- `click-workers/assets/env_temp.txt` — contained a live-looking Paystack
  secret key and Monnify keys in plaintext. Never commit this file; secrets
  belong server-side in the backend's `.env` (see `backend/.env.example`),
  not in a Flutter client asset.
- Generated/build artifacts (`.dart_tool/`, `.firebase/` hosting cache,
  `node_modules/`, Python `__pycache__/`, `.env` files) — these are
  regenerated locally and shouldn't live in git; each subfolder has its own
  `.gitignore`.

## Working conventions going forward

- All feature work happens on branches off `main`, merged via PR — nothing
  is committed directly to `main`.
- Each subfolder is independently runnable; see its own README/setup docs
  as they're added.
