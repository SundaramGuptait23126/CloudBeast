import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color background = Color(0xFF0C0E14);
  static const Color surface = Color(0xFF161922);
  static const Color surfaceVariant = Color(0xFF222634);
  static const Color primary = Color(0xFF8B5CF6); // Vibrant Purple
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color divider = Color(0xFF2A2E3D);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2230), Color(0xFF141720)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playerBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF1E1035),
      Color(0xFF0F172A),
      Color(0xFF090D16),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: divider,
        thumbColor: Colors.white,
        overlayColor: primary.withAlpha(51), // 0.2 * 255
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          color: textMuted,
        ),
      ),
    );
  }
}
