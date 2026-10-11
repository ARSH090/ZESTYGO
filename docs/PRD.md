# ZestyGo — Product Requirements Document (PRD)

**Version:** 1.0  
**Status:** Approved & Build-Ready  
**Platform Target:** India (INR / paise, GST compliant, Razorpay payments, Google Maps Platform)

---

## 1. Executive Summary & Product Vision

**ZestyGo** is a high-performance food delivery ecosystem for India inspired by top-tier modern delivery platforms (Swiggy/Zomato), sporting a distinct gourmet identity with a dark obsidian (`#100E10`), saffron flame (`#FF8A00` / `#FF9F1C`), and warm cream palette. 

The ecosystem connects four unified applications across a single server-authoritative Firebase backend:
1. **Customer Mobile App** (`apps/customer_app`) — Flutter iOS & Android
2. **Restaurant Web Portal** (`apps/restaurant_portal`) — Flutter Web
3. **Delivery Partner Mobile App** (`apps/delivery_app`) — Flutter iOS & Android
4. **Admin & Support Portal** (`apps/admin_portal`) — Flutter Web

---

## 2. Core Personas & User Journeys

| Persona | Application | Primary Goals | Key Pain Points Solved |
| :--- | :--- | :--- | :--- |
| **Customer (Foodie)** | `customer_app` | Instant discovery, reliable ETA, single-tap checkout, transparent fee breakdown, real-time live rider tracking. | Eliminate hidden charges, ensure warm glassmorphic modern UI, avoid stale menus. |
| **Restaurant Partner** | `restaurant_portal` | Fast order acceptance with audio alerts, item 86-ing (availability toggle), prep time updates. | Reduce order bottlenecks, prevent accepting orders when out of stock. |
| **Delivery Fleet Partner** | `delivery_app` | Clear order broadcast offers, turn-by-turn navigation link, low battery geo-streaming. | Battery drain minimization, fair distance compensation. |
| **Operations & Support Admin** | `admin_portal` | KYC verification, manual delivery dispatch overrides, instantaneous idempotency refunds, dispute resolution. | Immediate access to immutable audit trails and Razorpay reconciliation. |

---

## 3. UI/UX & Stitch Design Specifications

The platform UI is anchored in Google Stitch high-fidelity specifications:

### 3.1 Screen CUS-001: Animated Splash & Brand Launch
* **Stitch Screen ID:** `f401a53c2ded45bb9361bbe76e96e330`
* **Visual Aesthetic:** Deep obsidian canvas (`#100E10`) with radial saffron ambient glow (`#FF8A00`), frosted glass cards (`rgba(30, 26, 28, 0.62)`), kinetic cloche delivery pin vector icon, animated loading status ("Curating top flavors near you..."), and smooth transition into discovery.
* **Component Architecture:**
  * Animated Brand Cloche + Location Pin Badge
  * Dual-tone typography ("Zesty" in cream `#FFF9F4`, "Go" in flame gradient)
  * Slogan: "GOURMET FOOD • LIGHTNING DELIVERY"
  * Progress indicator with dynamic status microcopy

### 3.2 Screen CUS-002: Customer Discovery & Home
* **Stitch Screen ID:** `6b30bcf286384812a6bb6e62b643cd4e`
* **Visual Aesthetic:** Mobile viewport (`780 x 3480`), dark glassmorphism top navigation bar with live address pill, search pill with filter badge, visual food category horizontal carousels (Biryani, Gourmet Burgers, Pizza, Desserts, Healthy Bowls), promotional banner carousel with lightning delivery badges, and curated restaurant listing cards with veg/non-veg tags, ratings, and distance/ETA chips.
* **Component Architecture:**
  * `ZestyHeader`: Location selector + Profile avatar + Notification bell
  * `ZestySearchBar`: Voice search + Cuisine filter trigger
  * `CuisineCarousel`: Interactive category roundels with glow selection states
  * `PromoHeroBanner`: Highlighting discounts & "Under 25 mins" fast delivery
  * `RestaurantCard`: Hero image, delivery time chip (`20-25 mins`), average rating badge (`4.8 ★`), cuisine subtitle, and free delivery pill

### 3.3 Brand Vector Assets
* **Stitch Asset ID:** `63e50ad22ffa4369bcd62a24e99e166b`
* Scalable SVG cloche & location pin badge with gradient fills (`#FF9F1C` to `#FF6200`).

---

## 4. Functional Requirements

### 4.1 Authentication & Profile
* Multi-factor auth via Firebase Auth (Email/Password, Phone OTP, Google Sign-in).
* Automatic server-side user provisioning trigger creating customer profile in Firestore `users/{uid}`.
* Address book supporting Home, Work, and Other tags, with GPS pin confirmation and geohashed coordinates.

### 4.2 Restaurant & Menu Discovery
* Geohash proximity query filtering restaurants within 10 km delivery radius.
* Real-time availability checks (open/closed hours, temporary pauses).
* Search and filter by Veg/Non-Veg, Rating (4.0+), Price tier, and Prep time.

### 4.3 Cart & Server-Side Pricing (Paise Precision)
* **Single Restaurant Constraint:** Cart holds items from only one restaurant at a time; attempting to add from another prompts a modal to replace cart.
* **Server-Authoritative Quotes (`checkoutQuote`):**
  * Client sends item IDs, quantities, and selected delivery address.
  * Server calculates:
    $$\text{Item Total} = \sum (\text{Price} \times \text{Qty})$$
    $$\text{Taxes (GST 5\% on restaurant)}} = \text{round}(\text{Item Total} \times 0.05)$$
    $$\text{Delivery Fee} = \text{base}(\text{₹30}) + \text{surge}(\text{₹0}) + \text{distance fee}$$
    $$\text{Platform Fee} = \text{₹5.00 (500 paise)}$$
    $$\text{Discount} = \text{validated coupon discount}$$
    $$\text{Grand Total} = \text{Item Total} + \text{Taxes} + \text{Delivery Fee} + \text{Platform Fee} - \text{Discount}$$
  * Returns cryptographic `quoteId` valid for 10 minutes.

### 4.4 Orders & State Machine
The system enforces a strict 2-track state machine:
* **Order Status:** `CREATED` $\rightarrow$ `PAYMENT_PENDING` $\rightarrow$ `CONFIRMED` $\rightarrow$ `RESTAURANT_ACCEPTED` $\rightarrow$ `PREPARING` $\rightarrow$ `READY_FOR_PICKUP` $\rightarrow$ `PICKED_UP` $\rightarrow$ `OUT_FOR_DELIVERY` $\rightarrow$ `DELIVERED` (or terminal `CANCELLED` / `REFUNDED`).
* **Delivery Status:** `UNASSIGNED` $\rightarrow$ `OFFERED` $\rightarrow$ `ASSIGNED` $\rightarrow$ `AT_RESTAURANT` $\rightarrow$ `PICKED_UP` $\rightarrow$ `DELIVERED`.

### 4.5 Payments & Idempotency
* Razorpay standard integration in test mode (`INR` currency).
* Idempotent order creation with client-supplied UUID v4 keys.
* Dual confirmation: synchronous `paymentsVerify` and asynchronous webhook `payment.captured` with signature verification.

### 4.6 Live Location Tracking
* Driver transmits coordinates every 10 seconds (minimum 20m delta) during active delivery to `delivery_locations/{orderId}`.
* Customer app displays live moving bike pin with route polyline and dynamic ETA countdown.

---

## 5. Non-Functional & Security Requirements

1. **Security Rules:** Deny by default in Firestore and Cloud Storage. All money mutations handled exclusively via Cloud Functions v2.
2. **App Check:** Enforced via Play Integrity (Android) and DeviceCheck (iOS) to protect callable endpoints.
3. **Performance:** App launch to interactive discovery $\le 1.8\text{s}$; smooth 60fps animations.
4. **Offline Resilience:** Read persistence for cached restaurants and past orders.

---

## 6. Release & Build Roadmap

* **Milestone 1:** Design System & Brand Asset Integration (`packages/design_system`)
* **Milestone 2:** Splash (`CUS-001`) & Customer Discovery Home (`CUS-002`)
* **Milestone 3:** Cart, Server Quote Calculation & Address Management
* **Milestone 4:** Razorpay Payment Flow & Order Lifecycle State Machine
* **Milestone 5:** Live Delivery Tracking & Driver Location Stream
* **Milestone 6:** Restaurant Portal, Delivery App, Admin Portal & Hardening
