# ADR 0001: Firebase backend with all privileged logic in Cloud Functions

Status: Accepted

## Context
We need a fast path to a secure, real-time food delivery backend with a small team. Firestore security rules cannot safely express pricing, payment, coupon, refund or assignment logic, and the Admin SDK bypasses rules.

## Decision
Use Firebase (Auth, Firestore, Storage, Functions v2 in TypeScript, FCM). Clients read narrow data through rules and call functions for every business write. Each function authorizes the caller itself.

## Consequences
- Pricing, payments and state live in one trusted place and are testable.
- Function invocations add cost and latency compared with direct writes; location updates are the main watch item.
- Search and complex analytics need external services later (see ARCHITECTURE sections 9 and 15).
