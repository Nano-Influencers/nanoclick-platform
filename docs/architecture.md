# Architecture Summary & Migration Plan

_Last updated: initial baseline import._

## 1. What each project is

| Project | Stack | Role |
|---|---|---|
| `backend/` | FastAPI + SQLAlchemy 2.0 (async) + Postgres + Alembic + Redis/Celery + JWT + Paystack + S3/R2-compatible storage | Single shared API for both frontends |
| `click-workers/` | Flutter, web-only build | Worker-facing app: browse tasks, submit proof, get paid, KYC, gamification (rewards, leaderboard, treasure hunt) |
| `nano-influencers/` | React 18 + Vite + react-router | Advertiser-facing app: create campaigns, fund wallet, manage campaigns |

## 2. Backend — what's already real

Despite being described as "partially configured," the backend is substantially
built:

- **Auth**: JWT access/refresh tokens, bcrypt password hashing, working Google
  and Facebook OAuth (authorization-code exchange + account upsert).
- **Campaigns → Tasks**: a `TNI_service_type → CW_task_category` mapping table
  drives worker-pay formulas (`app/services/clickpoints.py`); a 9-tier
  audience-targeting expansion engine (`app/services/targeting.py`, 717 lines)
  matches campaigns to eligible KYC'd workers.
- **Task lifecycle**: accept → submit → admin review (or 72h auto-approve via
  Celery) → escrow release, with per-worker acceptance timers, pHash-based
  duplicate-screenshot detection, and task reporting.
- **Wallet**: a double-entry ledger in kobo (integer, not float) with escrow
  lock/release and a full ClickPoints formula (midnight-bonus window, urgency
  multipliers, per-category daily/lifetime tracking).
- **Leaderboard**: weekly/monthly scoring across speed, rating, approval rate,
  quantity, and diversity dimensions.
- **Admin**: submission/campaign/KYC/report moderation endpoints.

### Status: `backend/complete-gaps` branch (2 commits so far)

**Commit 1 — critical bug fixes + migrations:**
- `bcrypt==4.0.1` pinned — passlib 1.7.4's backend-detection reads an
  attribute bcrypt>=4.1 removed, so **every password hash silently threw a
  500** as shipped. Registration/login were completely broken.
- Fixed UUID/`str` type mismatches across every response schema (auth,
  campaign, task, wallet) — models use native UUID columns, schemas declared
  `str`, and Pydantic v2 refuses to coerce during response serialization, so
  **almost every endpoint returning a UUID field crashed**.
- Added `alembic.ini` + `alembic/env.py` (neither existed) and generated the
  first real migration (13 tables).

**Commit 2 — missing endpoints + more bug fixes:**
- `Notification` model + `GET/POST /notifications/*` — a real backend feed,
  replacing Firestore ad-hoc docs (click-workers) and a hardcoded static
  array (nano-influencers). Wired inline into submission/KYC/campaign
  approve-reject flows.
- `GET /rewards/progress` — Grit/Gratis achievement tracking, reverse
  engineered from `lib/Mobile/Rewards/{grit,gratis}_achievements.dart`
  (20 approved *difficult* tasks per Grit level, 100 approved *unpaid* tasks
  per Gratis level, 10 levels each). The Level-10 "share of ₦1,000,000" pool
  payout is admin-triggered (`POST /admin/rewards/distribute-pool`) rather
  than an invented fixed amount, since "a share of" implies a period split.
- `POST /wallet/spin` and `POST /wallet/checkin` (with streak tracking),
  both on a 24h cooldown. No prize table exists anywhere in the client, so
  amounts are documented, configurable constants in `app.config`.
- Referral bonus now actually pays out, gated on the referred worker's
  *first approved submission* (not just registration/KYC) as an anti-fraud
  measure.
- `GET /tasks/{id}`, `GET /tasks/my-submissions`, `POST /tasks/{id}/cancel`.
- **Withdrawals were fundamentally broken**: a raw account number was passed
  as Paystack's `recipient_code`, which must come from a separate "create
  transfer recipient" call — and `bank_code` was silently dropped before
  ever reaching the payout worker. Fixed the full chain and added
  `GET /wallet/resolve-account` so the frontend can confirm the account
  name before withdrawing.
- Paystack webhook only handled `charge.success`; added
  `transfer.success`/`transfer.failed`/`transfer.reversed` handling so a
  failed withdrawal actually gets reversed instead of silently lost.
- OAuth callback only redirected to a mobile deep link, meaningless for
  click-workers since it's a web-only build — added `?platform=web` support.

All of the above verified end-to-end against a real local Postgres+Redis
stack (referral signup → task accept/cancel/submit → admin approval →
wallet credit + referral bonus + notifications all confirmed firing;
spin/check-in cooldowns enforced; role-based authorization boundaries hold).

### Remaining backend gaps
- No automated test suite yet (verification so far has been manual/live).
- Real-time push (SSE/WebSocket) on top of the new notifications feed —
  currently polled, which is sufficient but not instant.
- `notify_new_tasks_available` exists but nothing currently calls it when a
  campaign goes live with targeting that matches specific workers.

## 3. `click-workers` — the Firebase problem

This is a large app: **102 Dart files**, of which **39 files (~43,000 lines)
touch Firebase directly**. It isn't just using Firebase Auth — it writes its
entire data model straight to Firestore from the client: wallet balances,
click points, KYC, streaks, treasure hunt, spin-to-win, and leaderboard
documents, with a schema that doesn't match the new backend's models (e.g.
Firestore stores earnings as strings with no kobo/escrow concept, and whole
subsystems — treasure hunt, grit/gratis tiers, spin-to-win — have no backend
equivalent yet). Since the client can write its own earnings directly to
Firestore, this is also a real **security weakness** that moving to a
server-authoritative backend fixes.

Confirmed web-only: no `google-services.json` / `GoogleService-Info.plist`,
`DefaultFirebaseOptions.currentPlatform` throws `UnsupportedError` for
Android/iOS, and the project deploys via Firebase Hosting
(`firebase.json` → `build/web`).

**Security note:** `assets/env_temp.txt` contained a live-looking Paystack
secret key and Monnify (a Nigerian payment gateway not used anywhere in the
backend) keys in plaintext, shipped in a client asset. This was excluded from
the initial commit — see the root README.

### Conversion plan (in priority order)

1. Build a `lib/services/api/` layer: an HTTP client wrapping the backend's
   JWT auth (login/register/refresh, token storage), replacing
   `FirebaseAuth`/`cloud_firestore` imports one module at a time.
2. Convert bootstrap + auth flow first (`main.dart`, `authentication/utils/auth.dart`,
   `sign_in.dart`, `sign_up.dart`, `google_sign_in.dart`, `facebook_sign_in.dart`)
   since everything else depends on it.
3. Convert the two realtime "stream" files
   (`Mobile/widgets/task_stream.dart`, `Mobile/widgets/wallet_stream.dart`) —
   these currently use Firestore `.snapshots()` listeners and need to become
   polling (or SSE, once the backend implements it) equivalents. These two
   files establish the pattern the remaining screens follow.
4. Convert the core earning loop (home, tasks, wallet, KYC) before the
   gamification extras (rewards/achievements, treasure hunt, ranking), since
   the former is required for the acceptance criteria and the latter needs
   net-new backend models first.
5. Remove `firebase_options.dart`, `.firebaserc`, `firebase.json`, the
   `.firebase/` cache, and all Firebase packages from `pubspec.yaml` once no
   file references them.

**Known tooling constraint:** this environment has no network access to
pub.dev, so `flutter pub get` / `flutter build` / `flutter test` cannot be run
here to verify compilation. Dart changes are written and reasoned through
carefully, but need a local `flutter pub get && flutter build web` (or
equivalent) to confirm before merging.

## 4. `nano-influencers` — what's actually there

Not "design only" so much as a fully click-through UI prototype: no auth
screens exist, and the dashboard/campaigns/wallet/notifications all run on
local `useState` plus a fake `window` event bus (`nano-action`), with
hardcoded data (a static "Zeal" welcome name, static notification text, a
static campaign list). No backend calls exist anywhere yet.

### Build-out plan

- Add login/register screens (advertiser role) against `/auth/*`.
- Wire the dashboard's balance/stats to `/wallet/balance` and
  `/wallet/transactions`.
- Expand the campaign-creation modal to collect what `POST /campaigns`
  actually needs (title, platform, action_type, tni_service_type, budget,
  price per action, targeting) rather than just a service + link.
- Wire campaign list/pause/cancel to `GET /campaigns` and
  `PATCH /campaigns/{id}/status`.
- Wire "Add Funds" to `POST /wallet/deposit/initialize` (Paystack redirect).
- Notifications: needs a real backend model/endpoint (see backend gaps above)
  rather than a hardcoded array.

## 5. Suggested execution order

1. Backend: migrations, missing endpoints/models, notifications, web-friendly
   OAuth redirect, tests. Fully achievable and testable in a normal dev
   environment.
2. `nano-influencers`: build out fully against the backend. Small enough to
   finish completely and verify with `npm run build`.
3. `click-workers`: API-client foundation → auth flow → stream files → core
   loop → gamification extras, per the plan above.
