# ZestyGo — Testing Strategy

## 1. Principles

- A feature is done only when its tests exist **and have been run**. Compiling is not verification.
- Business rules are tested where they live: on the server.
- Every privileged operation has allowed and denied tests.
- Payments are tested with Razorpay test mode and recorded fixtures; success is never faked in production code paths.

## 2. Test layers

| Layer | Tooling | Location | What it covers |
|-------|---------|----------|----------------|
| Backend unit | Vitest | `functions/test/unit` | State machine, pricing, coupon rules, signature checks, idempotency logic |
| Backend integration | Vitest plus Firebase Emulator Suite | `functions/test/integration` (add as modules land) | Callables against Firestore, Auth and Storage emulators: authorization, transactions, webhooks |
| Rules tests | `@firebase/rules-unit-testing` | `functions/test/rules` | Allowed and denied access for every collection family and storage path |
| Flutter unit and state | `flutter_test`, `riverpod` overrides | `apps/*/test`, `packages/*/test` | Controllers, repositories with fakes, cart display logic |
| Flutter widget | `flutter_test` | `apps/*/test` | Forms and validation, loading, empty and error states, navigation guards |
| End-to-end | `integration_test` with emulators | `apps/customer_app/integration_test` | Full order journey (section 5) |
| Performance | Flutter DevTools, Firebase Performance | Manual and release gate | Cold start, scroll jank, list rendering |
| Accessibility | Flutter semantics checks, manual screen reader pass | Manual and widget tests | Labels, targets, contrast, text scale |

## 3. Commands

Prerequisites: Flutter, Node 22, Java 17, Firebase CLI, Melos (see DEPLOYMENT).

```bash
# Flutter, all packages and apps
melos bootstrap
melos run analyze
melos run test

# Backend unit tests
cd functions && npm ci && npm test

# Rules tests (starts emulators automatically)
cd functions && npm run test:rules

# Emulator integration tests
firebase emulators:exec --only auth,firestore,functions,storage "npm --prefix functions run test:integration"

# Everything
./scripts/test-all.sh
```

Expected behavior: all suites exit with code 0; rules tests fail loudly if any allowed case is denied or denied case is allowed.

## 4. Required test matrix

### Backend and security

| Area | Cases |
|------|-------|
| Authentication | Unauthenticated rejected; suspended user rejected; role claim required |
| Authorization | Customer cannot touch other users' addresses or orders; restaurant A cannot read or edit restaurant B; partner cannot accept or complete another partner's delivery; non-admin cannot call admin functions; support cannot exceed refund limit |
| Pricing | Subtotal, add-ons, variants, discount caps, free delivery, taxes, platform fee, rounding to paise, closed restaurant, unavailable item, minimum order, price change warning |
| Coupons | Each rejection reason, per-user and global limits, concurrent redemption, release on expiry |
| Orders | Every allowed transition; every invalid transition rejected; actor restrictions; version increments; event log written |
| Idempotency | Same key returns same order; same key different payload rejected; in-progress duplicate; stale in-progress recovery |
| Payments | Valid and invalid checkout signature; amount mismatch; replayed verify; webhook signature valid and invalid; duplicate webhook; webhook before verify; late capture after expiry triggers refund |
| Refunds | Cannot exceed captured; partial then full; duplicate request idempotent |
| Delivery | Single winner when two partners accept; offer expiry; status transitions by assigned partner only; location accepted only on active delivery and throttled |
| Reviews | Delivered orders only, one per order, within 7 days, aggregate updated |
| Admin | Audit entry written for each action; role change requires super admin and recent auth |
| Rules | Public reads limited to approved restaurants; payments admin only; location visible only while active; unknown collections denied; role field edits denied |

### Flutter

Form validation, cart totals display from server quote, price-change and unavailable-item banners, checkout double-tap prevention, payment failure recovery screen, offline and error states, GoRouter redirects by role, reduced-motion behavior.

## 5. End-to-end journeys (emulator plus Razorpay test mode)

Happy path:

register customer, browse restaurants, select food, add to cart, quote, place order, complete test payment, restaurant accepts, preparing, ready, partner assigned, pickup, delivery with handover code, customer receives completion, submits review.

Failure paths: payment failure then retry; payment abandoned and order expires with coupon released; restaurant rejection with refund; unavailable item at quote; duplicate order submission; cancellation before and after acceptance; delivery failure handled by admin.

## 6. Release regression checklist (staging)

- [ ] Full happy path on a real Android device and an iOS device
- [ ] Payment success, failure and abandonment with Razorpay test keys
- [ ] Webhook delivery observed and deduplicated
- [ ] Live tracking works with stale-location fallback
- [ ] Notifications arrive and deep link correctly
- [ ] Admin intervention flows (assign, cancel, refund) produce audit entries
- [ ] Rules and function authorization suites green on the exact commit
- [ ] Performance: cold start and scroll checked on a mid-range Android device
- [ ] Accessibility pass on core customer screens

## 7. CI gates

Pull requests must pass formatting, static analysis, Flutter tests, backend build and unit tests, rules tests and dependency audit. Production deployment requires green staging regression and manual approval.

## 8. Honest reporting

Reports must state which suites were run, on what commit, with what result, and which suites were not run. Anything unrun is listed as unverified.
