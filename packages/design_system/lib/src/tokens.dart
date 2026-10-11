import 'package:flutter/material.dart';

/// ZestyGo palette matching Stitch brand identity:
/// Warm saffron flame on deep obsidian canvas with glassmorphism overlays.
abstract final class ZestyColors {
  // Brand Core
  static const Color primary = Color(0xFFFF8A00); // vibrant flame orange
  static const Color primaryAmber = Color(0xFFFF9F1C); // saffron amber
  static const Color primaryDeep = Color(0xFFD13F00); // deep saffron
  static const Color primarySoft = Color(0xFFFFE3D6); // pale saffron cream

  // Canvas & Surfaces (Obsidian Dark & Cream Light)
  static const Color darkCanvas = Color(0xFF100E10); // obsidian dark base
  static const Color darkCard = Color(0xFF1C181B); // elevated surface
  static const Color glassBg = Color(0x9E1E1A1C); // 62% frosted glass
  static const Color glassBorder = Color(0x1FFFFFFF); // 12% subtle white border
  static const Color glassPill = Color(0x14FFFFFF); // 8% glass pill

  // Light / Neutral Surfaces
  static const Color lightBackground = Color(0xFFFFF8F0); // warm cream
  static const Color surface = Color(0xFFFFFFFF);

  // Typography Colors
  static const Color ink = Color(0xFF1F1B16);
  static const Color inkMuted = Color(0xFF5E564D);
  static const Color textLight = Color(0xFFFFF9F4); // high-contrast cream on dark
  static const Color textMuted = Color(0xFFBDB4B0); // secondary label on dark

  // Feedback & Food Markings
  static const Color secondary = Color(0xFF1B7F4B); // fresh green
  static const Color error = Color(0xFFB3261E);
  static const Color vegMark = Color(0xFF1B8A3E); // Indian veg green indicator
  static const Color nonVegMark = Color(0xFFB3261E); // Indian non-veg red indicator
  static const Color ratingGold = Color(0xFFFFB627); // star rating gold
}

abstract final class ZestyGradients {
  static const LinearGradient flame = LinearGradient(
    colors: [ZestyColors.primaryAmber, ZestyColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCard = LinearGradient(
    colors: [
      Color(0x1AFFFFFF), // 10% white
      Color(0x08FFFFFF), // 3% white
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient ambientOrangeGlow = RadialGradient(
    colors: [
      Color(0x59FF8A00), // 35% orange
      Colors.transparent,
    ],
    radius: 0.8,
  );
}

abstract final class ZestySpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class ZestyRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double card = 24;
  static const double sheet = 32;
  static const double chip = 999;
}

abstract final class ZestyMotion {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration emphasized = Duration(milliseconds: 400);
  static const Duration splash = Duration(milliseconds: 1200);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve bouncy = Curves.elasticOut;
}
