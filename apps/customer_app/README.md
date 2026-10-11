# customer_app

Flutter mobile app for customers: onboarding, discovery, cart, checkout, live tracking, reviews and support.

## Feature modules (lib/features)
- `auth`
- `onboarding`
- `home`
- `search`
- `restaurant`
- `cart`
- `checkout`
- `orders`
- `tracking`
- `profile`
- `addresses`
- `reviews`
- `notifications`
- `support`

Each feature folder uses `data/` (repositories, DTOs), `domain/` (models, use cases where useful) and `presentation/` (screens, widgets, controllers).

## Run
```bash
flutter run --dart-define=ENV=dev
```

See docs/DEPLOYMENT.md for Firebase configuration and release builds.
