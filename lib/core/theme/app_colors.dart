import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF00E676); // Neon Green
  static const Color primaryDark = Color(0xFF00B259);
  static const Color primaryLight = Color(0xFF69F0AE);

  static const Color secondary = Color(0xFF1A1A1A); // Dark Grey / Black
  static const Color secondaryDark = Color(0xFF0A0A0A);
  static const Color secondaryLight = Color(0xFF2A2A2A);

  static const Color accent = Color(0xFF00E676); // Neon Green
  static const Color accentDark = Color(0xFF00B259);
  static const Color accentLight = Color(0xFF69F0AE);

  // Neutral Colors - Light Theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // Neutral Colors - Dark Theme
  static const Color darkBackground = Color(0xFF0A0A0A); // Deep Black
  static const Color darkSurface = Color(0xFF121212); // Charcoal Surface
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);

  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Swipe Colors
  static const Color swipeLike = Color(0xFF10B981); // Green
  static const Color swipeDislike = Color(0xFFEF4444); // Red
  static const Color swipeSuperLike = Color(0xFF3B82F6); // Blue

  // Social Platform Colors
  static const Color github = Color(0xFF181717);
  static const Color google = Color(0xFF4285F4);
  static const Color apple = Color(0xFF000000);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
