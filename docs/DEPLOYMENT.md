# ZestyGo — Deployment Guide

Nothing here has been run against your Firebase account; these are the exact steps to follow. Replace project IDs if yours differ.

## 1. Prerequisites

- Flutter stable (check `flutter doctor`), Dart SDK that ships with it
- Node.js 22 and npm
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Melos: `dart pub global activate melos`
- Java 17 or later (Firebase emulators)
- Accounts: Firebase (Blaze plan), Google Cloud, Razorpay (test mode), Apple Developer and Google Play for store releases

## 2. Create projects and aliases

```bash
firebase login
firebase projects:create zestygo-dev
firebase projects:create zestygo-staging
firebase projects:create zestygo-prod
firebase use --add            # choose zestygo-dev, alias dev; repeat for staging and prod
```

In each project enable: Authentication (email, Google, phone), Firestore (production mode, region close to users, for example asia-south1), Storage, Cloud Functions, Cloud Messaging, App Check, Crashlytics, Analytics, Performance. Upgrade to Blaze.

Create hosting sites for the web portals:

```bash
firebase hosting:sites:create zestygo-restaurant-dev --project zestygo-dev
firebase hosting:sites:create zestygo-admin-dev --project zestygo-dev
firebase target:apply hosting restaurant zestygo-restaurant-dev --project zestygo-dev
firebase target:apply hosting admin zestygo-admin-dev --project zestygo-dev
```
Repeat for staging and prod, and keep `.firebaserc` targets in sync.

## 3. Configure Flutter apps

```bash
./scripts/setup.sh            # installs melos, adds Firebase packages with compatible versions
cd apps/customer_app
flutterfire configure --project=zestygo-dev --out=lib/firebase_options_dev.dart \
  --platforms=android,ios
```
Run `flutterfire configure` for each app and environment (dev, staging, prod), then select options by `ENV` in `lib/core/bootstrap.dart`.

Run an app:
```bash
flutter run --dart-define=ENV=dev
flutter run -d chrome --dart-define=ENV=dev      # restaurant_portal, admin_portal
```

## 4. Secrets and external providers

```bash
firebase functions:secrets:set RAZORPAY_KEY_SECRET --project zestygo-dev
firebase functions:secrets:set RAZORPAY_WEBHOOK_SECRET --project zestygo-dev
firebase functions:secrets:set MAPS_SERVER_KEY --project zestygo-dev
```
Do the same per project with that environment's keys (test keys in dev and staging, live keys only in prod).

- **Razorpay:** create the webhook pointing at the deployed `razorpayWebhook` URL; subscribe to `payment.captured`, `payment.failed`, `refund.processed`, `refund.failed`; paste the webhook secret into the secret above.
- **Google Maps:** enable Maps SDK for Android and iOS, Places, Geocoding and Routes. Create separate keys: Android (restricted by package name and SHA-1), iOS (bundle ID), web (HTTP referrers) and one server key restricted by API.
- **Remote config or defines:** pass the Razorpay public key ID and client Maps keys per environment.
- **App Check:** register Play Integrity (Android), App Attest or DeviceCheck (iOS), reCAPTCHA Enterprise or v3 (web). Enforce after verifying clients send tokens.
- **First super admin:** create the user in Authentication, then set claims once with a script that uses the Admin SDK in a trusted environment (never from the client). Document who holds this access.

## 5. Local development with emulators

```bash
./scripts/emulators.sh        # starts Auth, Firestore, Functions, Storage, Hosting, UI on port 4000
```
Point apps to emulators in dev builds only.

## 6. Deploy backend

```bash
cd functions && npm ci && npm run build && cd ..
firebase deploy --only firestore:rules,firestore:indexes,storage --project zestygo-staging
firebase deploy --only functions --project zestygo-staging
```
Enable TTL policies once per project:
```bash
gcloud firestore fields ttls update expiresAt --collection-group=quotes --enable-ttl --project=zestygo-staging
gcloud firestore fields ttls update expiresAt --collection-group=idempotency_keys --enable-ttl --project=zestygo-staging
```

## 7. Deploy web portals

```bash
cd apps/restaurant_portal && flutter build web --release --dart-define=ENV=staging && cd ../..
cd apps/admin_portal && flutter build web --release --dart-define=ENV=staging && cd ../..
firebase deploy --only hosting --project zestygo-staging
```

## 8. Build mobile apps

```bash
cd apps/customer_app
flutter build appbundle --release --dart-define=ENV=prod      # Play Store
flutter build ipa --release --dart-define=ENV=prod            # App Store via Xcode or Transporter
```
Repeat for `delivery_app`. Complete signing setup (Android keystore, Apple certificates) outside the repository. Delivery app store listings must include the background location disclosure and the platform permission declarations.

## 9. CI/CD

- `.github/workflows/ci.yml`: format, analyze, Flutter tests, functions build and unit tests, rules tests in the emulator, dependency audit.
- `.github/workflows/deploy.yml`: manual dispatch; staging deploys after CI; production uses a GitHub environment with required reviewers.
- Authentication to Google Cloud uses workload identity federation; do not store service account JSON in GitHub.
- Required repository variables and secrets are listed at the top of `deploy.yml`.

## 10. Release flow

1. Merge to main after CI passes.
2. Deploy to staging and run the regression checklist (TESTING_STRATEGY section 6).
3. Approve the production deployment.
4. Deploy rules and indexes first, then functions, then hosting, then publish mobile builds with staged rollout.
5. Watch alerts for payment errors, function errors and stuck orders for the first hours.

**Rollback:** redeploy the previous tagged commit for functions and rules; use Hosting release rollback for web; halt staged rollout for mobile. Index or schema changes must be backward compatible for one release.

## 11. Backup and recovery

- Enable Firestore point-in-time recovery and scheduled backups in production.
- Weekly export to a locked Cloud Storage bucket: `gcloud firestore export gs://BUCKET/backups/$(date +%F) --project zestygo-prod`.
- Quarterly restore drill into the staging project.
- Storage bucket versioning for private documents.
- Record RPO and RTO targets (suggested: RPO 24 hours or better with PITR, RTO 4 hours) and test them.

## 12. Environment checklist

- [ ] Three projects created with budgets and alerts
- [ ] Secrets set per project
- [ ] Rules, indexes, TTL deployed
- [ ] Hosting targets mapped
- [ ] Razorpay webhook configured per environment
- [ ] App Check enforced after rollout verification
- [ ] First super admin created and documented
