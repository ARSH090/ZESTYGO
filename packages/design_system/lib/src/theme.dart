import 'package:flutter/material.dart';

import 'tokens.dart';

/// Dark obsidian theme matching Stitch screens for Customer & Delivery apps.
ThemeData buildZestyDarkTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ZestyColors.primary,
    onPrimary: Colors.white,
    secondary: ZestyColors.secondary,
    onSecondary: Colors.white,
    surface: ZestyColors.darkCard,
    onSurface: ZestyColors.textLight,
    error: ZestyColors.error,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: ZestyColors.darkCanvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: ZestyColors.textLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: ZestyColors.textLight),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZestyColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: ZestyColors.primary.withValues(alpha: 0.4),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZestyRadius.card),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: ZestyColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZestyRadius.card),
        side: const BorderSide(color: ZestyColors.glassBorder),
      ),
    ),
  );
}

/// Warm light theme for administrative & restaurant portals.
ThemeData buildZestyTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: ZestyColors.primary,
    primary: ZestyColors.primary,
    secondary: ZestyColors.secondary,
    surface: ZestyColors.surface,
    error: ZestyColors.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ZestyColors.lightBackground,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZestyColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZestyRadius.card),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ZestyColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ZestyRadius.card),
      ),
    ),
  );
}
