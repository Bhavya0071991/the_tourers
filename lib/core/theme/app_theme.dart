import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brutalist Streetwear Aesthetics
  static const Color pureWhite = Color(0xFFFAFAFA); // Softened from #FFF
  static const Color pureBlack = Color(0xFF0A0A0A); // Softened from #000
  static const Color secondaryBlack = Color(0xFF151515);
  static const Color softGrey = Color(0xFFEFEFEF); // For product backgrounds
  static const Color neonAccent = Color(0xFF00FFAA); // Cyberpunk Mint Green

  /// Primary theme for the app (Strictly Dark Theme)
  static ThemeData get theme => darkTheme;

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: pureWhite,
        primary: pureWhite,
        secondary: pureWhite, // In dark mode, buttons/accents should be white
        surface: secondaryBlack,
        surfaceContainerHighest: const Color(0xFF111111),
        onSurface: pureWhite,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: pureBlack,
      textTheme: GoogleFonts.spaceMonoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: pureWhite, displayColor: pureWhite),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: pureWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: pureWhite, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: BorderSide(
            color: pureWhite.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: pureWhite, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: GoogleFonts.spaceMono(
          color: pureWhite.withValues(alpha: 0.6),
          fontWeight: FontWeight.bold,
        ),
        hintStyle: GoogleFonts.spaceMono(
          color: pureWhite.withValues(alpha: 0.3),
        ),
        filled: true,
        fillColor: secondaryBlack,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonAccent,
          foregroundColor: pureBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Sharp, brutalist corners
            side: const BorderSide(color: pureWhite, width: 2), // Add border
          ),
          textStyle: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
