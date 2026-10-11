# common_services

Cross-cutting services: logging, analytics wrapper, error mapping, connectivity, feature flags.

## Responsibility
Interfaces plus implementations for logging, analytics events (no personal data), connectivity, remote flags, and AppFailure mapping.

Depends only on other shared packages and its own third-party packages. Must not import from any app.
