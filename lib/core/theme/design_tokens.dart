/// Design system tokens for OpenTV
/// TV-grade dark-first design system
library;

import 'package:flutter/material.dart';

/// Color palette - Dark-first, TV-friendly
class AppColors {
  AppColors._();

  // Brand colors (Red Accent Theme)
  static const Color primary = Color(0xFFE50914); // TV Red
  static const Color primaryLight = Color(0xFFFF5252);
  static const Color primaryDark = Color(0xFFB71C1C);

  // Surface colors
  static const Color surface = Color(0xFF0F0F14);
  static const Color surfaceElevated = Color(0xFF1A1A24);
  static const Color surfaceElevated2 = Color(0xFF252532);
  static const Color surfaceElevated3 = Color(0xFF2F2F40);

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Focus states (TV remote navigation)
  static const Color focusRing = Color(0xFF818CF8);
  static const Color focusBackground = Color(0x206366F1);

  // Overlay colors
  static const Color overlayDark = Color(0xCC000000);
  static const Color overlayLight = Color(0x1AFFFFFF);

  // Category colors for channel cards
  static const Map<String, Color> categoryColors = {
    'news': Color(0xFFEF4444),
    'sports': Color(0xFF22C55E),
    'entertainment': Color(0xFFF59E0B),
    'movies': Color(0xFF8B5CF6),
    'music': Color(0xFFEC4899),
    'kids': Color(0xFF06B6D4),
    'documentary': Color(0xFF14B8A6),
    'general': Color(0xFF6366F1),
  };
}

/// Spacing scale using 8pt grid
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Edge insets shortcuts
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}

/// Typography - Large, readable for TV viewing distance
class AppTypography {
  AppTypography._();

  // Display (Hero text)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  // Labels & Captions
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.textTertiary,
  );
}

/// Border radius tokens
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(full));
}

/// Motion/Animation timing
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration emphasis = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve emphasisCurve = Curves.easeOutQuint;
  static const Curve bounceCurve = Curves.elasticOut;
}

/// Shadow tokens
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x406366F1),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}
