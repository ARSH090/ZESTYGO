import { createHmac } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { verifyCheckoutSignature, verifyWebhookSignature } from '../../src/payments/razorpaySignature';

const sign = (data: string | Buffer, secret: string) =>
  createHmac('sha256', secret).update(data).digest('hex');

describe('checkout signature', () => {
  const base = { razorpayOrderId: 'order_ABC', razorpayPaymentId: 'pay_XYZ', keySecret: 'test_secret' };

  it('accepts a correct signature', () => {
    const signature = sign('order_ABC|pay_XYZ', 'test_secret');
    expect(verifyCheckoutSignature({ ...base, signature })).toBe(true);
  });

  it('rejects wrong secret, wrong payment id, and malformed signatures', () => {
    expect(verifyCheckoutSignature({ ...base, signature: sign('order_ABC|pay_XYZ', 'other') })).toBe(false);
    expect(verifyCheckoutSignature({ ...base, signature: sign('order_ABC|pay_OTHER', 'test_secret') })).toBe(false);
    expect(verifyCheckoutSignature({ ...base, signature: 'abc' })).toBe(false);
    expect(verifyCheckoutSignature({ ...base, signature: '' })).toBe(false);
  });
});

describe('webhook signature', () => {
  const body = JSON.stringify({ event: 'payment.captured', payload: { payment: { entity: { id: 'pay_XYZ' } } } });

  it('verifies against the exact raw body', () => {
    const signature = sign(body, 'whsec');
    expect(verifyWebhookSignature({ rawBody: body, signature, webhookSecret: 'whsec' })).toBe(true);
    expect(verifyWebhookSignature({ rawBody: Buffer.from(body), signature, webhookSecret: 'whsec' })).toBe(true);
  });

  it('rejects a re-serialized or tampered body', () => {
    const signature = sign(body, 'whsec');
    const reserialized = JSON.stringify(JSON.parse(body), null, 2);
    expect(verifyWebhookSignature({ rawBody: reserialized, signature, webhookSecret: 'whsec' })).toBe(false);
    expect(verifyWebhookSignature({ rawBody: body + ' ', signature, webhookSecret: 'whsec' })).toBe(false);
    expect(verifyWebhookSignature({ rawBody: body, signature, webhookSecret: 'wrong' })).toBe(false);
  });
});
