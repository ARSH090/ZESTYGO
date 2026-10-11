import { createHmac, timingSafeEqual } from 'node:crypto';

function safeEqual(a: string, b: string): boolean {
  const ba = Buffer.from(a, 'utf8');
  const bb = Buffer.from(b, 'utf8');
  return ba.length === bb.length && timingSafeEqual(ba, bb);
}

/** Checkout signature: HMAC-SHA256 of "razorpayOrderId|razorpayPaymentId" with the key secret. */
export function verifyCheckoutSignature(args: {
  razorpayOrderId: string;
  razorpayPaymentId: string;
  signature: string;
  keySecret: string;
}): boolean {
  const expected = createHmac('sha256', args.keySecret)
    .update(`${args.razorpayOrderId}|${args.razorpayPaymentId}`)
    .digest('hex');
  return safeEqual(expected, args.signature);
}

/** Webhook signature: HMAC-SHA256 of the RAW request body with the webhook secret. */
export function verifyWebhookSignature(args: {
  rawBody: Buffer | string;
  signature: string;
  webhookSecret: string;
}): boolean {
  const expected = createHmac('sha256', args.webhookSecret).update(args.rawBody).digest('hex');
  return safeEqual(expected, args.signature);
}
