import { randomUUID } from 'crypto';
import { AppError } from '../shared/errors';

export interface QuoteItemRequest {
  itemId: string;
  name: string;
  pricePaise: number;
  quantity: number;
}

export interface QuoteRequest {
  restaurantId: string;
  items: QuoteItemRequest[];
  couponCode?: string;
  deliveryDistanceKm?: number;
}

export interface QuoteBreakdown {
  quoteId: string;
  restaurantId: string;
  itemTotalPaise: number;
  gstPaise: number;
  deliveryFeePaise: number;
  platformFeePaise: number;
  discountPaise: number;
  grandTotalPaise: number;
  expiresAt: string;
}

/** Calculates server-authoritative pricing quote with 5% GST and platform fee. */
export function calculateQuote(req: QuoteRequest): QuoteBreakdown {
  if (!req.items || req.items.length === 0) {
    throw new AppError('VALIDATION_FAILED', 'Cart must contain at least one item');
  }

  let itemTotalPaise = 0;
  for (const item of req.items) {
    if (item.pricePaise <= 0 || item.quantity <= 0) {
      throw new AppError('VALIDATION_FAILED', 'Invalid item price or quantity');
    }
    itemTotalPaise += item.pricePaise * item.quantity;
  }

  // GST 5% on restaurant items
  const gstPaise = Math.round(itemTotalPaise * 0.05);

  // Platform fee (₹5.00)
  const platformFeePaise = 500;

  // Delivery fee: ₹30.00 base up to 3 km, ₹10 per km beyond
  const distance = req.deliveryDistanceKm ?? 2.0;
  let deliveryFeePaise = 3000;
  if (distance > 3.0) {
    deliveryFeePaise += Math.round((distance - 3.0) * 1000);
  }

  // Coupon evaluation
  let discountPaise = 0;
  if (req.couponCode && req.couponCode.toUpperCase() === 'ZESTYFEAST') {
    discountPaise = Math.min(itemTotalPaise, 10000); // Flat ₹100 off
  }

  const grandTotalPaise = Math.max(
    0,
    itemTotalPaise + gstPaise + deliveryFeePaise + platformFeePaise - discountPaise,
  );

  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

  return {
    quoteId: `q_${randomUUID()}`,
    restaurantId: req.restaurantId,
    itemTotalPaise,
    gstPaise,
    deliveryFeePaise,
    platformFeePaise,
    discountPaise,
    grandTotalPaise,
    expiresAt,
  };
}
