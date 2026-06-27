import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ==========================================
// GLASS CARD — Frosted glass effect
// ==========================================
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double blur;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.blur = 12,
    this.borderRadius = AppTheme.radius,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.08),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 0.8,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ==========================================
// SHIMMER LOADING EFFECT
// ==========================================
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: [
              AppTheme.border.withOpacity(0.3),
              AppTheme.border.withOpacity(0.8),
              AppTheme.border.withOpacity(0.3),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// FLOATING PARTICLES BACKGROUND
// ==========================================
class FloatingParticles extends StatefulWidget {
  final Color color;
  final int count;

  const FloatingParticles({
    super.key,
    this.color = AppTheme.primary,
    this.count = 12,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _Particle {
  double x, y, size, speed, opacity;
  _Particle(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        size = r.nextDouble() * 4 + 2,
        speed = r.nextDouble() * 0.003 + 0.001,
        opacity = r.nextDouble() * 0.4 + 0.1;
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => _Particle(_rand));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _ctrl.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.y -= p.speed;
          if (p.y < -0.05) {
            p.y = 1.05;
            p.x = _rand.nextDouble();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(_particles, widget.color),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  _ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        Paint()..color = color.withOpacity(p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ==========================================
// NEON BUTTON — Glowing tap effect
// ==========================================
class NeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  final bool small;

  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.onTap,
    this.loading = false,
    this.small = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.loading) widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: AppTheme.fast,
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, child) => Container(
            padding: widget.small
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_glow.value * 0.6),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: widget.small ? 16 : 18,
                  color: Colors.white,
                ),
              if (widget.icon != null || widget.loading)
                const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTheme.laoText(
                  size: widget.small ? 12 : 14,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WEBHOOK STATUS BADGE — Animated
// ==========================================
class WebhookBadge extends StatefulWidget {
  final bool connected;

  const WebhookBadge({super.key, required this.connected});

  @override
  State<WebhookBadge> createState() => _WebhookBadgeState();
}

class _WebhookBadgeState extends State<WebhookBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.connected ? AppTheme.success : AppTheme.warning;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5 + _ctrl.value * 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              widget.connected ? 'n8n ເຊື່ອມແລ້ວ' : 'ລໍຖ້າ n8n...',
              style: AppTheme.laoCaption(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// GRADIENT HEADER
// ==========================================
class GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Widget? trailing;
  final double height;

  const GradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.trailing,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          // Particles
          Positioned.fill(
            child: FloatingParticles(
              color: Colors.white,
              count: 10,
            ),
          ),
          // Curved bottom edge
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.laoDisplay(
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.laoText(
                          size: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ANIMATED COUNTER
// ==========================================
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle style;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _count;
  int _prev = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppTheme.slow);
    _count = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _ctrl, curve: AppTheme.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _prev = old.value;
      _count = IntTween(begin: _prev, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: AppTheme.easeOut),
      );
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _count,
      builder: (_, __) => Text('${_count.value}', style: widget.style),
    );
  }
}

// ==========================================
// RIPPLE TAP
// ==========================================
class RippleTap extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  const RippleTap({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.radius = AppTheme.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: (color ?? AppTheme.primary).withOpacity(0.12),
        highlightColor: (color ?? AppTheme.primary).withOpacity(0.06),
        child: child,
      ),
    );
  }
}
