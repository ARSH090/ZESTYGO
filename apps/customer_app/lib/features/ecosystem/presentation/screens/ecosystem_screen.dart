import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EcosystemScreen extends StatefulWidget {
  const EcosystemScreen({super.key});

  @override
  State<EcosystemScreen> createState() => _EcosystemScreenState();
}

class _EcosystemScreenState extends State<EcosystemScreen> {
  int _activePortalIndex = 0; // 0: Restaurant Portal, 1: Delivery App, 2: Admin Console

  // Restaurant Portal Demo State
  bool _biryaniAvailable = true;
  bool _orderAccepted = false;
  final int _prepTimeMinutes = 20;

  // Delivery Fleet Demo State
  bool _dutyOnline = true;
  bool _deliveryAccepted = false;

  // Admin Ops State
  bool _refundIssued = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: const Text('ZestyGo 4-in-1 Ecosystem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Portal Switcher Tabs
          Container(
            color: ZestyColors.darkCard,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _portalTab(0, Icons.storefront_rounded, 'Restaurant'),
                _portalTab(1, Icons.two_wheeler_rounded, 'Fleet App'),
                _portalTab(2, Icons.admin_panel_settings_rounded, 'Admin Console'),
              ],
            ),
          ),

          // Portal Content
          Expanded(
            child: IndexedStack(
              index: _activePortalIndex,
              children: [
                _buildRestaurantPortal(),
                _buildDeliveryApp(),
                _buildAdminConsole(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _portalTab(int index, IconData icon, String label) {
    final active = _activePortalIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activePortalIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? ZestyColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : ZestyColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : ZestyColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Restaurant Partner Portal
  Widget _buildRestaurantPortal() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(ZestySpacing.md),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: ZestyColors.primary,
              child: Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Royal Biryani Darbar — Partner Dashboard',
                    style: TextStyle(color: ZestyColors.textLight, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  Text('Indiranagar Outlet • KDS Kitchen Display v2', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ZestyColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('● ACCEPTING ORDERS', style: TextStyle(color: ZestyColors.secondary, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Live Incoming Order Card
        ZestyGlassCard(
          borderColor: _orderAccepted ? ZestyColors.secondary : ZestyColors.primaryAmber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('NEW ORDER #ord_8f2c', style: TextStyle(color: ZestyColors.primaryAmber, fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(_orderAccepted ? 'KITCHEN PREPARING' : 'RINGING LOUD (Audio Alert)', style: const TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('1x Dum Gosht Hyderabadi Biryani (Boneless)', style: TextStyle(color: ZestyColors.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
              const Text('1x Zafrani Shahi Phirni (Clay Matka)', style: TextStyle(color: ZestyColors.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Customer: Aarav S. • Paid via Razorpay ₹648', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
              const SizedBox(height: 14),
              if (!_orderAccepted)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() => _orderAccepted = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order #ord_8f2c Accepted! Kitchen ticket printed.')),
                          );
                        },
                        child: Text('Accept Order ($_prepTimeMinutes mins prep)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order Rejected: Kitchen Capacity Full')),
                        );
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                      child: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: ZestyColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: ZestyColors.secondary, size: 16),
                      SizedBox(width: 8),
                      Text('Order sent to Dum Stove station. Rider Rajesh K. assigned.', style: TextStyle(color: ZestyColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 86 Items / Availability Toggle
        const Text('Quick Menu Item Availability (Item 86-ing)', style: TextStyle(color: ZestyColors.textLight, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ZestyGlassCard(
          child: Column(
            children: [
              SwitchListTile(
                value: _biryaniAvailable,
                activeThumbColor: ZestyColors.primary,
                title: const Text('Dum Gosht Hyderabadi Biryani', style: TextStyle(color: ZestyColors.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text(_biryaniAvailable ? 'In Stock (Live on Customer App)' : '86-ed (Marked Sold Out)', style: const TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                onChanged: (val) {
                  setState(() => _biryaniAvailable = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? 'Biryani is now available online' : 'Biryani marked OUT OF STOCK')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Delivery Partner Mobile App
  Widget _buildDeliveryApp() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(ZestySpacing.md),
      children: [
        // Duty Status Header
        ZestyGlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_dutyOnline ? ZestyColors.secondary : Colors.grey).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.two_wheeler_rounded, color: _dutyOnline ? ZestyColors.secondary : Colors.grey, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rajesh Kumar (Fleet ID #FLT_092)', style: TextStyle(color: ZestyColors.textLight, fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(_dutyOnline ? 'Online • Geohash: tdre0u (Indiranagar)' : 'Offline (No orders)', style: const TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: _dutyOnline,
                activeThumbColor: ZestyColors.secondary,
                onChanged: (val) => setState(() => _dutyOnline = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Earnings Summary
        const Row(
          children: [
            Expanded(
              child: ZestyGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Payout', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('₹1,420.00', style: TextStyle(color: ZestyColors.textLight, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text('11 trips completed', style: TextStyle(color: ZestyColors.secondary, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ZestyGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance Pay', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('₹38.50 / km', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text('+ ₹20 surge active', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Live Order Broadcast Offer
        const Text('Trip Broadcast Offer', style: TextStyle(color: ZestyColors.textLight, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ZestyGlassCard(
          borderColor: ZestyColors.primaryAmber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TRIP OFFER • ₹68.00 PAYOUT', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 13, fontWeight: FontWeight.w900)),
                  Text('Pickup 0.8 km away', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.storefront_rounded, color: ZestyColors.primaryAmber, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('Pickup: The Royal Biryani Darbar (Indiranagar)', style: TextStyle(color: ZestyColors.textLight, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.home_rounded, color: ZestyColors.secondary, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('Drop: Flat 402, Sunshine Heights (1.8 km)', style: TextStyle(color: ZestyColors.textLight, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 14),
              if (!_deliveryAccepted)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() => _deliveryAccepted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delivery Assigned! Turn-by-turn navigation launched.')),
                      );
                    },
                    child: const Text('Accept Delivery Offer (25s left)'),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: ZestyColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.navigation_rounded, color: ZestyColors.secondary, size: 16),
                      SizedBox(width: 8),
                      Text('En route to restaurant. Live GPS telemetry streaming (10s delta).', style: TextStyle(color: ZestyColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Admin & Support Console
  Widget _buildAdminConsole() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(ZestySpacing.md),
      children: [
        const Text('ZestyGo Ops & Cloud Console', style: TextStyle(color: ZestyColors.textLight, fontSize: 16, fontWeight: FontWeight.w800)),
        const Text('Firebase Functions v2 • Cloud Firestore Server Authority', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
        const SizedBox(height: 14),

        // System Health
        const Row(
          children: [
            Expanded(
              child: ZestyGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Cloud Tasks', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('42 / 42 Healthy', style: TextStyle(color: ZestyColors.secondary, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('0 errors in last 1h', style: TextStyle(color: ZestyColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ZestyGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Razorpay Webhooks', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('100% Verified', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('Idempotency keys active', style: TextStyle(color: ZestyColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Dispute Resolution & Instant Refund Trigger
        const Text('Order Escalation & Idempotent Refund', style: TextStyle(color: ZestyColors.textLight, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ZestyGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dispute #DSP_8102', style: TextStyle(color: ZestyColors.textLight, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Customer: Aarav Sharma', style: TextStyle(color: ZestyColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Claim: Soup container leaked during transit on Order #ord_8f2c', style: TextStyle(color: ZestyColors.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              const Text('Calculated Partial Refund: ₹150.00 (Item + GST)', style: TextStyle(color: ZestyColors.primaryAmber, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              if (!_refundIssued)
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _refundIssued = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Instant Razorpay Refund of ₹150 triggered via Cloud Functions!')),
                    );
                  },
                  icon: const Icon(Icons.currency_rupee_rounded, size: 16),
                  label: const Text('Trigger Instant Server Refund'),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: ZestyColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: ZestyColors.secondary, size: 16),
                      SizedBox(width: 8),
                      Text('Refund settled! RZP_RFND_82910 credited to customer wallet.', style: TextStyle(color: ZestyColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
