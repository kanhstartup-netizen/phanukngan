// lib/screens/khopkhua_screen.dart
// ==========================================
// ທີມ Khopkhua — ນາຍໜ້າອະສັງຫາ 4 ເມືອງ
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class KhopkhuaScreen extends StatefulWidget {
  const KhopkhuaScreen({super.key});
  @override State<KhopkhuaScreen> createState() => _KhopkhuaScreenState();
}

class _KhopkhuaScreenState extends State<KhopkhuaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  // ຂໍ້ມູນ fallback ຖ້າ Supabase ໂຫລດບໍ່ໄດ້
  final _fallback = [
    {'emoji':'🔍','name_lao':'ນ້ອງຫາຊັບ',   'duty_lao':'ຫາຊັບໃໝ່ + ເກັບຂໍ້ມູນ','ai_engine':'gemini','role_key':'finder',  'districts':['ຈັນທະບູລີ','ສີໂຄດຕະບອງ','ໄຊເສດຖາ','ສີສັດຕະນາກ']},
    {'emoji':'✅','name_lao':'ນ້ອງກວດຂໍ້ມູນ','duty_lao':'ກວດ 15 ລາຍການໃຫ້ຄົບ','ai_engine':'claude', 'role_key':'checker', 'districts':[]},
    {'emoji':'✍️','name_lao':'ນ້ອງຂຽນໂພສ',  'duty_lao':'ຂຽນໂພສ + Caption','ai_engine':'claude', 'role_key':'writer',  'districts':[]},
    {'emoji':'💬','name_lao':'ນ້ອງຕອບລູກຄ້າ','duty_lao':'ຕອບ inbox/comment','ai_engine':'claude','role_key':'support', 'districts':[]},
    {'emoji':'📅','name_lao':'ນ້ອງນັດໝາຍ',  'duty_lao':'ນັດລູກຄ້າເບິ່ງຊັບ','ai_engine':'gemini','role_key':'booker',  'districts':[]},
    {'emoji':'📌','name_lao':'ນ້ອງຕິດຕາມ',  'duty_lao':'ຕິດຕາມລູກຄ້າ','ai_engine':'gemini',   'role_key':'tracker', 'districts':[]},
    {'emoji':'📊','name_lao':'ນ້ອງລາຍງານ',  'duty_lao':'ສະຫຼຸບລາຍງານ','ai_engine':'claude',    'role_key':'reporter','districts':[]},
    {'emoji':'👑','name_lao':'ຫົວໜ້າທີມ',   'duty_lao':'ແບ່ງ 4 ເມືອງ + WhatsApp','ai_engine':'claude','role_key':'leader','districts':['ຈັນທະບູລີ','ສີໂຄດຕະບອງ','ໄຊເສດຖາ','ສີສັດຕະນາກ']},
  ];

  final _districts = ['ຈັນທະບູລີ','ສີໂຄດຕະບອງ','ໄຊເສດຖາ','ສີສັດຕະນາກ'];
  final _districtIcons = ['🏛️','🏙️','🏢','🌆'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    try {
      final data = await Supabase.instance.client
          .from('team_members')
          .select()
          .order('sort_order');
      if (mounted) setState(() { _members = List<Map<String,dynamic>>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _members = _fallback; _loading = false; });
    }
  }

  Color _aiColor(String? engine) => switch (engine) {
    'claude'  => const Color(0xFFD97706),
    'gemini'  => AppTheme.primary,
    'openai'  => AppTheme.success,
    _         => AppTheme.textMuted,
  };

  String _aiLabel(String? engine) => switch (engine) {
    'claude'  => 'Claude',
    'gemini'  => 'Gemini',
    'openai'  => 'OpenAI',
    _         => 'AI',
  };

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF0B2545),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF0B2545), Color(0xFF1565C0), Color(0xFF00897B)])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('🏠', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Khopkhua Team',
                          style: AppTheme.laoText(size: 18, weight: FontWeight.w700, color: Colors.white)),
                        Text('ນາຍໜ້າອະສັງຫາ ນະຄອນຫລວງວຽງຈັນ',
                          style: AppTheme.laoText(size: 11, color: Colors.white.withOpacity(0.75))),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: _districts.asMap().entries.map((e) =>
                      Expanded(child: Container(
                        margin: EdgeInsets.only(right: e.key < 3 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.2))),
                        child: Column(children: [
                          Text(_districtIcons[e.key], style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(e.value.replaceAll('ສີ', ''), // ຫຍໍ້ຊື່
                            style: AppTheme.laoText(size: 8, color: Colors.white),
                            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]),
                      ))).toList()),
                  ]),
                )),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(child: Text('👥 ທີມງານ 8 ຄົນ', style: AppTheme.laoText(size: 12, color: Colors.white))),
                Tab(child: Text('🏘️ ແບ່ງ 4 ເມືອງ', style: AppTheme.laoText(size: 12, color: Colors.white))),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildTeamTab(),
            _buildDistrictTab(),
          ],
        ),
      ),
      // FAB ສ້າງໂພສ
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/chat'),
        backgroundColor: AppTheme.success,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: Text('ສ້າງໂພສຂາຍ', style: AppTheme.laoText(size: 13, weight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  // ==========================================
  // TAB 1: ທີມງານ 8 ຄົນ
  // ==========================================
  Widget _buildTeamTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final members = _members.isEmpty ? _fallback : _members;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final m = members[i];
        final engine = m['ai_engine'] as String? ?? 'claude';
        final aiColor = _aiColor(engine);
        final districts = (m['districts'] as List?)?.cast<String>() ?? [];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.border, width: 0.8)),
          child: Row(children: [
            // Emoji avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: aiColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: aiColor.withOpacity(0.3))),
              child: Center(child: Text(m['emoji'] ?? '👤',
                style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            // Info
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(m['name_lao'] ?? '', style: AppTheme.laoText(size: 14, weight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: aiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                  child: Text(_aiLabel(engine), style: AppTheme.laoCaption(color: aiColor))),
              ]),
              const SizedBox(height: 3),
              Text(m['duty_lao'] ?? '', style: AppTheme.laoText(size: 12, color: AppTheme.textSecondary)),
              if (districts.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 4, children: districts.map((d) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(d, style: AppTheme.laoCaption(color: AppTheme.primary)))).toList()),
              ],
            ])),
            // Chat button
            GestureDetector(
              onTap: () => context.go('/chat'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
                child: const Icon(Icons.chat_rounded, size: 18, color: AppTheme.primary))),
          ]),
        ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1);
      },
    );
  }

  // ==========================================
  // TAB 2: ແບ່ງ 4 ເມືອງ
  // ==========================================
  Widget _buildDistrictTab() {
    final districtData = [
      {'name':'ຈັນທະບູລີ', 'icon':'🏛️', 'color':AppTheme.primary,
       'desc':'ໃຈກາງເມືອງ · ທຳເລດີ · ລາຄາສູງ',
       'members':['🔍 ນ້ອງຫາຊັບ','👑 ຫົວໜ້າທີມ']},
      {'name':'ສີໂຄດຕະບອງ','icon':'🏙️','color':AppTheme.purple,
       'desc':'ທ່າເດືອດ · ຕະຫລາດໃໝ່ · ຂະຫຍາຍ',
       'members':['🔍 ນ້ອງຫາຊັບ','👑 ຫົວໜ້າທີມ']},
      {'name':'ໄຊເສດຖາ',  'icon':'🏢','color':AppTheme.success,
       'desc':'ທຸລະກິດ · ຊາວຕ່າງຊາດ · Condo',
       'members':['🔍 ນ້ອງຫາຊັບ','👑 ຫົວໜ້າທີມ']},
      {'name':'ສີສັດຕະນາກ','icon':'🌆','color':AppTheme.warning,
       'desc':'ທາງດ່ວນ · ໂຄງການໃໝ່ · ຕ.ມ.ຖືກ',
       'members':['🔍 ນ້ອງຫາຊັບ','👑 ຫົວໜ້າທີມ']},
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: districtData.length,
      itemBuilder: (_, i) {
        final d = districtData[i];
        final c = d['color'] as Color;
        final members = d['members'] as List<String>;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: c.withOpacity(0.25), width: 1.2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header ເມືອງ
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radius))),
              child: Row(children: [
                Text(d['icon'] as String, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ເມືອງ${d['name']}', style: AppTheme.laoText(size: 15, weight: FontWeight.w700, color: c)),
                  Text(d['desc'] as String, style: AppTheme.laoCaption()),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                  child: Text('2 ຄົນ', style: AppTheme.laoCaption(color: c))),
              ])),
            // ລາຍຊື່ທີມ
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  const Icon(Icons.person_rounded, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Text(m, style: AppTheme.laoText(size: 13)),
                ]),
              )).toList())),
            // ປຸ່ມ
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/chat'),
                  icon: Icon(Icons.add_home_rounded, size: 16, color: c),
                  label: Text('ເພີ່ມຊັບໃນ${d['name']}',
                    style: AppTheme.laoText(size: 12, color: c)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: c.withOpacity(0.4)))))),
          ]),
        ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideY(begin: 0.15);
      },
    );
  }
}
