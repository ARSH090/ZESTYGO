import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final isDelivered = !orderId.contains('live');

    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: Text('Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        children: [
          // 1. Order Status Header Card
          ZestyGlassCard(
            borderColor: isDelivered ? ZestyColors.secondary : ZestyColors.primaryAmber,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDelivered ? ZestyColors.secondary : ZestyColors.primary)
                        .withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDelivered ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                    color: isDelivered ? ZestyColors.secondary : ZestyColors.primaryAmber,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelivered ? 'Delivered on Oct 9, 8:42 PM' : 'Preparing at Kitchen',
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDelivered
                            ? 'Delivered to Home by Rajesh Kumar'
                            : 'ETA ~22 mins • Insulated delivery bag',
                        style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Kitchen Info Card
          ZestyGlassCard(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=200',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelivered
                            ? 'Artisan Woodfire Pizzeria'
                            : 'The Royal Biryani Darbar',
                        style: const TextStyle(
                          color: ZestyColors.textLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Indiranagar, Bengaluru',
                        style: TextStyle(color: ZestyColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.push(isDelivered ? '/restaurant/res_003' : '/restaurant/res_001');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: const BorderSide(color: ZestyColors.primaryAmber),
                  ),
                  child: const Text('Menu', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Items Summary
          ZestyGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items in Order',
                  style: TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (isDelivered) ...[
                  _itemRow('1x Neapolitan Margherita D.O.P', '₹429.00', true),
                  _itemRow('1x Cheesy Garlic Sourdough Bread', '₹219.00', true),
                ] else ...[
                  _itemRow('1x Dum Gosht Hyderabadi Biryani', '₹499.00', false),
                  _itemRow('1x Zafrani Shahi Phirni', '₹149.00', true),
                ],
                const Divider(color: ZestyColors.glassBorder, height: 24),
                _summaryRow('Item Subtotal', isDelivered ? '₹648.00' : '₹648.00'),
                _summaryRow('Delivery Partner Fee', '₹30.00'),
                _summaryRow('Platform Fee', '₹5.00'),
                _summaryRow('GST (5%)', '₹32.40'),
                _summaryRow('Coupon Discount (ZESTYFEAST)', '-₹100.00', isGreen: true),
                const Divider(color: ZestyColors.glassBorder, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total Paid',
                      style: TextStyle(color: ZestyColors.textLight, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      isDelivered ? '₹615.40' : '₹615.40',
                      style: const TextStyle(
                        color: ZestyColors.textLight,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Payment settled via Razorpay UPI (Instant verification)',
                  style: TextStyle(color: ZestyColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Delivery Address Card
          const ZestyGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    color: ZestyColors.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Flat 402, Sunshine Heights, 12th Main, Indiranagar, Bengaluru - 560038',
                  style: TextStyle(color: ZestyColors.textMuted, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Actions
          if (!isDelivered)
            FilledButton.icon(
              onPressed: () => context.push('/tracking/$orderId'),
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Track Live Delivery Stream'),
            )
          else ...[
            FilledButton.icon(
              onPressed: () => context.push('/restaurant/res_003'),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Re-order These Items'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('GST Invoice downloaded to your device!')),
                );
              },
              icon: const Icon(Icons.receipt_long_rounded),
              label: const Text('Download Official Tax Invoice (PDF)'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(String name, String price, bool isVeg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            color: isVeg ? Colors.greenAccent : Colors.redAccent,
            size: 10,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: ZestyColors.textLight, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            price,
            style: const TextStyle(color: ZestyColors.textLight, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: isGreen ? ZestyColors.secondary : ZestyColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
