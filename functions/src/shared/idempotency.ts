import { createHash } from 'node:crypto';
import { Firestore, Timestamp } from 'firebase-admin/firestore';
import { AppError } from './errors';

/** Deterministic JSON with sorted keys so equal payloads hash equally. */
export function stableStringify(value: unknown): string {
  if (value === null || typeof value !== 'object') return JSON.stringify(value) ?? 'null';
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(',')}]`;
  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${stableStringify(obj[k])}`).join(',')}}`;
}

export function hashRequest(payload: unknown): string {
  return createHash('sha256').update(stableStringify(payload)).digest('hex');
}

export interface IdempotencyOptions {
  uid: string;
  key: string;
  payload: unknown;
  ttlMs?: number;
  /** An in_progress record older than this is treated as a crashed attempt and may be resumed. */
  staleMs?: number;
}

type Decision<T> = { kind: 'run' } | { kind: 'replay'; response: T };

/**
 * Runs `work` at most once per (uid, key). Replays return the stored response.
 * `work` runs OUTSIDE the transaction, so it may call external services,
 * but it must itself be safe to resume after a crash (use provider idempotency keys).
 */
export async function runIdempotent<T>(
  db: Firestore,
  opts: IdempotencyOptions,
  work: () => Promise<T>,
): Promise<T> {
  const ttlMs = opts.ttlMs ?? 24 * 60 * 60 * 1000;
  const staleMs = opts.staleMs ?? 2 * 60 * 1000;
  const ref = db.collection('idempotency_keys').doc(`${opts.uid}_${opts.key}`);
  const requestHash = hashRequest(opts.payload);

  const decision = await db.runTransaction<Decision<T>>(async (tx) => {
    const snap = await tx.get(ref);
    const now = Date.now();
    const fresh = {
      uid: opts.uid,
      key: opts.key,
      requestHash,
      status: 'in_progress',
      startedAt: Timestamp.fromMillis(now),
      expiresAt: Timestamp.fromMillis(now + ttlMs),
    };
    if (!snap.exists) {
      tx.set(ref, fresh);
      return { kind: 'run' };
    }
    const data = snap.data() as {
      requestHash: string;
      status: 'in_progress' | 'completed' | 'failed';
      response?: T;
      startedAt: Timestamp;
    };
    if (data.requestHash !== requestHash) {
      throw new AppError('VALIDATION_FAILED', 'Idempotency key was reused with a different request');
    }
    if (data.status === 'completed') {
      return { kind: 'replay', response: data.response as T };
    }
    const stale = now - data.startedAt.toMillis() > staleMs;
    if (data.status === 'failed' || stale) {
      tx.set(ref, fresh);
      return { kind: 'run' };
    }
    throw new AppError('DUPLICATE_REQUEST_IN_PROGRESS', 'This request is already being processed', true);
  });

  if (decision.kind === 'replay') return decision.response;

  try {
    const response = await work();
    await ref.update({ status: 'completed', response });
    return response;
  } catch (err) {
    await ref.update({ status: 'failed' });
    throw err;
  }
}
