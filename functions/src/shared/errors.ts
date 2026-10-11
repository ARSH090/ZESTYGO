export type ErrorCode =
  | 'UNAUTHENTICATED'
  | 'PERMISSION_DENIED'
  | 'VALIDATION_FAILED'
  | 'NOT_FOUND'
  | 'RESTAURANT_CLOSED'
  | 'ITEM_UNAVAILABLE'
  | 'PRICE_CHANGED'
  | 'MIN_ORDER_NOT_MET'
  | 'NOT_SERVICEABLE'
  | 'COUPON_INVALID'
  | 'QUOTE_EXPIRED'
  | 'INVALID_TRANSITION'
  | 'DUPLICATE_REQUEST_IN_PROGRESS'
  | 'PAYMENT_SIGNATURE_INVALID'
  | 'REFUND_EXCEEDS_CAPTURED'
  | 'RECENT_AUTH_REQUIRED'
  | 'RESOURCE_EXHAUSTED'
  | 'INTERNAL';

export type HttpsCode =
  | 'unauthenticated'
  | 'permission-denied'
  | 'invalid-argument'
  | 'not-found'
  | 'failed-precondition'
  | 'already-exists'
  | 'resource-exhausted'
  | 'internal';

/** Domain error. Messages are safe to show to clients; details must not contain secrets. */
export class AppError extends Error {
  constructor(
    public readonly code: ErrorCode,
    message: string,
    public readonly retryable = false,
    public readonly details?: Record<string, unknown>,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

const HTTPS_CODE: Record<ErrorCode, HttpsCode> = {
  UNAUTHENTICATED: 'unauthenticated',
  PERMISSION_DENIED: 'permission-denied',
  VALIDATION_FAILED: 'invalid-argument',
  NOT_FOUND: 'not-found',
  RESTAURANT_CLOSED: 'failed-precondition',
  ITEM_UNAVAILABLE: 'failed-precondition',
  PRICE_CHANGED: 'failed-precondition',
  MIN_ORDER_NOT_MET: 'failed-precondition',
  NOT_SERVICEABLE: 'failed-precondition',
  COUPON_INVALID: 'failed-precondition',
  QUOTE_EXPIRED: 'failed-precondition',
  INVALID_TRANSITION: 'failed-precondition',
  DUPLICATE_REQUEST_IN_PROGRESS: 'already-exists',
  PAYMENT_SIGNATURE_INVALID: 'permission-denied',
  REFUND_EXCEEDS_CAPTURED: 'failed-precondition',
  RECENT_AUTH_REQUIRED: 'permission-denied',
  RESOURCE_EXHAUSTED: 'resource-exhausted',
  INTERNAL: 'internal',
};

export function toHttpsCode(code: ErrorCode): HttpsCode {
  return HTTPS_CODE[code];
}
