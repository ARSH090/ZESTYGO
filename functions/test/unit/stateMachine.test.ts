import { describe, expect, it } from 'vitest';
import {
  assertTransition,
  canTransition,
  isTerminal,
  nextStatuses,
  OrderStatus,
} from '../../src/orders/stateMachine';

describe('order state machine', () => {
  it('allows the online happy path in order', () => {
    const path: Array<[OrderStatus, OrderStatus, Parameters<typeof canTransition>[2]]> = [
      ['CREATED', 'PAYMENT_PENDING', 'system'],
      ['PAYMENT_PENDING', 'CONFIRMED', 'system'],
      ['CONFIRMED', 'RESTAURANT_ACCEPTED', 'restaurant'],
      ['RESTAURANT_ACCEPTED', 'PREPARING', 'restaurant'],
      ['PREPARING', 'READY_FOR_PICKUP', 'restaurant'],
      ['PICKED_UP', 'OUT_FOR_DELIVERY', 'delivery_partner'],
    ];
    for (const [from, to, actor] of path) {
      expect(canTransition(from, to, actor), `${from} -> ${to}`).toBe(true);
    }
    expect(
      canTransition('READY_FOR_PICKUP', 'PICKED_UP', 'delivery_partner', { deliveryStatus: 'ASSIGNED' }),
    ).toBe(true);
    expect(canTransition('OUT_FOR_DELIVERY', 'DELIVERED', 'delivery_partner')).toBe(true);
  });

  it('allows COD to skip payment states', () => {
    expect(canTransition('CREATED', 'CONFIRMED', 'system')).toBe(true);
  });

  it('rejects skipping states', () => {
    expect(canTransition('CONFIRMED', 'PREPARING', 'restaurant')).toBe(false);
    expect(canTransition('CREATED', 'DELIVERED', 'system')).toBe(false);
    expect(canTransition('PREPARING', 'DELIVERED', 'delivery_partner')).toBe(false);
  });

  it('enforces actor restrictions', () => {
    expect(canTransition('CONFIRMED', 'RESTAURANT_ACCEPTED', 'customer')).toBe(false);
    expect(canTransition('PAYMENT_PENDING', 'CONFIRMED', 'customer')).toBe(false);
    expect(canTransition('PAYMENT_PENDING', 'CONFIRMED', 'restaurant')).toBe(false);
    expect(canTransition('OUT_FOR_DELIVERY', 'DELIVERED', 'customer')).toBe(false);
  });

  it('requires an assigned partner before pickup', () => {
    expect(canTransition('READY_FOR_PICKUP', 'PICKED_UP', 'delivery_partner')).toBe(false);
    expect(
      canTransition('READY_FOR_PICKUP', 'PICKED_UP', 'delivery_partner', { deliveryStatus: 'UNASSIGNED' }),
    ).toBe(false);
    expect(
      canTransition('READY_FOR_PICKUP', 'PICKED_UP', 'delivery_partner', { deliveryStatus: 'AT_RESTAURANT' }),
    ).toBe(true);
  });

  it('blocks delivery when a required handover code is wrong', () => {
    expect(
      canTransition('OUT_FOR_DELIVERY', 'DELIVERED', 'delivery_partner', { handoverCodeValid: false }),
    ).toBe(false);
    expect(
      canTransition('OUT_FOR_DELIVERY', 'DELIVERED', 'delivery_partner', { handoverCodeValid: true }),
    ).toBe(true);
  });

  it('lets customers cancel freely only before restaurant acceptance', () => {
    expect(canTransition('CONFIRMED', 'CANCELLED', 'customer')).toBe(true);
    expect(canTransition('RESTAURANT_ACCEPTED', 'CANCELLED', 'customer')).toBe(false);
    expect(canTransition('PREPARING', 'CANCELLATION_REQUESTED', 'customer')).toBe(true);
    expect(canTransition('PICKED_UP', 'CANCELLATION_REQUESTED', 'customer')).toBe(false);
  });

  it('lets admins approve or decline cancellation requests', () => {
    expect(canTransition('CANCELLATION_REQUESTED', 'CANCELLED', 'admin')).toBe(true);
    expect(
      canTransition('CANCELLATION_REQUESTED', 'PREPARING', 'admin', { previousStatus: 'PREPARING' }),
    ).toBe(true);
    expect(canTransition('CANCELLATION_REQUESTED', 'PREPARING', 'admin')).toBe(false);
    expect(
      canTransition('CANCELLATION_REQUESTED', 'DELIVERED', 'admin', { previousStatus: 'DELIVERED' }),
    ).toBe(false);
    expect(canTransition('CANCELLATION_REQUESTED', 'CANCELLED', 'customer')).toBe(false);
  });

  it('handles rejection, expiry and payment retry', () => {
    expect(canTransition('CONFIRMED', 'REJECTED', 'restaurant')).toBe(true);
    expect(canTransition('CONFIRMED', 'REJECTED', 'system')).toBe(true);
    expect(canTransition('PAYMENT_PENDING', 'PAYMENT_FAILED', 'system')).toBe(true);
    expect(canTransition('PAYMENT_FAILED', 'PAYMENT_PENDING', 'customer')).toBe(true);
    expect(canTransition('PAYMENT_FAILED', 'EXPIRED', 'system')).toBe(true);
    expect(canTransition('PAYMENT_PENDING', 'EXPIRED', 'system')).toBe(true);
  });

  it('only starts a refund when something is refundable', () => {
    expect(canTransition('REJECTED', 'REFUND_PENDING', 'system')).toBe(false);
    expect(canTransition('REJECTED', 'REFUND_PENDING', 'system', { refundableAmountPaise: 0 })).toBe(false);
    expect(canTransition('REJECTED', 'REFUND_PENDING', 'system', { refundableAmountPaise: 51290 })).toBe(true);
    expect(canTransition('CANCELLED', 'REFUND_PENDING', 'system', { refundableAmountPaise: 100 })).toBe(true);
    expect(canTransition('REFUND_PENDING', 'REFUNDED', 'system')).toBe(true);
    expect(canTransition('REFUND_PENDING', 'REFUNDED', 'customer')).toBe(false);
  });

  it('treats delivered and refunded as terminal', () => {
    expect(isTerminal('DELIVERED')).toBe(true);
    expect(isTerminal('REFUNDED')).toBe(true);
    expect(nextStatuses('DELIVERED')).toEqual([]);
    expect(isTerminal('PREPARING')).toBe(false);
  });

  it('never allows leaving DELIVERED or REFUNDED', () => {
    const all: OrderStatus[] = [
      'CREATED', 'PAYMENT_PENDING', 'PAYMENT_FAILED', 'EXPIRED', 'CONFIRMED', 'RESTAURANT_ACCEPTED',
      'REJECTED', 'PREPARING', 'READY_FOR_PICKUP', 'PICKED_UP', 'OUT_FOR_DELIVERY', 'DELIVERED',
      'CANCELLATION_REQUESTED', 'CANCELLED', 'DELIVERY_FAILED', 'REFUND_PENDING', 'REFUNDED',
    ];
    for (const to of all) {
      for (const actor of ['system', 'customer', 'restaurant', 'delivery_partner', 'admin'] as const) {
        expect(canTransition('DELIVERED', to, actor, { refundableAmountPaise: 1 })).toBe(false);
        expect(canTransition('REFUNDED', to, actor, { refundableAmountPaise: 1 })).toBe(false);
      }
    }
  });

  it('assertTransition throws a typed error without side effects', () => {
    expect(() => assertTransition('CONFIRMED', 'DELIVERED', 'admin')).toThrowError(/CONFIRMED to DELIVERED/);
    try {
      assertTransition('CONFIRMED', 'DELIVERED', 'admin');
    } catch (e) {
      expect((e as { code: string }).code).toBe('INVALID_TRANSITION');
    }
  });
});
