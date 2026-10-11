# ZestyGo — Security, Threat Model and Privacy

## 1. Security model in one page

1. Identity comes from Firebase Authentication.
2. Roles are **custom claims set only by Cloud Functions**. A role field in a user-editable document is never used for authorization.
3. Firestore and Storage rules are **deny by default** and allow only narrow reads (and a few low-risk user-owned writes).
4. Every callable function verifies identity, role, resource ownership and account status itself, because the Admin SDK bypasses rules.
5. Money, status and permissions are computed server-side. Client values for price, status, role or payment are ignored.
6. Secrets live in Secret Manager through Functions secrets. They never appear in client code, repositories or logs.
7. Sensitive operations require recent authentication; admin operations require a second factor and are audited.

## 2. Role and permission matrix

| Capability | Customer | Restaurant owner | Restaurant manager | Partner | Support | Admin | Super admin |
|------------|----------|------------------|--------------------|---------|---------|-------|-------------|
| Read public restaurants and menus | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Own profile, addresses, cart, orders | Yes | n/a | n/a | n/a | Read | Read | Read |
| Manage own restaurant profile and hours | No | Yes | Hours no | No | No | Yes | Yes |
| Manage own menu | No | Yes | Yes | No | No | Yes | Yes |
| Transition own restaurant orders | No | Yes | Yes | No | No | Yes | Yes |
| Accept or progress assigned delivery | No | No | No | Own only | No | No | No |
| See live location of an order | Own active order | No | No | Own | Yes | Yes | Yes |
| Assign delivery | No | No | No | No | Yes | Yes | Yes |
| Refund | No | No | No | No | Up to limit | Yes | Yes |
| Approve restaurants and partners | No | No | No | No | No | Yes | Yes |
| Coupons, banners, fees, tax, areas | No | No | No | No | No | Yes | Yes |
| Commission, feature flags, payment methods | No | No | No | No | No | No | Yes |
| Assign roles | No | No | No | No | No | No | Yes |
| Read audit log | No | No | No | No | No | Yes | Yes |

Resource-based checks: a restaurant user must match `restaurantId` on the claim and on the resource; a partner must match `deliveryPartnerId` on the order; a customer must match `customerId`.

## 3. Authentication hardening

- Email verification and password policy enforced; phone OTP rate limited.
- Account suspension sets `users/{uid}.status = suspended`, revokes refresh tokens, and functions reject suspended users on every call.
- Admin accounts: second factor required; session length limited; re-authentication within 5 minutes for refunds above the configured amount, role changes, commission and payment settings.
- Logout deletes the device token record.
- Account deletion requires recent authentication, is blocked while orders are active, erases or anonymizes personal data, and keeps anonymized financial records.

## 4. Rules strategy

- Files: `firestore.rules`, `storage.rules`. Tests in `functions/test/rules` cover allowed and denied cases for every collection family.
- Clients can write only: `carts/{uid}`, `favorites`, own device tokens, `users/{uid}` display fields (`displayName`, `photoUrl`, `notificationPrefs`, `updatedAt`), and the `read` flag on own notifications.
- Menu items are readable only when the denormalized `restaurantApproved` is true (or by that restaurant and staff).
- Live location is readable by the order's customer only while `active` is true.
- Uploads: restaurant images (jpeg, png, webp, under 5 MB) to public paths for that restaurant; documents (images or PDF under 10 MB) to private paths readable only by the owner and admins.

## 5. Payment security

- Amount is taken from the server quote; the client amount is ignored.
- Checkout signature: HMAC SHA-256 of `razorpayOrderId|razorpayPaymentId`, constant-time comparison.
- Webhook: HMAC SHA-256 over the raw body with the webhook secret, event ID dedupe, fast 200 response.
- Provider payment is fetched and compared (amount, currency, order) before confirmation.
- Refund total is checked against captured amount inside a transaction; refunds use provider idempotency headers.
- No card data is stored. Test-mode keys in dev and staging; live keys only in production secrets.

## 6. Threat model (STRIDE oriented)

| # | Threat | Asset | Mitigation |
|---|--------|-------|-----------|
| T1 | User edits own role or status | Authorization | Claims server-set; rules block those fields; functions check claims and status |
| T2 | Client tampers with price or total | Revenue | Server quote and order snapshot; amount from stored quote |
| T3 | Fake payment success from client | Revenue | Server signature check, provider fetch, webhook confirmation |
| T4 | Forged or replayed webhook | Payments | HMAC over raw body, event ID dedupe, state checks |
| T5 | Double submit creates two orders or charges | Customers | Idempotency keys, deterministic redemption IDs |
| T6 | Customer reads another customer's order or address | Privacy | Rules by `customerId`; snapshots; tests |
| T7 | Restaurant reads or edits another restaurant's data | Isolation | `restaurantId` claim equals resource id on every check |
| T8 | Partner completes someone else's delivery | Integrity | Assignment check in transaction; rules and function tests |
| T9 | Unauthorized admin action or privilege escalation | Platform | RBAC, second factor, re-auth, audit log, no admin writes via rules |
| T10 | Coupon abuse or code guessing | Revenue | Server validation, per-user limits, rate limiting, deterministic redemption |
| T11 | Excessive refunds | Revenue | Cap check, roles and limits, audit |
| T12 | Location stalking | Privacy | Active-delivery-only visibility, single latest document, deletion after delivery, no partner history exposed |
| T13 | Malicious uploads | Storage | Type and size rules, private document paths, no executable types |
| T14 | API key theft (Maps) | Cost | Application and API restrictions, quotas, separate server key in Secret Manager |
| T15 | Bot abuse of OTP and quote endpoints | Cost and availability | App Check, rate limits, budget alerts |
| T16 | Secret leakage in repo or logs | All | `.gitignore`, secret scanning in CI, structured logs without secrets |
| T17 | Vulnerable dependencies | All | `npm audit`, Dart outdated checks, Dependabot |
| T18 | Insider modifies audit trail | Accountability | Audit written only by functions, never by clients or admins |
| T19 | Denial of service via listeners or large reads | Availability and cost | Pagination, narrow listeners, rate limits, budget alerts |

## 7. Privacy and data protection

- Collect only what is needed: phone and email for account, addresses for delivery, partner and restaurant documents for verification.
- Consent versions are stored with timestamps; promotional notifications require opt-in.
- Delivery partners see the customer's address and a masked contact only during an active delivery.
- Push payloads contain no addresses, phone numbers or payment details.
- Retention schedule is in DATABASE_SCHEMA section 6. Users can request export and deletion.
- Business teams must confirm obligations under India's data protection law and sector rules before launch; this document is an engineering control set, not legal advice.

## 8. Secret management

| Secret | Location | Never in |
|--------|----------|----------|
| RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET | Functions secrets per project | Client, repo, logs |
| MAPS_SERVER_KEY | Functions secrets | Client |
| Service account keys | Not created; CI uses workload identity federation | Repo |
| Public identifiers (Razorpay key ID, restricted Maps client keys) | Build defines or remote config | Treated as non-secret but restricted |

## 9. Security checklist before launch

- [ ] Rules tests pass with allowed and denied cases
- [ ] Every callable has an authorization test
- [ ] App Check enforced on functions and Storage in staging and prod
- [ ] Admin MFA enforced; super admin list reviewed
- [ ] Webhook signature and duplicate tests pass against test-mode events
- [ ] Maps keys restricted; budgets and alerts configured
- [ ] Secret scanning and dependency audit clean
- [ ] Backups enabled and restore tested
- [ ] Data retention jobs deployed
- [ ] Penetration test or external review completed
