import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// TaxNG Typography System — powered by Google Fonts for guaranteed rendering
class TaxNGTypography {
  /// Base text style using Google Fonts Inter
  static TextStyle _inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  /// Base monospace style using Google Fonts IBM Plex Mono
  static TextStyle _mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  /// Display Styles (Large headlines)
  static TextStyle get displayLarge => _inter(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => _inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
        height: 1.25,
      );

  static TextStyle get displaySmall => _inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.33,
      );

  /// Headline Styles
  static TextStyle get headlineLarge => _inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get headlineMedium => _inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineSmall => _inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  /// Title Styles
  static TextStyle get titleLarge => _inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get titleMedium => _inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.57,
      );

  static TextStyle get titleSmall => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.67,
      );

  /// Body Styles
  static TextStyle get bodyLarge => _inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.57,
      );

  static TextStyle get bodySmall => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.67,
      );

  /// Label Styles
  static TextStyle get labelLarge => _inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.57,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.67,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
      );

  /// Code/Monospace Styles
  static TextStyle get monoLarge => _mono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.57,
      );

  static TextStyle get monoMedium => _mono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.67,
      );

  static TextStyle get monoSmall => _mono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  /// Semantic text variants
  static TextStyle get error => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TaxNGColors.error,
      );

  static TextStyle get success => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TaxNGColors.success,
      );

  static TextStyle get warning => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TaxNGColors.warning,
      );

  static TextStyle get info => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TaxNGColors.info,
      );

  /// Disabled text
  static TextStyle get disabled => _inter(
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
      titleSmall:
          TaxNGTypography.titleSmall.copyWith(color: secondaryTextColor),
      bodyLarge: TaxNGTypography.bodyLarge.copyWith(color: textColor),
      bodyMedium: TaxNGTypography.bodyMedium.copyWith(color: textColor),
      bodySmall: TaxNGTypography.bodySmall.copyWith(color: secondaryTextColor),
      labelLarge: TaxNGTypography.labelLarge.copyWith(color: textColor),
      labelMedium:
          TaxNGTypography.labelMedium.copyWith(color: secondaryTextColor),
      labelSmall:
          TaxNGTypography.labelSmall.copyWith(color: secondaryTextColor),
    );
  }
}
