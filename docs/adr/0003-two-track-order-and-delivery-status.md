# ADR 0003: Two-track order status and delivery status

Status: Accepted

## Context
A single linear status cannot represent that a partner may be assigned before the food is ready, or after. Forcing one sequence makes valid situations impossible or ambiguous.

## Decision
Orders carry `status` (business and kitchen progress) and `deliveryStatus` (partner progress). The customer timeline merges both. Pickup requires order status READY_FOR_PICKUP and delivery status ASSIGNED or AT_RESTAURANT.

## Consequences
- Transitions are validated per track, with guards that read the other track.
- UI composes a single timeline from two fields.
