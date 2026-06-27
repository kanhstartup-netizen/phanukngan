// ==========================================
// phanukngan_logo.dart
// ==========================================
// Logo PHANUKNGAN — ແບບ 2 (ທີມ 3 ຄົນ + Navy + Gold)
// ==========================================
//
// pubspec.yaml ຕ້ອງໃສ່:
//   google_fonts: ^6.1.0
//   flutter_svg: ^2.0.9

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ==========================================
// BRAND COLORS
// ==========================================
class PhanuknganColors {
  static const navy  = Color(0xFF0B2545);  // Navy ຫຼັກ
  static const gold  = Color(0xFFC89B3C);  // Gold ຮອງ
  static const white = Color(0xFFFFFFFF);  // ຂາວ
  static const navyLight = Color(0xFF1E3A5F); // Navy Dark Mode
}

// ==========================================
// LOGO VARIANTS
// ==========================================
enum LogoVariant {
  iconOnly,   // Icon ສຳລັບ App Bar, Notification, Nav
  full,       // Icon + ຊື່ ສຳລັບ Header
  splash,     // Icon + ຊື່ + Sub ສຳລັບ Splash Screen
  invertedFull, // ສຳລັບ Dark Background
}

// ==========================================
// MAIN LOGO WIDGET
// ==========================================
class PhanuknganLogo extends StatelessWidget {
  final LogoVariant variant;
  final double size;
  final bool isDark;

  const PhanuknganLogo({
    super.key,
    this.variant = LogoVariant.iconOnly,
    this.size = 48,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark || Theme.of(context).brightness == Brightness.dark;
    return switch (variant) {
      LogoVariant.iconOnly       => _buildIcon(size, dark),
      LogoVariant.full           => _buildFull(size, dark),
      LogoVariant.splash         => _buildSplash(size),
      LogoVariant.invertedFull   => _buildFull(size, true),
    };
  }

  // ==========================================
  // ICON ONLY
  // ==========================================
  Widget _buildIcon(double s, bool dark) {
    return SvgPicture.string(
      dark ? _iconSvgDark : _iconSvg,
      width: s,
      height: s,
      semanticsLabel: 'PHANUKNGAN Logo',
    );
  }

  // ==========================================
  // FULL LOGO (Icon + Text)
  // ==========================================
  Widget _buildFull(double s, bool dark) {
    final textColor = dark
        ? PhanuknganColors.white
        : PhanuknganColors.navy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.string(
          dark ? _iconSvgDark : _iconSvg,
          width: s,
          height: s,
          semanticsLabel: 'PHANUKNGAN Icon',
        ),
        SizedBox(width: s * 0.18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PHANUKNGAN',
              style: GoogleFonts.montserrat(
                fontSize: s * 0.33,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.8,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 1,
              width: s * 2.5,
              color: PhanuknganColors.gold,
            ),
            const SizedBox(height: 3),
            Text(
              'ພະນັກງານ',
              style: GoogleFonts.notoSansLao(
                fontSize: s * 0.20,
                fontWeight: FontWeight.w700,
                color: PhanuknganColors.gold,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // SPLASH SCREEN
  // ==========================================
  Widget _buildSplash(double s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glow container
        Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s * 0.22),
            color: Colors.white.withOpacity(0.1),
          ),
          padding: EdgeInsets.all(s * 0.06),
          child: SvgPicture.string(
            _iconSvg,
            semanticsLabel: 'PHANUKNGAN Splash Icon',
          ),
        ),
        SizedBox(height: s * 0.2),
        Text(
          'PHANUKNGAN',
          style: GoogleFonts.montserrat(
            fontSize: s * 0.26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        SizedBox(height: s * 0.08),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: s * 0.15, height: 1, color: PhanuknganColors.gold),
            SizedBox(width: s * 0.06),
            Text(
              'ພະນັກງານ',
              style: GoogleFonts.notoSansLao(
                fontSize: s * 0.16,
                fontWeight: FontWeight.w700,
                color: PhanuknganColors.gold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: s * 0.06),
            Container(width: s * 0.15, height: 1, color: PhanuknganColors.gold),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// SVG SOURCE — LIGHT (Navy BG)
// ==========================================
const String _iconSvg = '''
<svg viewBox="0 0 96 96" xmlns="http://www.w3.org/2000/svg">
  <rect width="96" height="96" rx="22" fill="#0B2545"/>
  <!-- Gold arc (support/hand) -->
  <path d="M12 82 Q48 63 84 82"
    fill="none" stroke="#C89B3C"
    stroke-width="4.5" stroke-linecap="round"/>
  <!-- Left person — Gold -->
  <circle cx="22" cy="50" r="9" fill="#C89B3C"/>
  <path d="M8 78 Q22 66 36 78" fill="#C89B3C"/>
  <!-- Right person — Gold -->
  <circle cx="74" cy="50" r="9" fill="#C89B3C"/>
  <path d="M60 78 Q74 66 88 78" fill="#C89B3C"/>
  <!-- Center person — White (Leader) -->
  <circle cx="48" cy="38" r="13" fill="#FFFFFF"/>
  <path d="M26 78 Q48 63 70 78" fill="#FFFFFF"/>
  <!-- Tie detail -->
  <polygon points="47,52 49,52 51,64 48,67 45,64" fill="#0B2545" opacity="0.35"/>
</svg>
''';

// ==========================================
// SVG SOURCE — DARK MODE (slightly lighter Navy)
// ==========================================
const String _iconSvgDark = '''
<svg viewBox="0 0 96 96" xmlns="http://www.w3.org/2000/svg">
  <rect width="96" height="96" rx="22" fill="#1E3A5F"/>
  <path d="M12 82 Q48 63 84 82"
    fill="none" stroke="#C89B3C"
    stroke-width="4.5" stroke-linecap="round"/>
  <circle cx="22" cy="50" r="9" fill="#C89B3C"/>
  <path d="M8 78 Q22 66 36 78" fill="#C89B3C"/>
  <circle cx="74" cy="50" r="9" fill="#C89B3C"/>
  <path d="M60 78 Q74 66 88 78" fill="#C89B3C"/>
  <circle cx="48" cy="38" r="13" fill="#FFFFFF"/>
  <path d="M26 78 Q48 63 70 78" fill="#FFFFFF"/>
  <polygon points="47,52 49,52 51,64 48,67 45,64" fill="#1E3A5F" opacity="0.35"/>
</svg>
''';

// ==========================================
// USAGE EXAMPLES
// ==========================================
//
// 1. App Bar / Header:
// AppBar(
//   title: PhanuknganLogo(
//     variant: LogoVariant.full,
//     size: 38,
//   ),
// )
//
// 2. Splash Screen:
// Container(
//   color: PhanuknganColors.navy,
//   child: Center(
//     child: PhanuknganLogo(
//       variant: LogoVariant.splash,
//       size: 100,
//     ),
//   ),
// )
//
// 3. Bottom Nav / Notification Icon:
// PhanuknganLogo(
//   variant: LogoVariant.iconOnly,
//   size: 28,
// )
//
// 4. Dark Header:
// PhanuknganLogo(
//   variant: LogoVariant.full,
//   size: 38,
//   isDark: true,
// )
