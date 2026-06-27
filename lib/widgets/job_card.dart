import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final int delay;

  const JobCard({super.key, required this.job, this.delay = 0});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _pressed = false;

  Color get _statusColor {
    switch (widget.job['status']) {
      case 'doing': return AppTheme.primary;
      case 'done':  return AppTheme.success;
      case 'wait':  return AppTheme.warning;
      default:      return AppTheme.textMuted;
    }
  }

  String get _statusLabel {
    switch (widget.job['status']) {
      case 'doing': return 'ກຳລັງດຳເນີນ';
      case 'done':  return 'ສຳເລັດ';
      case 'wait':  return 'ລໍຖ້າ';
      default:      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppTheme.fast,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.border, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (widget.job['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  widget.job['icon'] as IconData,
                  color: widget.job['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job['title'],
                      style: AppTheme.laoText(
                        size: 13,
                        weight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.job['team']} · ${widget.job['time']}',
                      style: AppTheme.laoCaption(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _statusLabel,
                  style: AppTheme.laoCaption(color: _statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate(delay: Duration(milliseconds: widget.delay))
    .fadeIn(duration: 350.ms)
    .slideX(begin: 0.15, end: 0, duration: 350.ms, curve: AppTheme.easeOut);
  }
}
