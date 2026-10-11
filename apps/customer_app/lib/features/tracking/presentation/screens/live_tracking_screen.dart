import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen for real-time live map tracking, rider assignment, and order pipeline.
class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }


  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: Text('Order #${widget.orderId.substring(0, 8)}'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        child: Column(
          children: [
            // 1. Live ETA Hero Card
            ZestyGlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF281A14), Color(0xFF161215)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ZestyColors.primary.withValues(
                            alpha: 0.15 + (_pulseController.value * 0.15),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: ZestyColors.primary,
                          size: 32,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚡ Arriving in 22 mins',
                          style: TextStyle(
                            color: ZestyColors.textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kitchen is packing your royal feast',
                          style: TextStyle(
                            color: ZestyColors.primaryAmber,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ZestySpacing.md),

            // 2. Simulated Live Tracking Map Visualizer
            _buildLiveMapVisualizer(),

            const SizedBox(height: ZestySpacing.md),

            // 3. Multi-Step State Machine Pipeline
            ZestyGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Status Pipeline',
                    style: TextStyle(
                      color: ZestyColors.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusStep(
                    title: 'Order Confirmed',
                    subtitle: 'Payment verified via Razorpay',
                    isCompleted: true,
                    isActive: false,
                  ),
                  _buildStatusStep(
                    title: 'Kitchen Preparing Your Meal',
                    subtitle: 'Dum mutton is resting under hot coals',
                    isCompleted: true,
                    isActive: true,
                  ),
                  _buildStatusStep(
                    title: 'Rider Picked Up & Out For Delivery',
                    subtitle: 'Rajesh K. will carry your insulated bag',
                    isCompleted: false,
                    isActive: false,
                  ),
                  _buildStatusStep(
                    title: 'Delivered to Door',
                    subtitle: 'Enjoy your hot gourmet meal',
                    isCompleted: false,
                    isActive: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: ZestySpacing.md),

            // 4. Delivery Partner Contact Card
            ZestyGlassCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: ZestyColors.darkCard,
                    child: Icon(
                      Icons.person_pin_rounded,
                      color: ZestyColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rajesh Kumar',
                          style: TextStyle(
                            color: ZestyColors.textLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ather 450X • KA 05 EV 1234',
                          style: TextStyle(
                            color: ZestyColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '★ 4.9 • Vaccinated & Sanitized',
                          style: TextStyle(
                            color: ZestyColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: ZestyColors.secondary.withValues(alpha: 0.2),
                    child: IconButton(
                      icon: const Icon(
                        Icons.call_rounded,
                        color: ZestyColors.secondary,
                        size: 20,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling Rider Rajesh Kumar: +91 98450 12345 (Masked Number)')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Help & Details Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/support'),
                    icon: const Icon(Icons.support_agent_rounded, size: 16),
                    label: const Text('Order Support', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: ZestyColors.glassBorder)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/orders/${widget.orderId}'),
                    icon: const Icon(Icons.receipt_rounded, size: 16),
                    label: const Text('View Bill Receipt', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: ZestyColors.glassBorder)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMapVisualizer() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF19161B),
        borderRadius: BorderRadius.circular(ZestyRadius.card),
        border: Border.all(color: ZestyColors.glassBorder),
      ),
      child: Stack(
        children: [
          // Simulated Dark Map Grid Lines
          CustomPaint(
            size: const Size(double.infinity, 220),
            painter: _MapGridPainter(),
          ),

          // Restaurant Pin
          const Positioned(
            top: 40,
            left: 48,
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  color: ZestyColors.primaryAmber,
                  size: 26,
                ),
                Text(
                  'Kitchen',
                  style: TextStyle(
                    color: ZestyColors.primaryAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Customer Pin
          const Positioned(
            bottom: 40,
            right: 48,
            child: Column(
              children: [
                Icon(
                  Icons.home_rounded,
                  color: ZestyColors.secondary,
                  size: 26,
                ),
                Text(
                  'Your Home',
                  style: TextStyle(
                    color: ZestyColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Moving Rider Bike Pin (Center)
          Positioned(
            top: 90,
            left: 170,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ZestyColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ZestyColors.primary.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.two_wheeler_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Rajesh (2.1 km)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    Color iconColor;
    if (isActive) {
      iconColor = ZestyColors.primary;
    } else if (isCompleted) {
      iconColor = ZestyColors.secondary;
    } else {
      iconColor = ZestyColors.textMuted.withValues(alpha: 0.4);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted
                    ? ZestyColors.secondary
                    : (isActive ? ZestyColors.primary : Colors.transparent),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : (isActive
                      ? const Center(
                          child: SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isCompleted
                    ? ZestyColors.secondary
                    : ZestyColors.glassBorder,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted || isActive
                      ? ZestyColors.textLight
                      : ZestyColors.textMuted,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ZestyColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Polyline route
    final routePaint = Paint()
      ..color = ZestyColors.primaryAmber.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(60, 60);
    path.quadraticBezierTo(130, 70, 180, 110);
    path.quadraticBezierTo(240, 150, size.width - 60, size.height - 60);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
