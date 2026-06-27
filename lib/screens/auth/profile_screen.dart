import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/brand/phanukngan_logo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _brandCtrl   = TextEditingController();
  final _contactCtrl = TextEditingController();

  bool _darkMode  = false;
  bool _saving    = false;
  bool _loading   = true;
  String? _email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _email = Supabase.instance.client.auth.currentUser?.email;
    final profile = await SupabaseService.instance.getProfile();
    if (mounted) {
      setState(() {
        _brandCtrl.text   = profile?['brand_name'] ?? 'PHANUKNGAN';
        _contactCtrl.text = profile?['contact']    ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await SupabaseService.instance.upsertProfile(
      brandName: _brandCtrl.text.trim(),
      contact:   _contactCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ບັນທຶກສຳເລັດ', style: AppTheme.laoText(size: 13, color: Colors.white)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('ອອກຈາກລະບົບ', style: AppTheme.laoText(size: 16, weight: FontWeight.w600)),
        content: Text('ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ?',
          style: AppTheme.laoText(size: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ຍົກເລີກ', style: AppTheme.laoText(size: 13, color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
            child: Text('ອອກ', style: AppTheme.laoText(size: 13, weight: FontWeight.w600, color: Colors.white))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
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
          Text('ໂປຣໄຟລ໌ + ການຕັ້ງຄ່າ',
            style: AppTheme.laoText(size: 15, weight: FontWeight.w600, color: Colors.white)),
        ]),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ---- Account Card ----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: AppTheme.border)),
                  child: Row(children: [
                    // Avatar
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: PhanuknganColors.navy.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: PhanuknganColors.gold.withOpacity(0.4))),
                      child: Center(child: PhanuknganLogo(
                        variant: LogoVariant.iconOnly, size: 36))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_brandCtrl.text,
                        style: AppTheme.laoText(size: 15, weight: FontWeight.w600)),
                      Text(_email ?? '',
                        style: AppTheme.laoCaption()),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                        child: Text('ເຈົ້ານາຍ · ທີມ 100 ຄົນ',
                          style: AppTheme.laoCaption(color: AppTheme.success))),
                    ])),
                  ]),
                ).animate().fadeIn().slideY(begin: -0.1),

                const SizedBox(height: 20),

                // ---- Brand Settings ----
                _SectionTitle('ຂໍ້ມູນ Brand'),
                const SizedBox(height: 10),

                _SettingCard(children: [
                  _FieldRow(
                    icon: Icons.business_rounded,
                    label: 'ຊື່ Brand',
                    child: TextField(
                      controller: _brandCtrl,
                      style: AppTheme.laoText(size: 13),
                      decoration: InputDecoration(
                        hintText: 'PHANUKNGAN',
                        hintStyle: AppTheme.laoCaption(),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero),
                    )),
                  const Divider(height: 1),
                  _FieldRow(
                    icon: Icons.phone_rounded,
                    label: 'ເບີຕິດຕໍ່',
                    child: TextField(
                      controller: _contactCtrl,
                      style: AppTheme.laoText(size: 13),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '020-XXXX-XXXX',
                        hintStyle: AppTheme.laoCaption(),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero),
                    )),
                ]).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PhanuknganColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
                    child: _saving
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('ບັນທຶກ',
                            style: AppTheme.laoText(size: 13, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 20),

                // ---- App Settings ----
                _SectionTitle('ການຕັ້ງຄ່າ App'),
                const SizedBox(height: 10),
                _SettingCard(children: [
                  _ToggleRow(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark Mode',
                    sublabel: 'ສຸ່ມສີມືດ',
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                ]).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 20),

                // ---- n8n + API ----
                _SectionTitle('n8n + API Keys'),
                const SizedBox(height: 10),
                _SettingCard(children: [
                  _LinkRow(
                    icon: Icons.hub_rounded,
                    label: 'n8n Webhook URL',
                    sublabel: 'http://localhost:5678/webhook',
                    color: AppTheme.primary),
                  const Divider(height: 1),
                  _LinkRow(
                    icon: Icons.psychology_rounded,
                    label: 'Anthropic (Claude)',
                    sublabel: 'sk-ant-xxxx...xxxx',
                    color: AppTheme.purple),
                  const Divider(height: 1),
                  _LinkRow(
                    icon: Icons.thumb_up_rounded,
                    label: 'Facebook Page',
                    sublabel: 'Token ຕັ້ງໃນ n8n',
                    color: const Color(0xFF1877F2)),
                ]).animate(delay: 250.ms).fadeIn(),

                const SizedBox(height: 20),

                // ---- Stats ----
                _SectionTitle('ສະຖິຕິ'),
                const SizedBox(height: 10),
                _buildStats().animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 24),

                // ---- Logout ----
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout_rounded, color: AppTheme.danger, size: 18),
                    label: Text('ອອກຈາກລະບົບ',
                      style: AppTheme.laoText(size: 13, color: AppTheme.danger)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.danger.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ).animate(delay: 350.ms).fadeIn(),

                const SizedBox(height: 30),
                Center(child: Text('PHANUKNGAN v1.0.0 · Powered by Claude + n8n',
                  style: AppTheme.laoCaption(), textAlign: TextAlign.center)),
                const SizedBox(height: 20),
              ]),
            ),
    );
  }

  Widget _buildStats() {
    return FutureBuilder<Map<String, int>>(
      future: SupabaseService.instance.getStats(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox(height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        final s = snap.data!;
        return Row(children: [
          _StatMini('${s['total']}', 'ວຽກທັງໝົດ', AppTheme.primary),
          _StatMini('${s['done']}',  'ສຳເລັດ',     AppTheme.success),
          _StatMini('${s['active']}','ດຳເນີນ',     AppTheme.warning),
          _StatMini('100',           'ທີມງານ',     AppTheme.purple),
        ]);
      },
    );
  }
}

// ---- Widgets ----
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override Widget build(BuildContext context) => Text(text,
    style: AppTheme.laoText(size: 12, weight: FontWeight.w500, color: AppTheme.textMuted));
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      border: Border.all(color: AppTheme.border)),
    child: Column(children: children));
}

class _FieldRow extends StatelessWidget {
  final IconData icon; final String label; final Widget child;
  const _FieldRow({required this.icon, required this.label, required this.child});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.textMuted),
      const SizedBox(width: 10),
      Text(label, style: AppTheme.laoText(size: 12, color: AppTheme.textSecondary)),
      const SizedBox(width: 12),
      Expanded(child: child),
    ]));
}

class _ToggleRow extends StatelessWidget {
  final IconData icon; final String label, sublabel;
  final bool value; final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label,
    required this.sublabel, required this.value, required this.onChanged});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.textMuted),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.laoText(size: 13)),
        Text(sublabel, style: AppTheme.laoCaption()),
      ])),
      Switch(value: value, onChanged: onChanged,
        activeColor: AppTheme.primary),
    ]));
}

class _LinkRow extends StatelessWidget {
  final IconData icon; final String label, sublabel; final Color color;
  const _LinkRow({required this.icon, required this.label, required this.sublabel, required this.color});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.laoText(size: 12, weight: FontWeight.w500)),
        Text(sublabel, style: AppTheme.laoCaption(), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
    ]));
}

class _StatMini extends StatelessWidget {
  final String value, label; final Color color;
  const _StatMini(this.value, this.label, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      border: Border.all(color: AppTheme.border)),
    child: Column(children: [
      Text(value, style: AppTheme.laoDisplay(size: 20, color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppTheme.laoCaption(), textAlign: TextAlign.center),
    ])));
}
