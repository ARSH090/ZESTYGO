# delivery_app

Flutter mobile app for delivery partners: onboarding, availability, offers, pickup and delivery flow, location sharing, earnings.

## Feature modules (lib/features)
- `auth`
- `onboarding`
- `home`
- `assignments`
- `delivery`
- `location`
- `earnings`
- `history`
- `support`

Each feature folder uses `data/` (repositories, DTOs), `domain/` (models, use cases where useful) and `presentation/` (screens, widgets, controllers).

## Run
```bash
flutter run --dart-define=ENV=dev
```

See docs/DEPLOYMENT.md for Firebase configuration and release builds.
