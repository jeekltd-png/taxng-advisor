import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// TaxNG App Theme Configuration
class TaxNGTheme {
  /// Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary color scheme
      primaryColor: TaxNGColors.primary,
      colorScheme: ColorScheme.light(
        primary: TaxNGColors.primary,
        secondary: TaxNGColors.secondary,
        tertiary: TaxNGColors.accent,
        error: TaxNGColors.error,
        surface: TaxNGColors.bgLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: TaxNGColors.textDark,
      ),

      // Scaffold background
      scaffoldBackgroundColor: TaxNGColors.bgLight,

      // App bar theme — green background with white text/icons
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: TaxNGColors.primaryDark,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Tab bar theme — white text on green AppBar
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Bottom app bar theme
      bottomAppBarTheme: const BottomAppBarThemeData(
        elevation: 8,
        color: TaxNGColors.bgWhite,
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: TaxNGColors.bgWhite,
        selectedItemColor: TaxNGColors.primary,
        unselectedItemColor: TaxNGColors.textLight,
        showUnselectedLabels: true,
        selectedLabelStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.primary,
        ),
        unselectedLabelStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.textLight,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: TaxNGColors.borderLight,
            width: 1,
          ),
        ),
        color: TaxNGColors.bgWhite,
        surfaceTintColor: TaxNGColors.primary,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: TaxNGColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TaxNGTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: TaxNGColors.primary,
          side: const BorderSide(color: TaxNGColors.borderMedium, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TaxNGTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          elevation: 0,
          foregroundColor: TaxNGColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TaxNGTypography.labelLarge,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TaxNGColors.bgLight,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.borderLight),
        ),
        labelStyle: TaxNGTypography.bodyMedium.copyWith(
          color: TaxNGColors.textMedium,
        ),
        hintStyle: TaxNGTypography.bodyMedium.copyWith(
          color: TaxNGColors.textLight,
        ),
        errorStyle: TaxNGTypography.bodySmall.copyWith(
          color: TaxNGColors.error,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: TaxNGColors.borderMedium),
        ),
        backgroundColor: TaxNGColors.bgLight,
        selectedColor: TaxNGColors.primary,
        deleteIconColor: TaxNGColors.textMedium,
        disabledColor: TaxNGColors.textLight,
        brightness: Brightness.light,
        elevation: 0,
        pressElevation: 4,
        labelStyle: TaxNGTypography.labelMedium.copyWith(
          color: TaxNGColors.textDark,
        ),
        secondaryLabelStyle: TaxNGTypography.labelMedium.copyWith(
          color: Colors.white,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: TaxNGColors.bgWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Text theme
      textTheme: TaxNGTextTheme.buildTextTheme(false),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: TaxNGColors.borderLight,
        thickness: 1,
        space: 16,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: TaxNGColors.textDark,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: TaxNGColors.primary,
        foregroundColor: Colors.white,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        elevation: 8,
        backgroundColor: TaxNGColors.textDark,
        contentTextStyle: TaxNGTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TaxNGColors.primary,
        linearMinHeight: 4,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: TaxNGColors.primary,
        inactiveTrackColor: TaxNGColors.borderLight,
        activeTickMarkColor: TaxNGColors.primary,
        inactiveTickMarkColor: TaxNGColors.borderLight,
        disabledActiveTrackColor: TaxNGColors.textLight,
        disabledInactiveTrackColor: TaxNGColors.borderLight,
        thumbColor: TaxNGColors.primary,
        disabledThumbColor: TaxNGColors.textLight,
        overlayColor: TaxNGColors.primary.withOpacity(0.12),
        valueIndicatorColor: TaxNGColors.primary,
        valueIndicatorTextStyle: TaxNGTypography.labelSmall.copyWith(
          color: Colors.white,
        ),
      ),

      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: TaxNGColors.bgLight,
        selectedIconTheme: const IconThemeData(
          color: TaxNGColors.primary,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: TaxNGColors.textLight,
          size: 24,
        ),
        selectedLabelTextStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.primary,
        ),
        unselectedLabelTextStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.textLight,
        ),
      ),

      // Other settings
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Primary color scheme
      primaryColor: TaxNGColors.primaryLight,
      colorScheme: ColorScheme.dark(
        primary: TaxNGColors.primaryLight,
        secondary: TaxNGColors.secondaryLight,
        tertiary: TaxNGColors.accentLight,
        error: TaxNGColors.error,
        surface: TaxNGColors.bgDarkSecondary,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: Colors.white,
      ),

      // Scaffold background
      scaffoldBackgroundColor: TaxNGColors.bgDark,

      // App bar theme — green background with white text/icons
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: TaxNGColors.primaryDark,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Tab bar theme — white text on green AppBar
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Bottom app bar theme
      bottomAppBarTheme: const BottomAppBarThemeData(
        elevation: 8,
        color: TaxNGColors.bgDarkSecondary,
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: TaxNGColors.bgDarkSecondary,
        selectedItemColor: TaxNGColors.primaryLight,
        unselectedItemColor: TaxNGColors.textLight,
        showUnselectedLabels: true,
        selectedLabelStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.primaryLight,
        ),
        unselectedLabelStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.textLight,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF2A2A3E),
            width: 1,
          ),
        ),
        color: TaxNGColors.bgDarkSecondary,
        surfaceTintColor: TaxNGColors.primaryLight,
      ),

      // Text theme
      textTheme: TaxNGTextTheme.buildTextTheme(true),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: TaxNGColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TaxNGTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: TaxNGColors.primaryLight,
          side: const BorderSide(color: Color(0xFF2A2A3E), width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TaxNGTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          elevation: 0,
          foregroundColor: TaxNGColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TaxNGTypography.labelLarge,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TaxNGColors.bgDarkSecondary,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: TaxNGColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TaxNGColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
        ),
        labelStyle: TaxNGTypography.bodyMedium.copyWith(
          color: TaxNGColors.textLight,
        ),
        hintStyle: TaxNGTypography.bodyMedium.copyWith(
          color: TaxNGColors.textLight,
        ),
        errorStyle: TaxNGTypography.bodySmall.copyWith(
          color: TaxNGColors.error,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A2A3E)),
        ),
        backgroundColor: TaxNGColors.bgDarkSecondary,
        selectedColor: TaxNGColors.primaryLight,
        deleteIconColor: TaxNGColors.textLight,
        disabledColor: TaxNGColors.textLight,
        brightness: Brightness.dark,
        elevation: 0,
        pressElevation: 4,
        labelStyle: TaxNGTypography.labelMedium.copyWith(
          color: Colors.white,
        ),
        secondaryLabelStyle: TaxNGTypography.labelMedium.copyWith(
          color: Colors.white,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: TaxNGColors.bgDarkSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A3E),
        thickness: 1,
        space: 16,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: TaxNGColors.primaryLight,
        foregroundColor: Colors.white,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        elevation: 8,
        backgroundColor: const Color(0xFF2A2A3E),
        contentTextStyle: TaxNGTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TaxNGColors.primaryLight,
        linearMinHeight: 4,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: TaxNGColors.primaryLight,
        inactiveTrackColor: const Color(0xFF2A2A3E),
        activeTickMarkColor: TaxNGColors.primaryLight,
        inactiveTickMarkColor: const Color(0xFF2A2A3E),
        disabledActiveTrackColor: TaxNGColors.textLight,
        disabledInactiveTrackColor: const Color(0xFF2A2A3E),
        thumbColor: TaxNGColors.primaryLight,
        disabledThumbColor: TaxNGColors.textLight,
        overlayColor: TaxNGColors.primaryLight.withValues(alpha: 0.12),
        valueIndicatorColor: TaxNGColors.primaryLight,
        valueIndicatorTextStyle: TaxNGTypography.labelSmall.copyWith(
          color: Colors.white,
        ),
      ),

      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: TaxNGColors.bgDarkSecondary,
        selectedIconTheme: const IconThemeData(
          color: TaxNGColors.primaryLight,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: TaxNGColors.textLight,
          size: 24,
        ),
        selectedLabelTextStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.primaryLight,
        ),
        unselectedLabelTextStyle: TaxNGTypography.labelSmall.copyWith(
          color: TaxNGColors.textLight,
        ),
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
