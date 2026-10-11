import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'zestygo-rules-test',
    firestore: { rules: readFileSync(resolve(__dirname, '../../../firestore.rules'), 'utf8') },
  });
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/alice'), { displayName: 'Alice', role: 'customer', status: 'active' });
    await setDoc(doc(db, 'restaurants/r1'), { status: 'approved', name: 'Spice Route' });
    await setDoc(doc(db, 'restaurants/r2'), { status: 'draft', name: 'Not Live' });
    await setDoc(doc(db, 'orders/o1'), {
      customerId: 'alice',
      restaurantId: 'r1',
      deliveryPartnerId: 'p1',
      status: 'CONFIRMED',
    });
    await setDoc(doc(db, 'payments/pay1'), { orderId: 'o1', amountPaise: 51290 });
    await setDoc(doc(db, 'delivery_locations/o1'), { customerId: 'alice', active: true });
    await setDoc(doc(db, 'delivery_locations/o2'), { customerId: 'alice', active: false });
  });
});

const alice = () => env.authenticatedContext('alice', { role: 'customer' }).firestore();
const bob = () => env.authenticatedContext('bob', { role: 'customer' }).firestore();
const r1Owner = () =>
  env.authenticatedContext('owner1', { role: 'restaurant_owner', restaurantId: 'r1' }).firestore();
const r2Owner = () =>
  env.authenticatedContext('owner2', { role: 'restaurant_owner', restaurantId: 'r2' }).firestore();
const partner1 = () => env.authenticatedContext('p1', { role: 'delivery_partner' }).firestore();
const partner2 = () => env.authenticatedContext('p2', { role: 'delivery_partner' }).firestore();
const admin = () => env.authenticatedContext('adm', { role: 'admin' }).firestore();
const anon = () => env.unauthenticatedContext().firestore();

describe('orders', () => {
  it('lets the customer, restaurant and assigned partner read the order', async () => {
    await assertSucceeds(getDoc(doc(alice(), 'orders/o1')));
    await assertSucceeds(getDoc(doc(r1Owner(), 'orders/o1')));
    await assertSucceeds(getDoc(doc(partner1(), 'orders/o1')));
    await assertSucceeds(getDoc(doc(admin(), 'orders/o1')));
  });

  it('denies other customers, other restaurants, other partners and anonymous users', async () => {
    await assertFails(getDoc(doc(bob(), 'orders/o1')));
    await assertFails(getDoc(doc(r2Owner(), 'orders/o1')));
    await assertFails(getDoc(doc(partner2(), 'orders/o1')));
    await assertFails(getDoc(doc(anon(), 'orders/o1')));
  });

  it('never lets clients write orders, even their own', async () => {
    await assertFails(updateDoc(doc(alice(), 'orders/o1'), { status: 'DELIVERED' }));
    await assertFails(setDoc(doc(alice(), 'orders/o9'), { customerId: 'alice', status: 'CONFIRMED' }));
    await assertFails(updateDoc(doc(r1Owner(), 'orders/o1'), { status: 'PREPARING' }));
  });
});

describe('users', () => {
  it('lets a user edit display fields but not role or status', async () => {
    await assertSucceeds(updateDoc(doc(alice(), 'users/alice'), { displayName: 'Alice B' }));
    await assertFails(updateDoc(doc(alice(), 'users/alice'), { role: 'admin' }));
    await assertFails(updateDoc(doc(alice(), 'users/alice'), { status: 'suspended' }));
  });

  it('denies reading another user profile', async () => {
    await assertFails(getDoc(doc(bob(), 'users/alice')));
  });
});

describe('restaurants', () => {
  it('shows approved restaurants publicly and hides unapproved ones', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'restaurants/r1')));
    await assertFails(getDoc(doc(anon(), 'restaurants/r2')));
    await assertSucceeds(getDoc(doc(r2Owner(), 'restaurants/r2')));
  });

  it('denies client writes to restaurants', async () => {
    await assertFails(updateDoc(doc(r1Owner(), 'restaurants/r1'), { status: 'approved', name: 'X' }));
  });
});

describe('payments and live location', () => {
  it('limits payments to admins', async () => {
    await assertFails(getDoc(doc(alice(), 'payments/pay1')));
    await assertSucceeds(getDoc(doc(admin(), 'payments/pay1')));
  });

  it('shows live location to the customer only while active', async () => {
    await assertSucceeds(getDoc(doc(alice(), 'delivery_locations/o1')));
    await assertFails(getDoc(doc(alice(), 'delivery_locations/o2')));
    await assertFails(getDoc(doc(bob(), 'delivery_locations/o1')));
  });
});

describe('default deny', () => {
  it('denies unknown collections', async () => {
    await assertFails(getDoc(doc(admin(), 'secrets/x')));
    await assertFails(setDoc(doc(admin(), 'secrets/x'), { a: 1 }));
  });

  it('denies idempotency keys and quotes to everyone', async () => {
    await assertFails(getDoc(doc(admin(), 'idempotency_keys/a_b')));
    await assertFails(getDoc(doc(alice(), 'quotes/q1')));
  });
});
