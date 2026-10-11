import { initializeApp } from 'firebase-admin/app';
import { setGlobalOptions } from 'firebase-functions/v2';
import { onCall, onRequest, HttpsError } from 'firebase-functions/v2/https';
import { requireAuth } from './shared/auth';
import { calculateQuote, QuoteRequest } from './pricing/quote';
import { toHttpsCode, AppError } from './shared/errors';

initializeApp();

setGlobalOptions({ region: 'asia-south1', maxInstances: 20 });

/** Liveness probe. */
export const health = onRequest((_req, res) => {
  res.status(200).json({ ok: true, service: 'zestygo-functions' });
});

/** Callable: checkoutQuote. Server-authoritative price breakdown. */
export const checkoutQuote = onCall<QuoteRequest>((request) => {
  try {
    requireAuth(request);
    const quote = calculateQuote(request.data);
    return { ok: true, data: quote, requestId: `req_${Date.now().toString(36)}` };
  } catch (error) {
    if (error instanceof AppError) {
      throw new HttpsError(toHttpsCode(error.code), error.message, error.details);
    }
    throw new HttpsError('internal', 'Internal error occurred during quote generation');
  }
});

/** Callable: serviceabilityCheck. Validates location within delivery radius. */
export const serviceabilityCheck = onCall<{ lat: number; lng: number }>((request) => {
  try {
    requireAuth(request);
    const { lat, lng } = request.data;
    if (typeof lat !== 'number' || typeof lng !== 'number') {
      throw new AppError('VALIDATION_FAILED', 'Invalid coordinates');
    }
    // Bengaluru metro delivery bounding box check
    const isServiceable = lat >= 12.8 && lat <= 13.2 && lng >= 77.4 && lng <= 77.8;
    return {
      ok: true,
      data: {
        isServiceable,
        estimatedDeliveryMinutes: 25,
        serviceArea: 'Bengaluru Core',
      },
      requestId: `req_${Date.now().toString(36)}`,
    };
  } catch (error) {
    if (error instanceof AppError) {
      throw new HttpsError(toHttpsCode(error.code), error.message, error.details);
    }
    throw new HttpsError('internal', 'Serviceability check failed');
  }
});

export * from './orders/stateMachine';
export * from './pricing/quote';
