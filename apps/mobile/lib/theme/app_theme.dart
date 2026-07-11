import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system for Anti-Gaspi DZ.
/// Cairo font for Arabic (RTL), Inter for French (LTR).
/// Vibrant green/teal palette reflecting anti-waste & freshness.
class AppTheme {
  // ── Brand colors ──
  static const Color primaryGreen = Color(0xFF00B894);
  static const Color primaryDark = Color(0xFF00896E);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color backgroundLight = Color(0xFFF8FFFE);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textOnDark = Color(0xFFF5F6FA);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningOrange = Color(0xFFF39C12);
  static const Color dlcRed = Color(0xFFE74C3C);
  static const Color ddmAmber = Color(0xFFF39C12);

  // ── Semantic tokens (use these instead of Colors.blue.shade50 etc.) ──
  // These auto-adapt when passed a BuildContext-aware brightness.
  static Color infoBg(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF1B2A3D) : const Color(0xFFE8F4FD);
  static Color infoFg(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF6FB8F0) : const Color(0xFF1976D2);
  static Color infoBorder(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF2C4A6B) : const Color(0xFFBBDEFB);

  static Color successBg(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF163A2E) : const Color(0xFFE6F7EF);
  static Color successFg(BuildContext ctx) => successGreen;

  static Color warningBg(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF3A2E16) : const Color(0xFFFFF4E0);
  static Color warningFg(BuildContext ctx) => warningOrange;

  static Color dangerBg(BuildContext ctx) =>
      _isDark(ctx) ? const Color(0xFF3A1A1A) : const Color(0xFFFDECEA);
  static Color dangerFg(BuildContext ctx) => errorRed;

  static Color surfaceCard(BuildContext ctx) =>
      _isDark(ctx) ? cardDark : Colors.white;

  static bool _isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  // ── Motion tokens (shared durations/curves for consistent feel) ──
  static const Duration fastAnim = Duration(milliseconds: 180);
  static const Duration normalAnim = Duration(milliseconds: 320);
  static const Duration slowAnim = Duration(milliseconds: 550);
  static const Curve entryCurve = Curves.easeOutCubic;

  // ── Radius tokens ──
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;

  static ThemeData lightTheme(String locale) {
    final isArabic = locale == 'ar';
    final textTheme =
        isArabic ? GoogleFonts.cairoTextTheme() : GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: accentOrange,
        error: errorRed,
        surface: backgroundLight,
      ),
      textTheme: textTheme.apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: _appBarTheme(isArabic, Colors.white, primaryGreen),
      elevatedButtonTheme: _elevatedButtonTheme(isArabic),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        color: Colors.white,
      ),
      inputDecorationTheme: _inputTheme(Colors.grey.shade50, Colors.grey.shade300),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData darkTheme(String locale) {
    final isArabic = locale == 'ar';
    final textTheme =
        isArabic ? GoogleFonts.cairoTextTheme() : GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: accentOrange,
        error: errorRed,
        surface: surfaceDark,
      ),
      textTheme: textTheme.apply(bodyColor: textOnDark, displayColor: textOnDark),
      appBarTheme: _appBarTheme(isArabic, Colors.white, surfaceDark),
      elevatedButtonTheme: _elevatedButtonTheme(isArabic),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        color: cardDark,
      ),
      inputDecorationTheme: _inputTheme(surfaceDark, Colors.white24),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static AppBarTheme _appBarTheme(bool isArabic, Color fg, Color bg) => AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: (isArabic
                ? GoogleFonts.cairo(fontWeight: FontWeight.w700)
                : GoogleFonts.inter(fontWeight: FontWeight.w700))
            .copyWith(fontSize: 20, color: fg),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(bool isArabic) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: (isArabic
                  ? GoogleFonts.cairo(fontWeight: FontWeight.w600)
                  : GoogleFonts.inter(fontWeight: FontWeight.w600))
              .copyWith(fontSize: 16),
        ),
      );

  static InputDecorationTheme _inputTheme(Color fill, Color borderColor) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}