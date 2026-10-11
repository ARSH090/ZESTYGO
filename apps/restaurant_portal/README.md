# restaurant_portal

Flutter Web dashboard for restaurant owners and managers: onboarding, menu, live orders, reports and reviews.

## Feature modules (lib/features)
- `auth`
- `onboarding`
- `dashboard`
- `orders`
- `menu`
- `profile`
- `reports`
- `reviews`
- `settings`

Each feature folder uses `data/` (repositories, DTOs), `domain/` (models, use cases where useful) and `presentation/` (screens, widgets, controllers).

## Run
```bash
flutter run --dart-define=ENV=dev
```

See docs/DEPLOYMENT.md for Firebase configuration and release builds.
