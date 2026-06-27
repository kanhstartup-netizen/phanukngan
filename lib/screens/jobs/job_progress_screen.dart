import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/brand/phanukngan_logo.dart';

class JobProgressScreen extends StatefulWidget {
  final String jobId;
  const JobProgressScreen({super.key, required this.jobId});
  @override State<JobProgressScreen> createState() => _JobProgressScreenState();
}

class _JobProgressScreenState extends State<JobProgressScreen> {
  Job? _job;
  bool _loading = true;
  RealtimeChannel? _channel;

  // ຂັ້ນຕອນທັງໝົດ
  final _steps = [
    _Step('ຮັບຄຳສັ່ງ',      'pending',  Icons.inbox_rounded),
    _Step('ທີມກຳລັງດຳເນີນ', 'doing',    Icons.work_rounded),
    _Step('QC ກວດຄຸນນະພາບ', 'qc',       Icons.fact_check_rounded),
    _Step('ສຳເລັດແລ້ວ',     'done',     Icons.check_circle_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _startRealtime();
  }

  Future<void> _load() async {
    final data = await Supabase.instance.client
        .from('jobs').select().eq('id', widget.jobId).single();
    if (mounted) setState(() { _job = Job.fromMap(data); _loading = false; });
  }

  void _startRealtime() {
    _channel = SupabaseService.instance.listenJobs((job) {
      if (job.id == widget.jobId && mounted) {
        setState(() => _job = job);
      }
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  int get _currentStep {
    return switch (_job?.status) {
      'pending' => 0,
      'doing'   => 1,
      'qc'      => 2,
      'done'    => 3,
      _         => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: PhanuknganColors.navy,
        leading: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
        title: Row(children: [
          PhanuknganLogo(variant: LogoVariant.iconOnly, size: 28, isDark: true),
          const SizedBox(width: 10),
          Text('ຄວາມຄືບໜ້າ',
            style: AppTheme.laoText(size: 15, weight: FontWeight.w600, color: Colors.white)),
        ]),
        actions: [
          // Realtime indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _RealtimeDot(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final job = _job!;
    final isDone = job.status == 'done';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ---- Job Card ----
        _JobInfoCard(job: job).animate().fadeIn().slideY(begin: -0.1),

        const SizedBox(height: 24),

        // ---- Stepper ----
        Text('ຂັ້ນຕອນດຳເນີນງານ',
          style: AppTheme.laoText(size: 14, weight: FontWeight.w600))
        .animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 16),

        ...List.generate(_steps.length, (i) {
          final step   = _steps[i];
          final isActive  = i == _currentStep;
          final isDoneStep = i < _currentStep || isDone;
          final isFuture  = i > _currentStep && !isDone;

          return _StepRow(
            step:      step,
            index:     i,
            isActive:  isActive && !isDone,
            isDone:    isDoneStep,
            isFuture:  isFuture,
            isLast:    i == _steps.length - 1,
            delay:     100 + i * 80,
          );
        }),

        const SizedBox(height: 24),

        // ---- Caption (ຖ້າສຳເລັດ) ----
        if (job.caption != null) ...[
          Text('Caption ທີ່ Claude ຂຽນ',
            style: AppTheme.laoText(size: 14, weight: FontWeight.w600))
          .animate(delay: 400.ms).fadeIn(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.border)),
            child: Text(job.caption!,
              style: AppTheme.laoText(size: 13, height: 1.7, color: AppTheme.textSecondary)),
          ).animate(delay: 450.ms).fadeIn(),
          const SizedBox(height: 24),
        ],

        // ---- Actions ----
        if (isDone) ...[
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => context.go('/scheduler'),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text('ກຳນົດໂພສ',
                style: AppTheme.laoText(size: 13, weight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text('ດາວໂຫລດ', style: AppTheme.laoText(size: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
            )),
          ]).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),
        ],
      ]),
    );
  }
}

// ---- Job Info Card ----
class _JobInfoCard extends StatelessWidget {
  final Job job;
  const _JobInfoCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final color = switch (job.type) {
      'video'   => AppTheme.purple,
      'graphic' => AppTheme.primary,
      'content' => AppTheme.success,
      _         => AppTheme.warning,
    };
    final icon = switch (job.type) {
      'video'   => Icons.videocam_rounded,
      'graphic' => Icons.photo_camera_rounded,
      'content' => Icons.edit_rounded,
      _         => Icons.campaign_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(job.titleLao ?? job.title,
            style: AppTheme.laoText(size: 14, weight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('ສ້າງ ${_ago(job.createdAt)}',
            style: AppTheme.laoCaption()),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _statusColor(job.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
          child: Text(job.statusLao,
            style: AppTheme.laoCaption(color: _statusColor(job.status))),
        ),
      ]),
    );
  }

  Color _statusColor(String s) => switch (s) {
    'doing' => AppTheme.primary,
    'qc'    => AppTheme.warning,
    'done'  => AppTheme.success,
    _       => AppTheme.textMuted,
  };

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes} ນາທີກ່ອນ';
    if (d.inHours   < 24) return '${d.inHours} ຊົ່ວໂມງກ່ອນ';
    return '${d.inDays} ວັນກ່ອນ';
  }
}

// ---- Step Row ----
class _Step {
  final String label;
  final String status;
  final IconData icon;
  const _Step(this.label, this.status, this.icon);
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final int index, delay;
  final bool isActive, isDone, isFuture, isLast;

  const _StepRow({
    required this.step, required this.index, required this.delay,
    required this.isActive, required this.isDone,
    required this.isFuture, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppTheme.success : isActive ? AppTheme.primary : AppTheme.textMuted;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        // Circle
        AnimatedContainer(
          duration: AppTheme.normal,
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.success.withOpacity(0.1)
                : isActive
                    ? AppTheme.primary.withOpacity(0.1)
                    : AppTheme.surfaceAlt,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? AppTheme.success : isActive ? AppTheme.primary : AppTheme.border,
              width: isActive ? 2 : 1)),
          child: isActive
              ? SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                  ))
              : Icon(
                  isDone ? Icons.check_rounded : step.icon,
                  color: color,
                  size: 18),
        ),
        // Line
        if (!isLast) AnimatedContainer(
          duration: AppTheme.slow,
          width: 2, height: 44,
          color: isDone ? AppTheme.success.withOpacity(0.4) : AppTheme.border,
        ),
      ]),

      const SizedBox(width: 14),

      Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: isLast ? 0 : 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step.label,
              style: AppTheme.laoText(
                size: 13,
                weight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isFuture ? AppTheme.textMuted : AppTheme.textPrimary)),
            if (isActive)
              Text('ກຳລັງດຳເນີນ...',
                style: AppTheme.laoCaption(color: AppTheme.primary))
            else if (isDone)
              Text('ສຳເລັດ',
                style: AppTheme.laoCaption(color: AppTheme.success)),
          ]),
        ),
      ),
    ]).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.1);
  }
}

// ---- Realtime Dot ----
class _RealtimeDot extends StatefulWidget {
  @override State<_RealtimeDot> createState() => _RDState();
}
class _RDState extends State<_RealtimeDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: 1000.ms)..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.4 + _c.value * 0.6),
          shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('LIVE', style: AppTheme.laoCaption(color: Colors.white.withOpacity(0.8))),
    ]),
  );
}
