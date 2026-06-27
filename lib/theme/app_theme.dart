import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // COLORS
  // ==========================================
  static const Color primary     = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent      = Color(0xFF00BFA5);
  static const Color success     = Color(0xFF00C853);
  static const Color warning     = Color(0xFFFFAB00);
  static const Color danger      = Color(0xFFFF1744);
  static const Color purple      = Color(0xFF7C4DFF);

  static const Color bg          = Color(0xFFF8F9FA);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceAlt  = Color(0xFFF1F3F4);
  static const Color border      = Color(0xFFE0E0E0);

  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFF9CA3AF);

  // ==========================================
  // RADIUS
  // ==========================================
  static const double radius     = 12.0;
  static const double radiusFull = 999.0;

  // ==========================================
  // ANIMATION
  // ==========================================
  static const Duration fast   = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow   = Duration(milliseconds: 600);
  static const Duration xslow  = Duration(milliseconds: 900);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn  = Curves.easeInCubic;
  static const Curve spring  = Curves.elasticOut;
  static const Curve bounce  = Curves.bounceOut;

  // ==========================================
  // TEXT STYLES
  // ==========================================
  static TextStyle laoText({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color color = textPrimary,
    double? height,
  }) {
    return GoogleFonts.notoSansLao(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.6,
    );
  }

  static TextStyle laoDisplay({
    double size = 24,
    Color color = textPrimary,
  }) {
    return GoogleFonts.notoSansLao(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle laoCaption({Color color = textSecondary}) {
    return GoogleFonts.notoSansLao(
      fontSize: 11,
      color: color,
      height: 1.5,
    );
  }

  // ==========================================
  // THEMES
  // ==========================================
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      backgroundColor: surface,
      selectedLabelStyle: laoCaption(color: primary),
      unselectedLabelStyle: laoCaption(color: textMuted),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Color(0xFFF1F5F9),
      elevation: 0,
    ),
  );
}
