import 'package:flutter/material.dart';
import 'colors.dart';

/// TaxNG Typography System
class TaxNGTypography {
  /// Display Styles (Large headlines)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 40,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.33,
  );

  /// Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.57,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.67,
  );

  /// Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.67,
  );

  /// Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.57,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.67,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  /// Code/Monospace Styles
  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.67,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: 'IBM Plex Mono',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Semantic text variants
  static const TextStyle error = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: TaxNGColors.error,
  );

  static const TextStyle success = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: TaxNGColors.success,
  );

  static const TextStyle warning = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: TaxNGColors.warning,
  );

  static const TextStyle info = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: TaxNGColors.info,
  );

  /// Disabled text
  static const TextStyle disabled = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: TaxNGColors.textLight,
  );
}

/// Get text styles for a specific context
class TaxNGTextTheme {
  static TextTheme buildTextTheme(bool isDark) {
    final textColor = isDark ? Colors.white : TaxNGColors.textDark;
    final secondaryTextColor = isDark ? Colors.white70 : TaxNGColors.textMedium;

    return TextTheme(
      displayLarge: TaxNGTypography.displayLarge.copyWith(color: textColor),
      displayMedium: TaxNGTypography.displayMedium.copyWith(color: textColor),
      displaySmall: TaxNGTypography.displaySmall.copyWith(color: textColor),
      headlineLarge: TaxNGTypography.headlineLarge.copyWith(color: textColor),
      headlineMedium: TaxNGTypography.headlineMedium.copyWith(color: textColor),
      headlineSmall: TaxNGTypography.headlineSmall.copyWith(color: textColor),
      titleLarge: TaxNGTypography.titleLarge.copyWith(color: textColor),
      titleMedium: TaxNGTypography.titleMedium.copyWith(color: textColor),
      titleSmall: TaxNGTypography.titleSmall.copyWith(color: secondaryTextColor),
      bodyLarge: TaxNGTypography.bodyLarge.copyWith(color: textColor),
      bodyMedium: TaxNGTypography.bodyMedium.copyWith(color: textColor),
      bodySmall: TaxNGTypography.bodySmall.copyWith(color: secondaryTextColor),
      labelLarge: TaxNGTypography.labelLarge.copyWith(color: textColor),
      labelMedium: TaxNGTypography.labelMedium.copyWith(color: secondaryTextColor),
      labelSmall: TaxNGTypography.labelSmall.copyWith(color: secondaryTextColor),
    );
  }
}
