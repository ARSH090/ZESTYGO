# networking

Typed client for calling Cloud Functions callables.

## Responsibility
Callable wrapper, request and response decoding, retry and timeout policy, error decoding to AppFailure, idempotency key helper.

Depends only on other shared packages and its own third-party packages. Must not import from any app.
