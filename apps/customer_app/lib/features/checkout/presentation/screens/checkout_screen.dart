import 'package:common_models/common_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';

/// Screen for order review, coupon application, fee breakdown, and payment invocation.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _couponApplied = true;
  bool _isProcessing = false;
  final String _couponCode = 'ZESTYFEAST';

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: ZestyColors.darkCanvas,
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: ZestyColors.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  color: ZestyColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Explore Kitchens'),
              ),
            ],
          ),
        ),
      );
    }

    // Server-side calculation replication (paise precision)
    final itemTotalPaise = cart.subtotal.paise;
    final discountPaise = _couponApplied ? 10000 : 0; // ₹100 discount
    const deliveryFeePaise = 3000; // ₹30 delivery fee
    const platformFeePaise = 500; // ₹5 platform fee
    final gstPaise = (itemTotalPaise * 0.05).round(); // 5% restaurant GST

    final grandTotalPaise = (itemTotalPaise + deliveryFeePaise + platformFeePaise + gstPaise) -
        discountPaise;
    final grandTotal = Money(grandTotalPaise > 0 ? grandTotalPaise : 0);

    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: Text(cart.restaurantName ?? 'Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Card
            ZestyGlassCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: ZestyColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivering to Home',
                          style: TextStyle(
                            color: ZestyColors.textLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Flat 402, Sunshine Heights, 12th Main, Indiranagar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ZestyColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/addresses'),
                    child: const Text(
                      'CHANGE',
                      style: TextStyle(
                        color: ZestyColors.primaryAmber,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ZestySpacing.md),

            // 2. Order Items List
            ZestyGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cart.items.map((cartItem) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          if (cartItem.item.isVeg)
                            const ZestyVegBadge(size: 13)
                          else
                            const ZestyNonVegBadge(size: 13),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cartItem.item.name,
                              style: const TextStyle(
                                color: ZestyColors.textLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Stepper
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => ref
                                    .read(cartProvider.notifier)
                                    .removeItem(cartItem.item.id),
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: 18,
                                  color: ZestyColors.primaryAmber,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    color: ZestyColors.textLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Re-add to increment
                                  final r = Restaurant(
                                    id: cart.restaurantId!,
                                    name: cart.restaurantName!,
                                    imageUrl: '',
                                    cuisines: [],
                                    rating: 4.8,
                                    reviewCount: 100,
                                    deliveryTimeMinutes: 20,
                                    distanceKm: 2.0,
                                    priceForTwo: const Money(40000),
                                  );
                                  ref.read(cartProvider.notifier).addItem(
                                        restaurant: r,
                                        item: cartItem.item,
                                      );
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 18,
                                  color: ZestyColors.primaryAmber,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Text(
                            cartItem.totalPrice.format(),
                            style: const TextStyle(
                              color: ZestyColors.textLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: ZestySpacing.md),

            // 3. Coupon Applied Banner
            ZestyGlassCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: ZestyColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _couponApplied
                              ? 'Coupon "$_couponCode" Applied!'
                              : 'Have a coupon code?',
                          style: const TextStyle(
                            color: ZestyColors.textLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _couponApplied
                              ? 'You saved ₹100 with ZestyGo'
                              : 'Apply coupon to save extra',
                          style: TextStyle(
                            color: _couponApplied
                                ? ZestyColors.secondary
                                : ZestyColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _couponApplied = !_couponApplied;
                      });
                    },
                    child: Text(
                      _couponApplied ? 'REMOVE' : 'APPLY',
                      style: const TextStyle(
                        color: ZestyColors.primaryAmber,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ZestySpacing.md),

            // 4. Bill Details Breakdown
            ZestyGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bill Details',
                    style: TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _billRow('Item Total', cart.subtotal.format()),
                  _billRow(
                    'Delivery Fee (2.1 km)',
                    const Money(deliveryFeePaise).format(),
                  ),
                  _billRow(
                    'Platform Fee',
                    const Money(platformFeePaise).format(),
                  ),
                  _billRow(
                    'GST and Restaurant Charges (5%)',
                    Money(gstPaise).format(),
                  ),
                  if (_couponApplied)
                    _billRow(
                      'Coupon Discount',
                      '-${Money(discountPaise).format()}',
                      isDiscount: true,
                    ),
                  const Divider(color: ZestyColors.glassBorder, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'To Pay',
                        style: TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        grandTotal.format(),
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: ZestyColors.darkCanvas,
        padding: const EdgeInsets.fromLTRB(
          ZestySpacing.md,
          ZestySpacing.sm,
          ZestySpacing.md,
          ZestySpacing.lg,
        ),
        child: FilledButton(
          onPressed: _isProcessing
              ? null
              : () async {
                  setState(() => _isProcessing = true);
                  // Simulate Razorpay payment confirmation
                  await Future<void>.delayed(const Duration(milliseconds: 1200));
                  if (!context.mounted) return;
                  ref.read(cartProvider.notifier).clear();
                  context.go(
                    '/tracking/ord_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}',
                  );
                },
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Pay ${grandTotal.format()} with Razorpay'),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ZestyColors.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? ZestyColors.secondary : ZestyColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
