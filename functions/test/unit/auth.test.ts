import { describe, expect, it } from 'vitest';
import { requireAuth, requireRecentAuth, requireRestaurantAccess, requireRole } from '../../src/shared/auth';

const req = (uid: string, token: Record<string, unknown> = {}) => ({ auth: { uid, token } });

describe('auth guards', () => {
  it('rejects unauthenticated callers', () => {
    expect(() => requireAuth({ auth: null })).toThrowError(/Sign in/);
  });

  it('reads role and restaurant claims from the token only', () => {
    const ctx = requireAuth(req('u1', { role: 'restaurant_owner', restaurantId: 'r1' }));
    expect(ctx).toMatchObject({ uid: 'u1', role: 'restaurant_owner', restaurantId: 'r1' });
  });

  it('treats a missing or non-string role as none and denies role checks', () => {
    const ctx = requireAuth(req('u1', { role: 5 }));
    expect(ctx.role).toBe('none');
    expect(() => requireRole(ctx, 'customer')).toThrowError(/access/);
  });

  it('allows only listed roles', () => {
    const admin = requireAuth(req('a', { role: 'admin' }));
    expect(() => requireRole(admin, 'admin', 'super_admin')).not.toThrow();
    expect(() => requireRole(admin, 'super_admin')).toThrow();
  });

  it('isolates restaurants', () => {
    const owner = requireAuth(req('o', { role: 'restaurant_owner', restaurantId: 'r1' }));
    expect(() => requireRestaurantAccess(owner, 'r1')).not.toThrow();
    expect(() => requireRestaurantAccess(owner, 'r2')).toThrow();
    const customer = requireAuth(req('c', { role: 'customer', restaurantId: 'r1' }));
    expect(() => requireRestaurantAccess(customer, 'r1')).toThrow();
    const admin = requireAuth(req('a', { role: 'admin' }));
    expect(() => requireRestaurantAccess(admin, 'r2')).not.toThrow();
  });

  it('requires a recent sign-in for sensitive actions', () => {
    const now = 1_000_000;
    const fresh = requireAuth(req('a', { role: 'admin', auth_time: now - 60 }));
    const old = requireAuth(req('a', { role: 'admin', auth_time: now - 3600 }));
    const missing = requireAuth(req('a', { role: 'admin' }));
    expect(() => requireRecentAuth(fresh, now)).not.toThrow();
    expect(() => requireRecentAuth(old, now)).toThrowError(/sign in again/i);
    expect(() => requireRecentAuth(missing, now)).toThrow();
  });
});
