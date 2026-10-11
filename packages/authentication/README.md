# authentication

Auth repository, session and claims providers, router guards.

## Responsibility
Sign-in methods, session persistence, custom-claim role provider, GoRouter redirect helpers, logout cleanup (device token).

Depends only on other shared packages and its own third-party packages. Must not import from any app.
