# NanoClick Platform

NanoClick is a monorepo for a shared task-and-campaign platform serving **Click Workers** (workers who complete paid actions) and **Nano Influencers** (advertisers who create campaigns).

```text
.
├── backend/           FastAPI + SQLAlchemy (async) + PostgreSQL + Celery/Redis API
├── click-workers/     Flutter worker application
├── nano-influencers/  React/Vite advertiser application
└── docs/              Architecture and implementation-status notes
```

## Production readiness

**Current phase: Release Candidate hardening / verification.**

The core P0 security and financial-integrity implementation is substantially complete. The repository should **not** yet be described as production-verified because final CI, staging, end-to-end, load, and deployment evidence still has to pass on the release candidate.

### Readiness dashboard

| Area | Status | Assessment |
|---|---|---|
| Authentication & sessions | ✅ Hardened | JWT access/refresh handling, refresh rotation/revocation, HttpOnly web refresh cookies, OAuth state/code one-time use, and session invalidation are implemented. |
| OAuth account security | ✅ Hardened | Social login now requires a provider-verified email before an account can be created or linked. Redirect URIs are allowlisted. |
| Password recovery | ✅ Implemented | Reset tokens are random, hashed at rest, one-hour, single-use credentials delivered through configured SMTP. Production requires SMTP configuration. |
| Proof uploads | ✅ P0 hardened | Proofs use worker-scoped private object keys. Submission/resubmission validates object ownership, existence, size, and content type before acceptance. |
| SSRF protection | ✅ P0 fixed | Submission hashing no longer accepts or fetches arbitrary user-controlled HTTP URLs; image hashes are computed directly from private object storage. |
| KYC storage | ✅ P0 hardened | KYC uploads are worker-scoped, private, size/type validated, and exposed to authorized administrators only through short-lived signed URLs. |
| Financial integrity | ✅ Hardened | Wallet idempotency, transaction uniqueness, escrow locking/release/refund flows, withdrawal state handling, provider reconciliation, and task-capacity concurrency controls are implemented. |
| Payment flows | ✅ Hardened | Paystack deposits and withdrawals have idempotency, provider verification/reconciliation, locking, reversal safety, and stale-operation recovery. |
| Background jobs | ✅ Hardened | Celery JSON serialization, late acknowledgements, worker-loss rejection, bounded execution, queues, retries, payout reconciliation, and maintenance jobs are implemented. |
| Observability | ✅ Implemented | Request IDs, request timing/error logs, security headers, liveness/readiness endpoints, and dependency-aware readiness are implemented. |
| Flutter client | 🟡 Verification gate | Backend authentication migration and Firebase removal are implemented; clean analysis/tests/release builds remain release evidence. |
| Nano Influencers web | 🟡 Integration gate | React/Vite application is operational; complete advertiser/backend E2E verification remains. |
| CI/CD | 🟡 Verification gate | CI covers backend, migrations, tests, React build, Flutter analysis/tests/builds, and Firebase-free checks. A clean release-candidate run is still required. |
| Production deployment | 🟡 Not yet verified | Secrets, private storage, SMTP, HTTPS, health probes, backups, monitoring, and load/failure testing must be verified in staging/production-like infrastructure. |

**Legend:** ✅ implemented/hardened · 🟡 verification/integration remains · 🔴 missing.

> **Important:** This dashboard describes implementation state, not a certification or guarantee of security. Production approval requires the release gate below to pass.

## P0 security fixes completed in the current hardening pass

### 1. Secure proof uploads

Worker proof uploads are now namespaced as:

```text
proofs/{worker_id}/{uuid}.{extension}
```

The upload URL is short-lived and private. The API no longer returns a permanent/public proof URL. Before a proof can be submitted, the backend verifies that the object:

- belongs to the authenticated worker's storage namespace;
- exists in the configured private bucket;
- is non-empty and no larger than 50 MB;
- uses an allowed extension; and
- has a matching expected content type.

### 2. SSRF eliminated from proof hashing

The previous image-hashing path accepted an arbitrary URL and made a server-side HTTP request. It has been replaced with direct retrieval from the configured private object store using an authorized storage key.

`proof_urls` remains the legacy API field name for client compatibility, but its values are now **private storage keys, not HTTP URLs**.

### 3. KYC/file validation hardened

KYC documents are stored under:

```text
kyc/{worker_id}/{uuid}.{extension}
```

KYC submission verifies the ownership prefix and performs the same server-side object existence, size, extension, and content-type checks. KYC documents never receive permanent public URLs. Authorized admin retrieval uses short-lived signed GET URLs.

### 4. Password recovery and OAuth verification completed

Password recovery now has a real SMTP delivery path:

```text
POST /auth/forgot-password
        ↓
random token → hashed token stored in PostgreSQL
        ↓
short-lived reset link delivered by SMTP
        ↓
POST /auth/reset-password
        ↓
single-use token + password update + session revocation
```

Production requires `SMTP_HOST` and `SMTP_FROM_EMAIL` plus the configured password-reset frontend URL.

OAuth account creation/linking requires a provider-verified email. Google verification is taken from the provider response; Facebook login only proceeds when the provider supplies an email, which Facebook treats as an authenticated account email in this integration.

## Architecture

```text
Click Workers (Flutter) ───┐
                           ├── authenticated HTTPS API ── FastAPI
Nano Influencers (React) ──┘                                ├── PostgreSQL
                                                            ├── Redis / Celery
                                                            └── private object storage
```

Clients must not connect directly to PostgreSQL, Redis, Celery, private object-storage credentials, SMTP credentials, or payment-provider secret keys.

Payments and KYC/proof uploads are orchestrated server-side. Clients receive narrowly scoped API responses and short-lived presigned object-storage URLs where appropriate.

## Security controls

### Authentication and authorization

- Password authentication with access/refresh token handling.
- Refresh-token rotation and revocation.
- Browser refresh sessions use HttpOnly cookies.
- OAuth state is stored hashed, expires quickly, and is consumed exactly once.
- OAuth authorization codes are short-lived, hashed, and single-use.
- OAuth account linking requires a verified provider email.
- Web redirect URIs are checked against an explicit allowlist.
- Sensitive authentication endpoints are rate limited.
- Object-level authorization is enforced on protected resources.
- Admin actions have MFA and audit logging coverage.
- Client refresh operations are serialized to prevent competing refresh-token rotations.

### Financial integrity

- Monetary values are represented in kobo.
- Wallet credit/debit operations use stable references for idempotency.
- Wallet transaction references have database uniqueness protection.
- Wallet and escrow operations use row-level locking where required.
- Paystack webhook processing is signature-verified and event-idempotent.
- Deposit webhooks validate reference, currency, amount, and provider verification.
- Withdrawal processing has explicit state transitions and provider reconciliation.
- Failed/reversed withdrawals create idempotent reversal transactions.
- Payout workers refuse unsafe provider-failure finalization when the corresponding debit ledger entry cannot be found.
- Task acceptance reservations and approvals are serialized against task slot limits.
- Reward and referral claims are protected against duplicate crediting.

### Private storage

- Proof and KYC objects are private.
- Upload keys are namespaced to the authenticated worker.
- Uploads are validated server-side after PUT.
- Maximum accepted object size is 50 MB.
- Extension/content-type mismatches are rejected.
- KYC documents are never exposed through permanent public URLs.
- Admin document access is authorized and uses short-lived signed downloads.
- Image duplicate detection reads directly from object storage rather than arbitrary URLs.

### Background jobs

Celery uses JSON serialization, late acknowledgements, worker-loss rejection, bounded task execution, dedicated queues, retry controls, payout reconciliation, stale-operation recovery, and scheduled maintenance.

### Observability and health

- `GET /health` provides basic service metadata.
- `GET /health/live` is dependency-free and suitable for liveness probes.
- `GET /health/ready` verifies PostgreSQL and Redis and returns HTTP `503` when dependencies are unavailable.
- Requests receive an `X-Request-ID`.
- Request completion and unhandled request failures are logged with request context.
- Security response headers are applied globally, including HSTS in production.

## Configuration and secrets

Never commit `.env` files, credentials, payment-provider secrets, private storage credentials, SMTP passwords, refresh tokens, or generated build artifacts.

Production additionally requires secure values for:

- `DATABASE_URL`
- `REDIS_URL`
- `SECRET_KEY`
- Paystack keys
- private object-storage endpoint/credentials
- explicit HTTPS frontend origins
- OAuth client credentials and redirect allowlists
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USERNAME` / `SMTP_PASSWORD` where required
- `SMTP_FROM_EMAIL`
- `PASSWORD_RESET_URL`
- production HTTPS callback/redirect URLs

The Flutter and React applications must never contain backend secrets or Paystack secret keys.

## Client security and Firebase migration

Click Workers authenticates against the NanoClick backend rather than Firebase. The declared Flutter dependency graph is Firebase-free and CI contains a guard that fails if legacy Firebase packages reappear.

Native/mobile token storage uses platform secure storage. Web authentication should use the backend's HttpOnly refresh-cookie design rather than long-lived bearer tokens in browser storage.

The React advertiser client also serializes concurrent token refresh requests to prevent refresh-token rotation races.

## Development and verification

Backend CI provisions PostgreSQL 16 and validates imports, the Alembic migration graph, migration application, and the Python test suite.

Flutter CI performs:

```text
flutter pub get
Firebase-free dependency graph check
flutter analyze --no-fatal-infos
flutter test
flutter build web --release
flutter build apk --debug
```

The repository does not claim successful builds/tests until GitHub Actions reports them.

## Release gate

NanoClick becomes **production-verified** only after all of these are demonstrated on the release candidate/default branch:

1. GitHub Actions is green.
2. A fresh PostgreSQL database upgrades cleanly through the complete Alembic graph.
3. Backend tests pass against PostgreSQL/Redis-compatible infrastructure.
4. Flutter analysis, tests, Web release build, and Android build pass.
5. React production build and advertiser integration tests pass.
6. Proof upload → validation → submission → review works against real private object storage.
7. KYC upload → validation → submission → admin signed retrieval works against real private storage.
8. Password reset email delivery works through the production SMTP provider.
9. Google/Facebook OAuth flows are verified with real provider accounts and only verified emails are accepted.
10. Paystack deposit, webhook, withdrawal, reversal, and reconciliation flows are verified in a staging environment.
11. `/health/live` and `/health/ready` are wired to deployment probes.
12. Backups, restore procedures, monitoring, alerting, log retention, and secret rotation are documented and tested.
13. Load/failure-injection tests cover high-concurrency task acceptance and wallet/payout paths.
14. A final manual security review finds no authorization bypass, SSRF primitive, public KYC exposure, unsafe redirect, duplicate payout path, or direct client-side money mutation.

## Remaining roadmap

### Release candidate / P1 verification

- Run and fix the complete CI suite after the current P0 changes.
- Add/expand automated tests for private object ownership, object metadata validation, SSRF regression, SMTP password recovery, and OAuth verified-email enforcement.
- Complete Nano Influencers backend integration and end-to-end advertiser verification.
- Verify KYC/proof flows with real private R2-compatible storage in staging.
- Verify password recovery with the production-like SMTP provider.
- Run production-like load and failure-injection tests for wallet, payout, task-capacity, and submission paths.
- Complete deployment/security review, backup/restore rehearsal, monitoring, and secret-rotation checks.

### P2 — post-launch expansion

- SSE/WebSockets and richer real-time updates.
- Analytics and reporting.
- Fraud/risk detection.
- Richer rewards and leaderboards.
- Performance optimization and caching.
- Expanded admin tooling.
- Financial reconciliation dashboards and operational reporting.

## Historical architecture notes

See [docs/architecture.md](docs/architecture.md) for broader architecture analysis. Historical status claims are context only; the current repository state, automated tests, and CI results take precedence.
