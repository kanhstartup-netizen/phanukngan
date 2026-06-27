// ============================================================
// stat_card.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;
  final int delay;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.laoCaption(),
                ),
                Text(
                  value,
                  style: AppTheme.laoDisplay(size: 22, color: color),
                ),
                Text(
                  sub,
                  style: AppTheme.laoCaption(),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate(delay: Duration(milliseconds: delay))
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: AppTheme.easeOut);
  }
}
