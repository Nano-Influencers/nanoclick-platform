# NanoClick Platform

Monorepo for NanoClick: one shared backend serving **Click Workers** (the worker task and earnings app) and **Nano Influencers** (the advertiser campaign app).

```text
.
├── backend/           FastAPI + SQLAlchemy (async) + Postgres + Celery/Redis API
├── click-workers/     Flutter web app for workers
├── nano-influencers/  React/Vite advertiser app
└── docs/              Architecture and implementation-status notes
```

## Project progress / implementation status

This is not production-ready as a whole. The source tree, not previous progress
notes, is the source of truth; this summary is intentionally conservative.

| Area | Status | Evidence / limitation |
|---|---|---|
| Shared FastAPI backend | ⚠️ Needs verification | Auth, task, wallet, KYC, notifications, rewards, admin, and storage routes exist. The repository still needs an automated test suite and a clean migration/test run against a real Postgres/Redis environment. |
| Click Workers auth, task, and wallet flows | ⚠️ Needs verification | The app contains a backend API client and recent conversions for the core task and wallet paths. Flutter compilation and end-to-end tests have not been recorded in this repository. |
| Click Workers Firebase removal | 🟡 In progress | Several worker screens have been converted, but KYC and potentially other unconverted screens still import Firebase. Firebase packages remain intentionally until the import audit is clean. |
| Click Workers KYC | 🟡 In progress | The backend supports a single reviewed `POST /kyc/submit` workflow and a draft service exists, but remaining wizard screens must be converted before the client is Firebase-free. |
| Nano Influencers advertiser app | 🔴 Not implemented | The React app remains primarily a click-through prototype with local state and must be connected to authenticated backend APIs. |
| Production verification | 🔴 Not implemented | No documented successful full build, migration, test, or end-to-end verification covers all applications. |

Legend: ✅ complete and verified · 🟡 in progress · ⚠️ implemented but needs
verification · 🔴 not implemented.

## Current architecture

```text
Click Workers (Flutter web) ─┐
                             ├── authenticated HTTPS API ── FastAPI
Nano Influencers (React) ────┘                                ├── PostgreSQL
                                                              ├── Redis / Celery
                                                              └── object storage
```

Clients must not access PostgreSQL, Redis, Celery, private object-storage
credentials, or payment-provider secret keys directly. Payments and uploads are
orchestrated server-side; browser uploads use narrowly scoped presigned URLs.

## Security and configuration

- Do not commit `.env` files, credentials, payment-provider secrets, or
  generated build artifacts.
- Do not add payment credentials to the Flutter or React applications.
- The previously excluded `click-workers/assets/env_temp.txt` is deliberately
  not listed as a Flutter asset. Do not restore it.
- Firebase dependencies must not be removed until the remaining imports have
  been converted to backend API calls and a Flutter web build has passed.

## Remaining work

1. Finish the Click Workers Firebase audit and convert every remaining
   Firebase-dependent screen, beginning with the KYC wizard.
2. Build the advertiser app’s real authentication, campaign, wallet, and
   notification integrations against FastAPI.
3. Add automated backend, Flutter, React, migration, and critical end-to-end
   coverage; then run it against local production-like infrastructure.
4. Re-audit authorization, payment/webhook idempotency, storage access, CORS,
   secrets, and client/backend API contracts before declaring production
   readiness.

See [docs/architecture.md](docs/architecture.md) for the historical
architecture analysis. Its status claims should be revalidated as part of the
next full audit.
