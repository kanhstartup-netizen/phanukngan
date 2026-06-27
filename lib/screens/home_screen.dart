import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/n8n_service.dart';
import '../widgets/effects/ui_effects.dart';
import '../widgets/brand/phanukngan_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  bool _n8nConnected = false;
  bool _checkingN8n = true;

  final _stats = {'total': 47, 'active': 3, 'done': 44, 'team': 100};
  final _jobs = [
    {'id':'001','title':'ຕັດຄລິບໂປຣໂມດສິນຄ້າ','team':'Video Editor','time':'2 ຊົ່ວໂມງກ່ອນ','status':'doing','icon':Icons.videocam_rounded,'color':AppTheme.purple},
    {'id':'002','title':'ແຕ່ງຮູບ + Watermark','team':'Graphic Design','time':'4 ຊົ່ວໂມງກ່ອນ','status':'done','icon':Icons.photo_camera_rounded,'color':AppTheme.primary},
    {'id':'003','title':'ຂຽນ Caption + ໂພສ Facebook','team':'Content Creator','time':'5 ຊົ່ວໂມງກ່ອນ','status':'done','icon':Icons.edit_rounded,'color':AppTheme.success},
    {'id':'004','title':'ອອກແບບ Banner ການຕະຫຼາດ','team':'Marketing','time':'ລໍຖ້າຢືນຢັນ','status':'wait','icon':Icons.campaign_rounded,'color':AppTheme.warning},
  ];

  @override
  void initState() { super.initState(); _pingN8n(); }

  Future<void> _pingN8n() async {
    final ok = await N8nService.instance.ping();
    if (mounted) setState(() { _n8nConnected = ok; _checkingN8n = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDark)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _N8nStatusBar(connected: _n8nConnected, loading: _checkingN8n, onRetry: _pingN8n)
                .animate(delay: 100.ms).fadeIn().slideY(begin: -0.3),
              const SizedBox(height: 16),
              _buildStatGrid(),
              const SizedBox(height: 22),
              Row(children: [
                Text('ສ້າງວຽກໃໝ່', style: AppTheme.laoText(size: 15, weight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/new-job'),
                  child: Text('ທັງໝົດ', style: AppTheme.laoText(size: 12, color: AppTheme.primary))),
              ]).animate(delay: 500.ms).fadeIn().slideX(begin: -0.2),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(height: 22),
              Text('ວຽກລ່າສຸດ', style: AppTheme.laoText(size: 15, weight: FontWeight.w600))
                .animate(delay: 700.ms).fadeIn(),
              const SizedBox(height: 10),
              ..._jobs.asMap().entries.map((e) => _BeautifulJobCard(
                job: e.value, delay: 750 + e.key * 80,
                onTap: () => context.go('/result'))),
              const SizedBox(height: 110),
            ])),
          ),
        ]),
        Positioned(bottom: 80, left: 16, right: 16, child: _buildFAB()),
        Positioned(bottom: 0, left: 0, right: 0,
          child: _BeautifulBottomNav(currentIndex: _tab, onTap: (i) {
            setState(() => _tab = i);
            switch (i) {
              case 1: context.go('/chat'); break;
              case 2: context.go('/result'); break;
              case 3: context.go('/team'); break;
            }
          })),
      ]),
    );
  }

  // ---- HEADER ----
  Widget _buildHeader(bool isDark) {
    return SizedBox(
      height: 210,
      child: Stack(children: [
        Container(
          height: 210,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0B2545), Color(0xFF1A73E8), Color(0xFF0097A7)],
            ),
          ),
        ),
        const Positioned.fill(child: FloatingParticles(color: Colors.white, count: 12)),
        // ວົງກົມ Deco
        Positioned(top: -30, right: -30, child: Container(
          width: 130, height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.08))),
        )),
        // Curve bottom
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
        )),
        // Content
        Positioned(
          left: 20, right: 20, bottom: 36, top: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ---- LOGO ຢູ່ໃນ Header ----
                    PhanuknganLogo(
                      variant: LogoVariant.full,
                      size: 44,
                      isDark: true,
                    )
                    .animate().fadeIn(delay: 200.ms)
                    .slideX(begin: -0.2, duration: 400.ms),
                    const SizedBox(height: 4),
                    Text(
                      'ສະບາຍດີ, ເຈົ້ານາຍ!',
                      style: AppTheme.laoText(
                        size: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ).animate(delay: 350.ms).fadeIn(),
                  ],
                ),
              ),
              // Team badge
              GestureDetector(
                onTap: () => context.go('/team'),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.people_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 5),
                    Text('100 ຄົນ', style: AppTheme.laoText(size: 12, color: Colors.white, weight: FontWeight.w500)),
                  ]),
                ),
              ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStatGrid() {
    final items = [
      ('ວຽກທັງໝົດ', _stats['total']!, AppTheme.primary, Icons.work_rounded, 50.ms),
      ('ດຳເນີນຢູ່', _stats['active']!, AppTheme.warning, Icons.pending_rounded, 150.ms),
      ('ສຳເລັດແລ້ວ', _stats['done']!, AppTheme.success, Icons.check_circle_rounded, 250.ms),
      ('ພະນັກງານ', _stats['team']!, AppTheme.purple, Icons.people_rounded, 350.ms),
    ];
    return GridView.count(
      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
      childAspectRatio: 1.55, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        final (label, val, color, icon, delay) = item;
        return _StatCard(label: label, value: val, color: color, icon: icon, delay: delay);
      }).toList());
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.videocam_rounded, 'ຕັດຄລິບ', AppTheme.purple),
      (Icons.photo_camera_rounded, 'ແຕ່ງຮູບ', AppTheme.primary),
      (Icons.edit_rounded, 'ຂຽນໂພສ', AppTheme.success),
      (Icons.campaign_rounded, 'Banner', AppTheme.warning),
      (Icons.chat_rounded, 'AI Chat', AppTheme.accent),
    ];
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (icon, label, color) = actions[i];
          return _QuickActionChip(
            icon: icon, label: label, color: color,
            delay: 550 + i * 60,
            onTap: () => i == 4 ? context.go('/chat') : context.go('/new-job'));
        }),
    );
  }

  Widget _buildFAB() => NeonButton(
    label: 'ສ້າງວຽກໃໝ່ + ສົ່ງ n8n',
    icon: Icons.add_rounded,
    color: AppTheme.primary,
    onTap: () => context.go('/chat'))
  .animate(delay: 900.ms)
  .scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 700.ms)
  .fadeIn(duration: 400.ms);
}

// ---- N8N STATUS BAR ----
class _N8nStatusBar extends StatelessWidget {
  final bool connected, loading;
  final VoidCallback onRetry;
  const _N8nStatusBar({required this.connected, required this.loading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppTheme.success : AppTheme.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: color.withOpacity(0.25))),
      child: Row(children: [
        Icon(Icons.hub_rounded, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(child: loading
          ? Text('ກຳລັງກວດ n8n...', style: AppTheme.laoCaption(color: AppTheme.textMuted))
          : Text(connected
              ? 'n8n AI Brain ເຊື່ອມສຳເລັດ — ອັດຕະໂນມັດ 100%'
              : 'n8n ຍັງບໍ່ເຊື່ອມ — ກົດທົດລອງໃໝ່',
              style: AppTheme.laoCaption(color: color))),
        if (!connected && !loading) GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            child: Text('ລອງໃໝ່', style: AppTheme.laoCaption(color: color)))),
        if (loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
      ]));
  }
}

// ---- STAT CARD ----
class _StatCard extends StatelessWidget {
  final String label; final int value; final Color color;
  final IconData icon; final Duration delay;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border, width: 0.8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 17)),
            const Spacer(),
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedCounter(value: value, style: AppTheme.laoDisplay(size: 24, color: color)),
            Text(label, style: AppTheme.laoCaption()),
          ]),
        ]))
    .animate(delay: delay).fadeIn(duration: 400.ms)
    .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: AppTheme.easeOut);
  }
}

// ---- QUICK ACTION CHIP ----
class _QuickActionChip extends StatefulWidget {
  final IconData icon; final String label; final Color color;
  final int delay; final VoidCallback onTap;
  const _QuickActionChip({required this.icon, required this.label, required this.color, required this.delay, required this.onTap});
  @override State<_QuickActionChip> createState() => _QCS();
}
class _QCS extends State<_QuickActionChip> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(scale: _p ? 0.88 : 1.0, duration: AppTheme.fast,
        child: AnimatedContainer(duration: AppTheme.fast, width: 74,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_p ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: widget.color.withOpacity(_p ? 0.6 : 0.25), width: 0.8)),
          child: Column(children: [
            Icon(widget.icon, color: widget.color, size: 22),
            const SizedBox(height: 5),
            Text(widget.label, style: AppTheme.laoCaption(color: widget.color), textAlign: TextAlign.center),
          ]))))
    .animate(delay: Duration(milliseconds: widget.delay))
    .fadeIn(duration: 350.ms).slideY(begin: 0.4, end: 0, duration: 350.ms, curve: AppTheme.easeOut);
  }
}

// ---- JOB CARD ----
class _BeautifulJobCard extends StatefulWidget {
  final Map<String, dynamic> job; final int delay; final VoidCallback onTap;
  const _BeautifulJobCard({required this.job, required this.delay, required this.onTap});
  @override State<_BeautifulJobCard> createState() => _BJC();
}
class _BJC extends State<_BeautifulJobCard> {
  bool _p = false;
  Color get _sc => switch (widget.job['status']) {'doing'=>AppTheme.primary,'done'=>AppTheme.success,'wait'=>AppTheme.warning,_=>AppTheme.textMuted};
  String get _sl => switch (widget.job['status']) {'doing'=>'ດຳເນີນ','done'=>'ສຳເລັດ','wait'=>'ລໍຖ້າ',_=>''};

  @override
  Widget build(BuildContext context) {
    final color = widget.job['color'] as Color;
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(scale: _p ? 0.97 : 1.0, duration: AppTheme.fast,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: _p ? color.withOpacity(0.4) : AppTheme.border, width: 0.8)),
          child: Row(children: [
            Container(width: 4, height: 62,
              decoration: BoxDecoration(color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radius),
                  bottomLeft: Radius.circular(AppTheme.radius)))),
            Padding(padding: const EdgeInsets.all(12),
              child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(widget.job['icon'] as IconData, color: color, size: 20))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.job['title'], style: AppTheme.laoText(size: 13, weight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${widget.job['team']} · ${widget.job['time']}', style: AppTheme.laoCaption()),
              ]))),
            Padding(padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                child: Text(_sl, style: AppTheme.laoCaption(color: _sc)))),
          ]))))
    .animate(delay: Duration(milliseconds: widget.delay))
    .fadeIn(duration: 350.ms).slideX(begin: 0.15, end: 0, duration: 350.ms, curve: AppTheme.easeOut);
  }
}

// ---- BOTTOM NAV ----
class _BeautifulBottomNav extends StatelessWidget {
  final int currentIndex; final ValueChanged<int> onTap;
  const _BeautifulBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'ໜ້າຫຼັກ'),
      (Icons.chat_rounded, 'ສົນທະນາ'),
      (Icons.sparkles_rounded, 'ຜົນງານ'),
      (Icons.people_rounded, 'ທີມງານ'),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5))),
      child: Row(children: items.asMap().entries.map((e) {
        final active = e.key == currentIndex;
        final (icon, label) = e.value;
        return Expanded(child: GestureDetector(
          onTap: () => onTap(e.key),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(duration: AppTheme.fast,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedScale(scale: active ? 1.2 : 1.0, duration: AppTheme.fast,
                child: Icon(icon, size: 22, color: active ? AppTheme.primary : AppTheme.textMuted)),
              const SizedBox(height: 3),
              Text(label, style: AppTheme.laoCaption(color: active ? AppTheme.primary : AppTheme.textMuted)),
            ]))));
      }).toList()));
  }
}
