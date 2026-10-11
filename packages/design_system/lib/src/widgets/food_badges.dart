import 'package:flutter/material.dart';
import '../tokens.dart';

/// Standard Indian vegetarian indicator (green square with green dot).
class ZestyVegBadge extends StatelessWidget {
  const ZestyVegBadge({super.key, this.size = 14.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: ZestyColors.vegMark, width: 1.5),
        borderRadius: BorderRadius.circular(2.5),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: const BoxDecoration(
          color: ZestyColors.vegMark,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Standard Indian non-vegetarian indicator (red square with red triangle).
class ZestyNonVegBadge extends StatelessWidget {
  const ZestyNonVegBadge({super.key, this.size = 14.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: ZestyColors.nonVegMark, width: 1.5),
        borderRadius: BorderRadius.circular(2.5),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.5, size * 0.5),
        painter: _TrianglePainter(color: ZestyColors.nonVegMark),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Star rating badge (e.g. "4.8 ★").
class ZestyRatingBadge extends StatelessWidget {
  const ZestyRatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.isCompact = false,
  });

  final double rating;
  final int? reviewCount;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: ZestyColors.secondary,
        borderRadius: BorderRadius.circular(ZestyRadius.xs),
        boxShadow: [
          BoxShadow(
            color: ZestyColors.secondary.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.star_rounded,
            size: 13,
            color: Colors.white,
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 3),
            Text(
              '($reviewCount)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ETA and distance chip (e.g. "⚡ 20-25 mins • 2.4 km").
class ZestyEtaChip extends StatelessWidget {
  const ZestyEtaChip({
    super.key,
    required this.etaText,
    this.distanceText,
  });

  final String etaText;
  final String? distanceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ZestyColors.glassPill,
        borderRadius: BorderRadius.circular(ZestyRadius.chip),
        border: Border.all(color: ZestyColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 14,
            color: ZestyColors.primaryAmber,
          ),
          const SizedBox(width: 3),
          Text(
            etaText,
            style: const TextStyle(
              color: ZestyColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (distanceText != null) ...[
            Text(
              ' • $distanceText',
              style: const TextStyle(
                color: ZestyColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
