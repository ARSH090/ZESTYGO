# ZestyGo — API Specification

## 1. Interface decision

- **Callable functions (Firebase Functions v2 `onCall`)** for every authenticated app operation. They carry the Firebase ID token and App Check token automatically and avoid hand-built routing.
- **One HTTPS function** only for the Razorpay webhook, because the provider calls it and signature verification needs the raw body.
- **Direct Firestore reads** (rules-guarded) for restaurant lists, menus, own orders and live listeners.

The logical routes from the product spec map to callables as shown below, for example `POST /v1/checkout/quote` is the callable `checkoutQuote`.

## 2. Common contract

**Request:** the callable `data` object validated with zod. Unknown fields are rejected. Mutating calls that create money or state require `idempotencyKey` (UUID v4, generated once per user action and reused on retry).

**Success response:**
```json
{ "ok": true, "data": { }, "requestId": "req_8f2c" }
```

**Error response** (as `HttpsError` with `details`):
```json
{ "code": "ITEM_UNAVAILABLE", "message": "Chicken Biryani is no longer available", "retryable": false, "requestId": "req_8f2c", "details": { "itemId": "i_1" } }
```

Internal stack traces and provider messages are never returned; they are logged with the `requestId`.

### Error codes

| Code | Meaning |
|------|---------|
| UNAUTHENTICATED | No valid token |
| PERMISSION_DENIED | Role, ownership, or account status forbids the action |
| VALIDATION_FAILED | Schema or business validation failed (includes idempotency key reused with a different payload) |
| NOT_FOUND | Resource missing or not visible to the caller |
| RESTAURANT_CLOSED, ITEM_UNAVAILABLE, PRICE_CHANGED, MIN_ORDER_NOT_MET, NOT_SERVICEABLE | Cart and checkout failures |
| COUPON_INVALID | `details.reason`: expired, not_started, min_order, limit_reached, not_eligible, inactive |
| QUOTE_EXPIRED | Request a new quote |
| INVALID_TRANSITION | State machine rejected the change |
| DUPLICATE_REQUEST_IN_PROGRESS | Same idempotency key still running (retryable) |
| PAYMENT_SIGNATURE_INVALID | Signature check failed |
| REFUND_EXCEEDS_CAPTURED | Refund larger than refundable amount |
| RECENT_AUTH_REQUIRED | Sensitive action needs fresh sign-in |
| RESOURCE_EXHAUSTED | Rate limit hit (retryable after delay) |
| INTERNAL | Unexpected error (retryable) |

## 3. Endpoint catalogue

Auth column: `A` authenticated, `P` public. Idem column: `Y` requires idempotency key. Limits are per user unless stated.

### 3.1 Customer

| Callable | Logical route | Auth and roles | Idem | Rate limit | Tests required |
|----------|---------------|----------------|------|-----------|----------------|
| usersProvision | POST /v1/users/provision | A any | Natural | 5/min | Creates once; cannot set role |
| usersUpsertAddress / usersDeleteAddress | POST /v1/users/addresses | A customer | No | 20/min | Cap of 10; serviceability; ownership |
| usersDeleteAccount | POST /v1/users/delete | A, recent auth | Y | 2/day | Blocked with active orders; anonymization |
| serviceabilityCheck | POST /v1/serviceability | A | No | 30/min | Inside and outside area |
| couponsValidate | POST /v1/coupons/validate | A customer | No | 20/min | Each rejection reason |
| checkoutQuote | POST /v1/checkout/quote | A customer | No | 30/min | Prices, taxes, fees, rounding, closed, unavailable |
| ordersCreate | POST /v1/orders | A customer | Y | 10/min | Double submit, expired quote, coupon reservation |
| ordersCancel | POST /v1/orders/{id}/cancel | A customer owner | Y | 10/min | Allowed and denied states |
| paymentsCreateOrder | POST /v1/payments/create-order | A customer owner | Y | 10/min | Retry creates no second provider order for same attempt |
| paymentsVerify | POST /v1/payments/verify | A customer owner | Y | 20/min | Valid, invalid signature, replay, amount mismatch |
| reviewsCreate / reviewsReport | POST /v1/reviews | A customer | Y | 10/day | Eligibility, duplicate |
| supportCreateTicket / supportReply | POST /v1/support/tickets | A | Y | 10/day | Ownership |
| (Firestore) restaurants, menus, orders, live location | GET /v1/restaurants, /menu, /orders/{id} | Rules | n/a | n/a | Rules tests |

### 3.2 Restaurant

| Callable | Roles | Idem | Notes |
|----------|-------|------|-------|
| restaurantsRegister | customer or restaurant_owner | Y | Creates unverified restaurant, sets `restaurantId` claim |
| restaurantsUpdateProfile, restaurantsSetOpen | owner, manager (hours: owner) | No | Approved restaurants only for open toggle |
| menuUpsertCategory, menuUpsertItem, menuDeleteItem, menuSetAvailability | owner, manager of that restaurant | No | Validates min and max add-on rules, limits |
| ordersRestaurantTransition | owner, manager | Y | `action`: accept (prep time required), reject (reason required), preparing, ready |
| restaurantsReplyReview | owner | No | One reply per review |

### 3.3 Delivery partner

| Callable | Logical route | Idem | Notes |
|----------|---------------|------|-------|
| deliveryPartnerRegister | POST /v1/partners/register | Y | Status pending |
| deliveryPartnerSetOnline | POST /v1/partners/online | No | Only if approved |
| deliveriesAccept / deliveriesReject | POST /v1/deliveries/{id}/accept | Y | Transaction; only the offered partner; one winner |
| deliveriesUpdateStatus | POST /v1/deliveries/{id}/status | Y | `status`: arrived, picked_up, out_for_delivery, delivered, failed; `handoverCode` for delivered |
| deliveriesPostLocation | POST /v1/deliveries/{id}/location | No | Active assigned delivery only; throttled to 1 per 5 s |

### 3.4 Admin and support

| Callable | Minimum role | Extra requirements |
|----------|--------------|--------------------|
| adminApproveRestaurant, adminApprovePartner | admin | Reason on reject; audit |
| adminSetAccountStatus | admin | Revokes refresh tokens; audit |
| adminAssignDelivery | admin, support | Transaction; audit |
| adminDecideCancellation | admin | Refund policy check; audit |
| adminRefund | support (up to limit), admin | Recent auth above threshold; cap check; idempotent |
| adminUpsertCoupon, adminUpsertBanner | admin | Validation; audit |
| adminUpdateConfig (fees, taxes, areas) | admin | Versioned; audit |
| adminUpdateCommission, adminSetFeatureFlag, adminSetPaymentMethods | super_admin | Recent auth; audit |
| adminSetRole | super_admin | Recent auth and second factor; audit |
| adminModerateReview | admin, support | Audit |

### 3.5 Webhook

| Function | Method | Auth |
|----------|--------|------|
| razorpayWebhook | POST /v1/webhooks/razorpay | HMAC signature header verified against the raw body and webhook secret; no user auth |

## 4. Detailed contracts

### 4.1 checkoutQuote

Request:
```ts
{
  restaurantId: string,
  lines: Array<{ itemId: string, variantId?: string, addOnIds: string[], qty: number /* 1-20 */, note?: string /* max 200 */ }>, // max 30 lines
  addressId: string,
  couponCode?: string,
  paymentMethod: 'online' | 'cod'
}
```
Response:
```ts
{
  quoteId: string,
  expiresAt: string,               // ISO, 10 minutes
  lines: Array<{ itemId: string, name: string, qty: number, unitPaise: number, linePaise: number }>,
  subtotalPaise: number,
  discountPaise: number,
  deliveryFeePaise: number,
  platformFeePaise: number,
  taxPaise: number,
  totalPaise: number,
  etaMinutes: number,
  warnings: Array<{ type: 'PRICE_CHANGED' | 'ITEM_UNAVAILABLE', itemId: string }>
}
```
Behavior: loads menu and config from Firestore, rejects closed restaurants, unavailable items, non-serviceable addresses and unmet minimum order, applies the coupon, computes every amount in paise, stores the snapshot in `quotes/{quoteId}`.

### 4.2 ordersCreate

Request: `{ quoteId: string, idempotencyKey: string, deliveryInstructions?: string, contactPhone: string }`

Response: `{ orderId, status, payment?: { razorpayOrderId, keyId, amountPaise, currency } }`

Behavior: transaction checks the idempotency record and that the quote belongs to the caller, is unexpired and unused; creates the order, marks the quote used, reserves the coupon. After commit it creates the Razorpay order (online) and moves the order to PAYMENT_PENDING; COD orders go to CONFIRMED when COD is enabled and within limit. Replays return the stored response.

### 4.3 paymentsVerify

Request: `{ orderId, razorpayPaymentId, razorpaySignature, idempotencyKey }`

Behavior: confirm caller owns the order; compute HMAC SHA-256 of `razorpayOrderId|razorpayPaymentId` with the key secret and compare in constant time; fetch the payment from Razorpay and confirm amount, currency and order match; call `confirmPayment` (transaction). Invalid signature returns `PAYMENT_SIGNATURE_INVALID` and logs a security event.

### 4.4 razorpayWebhook

Behavior: read `req.rawBody`; verify `X-Razorpay-Signature` as HMAC SHA-256 of the raw body using the webhook secret; reject with 400 if invalid; create `payments/{id}/webhook_events/{eventId}` in a transaction to dedupe (header `X-Razorpay-Event-Id`); handle `payment.captured`, `payment.failed`, `refund.processed`, `refund.failed`; always respond 200 quickly after persisting, including for duplicates and unknown events.

### 4.5 deliveriesAccept

Request: `{ deliveryId, idempotencyKey }`

Behavior: transaction verifies an unexpired offer for `request.auth.uid`, the partner is approved and online, and the delivery is still OFFERED; sets `partnerId`, `ASSIGNED`, mirrors `deliveryPartnerId` onto the order; other offers are cancelled. Any other caller receives `PERMISSION_DENIED`.

### 4.6 deliveriesPostLocation

Request: `{ deliveryId, lat, lng, heading?, speedMps?, clientTime }`

Behavior: caller must be the assigned partner on an active delivery (order status PICKED_UP or OUT_FOR_DELIVERY); coordinates validated; updates faster than 5 seconds are dropped; writes the single `delivery_locations/{orderId}` document.

## 5. Logging requirements

Every function logs `fn`, `requestId`, `uid`, `role`, `orderId` (if present), outcome and duration. Payment, refund, role and admin actions also write an audit or payment event. Never log tokens, secrets, full addresses, phone numbers or card data.

## 6. Abuse controls

Per-user rate limits (table above) via a Firestore-backed or Redis-backed limiter; App Check enforcement on callables; OTP attempts limited by Firebase Auth plus an app-level cooldown; coupon validation attempts limited to reduce code guessing.
