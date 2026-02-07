import 'package:flutter/material.dart';

/// TaxNG Modern Color Palette — Green-first, Gen Z-friendly
class TaxNGColors {
  // Primary Colors — Contemporary Green
  static const Color primary = Color(0xFF16A34A); // Vibrant Green
  static const Color primaryLight = Color(0xFF4ADE80); // Light Green
  static const Color primaryDark = Color(0xFF166534); // Deep Green

  // Secondary Colors — Complementary Teal
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color secondaryLight = Color(0xFF5EEAD4);
  static const Color secondaryDark = Color(0xFF0F766E);

  // Accent Colors — Warm Lime for Gen Z pop
  static const Color accent = Color(0xFF84CC16); // Lime Green
  static const Color accentLight = Color(0xFFA3E635);
  static const Color accentDark = Color(0xFF65A30D);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E); // Success Green
  static const Color warning = Color(0xFFF59E0B); // Warning Amber
  static const Color error = Color(0xFFEF4444); // Error Red
  static const Color info = Color(0xFF3B82F6); // Info Blue

  // Neutral Colors — Clean and modern
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textMedium = Color(0xFF475569); // Slate 600
  static const Color textLight = Color(0xFF94A3B8); // Slate 400
  static const Color textLighter = Color(0xFFCBD5E1); // Slate 300

  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color bgDarkSecondary = Color(0xFF1E293B); // Slate 800

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderMedium = Color(0xFFCBD5E1); // Slate 300
  static const Color borderDark = Color(0xFF94A3B8); // Slate 400

  // Gradient Colors — Contemporary greens
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF166534), Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF84CC16), Color(0xFFA3E635)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x26000000);
  static const Color shadowDark = Color(0x40000000);

  // Chart Colors — vibrant, Gen Z palette
  static const List<Color> chartColors = [
    Color(0xFF16A34A), // Green
    Color(0xFF0D9488), // Teal
    Color(0xFF84CC16), // Lime
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFF59E0B), // Amber
  ];
}

/// TaxNG Color Extensions
extension TaxNGColorExtension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get accentColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get textColor =>
      Theme.of(this).textTheme.bodyMedium?.color ?? TaxNGColors.textDark;
}
