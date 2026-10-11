import { describe, expect, it } from 'vitest';
import { calculateQuote } from '../../src/pricing/quote';

describe('calculateQuote', () => {
  it('calculates item total, GST, platform fee, and delivery fee correctly', () => {
    const quote = calculateQuote({
      restaurantId: 'res_001',
      items: [
        { itemId: 'i_1', name: 'Biryani', pricePaise: 40000, quantity: 1 },
      ],
      deliveryDistanceKm: 2.0,
    });

    expect(quote.itemTotalPaise).toBe(40000); // ₹400
    expect(quote.gstPaise).toBe(2000); // ₹20 (5%)
    expect(quote.platformFeePaise).toBe(500); // ₹5
    expect(quote.deliveryFeePaise).toBe(3000); // ₹30
    expect(quote.discountPaise).toBe(0);
    expect(quote.grandTotalPaise).toBe(45500); // ₹455
    expect(quote.quoteId).toMatch(/^q_/);
  });

  it('applies ZESTYFEAST coupon code discount', () => {
    const quote = calculateQuote({
      restaurantId: 'res_001',
      items: [
        { itemId: 'i_1', name: 'Biryani', pricePaise: 40000, quantity: 1 },
      ],
      couponCode: 'ZESTYFEAST',
    });

    expect(quote.discountPaise).toBe(10000); // ₹100
    expect(quote.grandTotalPaise).toBe(35500); // ₹355
  });

  it('throws on empty items array', () => {
    expect(() =>
      calculateQuote({
        restaurantId: 'res_001',
        items: [],
      }),
    ).toThrowError(/Cart must contain at least one item/);
  });
});
