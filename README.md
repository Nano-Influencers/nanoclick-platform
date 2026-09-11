# NanoClick Platform

NanoClick is a monorepo for a shared task-and-campaign platform serving **Click Workers** (workers who complete paid actions) and **Nano Influencers** (advertisers who create campaigns).

```text
.
├── backend/           FastAPI + SQLAlchemy (async) + PostgreSQL + Celery/Redis API
├── click-workers/     Flutter worker application
├── nano-influencers/  React/Vite advertiser application
└── docs/              Architecture and implementation-status notes
```

## Project progress

NanoClick has completed a substantial **P0/P1 production-readiness implementation pass** across security, authentication, financial integrity, background processing, KYC protection, observability, and client migration work.

The project is now in the **verification and final integration stage** rather than the initial hardening stage. The remaining production gate is evidence: a clean PostgreSQL migration run, the full automated test suite, Flutter/React CI, end-to-end KYC/payment verification, and final deployment checks must pass before the platform should be described as production-verified.

### What has been completed

| Area | Status | Progress |
|---|---|---|
| Backend security foundations | ✅ Complete | Authentication hardening, OAuth state validation, refresh-token rotation/revocation, rate limiting, admin MFA, audit logging, object-level authorization, KYC ownership checks, secure configuration controls, and security headers are implemented. |
| Financial integrity | ✅ Hardened | Wallet idempotency, transaction uniqueness, escrow locking/release/refund flows, withdrawal state handling, provider reconciliation, reward-claim uniqueness, referral idempotency, and task-capacity concurrency controls are implemented and covered by regression tests. |
| Payment flows | ✅ Hardened | Paystack deposits use idempotent initialization and webhook processing. Withdrawals use stable references, atomic wallet debits, idempotency keys, provider verification, reversal/refund handling, advisory locking, and stale-transfer reconciliation. |
| Payout failure safety | ✅ Complete | A provider failure can no longer finalize a withdrawal as failed when its debit ledger entry is missing; the worker now fails safely so retry/reconciliation can recover the state instead of silently leaving funds unrefunded. |
| Background jobs | ✅ Hardened | Celery JSON serialization, late acknowledgements, worker-loss rejection, bounded task execution, dedicated queues, retries, payout reconciliation, stale-withdrawal sweeps, and scheduled maintenance are implemented. |
| Task execution | ✅ Hardened | Acceptance reservations, submission expiry, approval locking, payout idempotency, slot accounting, and auto-approval/expiry paths have regression coverage. |
| KYC/storage | ✅ Backend hardened | Worker-owned KYC object keys, owner-bound submission checks, private storage expectations, short-lived signed document URLs, and an authorized admin document retrieval endpoint are implemented. |
| Flutter Firebase migration | ✅ Implementation complete | Legacy Firebase packages and dotenv-based client configuration have been removed from Click Workers. Authentication now uses the backend API, with native secure token storage and web-compatible token storage. |
| Flutter client | 🟡 Verification gate | API authentication, token refresh serialization, OAuth/deep-link handling, KYC/API migration, web compatibility, analysis/tests, Web release build, and Android build configuration are in place. Final clean CI verification remains required. |
| Nano Influencers web | 🟡 Integration stage | React/Vite application and build pipeline are operational; advertiser authentication, campaign, wallet, and notification flows still require complete backend integration and end-to-end verification. |
| Observability/readiness | ✅ Complete | Request IDs, request timing/error logs, security headers, dependency-aware readiness, Redis timeouts, and liveness/readiness endpoints are implemented. |
| CI/CD | 🟡 Verification gate | CI covers backend compilation/imports, PostgreSQL migration validation, Python tests, React production build, Flutter analysis/tests, Firebase-free dependency checks, Flutter Web release build, and Android debug build. A green current-branch run is still required as final evidence. |
| Migration graph | ✅ Repaired | The platform-wallet migration branch is now connected to the password/security migration chain in the correct dependency order, preventing the platform revenue-wallet migration from running before its underlying wallet tables exist. |

**Legend:** ✅ implemented/hardened · 🟡 final verification or integration remains · 🔴 not implemented.

## Production-readiness milestone

The current implementation has moved the project from broad security/reliability remediation into a **release-candidate hardening and verification phase**.

Recent production-hardening milestones include:

- Serialized concurrent access-token refreshes in both advertiser and Flutter clients.
- Removed the legacy Firebase authentication/dependency path from Click Workers.
- Removed the legacy client-side environment-loading path that could expose payment-provider configuration.
- Added private, short-lived signed KYC document downloads for authorized administrators.
- Added server-side KYC document ownership validation.
- Added wallet deposit and withdrawal idempotency keys with database uniqueness protection.
- Added Paystack payment-event idempotency and exact deposit amount validation.
- Added withdrawal provider reconciliation before retrying ambiguous payouts.
- Added PostgreSQL advisory locking around payout attempts using the stable withdrawal reference.
- Added stale withdrawal reconciliation for jobs stranded between database commit and queue delivery.
- Added regression coverage for deposit, withdrawal, webhook, concurrency, idempotency, and payout failure scenarios.
- Added a safety guard preventing provider-failure finalization when the corresponding wallet debit ledger entry is missing.
- Repaired the Alembic dependency graph so platform-wallet migrations execute in a valid order.
- Strengthened CI to validate the migration graph before running backend tests.

## Architecture

```text
Click Workers (Flutter) ───┐
                           ├── authenticated HTTPS API ── FastAPI
Nano Influencers (React) ──┘                                ├── PostgreSQL
                                                            ├── Redis / Celery
                                                            └── private object storage
```

Clients must not connect directly to PostgreSQL, Redis, Celery, private object-storage credentials, or payment-provider secret keys. Payments and KYC uploads are orchestrated server-side; browser/mobile clients use narrowly scoped API operations and presigned object-storage URLs where appropriate.

## Security controls

### Authentication and authorization

- Password authentication with access/refresh token handling.
- Refresh-token rotation and revocation.
- OAuth state verification and controlled web redirect allowlists.
- OAuth tokens are not placed in redirect URLs.
- Sensitive authentication endpoints are rate limited.
- Object-level authorization is enforced on protected resources.
- Admin actions have MFA and audit logging coverage.
- Client refresh operations are serialized to prevent competing refresh-token rotations.

### Financial integrity

- Monetary values are represented in kobo to avoid floating-point money calculations.
- Wallet credit/debit operations use stable references for idempotency.
- Wallet transaction references have database uniqueness protection.
- Wallet and escrow operations use row-level locking where required.
- Deposit initialization supports idempotency keys and preserves failed provider initialization state.
- Paystack webhook processing is signature-verified and event-idempotent.
- Deposit webhooks validate reference, currency, amount, and provider verification before crediting the wallet.
- Withdrawal processing has explicit state transitions and provider reconciliation.
- Failed/reversed withdrawals create idempotent reversal transactions.
- Payout workers refuse to finalize a provider failure if the corresponding debit ledger entry cannot be found.
- Campaign escrow is synchronized with campaign cancellation/refund and task payout paths.
- Task payouts distinguish advertiser client pricing from worker payout amounts.
- Reward claims and referral bonuses are protected against duplicate crediting.
- Task acceptance reservations and approvals are serialized against task slot limits.

### KYC and storage

- KYC object keys are bound to the authenticated worker.
- KYC submission rejects document keys owned by another user.
- KYC upload URLs are scoped and time-limited.
- Authorized administrators can retrieve KYC documents through short-lived signed download URLs.
- KYC endpoints do not expose permanent public document URLs.
- Production object storage must remain private.

### Background jobs

Celery is configured with JSON serialization, late acknowledgements, worker-loss rejection, single-message prefetch, task time limits, dedicated queues for financial/approval workloads, retry controls, and scheduled maintenance jobs.

Withdrawal processing uses a stable provider reference and a PostgreSQL advisory lock to prevent duplicate payout attempts. Ambiguous provider responses are reconciled before another transfer is created, while stale requested/processing withdrawals can be discovered and reconciled automatically.

### Observability and health

- `GET /health` provides basic service metadata.
- `GET /health/live` is dependency-free and suitable for liveness probes.
- `GET /health/ready` verifies PostgreSQL and Redis and returns HTTP `503` when dependencies are unavailable.
- Requests receive an `X-Request-ID`; supplied request IDs are preserved.
- Request completion and unhandled request failures are logged with request context.
- Readiness Redis probes use bounded connection/read timeouts.
- Security response headers are applied globally, including HSTS in production.

## Client security and Firebase migration

Click Workers now authenticates against the NanoClick backend instead of Firebase. The declared Flutter dependency graph is Firebase-free and CI contains a guard that fails if legacy Firebase packages reappear.

Native/mobile token storage uses platform secure storage. Web token storage remains an area for future hardening: a production-grade browser deployment should prefer an HttpOnly, Secure, SameSite cookie-based session/refresh design rather than long-lived bearer tokens in browser storage.

The React advertiser client also uses the backend authentication API and serializes concurrent token refresh requests to prevent refresh-token rotation races.

## Development and verification

Backend tests use PostgreSQL-compatible database behavior. CI provisions PostgreSQL 16 and runs backend compilation/import validation, migration-graph validation, migration application, and the Python test suite.

Flutter CI currently performs:

```text
flutter pub get
Firebase-free dependency graph check
flutter analyze --no-fatal-infos
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

## Release gate

The implementation work is substantially complete, but the platform should only be marked **production-verified** after all of the following pass on the current default branch:

1. GitHub Actions completes successfully.
2. A fresh PostgreSQL database upgrades cleanly through the complete Alembic graph.
3. Backend automated tests pass against PostgreSQL/Redis-compatible infrastructure.
4. Flutter analysis, tests, Web release build, and Android build pass.
5. The Flutter dependency graph remains Firebase-free.
6. KYC upload, submit, review, and signed document retrieval flows are verified end-to-end with private storage.
7. Nano Influencers authentication and core advertiser flows are connected to the backend and verified end-to-end.
8. Production secrets/configuration are supplied through the deployment environment.
9. `/health/live` and `/health/ready` are wired to deployment health probes.
10. A final manual security review confirms no new direct money mutation, authorization bypass, public KYC object exposure, duplicate payout path, or unsafe redirect has been introduced.
11. Operational load/performance testing is completed for payment, task, and high-concurrency wallet paths.

## Remaining roadmap

### Release candidate / P1 verification

- Complete the current CI verification cycle.
- Resolve any backend test failures exposed after migrations begin running.
- Complete Nano Influencers backend integration and end-to-end advertiser verification.
- Verify KYC flows against real private object storage in a staging environment.
- Regenerate and commit a clean Flutter `pubspec.lock` from a trusted Flutter environment after the Firebase migration.
- Run production-like load and failure-injection tests for wallet and payout flows.
- Complete final deployment/security review.

### P2 — post-launch platform expansion

- SSE/WebSockets and richer real-time updates.
- Analytics and reporting.
- Fraud/risk detection.
- Richer rewards and leaderboards.
- Performance optimization and caching.
- Expanded admin tooling.
- Financial reconciliation dashboards and operational reporting.

## Historical architecture notes

See [docs/architecture.md](docs/architecture.md) for the broader architecture analysis. Historical status claims should be treated as context; the current repository state, automated tests, and CI results take precedence.
