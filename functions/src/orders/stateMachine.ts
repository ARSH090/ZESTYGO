import { AppError } from '../shared/errors';

export type OrderStatus =
  | 'CREATED'
  | 'PAYMENT_PENDING'
  | 'PAYMENT_FAILED'
  | 'EXPIRED'
  | 'CONFIRMED'
  | 'RESTAURANT_ACCEPTED'
  | 'REJECTED'
  | 'PREPARING'
  | 'READY_FOR_PICKUP'
  | 'PICKED_UP'
  | 'OUT_FOR_DELIVERY'
  | 'DELIVERED'
  | 'CANCELLATION_REQUESTED'
  | 'CANCELLED'
  | 'DELIVERY_FAILED'
  | 'REFUND_PENDING'
  | 'REFUNDED';

export type DeliveryStatus =
  | 'UNASSIGNED'
  | 'OFFERED'
  | 'ASSIGNED'
  | 'AT_RESTAURANT'
  | 'PICKED_UP'
  | 'DELIVERED'
  | 'FAILED';

export type Actor = 'system' | 'customer' | 'restaurant' | 'delivery_partner' | 'admin';

/** Facts the guards need. Callers load these inside the transaction. */
export interface TransitionContext {
  deliveryStatus?: DeliveryStatus;
  /** Status before a cancellation request, for restoring when admin declines. */
  previousStatus?: OrderStatus;
  /** Captured amount minus refunded amount, in paise. */
  refundableAmountPaise?: number;
  /** False only when handover codes are enabled and the supplied code was wrong. */
  handoverCodeValid?: boolean;
}

interface Rule {
  from: OrderStatus[];
  to: OrderStatus;
  actors: Actor[];
  guard?: (ctx: TransitionContext) => boolean;
}

const BEFORE_PICKUP: OrderStatus[] = ['RESTAURANT_ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP'];

const RULES: Rule[] = [
  // Payment
  { from: ['CREATED'], to: 'PAYMENT_PENDING', actors: ['system'] },
  { from: ['CREATED'], to: 'CONFIRMED', actors: ['system'] }, // COD
  { from: ['PAYMENT_PENDING'], to: 'CONFIRMED', actors: ['system'] },
  { from: ['PAYMENT_PENDING'], to: 'PAYMENT_FAILED', actors: ['system'] },
  { from: ['PAYMENT_FAILED'], to: 'PAYMENT_PENDING', actors: ['customer'] },
  { from: ['PAYMENT_PENDING', 'PAYMENT_FAILED'], to: 'EXPIRED', actors: ['system'] },

  // Restaurant
  { from: ['CONFIRMED'], to: 'RESTAURANT_ACCEPTED', actors: ['restaurant', 'admin'] },
  { from: ['CONFIRMED'], to: 'REJECTED', actors: ['restaurant', 'system', 'admin'] },
  { from: ['RESTAURANT_ACCEPTED'], to: 'PREPARING', actors: ['restaurant', 'admin'] },
  { from: ['PREPARING'], to: 'READY_FOR_PICKUP', actors: ['restaurant', 'admin'] },

  // Delivery
  {
    from: ['READY_FOR_PICKUP'],
    to: 'PICKED_UP',
    actors: ['delivery_partner', 'admin'],
    guard: (c) => c.deliveryStatus === 'ASSIGNED' || c.deliveryStatus === 'AT_RESTAURANT',
  },
  { from: ['PICKED_UP'], to: 'OUT_FOR_DELIVERY', actors: ['delivery_partner', 'system'] },
  {
    from: ['OUT_FOR_DELIVERY'],
    to: 'DELIVERED',
    actors: ['delivery_partner', 'admin'],
    guard: (c) => c.handoverCodeValid !== false,
  },
  { from: ['PICKED_UP', 'OUT_FOR_DELIVERY'], to: 'DELIVERY_FAILED', actors: ['delivery_partner', 'admin'] },
  { from: ['DELIVERY_FAILED'], to: 'CANCELLED', actors: ['admin'] },
  { from: ['DELIVERY_FAILED'], to: 'OUT_FOR_DELIVERY', actors: ['admin'] },

  // Cancellation
  { from: ['CONFIRMED'], to: 'CANCELLED', actors: ['customer', 'admin'] },
  { from: BEFORE_PICKUP, to: 'CANCELLATION_REQUESTED', actors: ['customer'] },
  { from: BEFORE_PICKUP, to: 'CANCELLED', actors: ['admin'] },
  { from: ['CANCELLATION_REQUESTED'], to: 'CANCELLED', actors: ['admin'] },
  // Declining a request restores previousStatus; handled in canTransition.

  // Refund
  {
    from: ['REJECTED', 'CANCELLED', 'EXPIRED', 'DELIVERY_FAILED'],
    to: 'REFUND_PENDING',
    actors: ['system'],
    guard: (c) => (c.refundableAmountPaise ?? 0) > 0,
  },
  { from: ['REFUND_PENDING'], to: 'REFUNDED', actors: ['system'] },
];

export function canTransition(
  from: OrderStatus,
  to: OrderStatus,
  actor: Actor,
  ctx: TransitionContext = {},
): boolean {
  // Admin declines a cancellation request: return to the remembered status.
  if (from === 'CANCELLATION_REQUESTED' && actor === 'admin') {
    if (ctx.previousStatus !== undefined && to === ctx.previousStatus && BEFORE_PICKUP.includes(to)) {
      return true;
    }
  }
  return RULES.some(
    (r) => r.to === to && r.from.includes(from) && r.actors.includes(actor) && (r.guard?.(ctx) ?? true),
  );
}

export function assertTransition(
  from: OrderStatus,
  to: OrderStatus,
  actor: Actor,
  ctx: TransitionContext = {},
): void {
  if (!canTransition(from, to, actor, ctx)) {
    throw new AppError('INVALID_TRANSITION', `Cannot move order from ${from} to ${to}`, false, {
      from,
      to,
      actor,
    });
  }
}

/** Statuses that can still lead somewhere (used by schedulers and listeners). */
export function nextStatuses(from: OrderStatus): OrderStatus[] {
  const out = new Set<OrderStatus>();
  for (const r of RULES) if (r.from.includes(from)) out.add(r.to);
  return [...out];
}

export function isTerminal(status: OrderStatus): boolean {
  return nextStatuses(status).length === 0;
}
