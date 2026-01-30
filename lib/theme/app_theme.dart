import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color avocadoGreen = Color(0xFF8CB33E);
  static const Color lightCream = Color(0xFFE8F2D0); // From your splash
  static const Color darkPit = Color(0xFF3E2723); // Brown accent for "Pit"

  // Backgrounds
  static const Color organicBlack = Color(
    0xFF0D1108,
  ); // Organic deep olive black
  static const Color surfaceOlive = Color(
    0xFF1B1F14,
  ); // Deep olive card surface

  static TextTheme _appTextTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleMedium: GoogleFonts.dmSans(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.dmSans(
        textStyle: base.bodyLarge,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      labelSmall: GoogleFonts.dmSans(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Refined Light Theme
  static ThemeData light({Color? seedColor}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? avocadoGreen,
      brightness: Brightness.light,
      primary: avocadoGreen,
      surface: const Color(0xFFFAFAF7),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _appTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFFF1F4E8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: avocadoGreen.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  /// Premium Dark Theme
  static ThemeData dark({Color? seedColor}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor ?? avocadoGreen,
      brightness: Brightness.dark,
      primary: avocadoGreen,
      onPrimary: organicBlack,
      secondary: lightCream,
      onSecondary: organicBlack,
      tertiary: const Color(0xFFA6C48A),
      surface: organicBlack,
      surfaceContainer: surfaceOlive,
      onSurface: const Color(0xFFE3E4D7),
      onSurfaceVariant: const Color(0xFFC4C8BA),
      outline: const Color(0xFF43493E),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: _appTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: organicBlack,

      // Makes the Appbar feel like it's floating on the background
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE3E4D7),
        ),
      ),

      // Premium cards with subtle glass/olive tint
      cardTheme: CardThemeData(
        color: surfaceOlive,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),

      // Styling for Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceOlive,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: avocadoGreen, width: 1.5),
        ),
      ),

      // Modern Navigation Bar (Semi-transparent Olive)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: organicBlack,
        indicatorColor: avocadoGreen.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: organicBlack,
        elevation: 0,
      ),
    );
  }
}
