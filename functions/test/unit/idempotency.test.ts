import { describe, expect, it } from 'vitest';
import { hashRequest, stableStringify } from '../../src/shared/idempotency';

describe('idempotency hashing', () => {
  it('is insensitive to key order', () => {
    expect(hashRequest({ a: 1, b: { x: 1, y: 2 } })).toBe(hashRequest({ b: { y: 2, x: 1 }, a: 1 }));
  });

  it('differs when values differ', () => {
    expect(hashRequest({ quoteId: 'q1' })).not.toBe(hashRequest({ quoteId: 'q2' }));
  });

  it('keeps array order significant', () => {
    expect(stableStringify([1, 2])).not.toBe(stableStringify([2, 1]));
  });
});
