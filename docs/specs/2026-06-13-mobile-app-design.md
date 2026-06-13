# MariJoy Powerbank — Mobile App Design

**Date:** 2026-06-13
**Status:** Approved (brainstorming) — ready for implementation planning
**Scope:** Flutter mobile app (Android-first MVP, iOS in v1) for the MariJoy shared-powerbank rental platform.
**Authoritative source:** `Powerbank_shared/SPEC.md` (system spec), `docs/payments-tanzania.md`, `docs/cabinet-protocol.md`, `docs/implementation-plan.md`. This document refines SPEC §3.1 into a buildable app design and does not override the system spec or the CLAUDE.md invariants.

> **Naming note:** The business is **MariJoy**. The checked-in `SPEC.md`/`CLAUDE.md` still say "MediAssist" — those docs should be corrected separately. This app uses **MariJoy** throughout.

---

## Decisions log (from brainstorming)

| Decision | Choice |
|---|---|
| Backend availability | **Mock-first** — app built against the documented API contract (SPEC §6) with a local mock data layer; runs the full rental loop on a phone with no backend. Swap to real API via one config flag. |
| App architecture | **Approach A** — feature-first folders, repository abstraction, swappable mock/HTTP data sources. |
| Branding | **Fresh design system** for MariJoy (energy/charging theme). |
| MVP edge scope (all in) | Manual Lipa-Namba fallback · Report bad bank · OS-camera deep links · In-app FAQ + WhatsApp support. |
| Repo home | App lives in **github.com/Peter-Ulm/shared_powerbank_app**; this design doc lives there under `docs/specs/`. |
| Platform | Android first (MVP); iOS in v1. |

**Out of scope for MVP (deferred to v1+ per SPEC §15):** wallet/prepaid balance, rental extend, automated payout-API refunds (MVP refunds are ops-driven), RAG support assistant, dark theme polish.

---

## 1. Architecture & project structure

Three thin layers per feature; one folder per feature. Matches CLAUDE.md feature-folder + Riverpod/freezed conventions.

```
app/lib/
├── main.dart                  # bootstrap: ProviderScope, env, Sentry, Firebase
├── app.dart                   # MaterialApp.router + theme + locale
├── core/
│   ├── env/                   # AppEnvironment (mock | dev | prod) — the ONE swap point
│   ├── network/               # dio client, auth interceptor, error→AppException mapping
│   ├── error/                 # AppException + machine-code → sw/en message mapper
│   ├── storage/               # flutter_secure_storage (tokens) + shared_preferences JSON cache
│   ├── router/                # go_router config, deep-link parsing (/c/{deviceId})
│   ├── theme/                 # MariJoy design system (Section 2)
│   ├── l10n/                  # ARB files sw/en, generated localizations
│   └── push/                  # FCM token + foreground/background message handling
├── features/
│   ├── onboarding/   { presentation/ domain/ data/ }
│   ├── home/         # map + nearby cabinet list
│   ├── scan/         # QR scanner + deep-link entry
│   ├── checkout/     # cabinet card, qty stepper, wallet pick, price
│   ├── payment/      # payment-wait + Lipa-Namba fallback
│   ├── rental/       # ejection progress + active rental timers + report-bad-bank
│   ├── history/      # rentals/receipts
│   └── support/      # FAQ + WhatsApp/call
└── mock/
    ├── scenario_engine.dart   # drives the timed loop + §9 fault injection
    └── fixtures/              # seed cabinets, banks, prices
```

**Per-feature layers**
- **domain/** — freezed models + a repository *interface* (e.g. `OrdersRepository`, `CabinetsRepository`, `RentalsRepository`, `AuthRepository`).
- **data/** — two implementations per repository: `MockX` and `HttpX` (dio). A Riverpod provider returns the right one based on `AppEnvironment`.
- **presentation/** — screens (`ConsumerWidget`) + controllers (`AsyncNotifier`/`Notifier`). Controllers hold no I/O; they call the repository.

**The one swap point.** `AppEnvironment.current` (via `--dart-define`, plus a hidden debug toggle in non-prod) decides mock vs HTTP. UI, controllers, models, and the router never know which backend is live.

**Scenario engine (mock side).** A single stateful service shared by the mock repositories. It models SPEC §4 on an injectable clock/timers: `createOrder` → `paid` (~4s) → per-bank ejection events → rentals active with `dueAt = now + 5h`. A debug panel forces any §9 branch: eject-fail→auto-refund, 2-of-3 partial, push-timeout, offline-return, overdue/lost. This makes the whole app demo-able with no backend, and the same scenarios become the integration-test cases.

**Navigation (go_router).** Auth-gate redirect (no token → onboarding); deep-link route `/c/:deviceId` → Checkout (OS-camera scans); order/rental routes that survive restart (resume in-flight payment or active rental from server/cached state on launch).

**State & data flow.** Strictly one-directional: `Screen → Controller (AsyncValue) → Repository → Model`. No business/billing math in the app — countdowns render from server `startedAt`/`dueAt` only (CLAUDE.md invariant 7). Payment polling (`GET /orders/{id}` every 3s) lives in the payment controller and auto-stops on terminal state.

**Stack (fixed by SPEC §3.1):** Flutter 3.x / Dart 3, `flutter_riverpod`, `go_router`, `dio`, `mobile_scanner`, `firebase_core`/`firebase_messaging`, `flutter_secure_storage`, `freezed` + `json_serializable`, `intl`, `flutter_map` (OSM tiles — no Google billing), `sentry_flutter`, `connectivity_plus`, `url_launcher`.

---

## 2. MariJoy design system

Energy/charging-themed identity on Material 3, with distinct MariJoy tokens. Designed for cheap Android screens, outdoor sunlight, 3G, thumbs/gloves, Swahili-first.

**Color tokens (light theme, primary):**

| Token | Hex | Use |
|---|---|---|
| Charge Green (primary) | `#0E9F6E` | brand, CTAs, "available", positive/success |
| Marigold (accent) | `#F59E0B` | energy moments — eject success burst, highlights, "few left" |
| Ink | `#111827` | primary text |
| Slate | `#6B7280` | secondary text |
| Mist | `#F3F4F6` | surfaces / card backgrounds |
| Warning | `#F59E0B` | overage approaching, low battery |
| Error | `#DC2626` | offline, faults, payment failed |
| Info | `#2563EB` | links, T&Cs, info |

Generated via `ColorScheme.fromSeed(Charge Green)`, then semantic + status tokens overridden explicitly. Dark theme comes nearly free from M3 (included; light prioritized for outdoor readability). **Status is always colorblind-safe**: color paired with icon + label.

**Typography.** Bundle **Inter (variable)** — one small file, strong legibility, supports Swahili's Latin set, keeps APK inside the 30MB budget. **Tabular figures** for the countdown and all prices. Scale: Display (timer numerals) · Headline · Title · Body · Label.

**Key custom components**
1. **RentalTimerCard** — hero of active rental. Large tabular 5h countdown; ring/bar shifts green → marigold (T-60) → red (T-15 / overdue). Multi-bank stacks per-bank timers in one card. Renders purely from server `startedAt`/`dueAt`.
2. **PaymentWaitView** — calm, the biggest drop-off point. Pulsing phone illustration, "Angalia simu yako, weka PIN" / "Check your phone, enter your PIN," ≤3-min progress, actions: Resend prompt · I paid but nothing happened · Pay another way (Lipa Namba). **No PIN field, ever** (invariant 4).
3. **CabinetCard** — availability badges (banks available / free return slots), distance, online dot.
4. **StatusChip** — online/offline/maintenance, paid/pending, eject ✓/✗.
5. **PrimaryButton** — 56dp tall, full-width.

**Motion.** Restrained, cheap to render: payment-wait pulse, lightweight marigold eject-success burst, countdown tick. Honors reduced-motion.

**Accessibility & bilingual.** ≥48dp tap targets; AA contrast (4.5:1); large-dynamic-type safe; **Swahili default**, English toggle. Flexible layouts for longer Swahili strings (no fixed-width buttons, no truncation on timer/price). Currency `TZS 1,000` (integer) via `intl`.

---

## 3. Screen-by-screen flow

Each screen lists states, API calls (SPEC §6, mocked for now), and error/edge UX tied to §9 failure modes. Happy path follows SPEC §4.

### 1. Onboarding & auth
- **Flow:** language picker (sw default / en) → phone entry (`+255`, validated) → SMS OTP (6-digit, auto-advance, paste-fill, resend timer) → JWT in secure storage.
- **API:** `POST /auth/otp/request` → `POST /auth/otp/verify` → tokens; `PATCH /me` saves locale + fcmToken.
- **Edges:** rate-limit (3/h) → wait countdown; wrong code → inline error + attempts left; OTP delay (§9 #17) → resend after 30s. First login shows **T&Cs (sw/en)** acceptance once (overage, lost-fee, refund — payments §7).

### 2. Home / map
- **States:** loading · loaded (map + list) · empty · offline (cached + banner).
- **Content:** `flutter_map` (OSM) pins + distance-sorted list; `CabinetCard` shows banks-available, free-return-slots, distance, online dot. Prominent **"Nearest cabinet with a free slot"** CTA when a rental is active.
- **API:** `GET /cabinets?lat&lng&radius`. Location permission gate with rationale; fallback to last-known/region center.
- **Edges:** offline → cached cabinets greyed + "last updated"; offline cabinet (§9 #5) → grey pin + badge, can't rent.

### 3. Scan
- **Flow:** in-app `mobile_scanner`; **also** OS-camera deep links `https://app.<domain>/c/{deviceId}` → Checkout.
- **Logic:** extract `deviceId` only (QR carries no secrets, §8); Checkout re-fetches availability server-side (tamper-proof, §9 #15).
- **Edges:** torch toggle; manual "enter cabinet code" fallback; invalid code → friendly error + rescan.

### 4. Checkout
- **States:** loading availability · ready · insufficient banks · cabinet offline · blocked user.
- **Content:** `CabinetCard` (live) · quantity stepper `1..min(available, perUserMax=3)` · wallet auto-detected from MSISDN prefix with override · price summary (`qty × unit_price`, server snapshot) · **Pay**. Pre-warm availability refresh on open (SPEC §10).
- **API:** `GET /cabinets/{id}` → `POST /orders {cabinetId, qty, wallet}` with **`Idempotency-Key`** (one per checkout attempt, reused on retry — invariant 3).
- **Edges:** `INSUFFICIENT_BANKS` / `CABINET_OFFLINE` / `USER_BLOCKED` → mapped to sw/en; blocked-for-overage (§9 #19) → settle-up screen; cap reached → "return one first."

### 5. Payment-wait *(critical screen)*
- **States:** initiating · waiting-for-PIN (poll) · succeeded→eject · failed · timeout · manual-fallback.
- **Behavior:** `PaymentWaitView`; polls `GET /orders/{id}` every 3s (auto-stops on terminal); ≤3-min wait. Actions: **Resend prompt** (`POST /orders/{id}/repush`, idempotent), **I paid but nothing happened** (forces status re-check), **Pay another way → Lipa-Namba** (till + order ref, reconcile by poll).
- **Edges (§9 #3):** wrong PIN / no balance / expired → specific message + retry; push never arrives → Lipa-Namba; **never a PIN field**. Backgrounding → FCM + on-resume state restore returns to the right place.

### 6. Ejection progress
- **States:** fulfilling (per-bank) · success · partial · refunded.
- **Behavior:** driven by `GET /orders/{id}` fulfilment array — "Inatoa benki 1 kati ya 2 — mlango 7 unawaka," then marigold success burst → Active rental.
- **Edges:** eject fail → auto-refund unit + receipt (§9 #1); partial multi-bank → per-unit result + auto partial refund (§9 #9); ejected-but-not-taken (§9 #2) → guidance + try-again/refund.

### 7. Active rental
- **Content:** `RentalTimerCard` per bank — 5h countdown from server `dueAt`, due time, **"Find a return cabinet"** (→ Home filtered to free slots). Overage warning near T-0. **Report bad bank** → flags bank + opens refund/support (§9 #20).
- **API:** `GET /rentals` / `GET /rentals/{id}` (server-computed `dueAt`, `overageTzs`). FCM reminders **T-60 / T-15**.
- **Edges:** overdue → status flips, overage meter (display-only); return is physical — app shows `completed` when backend matches the `RS` report → receipt; offline-return dispute (§9 #7) → support link; lost (48h) → lost-fee + block screen on next open (§9 #8).

### 8. History & receipts
- Past rentals + payments; receipt detail (amount, cabinet, duration, overage, refund refs). SMS receipts exist independently for money events.
- **API:** `GET /rentals?status=`, order/receipt detail.

### 9. Profile
- Language switch (sw/en, live), phone number, logout, T&Cs/privacy links, app version. `PATCH /me` for locale.

### 10. Support
- Static bilingual FAQ (`GET /content/faq?lang=`) + WhatsApp/call (`url_launcher`) + contact (`POST /support/tickets`, optional rentalId).

**Resume-on-launch (cross-cutting, flow-critical).** On cold start with a token, ask the server for any in-flight order or active rentals and land on the right screen — a killed app mid-payment or mid-rental never strands the user and never double-charges (order state lives server-side).

---

## 4. Cross-cutting concerns

Each is a small single-purpose module under `core/`.

**Auth & token lifecycle.** JWT access (15 min) + refresh (30 d) in `flutter_secure_storage`. Dio interceptor attaches bearer; on `401` transparently refreshes once, retries, and on refresh failure clears tokens → onboarding. A single in-flight refresh is shared to avoid stampede. Device-bound (SPEC §3.2).

**Internationalization (sw/en).** ARB files from day one (`app_sw.arb` default, `app_en.arb`), `gen-l10n`. No hardcoded user-facing strings. Live locale switch persisted via `PATCH /me`. Swahili-first copy; currency/dates via `intl`.

**Error handling & machine codes.** Backend returns `{error:{code,message,details}}` with stable codes. A single `ErrorMapper` → sw/en string + suggested action; UI never shows raw server text. Unknown codes → generic bilingual fallback. Network/timeout/offline are typed `AppException`s.

**Offline & caching.** `connectivity_plus` drives an offline banner. Cache last cabinet list + active rentals locally in a `shared_preferences` JSON cache (small, simplest for MVP; upgrade to drift/sqflite in v1 if the cache grows); map tiles cached by `flutter_map`. **Billing never computed offline** — timers display from server timestamps; on reconnect, re-sync rental/order state from the server (source of truth).

**Deep links.** App/Universal Links for `https://app.<domain>/c/{deviceId}` → Checkout (with server-side availability re-fetch). Unmatched links → Home + toast. Store-fallback page handled on web.

**Push (FCM).** Register token on login (`PATCH /me`), refresh on rotation. Foreground → in-app banner; background/tapped → deep-link into the relevant order/rental (payment ready, T-60/T-15, receipt, refund, lost-fee). SMS is the backend's fallback for money events — the app never depends on push for correctness.

**Config / environment.** `AppEnvironment{ mock | dev | prod }` via `--dart-define` (+ hidden debug menu in non-prod to flip data source and trigger scenario faults). Holds API base URL, deep-link domain, Sentry DSN, feature flags.

**Observability.** `sentry_flutter` for crashes + PII-scrubbed breadcrumbs (no phone numbers, no amounts in tags). Lightweight analytics events (SPEC §3.4: scan, checkout_started, paid, ejected, returned) behind a thin interface (no-op in mock).

**Security recap (app side).** No PIN ever requested/stored (invariant 4); tokens only in secure storage; TLS only; QR/deep links carry deviceId only; all pricing/availability/billing re-fetched server-side.

---

## 5. Testing strategy

The mock-first architecture makes the app testable with no backend; the scenario engine runs deterministically (injectable clock, no real timers/network).

**Unit (bulk).**
- Controllers vs fake repositories — assert state transitions (payment `waiting → succeeded → ejecting → active`; `waiting → timeout → fallback`).
- Repositories — `HttpX` vs mocked dio (`http_mock_adapter`): request shape, `Idempotency-Key` reuse on retry, error-envelope parsing.
- `ErrorMapper` — every machine code → correct sw + en string + action.
- Pure logic — phone validation, wallet-prefix detection, countdown formatting under clock skew (device clock ahead/behind must not change remaining time).

**Widget / golden** for product-carrying components in **both sw and en** (catch text overflow): `RentalTimerCard` (color thresholds, multi-bank, overdue), `PaymentWaitView` (invariant: no PIN field), `CabinetCard` states, `StatusChip` states.

**Integration / E2E** (`integration_test`, optionally `patrol`): golden path **scan → checkout → pay → ejection → countdown** via the scenario engine, plus §9 branches as named scenarios — eject-fail→auto-refund, 2-of-3 partial, push-timeout→Lipa-Namba, offline-return, resume-on-launch (kill mid-payment → relaunch → land correctly).

**Contract alignment.** Repository interfaces + freezed models written against SPEC §6 exactly, so `HttpX` impls slot into the same tests when the backend is live. Fixtures double as documented request/response shapes.

**CI.** `flutter analyze` + `flutter test` (unit + widget/golden) on every push; integration tests nightly/PR. Green before merge.

---

## Build order (for the implementation plan)

Aligned with SPEC implementation-plan Phase 7:

1. Project scaffold (`flutter create --org tz.marijoy`), theme, l10n, env, router, dio + error mapper, secure storage.
2. Mock scenario engine + fixtures + repository interfaces.
3. Onboarding & auth (mock).
4. Home / map + cabinet list.
5. Scan + deep links.
6. Checkout (idempotent order creation).
7. Payment-wait (poll + Lipa-Namba fallback).
8. Ejection progress + active rental timers (RentalTimerCard).
9. History, profile, support (FAQ + WhatsApp + report bad bank).
10. Resume-on-launch, push (FCM), Sentry, analytics.
11. `HttpX` repository implementations behind the same interfaces; flip to `dev` env against the real API + simulator.
12. Test passes (unit + golden + integration) green.

---

## References
- `SPEC.md` §3.1 (app), §4 (rental flow), §5 (data model), §6 (API), §8 (security), §9 (failure modes), §10 (perf/UX), §15 (roadmap)
- `docs/payments-tanzania.md` §3 (USSD push UX), §4 (payment state machine), §5 (pricing)
- `docs/cabinet-protocol.md` §4 (ejection state machine — backend-owned, surfaced to app via order fulfilment)
- `CLAUDE.md` — non-negotiable invariants (esp. 1, 4, 7) and Flutter conventions
