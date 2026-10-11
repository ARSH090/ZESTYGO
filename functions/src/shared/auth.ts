import { AppError } from './errors';

export type Role =
  | 'customer'
  | 'restaurant_owner'
  | 'restaurant_manager'
  | 'delivery_partner'
  | 'support'
  | 'admin'
  | 'super_admin';

export interface AuthContext {
  uid: string;
  role: Role | 'none';
  restaurantId?: string;
  authTimeSeconds?: number;
}

/** Minimal shape of a callable request; keeps this module testable without Firebase. */
export interface RequestLike {
  auth?: {
    uid: string;
    token: Record<string, unknown>;
  } | null;
}

export function requireAuth(req: RequestLike): AuthContext {
  if (!req.auth) {
    throw new AppError('UNAUTHENTICATED', 'Sign in required');
  }
  const token = req.auth.token;
  return {
    uid: req.auth.uid,
    role: (typeof token.role === 'string' ? token.role : 'none') as Role | 'none',
    restaurantId: typeof token.restaurantId === 'string' ? token.restaurantId : undefined,
    authTimeSeconds: typeof token.auth_time === 'number' ? token.auth_time : undefined,
  };
}

export function requireRole(ctx: AuthContext, ...allowed: Role[]): void {
  if (ctx.role === 'none' || !allowed.includes(ctx.role)) {
    throw new AppError('PERMISSION_DENIED', 'You do not have access to this action');
  }
}

/** The caller must be a restaurant user for exactly this restaurant (or an admin). */
export function requireRestaurantAccess(ctx: AuthContext, restaurantId: string): void {
  const isAdmin = ctx.role === 'admin' || ctx.role === 'super_admin';
  const isRestaurantUser = ctx.role === 'restaurant_owner' || ctx.role === 'restaurant_manager';
  if (isAdmin) return;
  if (!isRestaurantUser || ctx.restaurantId !== restaurantId) {
    throw new AppError('PERMISSION_DENIED', 'You do not have access to this restaurant');
  }
}

/** Sensitive actions need a sign-in newer than maxAgeSeconds. */
export function requireRecentAuth(ctx: AuthContext, nowSeconds: number, maxAgeSeconds = 300): void {
  if (ctx.authTimeSeconds === undefined || nowSeconds - ctx.authTimeSeconds > maxAgeSeconds) {
    throw new AppError('RECENT_AUTH_REQUIRED', 'Please sign in again to continue');
  }
}
