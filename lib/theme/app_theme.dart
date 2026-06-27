import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // COLORS — Brand Palette
  // ==========================================
  static const Color primary    = Color(0xFF1A73E8);
  static const Color primaryDark= Color(0xFF0D47A1);
  static const Color accent     = Color(0xFF00BFA5);
  static const Color success    = Color(0xFF00C853);
  static const Color warning    = Color(0xFFFFAB00);
  static const Color danger     = Color(0xFFFF1744);
  static const Color purple     = Color(0xFF7C4DFF);

  static const Color bg         = Color(0xFFF8F9FA);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3F4);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFF9CA3AF);

  // ==========================================
  // FONTS — Noto Sans Lao ຫຼັກ
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
      height: height ?? 1.6,  // Lao ຕ້ອງການ line-height ສູງກວ່າ
    );
  }

  static TextStyle laoDisplay({double size = 24, Color color = textPrimary}) {
    return GoogleFonts.notoSansLao(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
      letterSpacing: -0.3,
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
  // ANIMATION DURATIONS
  // ==========================================
  static const Duration fast   = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow   = Duration(milliseconds: 600);
  static const Duration xslow  = Duration(milliseconds: 900);

  static const Curve easeOut  = Curves.easeOutCubic;
  static const Curve easeIn   = Curves.easeInCubic;
  static const Curve spring   = Curves.elasticOut;
  static const Curve bounce   = Curves.bounceOut;

  // ==========================================
  // SPACING
  // ==========================================
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  // ==========================================
  // BORDER RADIUS
  // ==========================================
  static const double radiusSm  = 8;
  static const double radius    = 12;
  static const double radiusLg  = 20;
  static const double radiusXl  = 28;
  static const double radiusFull= 999;

  // ==========================================
  // MATERIAL THEME
  // ==========================================
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: bg,
      fontFamily: GoogleFonts.notoSansLao().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: laoText(size: 18, weight: FontWeight.w600),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: laoText(size: 14, weight: FontWeight.w600, color: Colors.white),
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
        hintStyle: laoCaption(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: laoCaption(color: primary),
        unselectedLabelStyle: laoCaption(),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F17),
      fontFamily: GoogleFonts.notoSansLao().fontFamily,
    );
  }
}
