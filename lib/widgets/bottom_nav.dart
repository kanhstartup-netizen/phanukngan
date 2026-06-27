import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhanuknganBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PhanuknganBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.8)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,     label: 'ຫຼັກ',      index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.chat_rounded,     label: 'Chat',     index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.auto_awesome_rounded, label: 'ຜົນ',       index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.people_rounded,   label: 'ທີມ',      index: 3, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.15 : 1.0,
              duration: AppTheme.fast,
              child: Icon(
                icon,
                size: 22,
                color: active ? AppTheme.primary : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTheme.laoCaption(
                color: active ? AppTheme.primary : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
