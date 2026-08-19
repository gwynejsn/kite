import 'package:flutter/material.dart';

abstract class AppTheme {
  static const Color primary = Color(0xFF10B981);
  static const Color secondary = Color(0xFF14B8A6);

  static const Color scaffoldBgDark = Color(0xFF022C22);
  static const Color surfaceDark = Color(0xFF06372B);
  static const Color inputFillDark = Color(0xFF0A3F32);
  static const Color onSurfaceDark = Color(0xFFF0FDF4);
  static const Color mutedTextDark = Color(0xFF94A3B8);

  static const Color scaffoldBgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color inputFillLight = Color(0xFFF1F5F9);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color mutedTextLight = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBgLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSurface: onSurfaceLight,
        onSurfaceVariant: mutedTextLight,
        primaryContainer: Color(0xFFD1FAE5),
        onPrimaryContainer: Color(0xFF065F46),
        surfaceContainerHighest: inputFillLight,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
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
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBgLight,
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
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSurface: onSurfaceDark,
        onSurfaceVariant: mutedTextDark,
        primaryContainer: Color(0xFF065F46),
        onPrimaryContainer: Color(0xFFD1FAE5),
        surfaceContainerHighest: inputFillDark,
      ),
      cardTheme: CardThemeData(
        elevation: 10,
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 20,
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
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
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
    );
  }
}
