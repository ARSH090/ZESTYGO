# ZestyGo

A Swiggy-inspired food delivery platform for India, built with Flutter and Firebase. Four apps share one secure backend: customer app, restaurant portal, delivery partner app and admin portal. Original branding and assets.

**Status:** architecture, security rules, backend foundation (order state machine, payment signature checks, idempotency, auth guards) and workspace scaffolding. Feature screens and most callable functions are not built yet. See "What is verified" below.

## Repository layout

```
zestygo/
├── apps/
│   ├── customer_app/        Flutter mobile (Android, iOS)
│   ├── restaurant_portal/   Flutter Web
│   ├── delivery_app/        Flutter mobile
│   └── admin_portal/        Flutter Web
│       └── each: lib/{app,core,features/*}, test/
├── packages/
│   ├── design_system/       tokens, theme, shared widgets
│   ├── common_models/       enums, Money, DTOs
│   ├── common_services/     logging, analytics, connectivity, flags
│   ├── networking/          callable client, retries, error decoding
│   ├── authentication/      auth repo, claims, router guards
│   └── location_services/   permissions, location stream, geohash
├── functions/               Cloud Functions v2 (TypeScript)
│   ├── src/{auth,users,restaurants,menus,cart,pricing,coupons,orders,
│   │        payments,refunds,delivery,notifications,reviews,support,
│   │        admin,scheduled,shared}
│   └── test/{unit,rules,integration}
├── docs/                    ARCHITECTURE, DATABASE_SCHEMA, API_SPECIFICATION,
│                            SECURITY, DEPLOYMENT, TESTING_STRATEGY, adr/
├── scripts/                 setup.sh, emulators.sh, test-all.sh
├── .github/workflows/       ci.yml, deploy.yml
├── firebase.json  .firebaserc  firestore.rules  firestore.indexes.json  storage.rules
└── melos.yaml  analysis_options.yaml  .env.example
```

## Documentation

| Document | What it covers |
|----------|----------------|
| PRD (docs/PRD.md) | Product requirements. Export the PRD document to Markdown and save it here. |
| docs/ARCHITECTURE.md | Components, trust boundaries, flows, failure handling, scaling |
| docs/DATABASE_SCHEMA.md | Collections, fields, ownership, indexes, retention |
| docs/API_SPECIFICATION.md | Callable and webhook contracts, errors, limits |
| docs/SECURITY.md | Role matrix, threat model, secrets, privacy |
| docs/DEPLOYMENT.md | Environments, secrets, deploy and rollback commands |
| docs/TESTING_STRATEGY.md | Test layers, commands, matrix, release checklist |
| docs/adr/ | Architecture decision records |

## Quick start

Prerequisites: Flutter stable, Node.js 22, Java 17, Firebase CLI, Melos (see docs/DEPLOYMENT.md).

```bash
./scripts/setup.sh                 # adds Firebase and other packages, installs functions deps, melos bootstrap
./scripts/emulators.sh             # local Firebase emulators (UI on http://localhost:4000)

cd functions && npm test           # backend unit tests
cd functions && npm run test:rules # security rules tests (needs emulators and Java)

cd apps/customer_app && flutter run --dart-define=ENV=dev
```

Configure Firebase per app with `flutterfire configure` and set secrets with `firebase functions:secrets:set` (docs/DEPLOYMENT.md). Never commit `.env`, service account files or `firebase_options` for production.

## Build order (recommended)

1. Backend core: roles and provisioning, restaurants and menus, pricing and quote, coupons, idempotent order creation, state machine wiring, audit log.
2. Customer app: auth, address, discovery, cart, checkout, history.
3. Payments with Razorpay test mode, webhooks, refunds, reconciliation.
4. Restaurant portal, delivery app with maps and tracking, admin portal.
5. Hardening: performance, accessibility, security review, cost check.

## What is verified

Run in the authoring environment:
- `functions`: TypeScript typecheck and build passed; 26 unit tests passed (state machine, auth guards, Razorpay signatures, idempotency hashing).

Written but not run (needs Flutter SDK, Java and Firebase emulators, or a Firebase account):
- Firestore rules tests (`functions/test/rules`)
- All Flutter packages, apps and their tests
- CI and deploy workflows, setup and emulator scripts
- Firebase configuration against real projects

Treat anything in the second list as unverified until you run it.
