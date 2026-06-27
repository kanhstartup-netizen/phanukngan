// result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final String jobId;
  const ResultScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text('ຜົນໄດ້ຮັບ', style: AppTheme.laoText(size: 16, weight: FontWeight.w600))),
      body: ListView(padding: const EdgeInsets.all(AppTheme.md), children: [
        _ResultCard(
          title: 'ຄລິບໂປຣໂມດສິນຄ້າ',
          status: 'done',
          detail: 'ຄລິບ 0:45 · 1080p · Subtitle + Logo + Watermark',
          caption: 'ສິນຄ້າໃໝ່ຂອງເຮົາມາແລ້ວ! ຄຸນນະພາບດີ ລາຄາຫຼຸດ ຈຳກັດ!\n#ສິນຄ້າລາວ #ຄຸນນະພາບດີ',
          icon: Icons.videocam_rounded,
          color: AppTheme.purple,
          delay: 0,
          onSchedule: () => context.go('/scheduler'),
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'ຮູບສິນຄ້າ + Watermark',
          status: 'done',
          detail: '1080x1080px · Watermark + Contact ໃສ່ແລ້ວ',
          caption: 'ສິນຄ້າໃໝ່ລ໋ອດນີ້ ສວຍງາມ ທົນທານ!\nTel: 020-XXXX #ສິນຄ້ານຳເຂົ້າ',
          icon: Icons.photo_camera_rounded,
          color: AppTheme.primary,
          delay: 100,
          onSchedule: () => context.go('/scheduler'),
        ),
        const SizedBox(height: 12),
        _ResultCard(
          title: 'Banner ການຕະຫຼາດ',
          status: 'doing',
          detail: 'ກຳລັງດຳເນີນ... 70%',
          caption: '',
          icon: Icons.campaign_rounded,
          color: AppTheme.warning,
          delay: 200,
          onSchedule: null,
        ),
      ]),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title, status, detail, caption;
  final IconData icon;
  final Color color;
  final int delay;
  final VoidCallback? onSchedule;

  const _ResultCard({
    required this.title, required this.status, required this.detail,
    required this.caption, required this.icon, required this.color,
    required this.delay, required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'done';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: isDone ? color.withOpacity(0.3) : AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTheme.laoText(size: 13, weight: FontWeight.w500))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDone ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            child: Text(isDone ? 'ສຳເລັດ' : 'ກຳລັງດຳເນີນ',
              style: AppTheme.laoCaption(color: isDone ? AppTheme.success : AppTheme.warning))),
        ]),
        const SizedBox(height: 12),
        Container(height: 80, decoration: BoxDecoration(
          color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 28, color: color.withOpacity(0.4)),
            const SizedBox(height: 4),
            Text(detail, style: AppTheme.laoCaption(), textAlign: TextAlign.center),
          ]))),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Caption:', style: AppTheme.laoCaption()),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Text(caption, style: AppTheme.laoText(size: 12, color: AppTheme.textSecondary, height: 1.6))),
        ],
        if (isDone) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text('ດາວໂຫລດ', style: AppTheme.laoText(size: 12)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: onSchedule,
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: Text('ກຳນົດໂພສ', style: AppTheme.laoText(size: 12, color: Colors.white)))),
          ]),
        ],
      ]),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 400.ms).slideY(begin: 0.2, curve: AppTheme.easeOut);
  }
}

// ============================================================
// scheduler_screen.dart
// ============================================================
class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});
  @override State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final Map<String, bool> _platforms = {'Facebook': true, 'TikTok': true, 'Instagram': false, 'YouTube': false};
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text('Social Scheduler', style: AppTheme.laoText(size: 16, weight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ຄລິບໂປຣໂມດສິນຄ້າ', style: AppTheme.laoText(size: 15, weight: FontWeight.w600))
            .animate().fadeIn(),
          const SizedBox(height: 14),
          Text('ເລືອກ Platform:', style: AppTheme.laoText(size: 13, weight: FontWeight.w500)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: _platforms.entries.map((e) =>
            GestureDetector(
              onTap: () => setState(() => _platforms[e.key] = !e.value),
              child: AnimatedContainer(
                duration: AppTheme.fast,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: e.value ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: e.value ? AppTheme.primary : AppTheme.border,
                    width: e.value ? 1.5 : 0.8)),
                child: Text(e.key, style: AppTheme.laoText(size: 13,
                  color: e.value ? AppTheme.primary : AppTheme.textSecondary,
                  weight: e.value ? FontWeight.w500 : FontWeight.normal))),
            )).toList()),
          const SizedBox(height: 20),
          Text('ກຳນົດເວລາ:', style: AppTheme.laoText(size: 13, weight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppTheme.border)),
            child: Row(children: [
              const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 12),
              Text('28 ມິຖຸນາ 2026 · 09:00', style: AppTheme.laoText(size: 14)),
            ])),
          const SizedBox(height: 24),
          if (_confirmed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppTheme.success.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
                const SizedBox(width: 10),
                Text('ກຳນົດໂພສສຳເລັດ! ຈະໂພສ 28 ມິ.ຖ. 09:00 ອັດຕະໂນມັດ',
                  style: AppTheme.laoText(size: 13, color: AppTheme.success)),
              ]),
            ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9))
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _confirmed = true),
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text('ຢືນຢັນ Schedule', style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)))),
        ]),
      ),
    );
  }
}

// ============================================================
// team_screen.dart
// ============================================================
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  final _teams = const [
    {'name': 'Video Editor',    'role': 'ຕັດຄລິບ · Subtitle · Logo', 'count': '20', 'color': AppTheme.purple},
    {'name': 'Graphic Designer','role': 'ແຕ່ງຮູບ · Banner · Poster',  'count': '20', 'color': AppTheme.primary},
    {'name': 'Content Creator', 'role': 'Caption · ພາສາລາວ 100%',     'count': '20', 'color': AppTheme.success},
    {'name': 'Marketing',       'role': 'ວາງແຜນ · ໂປຣໂມດ',          'count': '15', 'color': AppTheme.warning},
    {'name': 'Social Media',    'role': 'ໂພສ FB · TikTok · IG',      'count': '15', 'color': AppTheme.accent},
    {'name': 'QC Team',         'role': 'ກວດຄຸນນະພາບທຸກຊິ້ນ',       'count': '10', 'color': AppTheme.danger},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text('ທີມງານ 100 ຄົນ', style: AppTheme.laoText(size: 16, weight: FontWeight.w600))),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15),
        itemCount: _teams.length,
        itemBuilder: (_, i) {
          final t = _teams[i];
          final c = t['color'] as Color;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.border, width: 0.8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(child: Text(
                  (t['name'] as String).substring(0, 2).toUpperCase(),
                  style: AppTheme.laoText(size: 14, weight: FontWeight.w700, color: c)))),
              const SizedBox(height: 10),
              Text(t['name'] as String, style: AppTheme.laoText(size: 13, weight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(t['role'] as String, style: AppTheme.laoCaption(), maxLines: 2),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                child: Text('${t['count']} ຄົນ', style: AppTheme.laoCaption(color: c))),
            ]),
          ).animate(delay: Duration(milliseconds: i * 80))
            .fadeIn(duration: 350.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: AppTheme.easeOut);
        },
      ),
    );
  }
}
