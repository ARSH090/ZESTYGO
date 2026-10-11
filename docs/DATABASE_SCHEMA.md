# ZestyGo — Firestore Database Schema

## 1. Conventions

- **Money:** integer paise (`pricePaise`, `totalPaise`). Currency is INR; stored on payment documents as `currency`.
- **Time:** Firestore `Timestamp` in UTC. Fields: `createdAt`, `updatedAt`, plus event-specific times. Server timestamps only.
- **Enums:** uppercase strings for order and delivery states, lowercase for simple statuses.
- **IDs:** auto IDs unless a deterministic ID gives idempotency or a 1:1 relation (noted per collection).
- **Server-authoritative fields:** anything marked **S** below is written only by Cloud Functions. Clients never write it.
- **Bounded data:** arrays stay small (limits noted). Anything that grows (events, messages, locations) is a subcollection or overwritten single document.
- **Denormalization:** order documents store immutable snapshots of prices, names and addresses so later menu edits do not change history.

## 2. Collection map

| Collection | Doc ID | Purpose | Read | Write |
|------------|--------|---------|------|-------|
| `users/{uid}` | Auth uid | Profile, status, consent, prefs | Self, staff | Self (display fields only), functions |
| `users/{uid}/addresses/{id}` | auto | Saved addresses | Self, staff | Functions (`usersUpsertAddress`) |
| `users/{uid}/devices/{deviceId}` | device id | FCM tokens | Self | Self (token fields) |
| `users/{uid}/notifications/{key}` | `{eventId}_{uid}` | In-app notifications | Self | Functions; self may set `read` |
| `restaurants/{rid}` | auto | Public restaurant profile | Public if approved; restaurant users; staff | Functions |
| `restaurants/{rid}/private/{doc}` | fixed (`business`) | Documents, tax and bank reference | Restaurant owner, admin | Functions |
| `restaurants/{rid}/menu_categories/{cid}` | auto | Menu categories | As restaurant | Functions |
| `restaurants/{rid}/menu_items/{iid}` | auto | Menu items | Public if restaurant approved | Functions |
| `carts/{uid}` | uid | Display-only cart | Self | Self |
| `quotes/{quoteId}` | auto | Server quote snapshot (TTL) | None | Functions |
| `orders/{orderId}` | auto | Orders | Customer, restaurant, assigned partner, staff | Functions |
| `orders/{orderId}/events/{eventId}` | auto | Append-only transition log | Same as order | Functions |
| `payments/{paymentId}` | auto | Payment records | Admin | Functions |
| `payments/{paymentId}/webhook_events/{eventId}` | provider event id | Webhook dedupe | None | Functions |
| `refunds/{refundId}` | auto | Refund records | Admin, support | Functions |
| `coupons/{couponId}` | auto | Coupon definitions | Staff | Functions |
| `coupon_redemptions/{orderId}` | orderId | Reservation and redemption per order | Staff | Functions |
| `delivery_partners/{uid}` | uid | Partner profile and status | Self, staff | Functions |
| `deliveries/{orderId}` | orderId (1:1) | Delivery state and payout | Assigned partner, restaurant, staff | Functions |
| `deliveries/{orderId}/offers/{partnerId}` | partnerId | Offer and expiry | Offered partner | Functions |
| `delivery_locations/{orderId}` | orderId | Latest partner location only | Order customer while active; staff | Functions |
| `reviews/{orderId}` | orderId (one review per order) | Reviews | Public if visible; author; staff | Functions |
| `favorites/{uid}/restaurants/{rid}` | restaurant id | Favorites | Self | Self |
| `support_tickets/{ticketId}` | auto | Tickets | Owner, staff | Functions |
| `support_tickets/{ticketId}/messages/{id}` | auto | Messages | Owner, staff | Functions |
| `platform_config/public` | fixed | Public flags, payment methods, legal versions | Public | Functions |
| `platform_config/private` | fixed | Fees, taxes, commission, thresholds | Admin | Functions |
| `service_areas/{areaId}` | auto | Serviceable polygons | Public | Functions |
| `food_categories/{id}` | auto | Home category chips | Public | Functions |
| `banners/{id}` | auto | Promotional banners | Public | Functions |
| `stats_daily/{yyyymmdd}_{scope}` | date and scope | Aggregates (`all` or restaurantId) | Admin; restaurant for own scope | Functions |
| `admin_audit_logs/{logId}` | auto | Immutable audit trail | Admin | Functions |
| `idempotency_keys/{uid}_{key}` | uid and key | Request replay protection (TTL 24 h) | None | Functions |

## 3. Field definitions for key collections

### 3.1 users/{uid}

| Field | Type | Req | Notes |
|-------|------|-----|-------|
| displayName | string | yes | Client editable |
| email | string | no | S |
| phone | string | no | S, E.164 |
| photoUrl | string | no | Client editable |
| role | string | yes | **S**, mirrors the custom claim for convenience; rules never trust it |
| status | string | yes | **S** `active`, `suspended`, `deleted` |
| notificationPrefs | map | yes | `{orders: bool, promos: bool}`, client editable |
| consent | map | yes | **S** `{termsVersion, privacyVersion, acceptedAt}` |
| createdAt, updatedAt | timestamp | yes | S |

### 3.2 restaurants/{rid}

| Field | Type | Req | Notes |
|-------|------|-----|-------|
| ownerUid | string | yes | S |
| name, slug | string | yes | |
| searchTokens | array<string> | yes | Max 10 lowercase tokens |
| cuisines | array<string> | yes | Max 8 |
| logoUrl, coverUrl | string | no | Public storage URLs |
| address | map | yes | `{line1, area, city, pincode}` |
| geo, geohash | GeoPoint, string | yes | |
| serviceAreaIds | array<string> | yes | S, max 5 |
| status | string | yes | **S** `draft`, `submitted`, `approved`, `rejected`, `suspended` |
| isOpen | bool | yes | Manual override of schedule |
| hours | map | yes | `{mon: [{open: "11:00", close: "23:00"}], ...}` max 3 slots per day |
| timezone | string | yes | Default `Asia/Kolkata` |
| minOrderPaise | int | yes | |
| avgPrepMinutes | int | yes | |
| priceBand | int | yes | 1 to 4 |
| isVegOnly | bool | yes | |
| ratingAvg, ratingCount | number, int | yes | **S** |
| commissionBps | int | yes | **S**, basis points |
| createdAt, updatedAt | timestamp | yes | S |

```json
{
  "ownerUid": "u_91ab",
  "name": "Spice Route Kitchen",
  "slug": "spice-route-kitchen",
  "searchTokens": ["spice", "route", "kitchen"],
  "cuisines": ["North Indian", "Biryani"],
  "address": {"line1": "12 Main Road", "area": "Bistupur", "city": "Jamshedpur", "pincode": "831001"},
  "geohash": "tuw1k7e",
  "serviceAreaIds": ["jsr-central"],
  "status": "approved",
  "isOpen": true,
  "hours": {"mon": [{"open": "11:00", "close": "23:00"}]},
  "timezone": "Asia/Kolkata",
  "minOrderPaise": 15000,
  "avgPrepMinutes": 20,
  "priceBand": 2,
  "isVegOnly": false,
  "ratingAvg": 4.3,
  "ratingCount": 182,
  "commissionBps": 1800
}
```

### 3.3 restaurants/{rid}/menu_items/{iid}

| Field | Type | Req | Notes |
|-------|------|-----|-------|
| restaurantId | string | yes | S, denormalized for collection-group queries and rules |
| restaurantApproved | bool | yes | **S**, kept in sync when restaurant status changes |
| categoryId | string | yes | |
| name, nameTokens | string, array | yes | Tokens max 10 |
| description | string | no | Max 500 chars |
| pricePaise | int | yes | Base price |
| isVeg | bool | yes | |
| imageUrl | string | no | |
| isAvailable | bool | yes | |
| variants | array<map> | no | Max 10: `{id, name, pricePaise}` |
| addOnGroups | array<map> | no | Max 10 groups: `{id, name, min, max, options: [{id, name, pricePaise, isAvailable}]}` max 20 options each |
| taxCategory | string | yes | Used by pricing |
| sortOrder | int | yes | |
| updatedAt | timestamp | yes | S |

### 3.4 orders/{orderId}

| Field | Type | Req | Notes |
|-------|------|-----|-------|
| customerId, restaurantId | string | yes | S |
| status | string | yes | **S** order state (see PRD section 5) |
| deliveryStatus | string | yes | **S** `UNASSIGNED`, `OFFERED`, `ASSIGNED`, `AT_RESTAURANT`, `PICKED_UP`, `DELIVERED`, `FAILED` |
| deliveryPartnerId | string | no | S |
| paymentMethod | string | yes | `online` or `cod` |
| priceSnapshot | map | yes | Immutable: `lines`, `subtotalPaise`, `discountPaise`, `deliveryFeePaise`, `platformFeePaise`, `taxPaise`, `totalPaise` |
| addressSnapshot | map | yes | Includes geo, contact, instructions |
| restaurantSnapshot | map | yes | Name, address, geo |
| couponId | string | no | |
| handoverCodeHash | string | no | S |
| previousStatus | string | no | S, used for cancellation requests |
| etaAt | timestamp | no | |
| expiresAt | timestamp | no | Payment expiry |
| version | int | yes | S, incremented per transition |
| placedAt, acceptedAt, readyAt, pickedUpAt, deliveredAt, cancelledAt | timestamp | no | S |
| createdAt, updatedAt | timestamp | yes | S |

```json
{
  "customerId": "u_204c",
  "restaurantId": "r_17f2",
  "status": "PREPARING",
  "deliveryStatus": "ASSIGNED",
  "deliveryPartnerId": "p_88d1",
  "paymentMethod": "online",
  "priceSnapshot": {
    "lines": [{"itemId": "i_1", "name": "Chicken Biryani", "qty": 2, "unitPaise": 24900, "addOns": [], "linePaise": 49800}],
    "subtotalPaise": 49800,
    "discountPaise": 5000,
    "deliveryFeePaise": 3500,
    "platformFeePaise": 500,
    "taxPaise": 2490,
    "totalPaise": 51290
  },
  "version": 5
}
```

### 3.5 payments/{paymentId}

| Field | Type | Notes |
|-------|------|-------|
| orderId, customerId | string | |
| provider | string | `razorpay` |
| providerOrderId, providerPaymentId | string | |
| amountPaise, currency | int, string | Amount equals the order total; verified on capture |
| status | string | `created`, `authorized`, `captured`, `failed`, `refund_pending`, `partially_refunded`, `refunded` |
| method | string | Provider-reported type only (card, upi, netbanking); no card data |
| refundedPaise | int | Never exceeds amountPaise (checked in transaction) |
| createdAt, updatedAt | timestamp | |

### 3.6 deliveries/{orderId}, delivery_locations/{orderId}

```json
{
  "deliveries": {
    "orderId": "o_9a", "restaurantId": "r_17f2", "customerId": "u_204c",
    "partnerId": "p_88d1", "status": "ASSIGNED",
    "pickup": {"geo": "GeoPoint", "label": "Spice Route Kitchen"},
    "drop": {"geo": "GeoPoint", "area": "Sakchi"},
    "payoutPaise": 4500
  },
  "delivery_locations": {
    "partnerId": "p_88d1", "customerId": "u_204c",
    "geo": "GeoPoint", "heading": 92, "speedMps": 6.1,
    "active": true, "updatedAt": "Timestamp"
  }
}
```

### 3.7 Other documents (summary)

- **coupons:** `code` (uppercase, unique), `type` (`percent`, `flat`, `free_delivery`), `value`, `maxDiscountPaise`, `minOrderPaise`, `startsAt`, `endsAt`, `usageLimitTotal`, `usageLimitPerUser`, `usedCount` (S), `restaurantIds` (max 20, empty means all), `firstOrderOnly`, `isActive`.
- **coupon_redemptions/{orderId}:** `couponId`, `uid`, `amountPaise`, `status` (`reserved`, `redeemed`, `released`). Deterministic ID makes redemption idempotent. Per-user usage is counted with an aggregation query on `couponId` and `uid`.
- **reviews/{orderId}:** `customerId`, `restaurantId`, `rating` (1 to 5), `text` (max 500), `status` (`visible`, `hidden`, `reported`), `reply {text, at}`, `createdAt`.
- **support_tickets:** `uid`, `orderId?`, `category`, `status`, `assigneeUid?`, `subject`, timestamps.
- **admin_audit_logs:** `actorUid`, `actorRole`, `action`, `targetType`, `targetId`, `summary {before, after}` (redacted), `requestId`, `at`.
- **idempotency_keys:** `uid`, `key`, `requestHash`, `status` (`in_progress`, `completed`, `failed`), `response`, `startedAt`, `expiresAt`.

## 4. Client-editable versus server-authoritative

| Client may write | Only functions may write |
|------------------|--------------------------|
| users: displayName, photoUrl, notificationPrefs | users: role, status, consent, contact fields |
| users/devices: token fields | Everything under orders, payments, refunds, deliveries, delivery_locations |
| carts/{uid} (display-only) | restaurants, menus, coupons, config, areas, banners |
| favorites | reviews, tickets, audit logs, stats |
| users/notifications: `read` flag | idempotency keys, quotes |

## 5. Indexes

Defined in `firestore.indexes.json`.

| Collection | Fields | Query |
|------------|--------|-------|
| restaurants | status, serviceAreaIds (array), ratingAvg desc | Home feed by area |
| restaurants | status, cuisines (array), ratingAvg desc | Cuisine filter |
| restaurants | status, searchTokens (array), ratingAvg desc | Search |
| orders | customerId, createdAt desc | Customer history |
| orders | restaurantId, status, createdAt desc | Restaurant queue and history |
| orders | status, createdAt desc | Admin order lists |
| deliveries | partnerId, createdAt desc | Partner history |
| reviews | restaurantId, status, createdAt desc | Restaurant reviews |
| menu_items (collection group) | restaurantApproved, isAvailable, nameTokens (array) | Dish search |
| support_tickets | uid, createdAt desc; status, createdAt desc | User and staff queues |
| admin_audit_logs | actorUid, at desc; action, at desc | Audit search |

Geohash nearby queries use range filters on `geohash` per cell and need an index for each filter combination in use; add them as features land.

## 6. Retention and sensitivity

| Data | Classification | Retention |
|------|----------------|-----------|
| Orders, events, payments, refunds | Financial | 8 years (anonymize customer references after account deletion) |
| User profile, addresses | Personal | Until deletion request, then erased or anonymized |
| Delivery location | Sensitive | Single latest document, deleted within 1 hour of completion |
| Partner and restaurant documents | Sensitive | Life of account plus legal minimum; private storage |
| Support tickets | Personal | 2 years |
| Audit logs | Internal | 7 years |
| Quotes | Internal | TTL 1 hour |
| Idempotency keys | Internal | TTL 24 hours |
| Device tokens | Personal | Removed on logout, invalid response, or deletion |

TTL policies are enabled with gcloud, for example:
`gcloud firestore fields ttls update expiresAt --collection-group=quotes --enable-ttl --project=PROJECT_ID`

Never stored: card numbers, CVV, UPI PINs, payment secrets, government ID numbers beyond what verification requires (documents sit in private storage with restricted access).

## 7. Firestore limits and implications

- A document sustains roughly one write per second; use per-day or sharded counters for stats.
- Document size is limited to 1 MiB; bounded arrays keep menu items and carts far below that.
- Transactions retry on contention, so callbacks must be free of side effects and external calls.
- Collection-group queries need their own indexes and rules (`match /{path=**}/menu_items/{id}`).
- Offset pagination is expensive; use cursors (`startAfter`).
- Rules `get()` calls count as billable reads and are capped per request; keep rules lookups to one or two documents.
