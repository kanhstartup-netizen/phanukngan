import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/brand/phanukngan_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhanuknganColors.navy,
      body: Stack(
        children: [
          // ---- ວົງກົມ Deco ----
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08), width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PhanuknganColors.gold.withOpacity(0.08),
              ),
            ),
          ),
          // ---- Content ----
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Splash ມີ Animation
                PhanuknganLogo(
                  variant: LogoVariant.splash,
                  size: 110,
                )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

                const SizedBox(height: 60),

                // Loading Dots
                _LoadingDots()
                .animate(delay: 900.ms)
                .fadeIn(duration: 400.ms),

                const SizedBox(height: 16),
                Text(
                  'ທີມງານ 100 ຄົນ ພ້ອມຮັບຄຳສັ່ງ',
                  style: AppTheme.laoText(
                    size: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Loading Dots ----
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _controllers.add(c);
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8 + _controllers[i].value * 10,
            decoration: BoxDecoration(
              color: PhanuknganColors.gold
                  .withOpacity(0.4 + _controllers[i].value * 0.6),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}
