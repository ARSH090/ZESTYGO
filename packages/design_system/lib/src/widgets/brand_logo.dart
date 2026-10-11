import 'package:flutter/material.dart';
import '../tokens.dart';

/// Vector-drawn ZestyGo brand logo matching Stitch Official Brand Logo (63e50ad2).
/// Displays the kinetic cloche & location pin emblem with optional typography.
class ZestyBrandLogo extends StatelessWidget {
  const ZestyBrandLogo({
    super.key,
    this.size = 64.0,
    this.showText = true,
    this.showTagline = true,
    this.isLight = false,
  });

  final double size;
  final bool showText;
  final bool showTagline;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final emblem = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ZestyLogoPainter(),
      ),
    );

    if (!showText) return emblem;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(width: size * 0.2),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: isLight ? ZestyColors.ink : ZestyColors.textLight,
                  fontFamily: 'sans-serif',
                ),
                children: const [
                  TextSpan(text: 'Zesty'),
                  TextSpan(
                    text: 'Go',
                    style: TextStyle(color: ZestyColors.primary),
                  ),
                ],
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: 2),
              Text(
                'GOURMET FOOD • LIGHTNING DELIVERY',
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isLight ? ZestyColors.inkMuted : ZestyColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ZestyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle Outer Glow
    final glowPaint = Paint()
      ..color = ZestyColors.primary.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, glowPaint);

    // 2. Dark Rounded Container Badge
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.28),
    );
    final badgePaint = Paint()..color = const Color(0xFF1C181B);
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;

    canvas.drawRRect(badgeRRect, badgePaint);
    canvas.drawRRect(badgeRRect, borderPaint);

    // 3. Cloche Dome (Saffron Gradient)
    final gradientShader = const LinearGradient(
      colors: [ZestyColors.primaryAmber, ZestyColors.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6));

    final clochePaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.fill;

    // Cloche Dome Arc Path
    final clochePath = Path();
    clochePath.moveTo(w * 0.28, h * 0.54);
    clochePath.quadraticBezierTo(
      w * 0.28,
      h * 0.32,
      w * 0.5,
      h * 0.32,
    );
    clochePath.quadraticBezierTo(
      w * 0.72,
      h * 0.32,
      w * 0.72,
      h * 0.54,
    );
    clochePath.close();
    canvas.drawPath(clochePath, clochePaint);

    // Cloche Top Bead
    final beadPaint = Paint()..color = const Color(0xFFFFF9F4);
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.045, beadPaint);

    // 4. Platter / Speed Base Ring
    final platterRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.55, w * 0.56, h * 0.055),
      Radius.circular(w * 0.03),
    );
    final platterPaint = Paint()..color = const Color(0xFFFFF9F4);
    canvas.drawRRect(platterRRect, platterPaint);

    // 5. Kinetic Location Pin Needle
    final pinPath = Path();
    pinPath.moveTo(w * 0.36, h * 0.63);
    pinPath.lineTo(w * 0.5, h * 0.82);
    pinPath.lineTo(w * 0.64, h * 0.63);
    pinPath.close();
    canvas.drawPath(pinPath, clochePaint);

    // Pin Eye Dot
    final eyePaint = Paint()..color = const Color(0xFF1C181B);
    canvas.drawCircle(Offset(w * 0.5, h * 0.68), w * 0.03, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
