# NanoClick Platform

NanoClick is a monorepo for a shared task-and-campaign platform serving **Click Workers** (workers who complete paid actions) and **Nano Influencers** (advertisers who create campaigns).

```text
.
├── backend/           FastAPI + SQLAlchemy (async) + PostgreSQL + Celery/Redis API
├── click-workers/     Flutter worker application
├── nano-influencers/  React/Vite advertiser application
└── docs/              Architecture and implementation-status notes
```

## Production-readiness status

The repository has undergone a substantial P0/P1 security and reliability hardening pass. The codebase should **not** be described as production-verified until the CI pipeline and a production-like Postgres/Redis deployment have completed successfully. Source code and automated verification are the source of truth.

| Area | Status | Current state |
|---|---|---|
| Backend security foundations | ✅ Implemented | Authentication hardening, OAuth state validation, refresh-token rotation/revocation, rate limiting, admin MFA/audit logging, object-level authorization, KYC ownership checks, and production configuration controls are implemented. |
| Financial integrity | ✅ Hardened | Wallet idempotency, transaction uniqueness, escrow locking/release/refund flows, withdrawal state handling, Paystack reconciliation, reward-claim uniqueness, referral idempotency, and task-capacity concurrency controls are covered by code and regression tests. |
| Task execution | ✅ Hardened | Acceptance reservations, submission expiry, approval locking, payout idempotency, slot accounting, and Celery auto-approval/expiry paths have regression coverage. |
| KYC/storage | 🟡 Backend hardened; client verification pending | KYC uploads use owner-bound private object keys and server-side submission checks. Flutter KYC/API migration is implemented, but final Flutter build/test verification must still be recorded. |
| Firebase removal | 🟡 Migration implemented; verification pending | Firebase dependencies/imports have been removed from the declared Flutter dependency graph and CI has a Firebase-free dependency guard. A clean generated Flutter lockfile and successful CI run still need to be recorded. |
| Click Workers | 🟡 Needs CI verification | Platform-safe token storage, API access, KYC draft serialization, web compatibility, Android build coverage, and Flutter tests are in place. CI has not yet been recorded as passing. |
| Nano Influencers | 🟡 Prototype / integration pending | React/Vite frontend exists, but the advertiser-facing authentication, campaign, wallet, and notification flows still require full backend integration and end-to-end verification. |
| Observability/readiness | ✅ Implemented | Request IDs, request timing/error logs, dependency-aware readiness, Redis timeouts, and readiness regression tests are implemented. |
| CI/CD | 🟡 Configured; verification pending | CI covers backend tests/compile checks, React build, Flutter analysis/tests, Firebase-free dependency checks, Flutter Web release build, and Android debug build. No green run is claimed until GitHub Actions reports success. |

Legend: ✅ implemented · 🟡 implemented but verification/integration remains · 🔴 not implemented.

## Architecture

```text
Click Workers (Flutter) ───┐
                           ├── authenticated HTTPS API ── FastAPI
Nano Influencers (React) ──┘                                ├── PostgreSQL
                                                            ├── Redis / Celery
                                                            └── private object storage
```

Clients must not connect directly to PostgreSQL, Redis, Celery, private object-storage credentials, or payment-provider secret keys. Payments and KYC uploads are orchestrated server-side; browser/mobile clients use narrowly scoped API operations and presigned object-storage URLs where appropriate.

## Security controls currently implemented

### Authentication and authorization

- Password authentication with access/refresh token handling.
- Refresh-token rotation and revocation.
- OAuth state verification and controlled web redirect allowlists.
- OAuth tokens are not placed in redirect URLs.
- Sensitive authentication endpoints are rate limited.
- Object-level authorization is enforced on protected resources.
- Admin actions have MFA and audit logging coverage.

### Financial integrity

- Wallet credit/debit operations use stable references for idempotency.
- Wallet transaction references have database uniqueness protection.
- Wallet and escrow operations use row-level locking where required.
- Withdrawal processing has explicit state transitions and provider reconciliation.
- Paystack webhook processing is idempotent.
- Campaign escrow is synchronized with campaign cancellation/refund and task payout paths.
- Task payouts distinguish advertiser client pricing from worker payout amounts.
- Reward claims and referral bonuses are protected against duplicate crediting.
- Task acceptance reservations and approvals are serialized against task slot limits.

### KYC and storage

- KYC object keys are bound to the authenticated worker.
- KYC submission rejects document keys owned by another user.
- KYC upload URLs are scoped and time-limited.
- KYC endpoints do not expose public document URLs.
- Production storage must remain private; reviewers should use authenticated/signed download paths rather than public buckets.

### Background jobs

Celery is configured with JSON serialization, late acknowledgements, worker-loss rejection, single-message prefetch, task time limits, dedicated queues for financial/approval workloads, retry controls, and scheduled maintenance jobs.

Regression coverage includes worker configuration plus actual auto-approval, acceptance-expiry, payout, and redelivery/idempotency behavior.

### Observability and health

- `GET /health` provides basic service metadata.
- `GET /health/live` is dependency-free and suitable for liveness probes.
- `GET /health/ready` verifies PostgreSQL and Redis and returns HTTP `503` when dependencies are unavailable.
- Requests receive an `X-Request-ID`; supplied request IDs are preserved.
- Request completion and unhandled request failures are logged with request context.
- Readiness Redis probes use bounded connection/read timeouts.

## Development and verification

Backend tests use PostgreSQL-compatible database behavior. CI provisions PostgreSQL 16 and runs backend compilation/import validation and the Python test suite.

Flutter CI currently performs:

```text
flutter pub get
Firebase-free dependency graph check
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

The repository deliberately does **not** claim a successful build/test until GitHub Actions reports it.

## Configuration and secrets

Required backend secrets/configuration are supplied through environment variables. Do not commit `.env` files, credentials, payment-provider secrets, private storage credentials, refresh tokens, or generated build artifacts.

Important configuration includes:

- `DATABASE_URL`
- `REDIS_URL`
- `SECRET_KEY`
- Paystack secret/public keys
- object-storage endpoint and credentials
- frontend CORS origins
- OAuth client credentials and redirect allowlists
- application environment and task/reward configuration

The Flutter and React applications must never contain backend secrets or payment-provider secret keys.

## P1 completion gate

P1 should be considered complete only when all of the following are true:

1. GitHub Actions completes successfully for the current default branch.
2. Backend migrations run cleanly against a fresh PostgreSQL database.
3. Backend automated tests pass against PostgreSQL/Redis-compatible infrastructure.
4. Flutter analysis/tests/Web/Android builds pass.
5. The Flutter dependency graph remains Firebase-free.
6. KYC upload/submit/review flows are verified end-to-end with private storage.
7. Nano Influencers authentication and core advertiser flows are connected to the backend.
8. Production secrets/configuration are supplied through the deployment environment.
9. `/health/live` and `/health/ready` are wired to deployment health probes.
10. A final manual security review confirms no new direct money mutation, authorization bypass, public KYC object exposure, duplicate payout path, or unsafe redirect has been introduced.

## Remaining work after P1

- Complete the Nano Influencers backend integration and end-to-end verification.
- Record a successful production-like migration/test/build run.
- Regenerate and commit a clean Flutter `pubspec.lock` from a trusted Flutter environment after the Firebase migration.
- Add authenticated/signed KYC document download/review flows if the admin UI requires document retrieval.
- Perform operational load/performance testing before public launch.
- P2: SSE/WebSockets, analytics/reporting, fraud detection, richer rewards/leaderboards, performance optimization, admin tooling, and reconciliation reporting.

## Historical architecture notes

See [docs/architecture.md](docs/architecture.md) for the broader architecture analysis. Historical status claims should be treated as context; the current repository state and CI results take precedence.
