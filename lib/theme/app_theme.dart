import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF245C66);
  static const Color secondary = Color(0xFFE07A5F);
  static const Color accent = Color(0xFF4D9B8A);
  static const Color mist = Color(0xFFF5F7FA);
  static const Color card = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: card,
    );

    final textTheme = GoogleFonts.beirutiTextTheme().copyWith(
      headlineLarge: GoogleFonts.beiruti(
        fontWeight: FontWeight.w800,
        fontSize: 32,
      ),
      headlineMedium: GoogleFonts.beiruti(
        fontWeight: FontWeight.w800,
        fontSize: 28,
      ),
      headlineSmall: GoogleFonts.beiruti(
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.beiruti(
        fontWeight: FontWeight.w700,
        fontSize: 23,
      ),
      titleMedium: GoogleFonts.beiruti(
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.beiruti(
        height: 1.6,
        fontSize: 18,
        color: const Color(0xFF1F2D33),
      ),
      bodyMedium: GoogleFonts.beiruti(
        height: 1.58,
        fontSize: 16,
        color: const Color(0xFF2A3A41),
      ),
      labelLarge: GoogleFonts.beiruti(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: mist,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.primary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontSize: 24,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE4EBF0)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: const BorderSide(color: Color(0xFFD8E2E8)),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: const Color(0xFF30444D),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: const Color(0xFFF1F5F8),
        selectedColor: colorScheme.primary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? colorScheme.primary : const Color(0xFF6A7A82),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colorScheme.primary : const Color(0xFF7A8990),
          );
        }),
      ),
    );
  }
}
