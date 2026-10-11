# ADR 0002: Single-restaurant cart for the MVP

Status: Accepted

## Context
Multi-restaurant carts complicate delivery fees, preparation times, partner assignment, refunds and order state.

## Decision
A cart holds items from one restaurant. Adding from another restaurant shows an explicit replace-cart dialog.

## Consequences
- One order maps to one restaurant and one delivery.
- Multi-restaurant orders can be modeled later as a parent order with child orders.
