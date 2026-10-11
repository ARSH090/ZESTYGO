import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens.dart';

/// Reusable glassmorphic container widget matching Stitch design aesthetic.
class ZestyGlassCard extends StatelessWidget {
  const ZestyGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ZestySpacing.md),
    this.borderRadius = ZestyRadius.card,
    this.borderWidth = 1.0,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double borderWidth;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? ZestyColors.glassBg,
            gradient: gradient ?? ZestyGradients.glassCard,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? ZestyColors.glassBorder,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

/// Compact glassmorphic pill for chips, filters, and status tags.
class ZestyGlassPill extends StatelessWidget {
  const ZestyGlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.onTap,
    this.isSelected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? ZestyColors.primary : ZestyColors.glassPill,
          borderRadius: BorderRadius.circular(ZestyRadius.chip),
          border: Border.all(
            color: isSelected
                ? ZestyColors.primaryAmber
                : ZestyColors.glassBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ZestyColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
