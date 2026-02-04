import 'package:flutter/material.dart';

/// TaxNG Modern Color Palette
class TaxNGColors {
  // Primary Colors
  static const Color primary = Color(0xFF0066FF); // Modern Blue
  static const Color primaryLight = Color(0xFF4D94FF);
  static const Color primaryDark = Color(0xFF0047CC);

  // Secondary Colors (Trust & Growth)
  static const Color secondary = Color(0xFF00CC99); // Fresh Green
  static const Color secondaryLight = Color(0xFF4DDBAA);
  static const Color secondaryDark = Color(0xFF00994D);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B35); // Warm Orange
  static const Color accentLight = Color(0xFFFF8C5A);
  static const Color accentDark = Color(0xFFCC5629);

  // Semantic Colors
  static const Color success = Color(0xFF06D6A0); // Success Green
  static const Color warning = Color(0xFFFFB703); // Warning Amber
  static const Color error = Color(0xFFEF476F); // Error Red
  static const Color info = Color(0xFF0D7AFF); // Info Blue

  // Neutral Colors
  static const Color textDark = Color(0xFF1A1A2E); // Very Dark Blue
  static const Color textMedium = Color(0xFF4A4A68); // Medium Gray
  static const Color textLight = Color(0xFF8A8AA0); // Light Gray
  static const Color textLighter = Color(0xFFC0C0D0); // Lighter Gray

  static const Color bgLight = Color(0xFFF5F5F7); // Off-white
  static const Color bgWhite = Color(0xFFFFFFFF); // Pure white
  static const Color bgDark = Color(0xFF0F0F1E); // Dark background
  static const Color bgDarkSecondary = Color(0xFF1A1A2E); // Secondary dark

  // Border Colors
  static const Color borderLight = Color(0xFFEAEAF0);
  static const Color borderMedium = Color(0xFFD0D0D8);
  static const Color borderDark = Color(0xFF8A8AA0);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF4D94FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF00CC99)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // 10% opacity
  static const Color shadowMedium = Color(0x26000000); // 15% opacity
  static const Color shadowDark = Color(0x40000000); // 25% opacity

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF0066FF), // Blue
    Color(0xFF00CC99), // Green
    Color(0xFFFF6B35), // Orange
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFF59E0B), // Amber
  ];
}

/// TaxNG Color Extensions
extension TaxNGColorExtension on BuildContext {
  /// Get colors based on current theme
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get textColor => Theme.of(this).textTheme.bodyMedium?.color ?? TaxNGColors.textDark;
}
