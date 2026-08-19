import 'package:flutter/material.dart';

abstract class AppTheme {
  // Official LINE Sally Palette
  static const Color sallyYellow = Color(0xFFFFD600); // Bright Sunny Yellow (Sent Bubbles)
  static const Color sallyGreen = Color(0xFF68B92E); // Sally Green (Badges)
  static const Color darkCocoaText = Color(0xFF1A0C00); // High-Contrast Dark Cocoa Text for Yellow Bubbles

  // LINE Sally Midnight Dark Theme Palette (Warm Stone Charcoal & Brown)
  static const Color scaffoldBgDark = Color(0xFF1C1917); // Warm Stone Charcoal
  static const Color surfaceDark = Color(0xFF292524); // Dark Warm Surface
  static const Color inputFillDark = Color(0xFF38322E); // Dark Warm Input Fill
  static const Color onSurfaceDark = Color(0xFFFFFDE7); // Crisp Cream White Text
  static const Color mutedTextDark = Color(0xFFA8A29E); // Muted Warm Grey

  // Soft Light Theme Palette (Clean Neutral Off-White)
  static const Color scaffoldBgLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFF1F5F3);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color mutedTextLight = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBgLight,
      colorScheme: const ColorScheme.light(
        primary: sallyYellow,
        secondary: sallyGreen,
        surface: surfaceLight,
        onPrimary: darkCocoaText,
        onSurface: onSurfaceLight,
        onSurfaceVariant: mutedTextLight,
        primaryContainer: Color(0xFFFFF3C4),
        onPrimaryContainer: Color(0xFF4E2C00),
        surfaceContainerHighest: inputFillLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sallyYellow,
          foregroundColor: darkCocoaText,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillLight,
        hintStyle: const TextStyle(color: mutedTextLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: sallyYellow, width: 2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurfaceLight),
        actionsIconTheme: IconThemeData(color: onSurfaceLight),
        titleTextStyle: TextStyle(
          color: onSurfaceLight,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        elevation: 0,
        indicatorColor: sallyYellow.withValues(alpha: 0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkCocoaText);
          }
          return const IconThemeData(color: mutedTextLight);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: onSurfaceLight,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: mutedTextLight,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBgDark,
      colorScheme: const ColorScheme.dark(
        primary: sallyYellow, // Bright Sunny Yellow for sent bubbles
        secondary: sallyGreen, // Sally Green
        surface: surfaceDark,
        onPrimary: darkCocoaText, // Deep Cocoa dark text on yellow bubbles
        onSurface: onSurfaceDark,
        onSurfaceVariant: mutedTextDark,
        primaryContainer: Color(0xFFB45309),
        onPrimaryContainer: Color(0xFFFEF3C7),
        surfaceContainerHighest: inputFillDark,
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF44403C), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sallyYellow,
          foregroundColor: darkCocoaText,
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillDark,
        hintStyle: const TextStyle(color: mutedTextDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF44403C), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: sallyYellow, width: 2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurfaceDark),
        actionsIconTheme: IconThemeData(color: onSurfaceDark),
        titleTextStyle: TextStyle(
          color: onSurfaceDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        elevation: 0,
        indicatorColor: sallyYellow.withValues(alpha: 0.3),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: onSurfaceDark),
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: onSurfaceDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
