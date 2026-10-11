# admin_portal

Flutter Web portal for support, admins and super admins: approvals, orders, refunds, configuration, audit log.

## Feature modules (lib/features)
- `auth`
- `dashboard`
- `restaurants`
- `partners`
- `customers`
- `orders`
- `coupons`
- `banners`
- `config`
- `service_areas`
- `support`
- `audit`
- `roles`

Each feature folder uses `data/` (repositories, DTOs), `domain/` (models, use cases where useful) and `presentation/` (screens, widgets, controllers).

## Run
```bash
flutter run --dart-define=ENV=dev
```

See docs/DEPLOYMENT.md for Firebase configuration and release builds.
