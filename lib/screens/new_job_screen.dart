// new_job_screen.dart — ເພີ່ມ "ສ້າງໂພສຂາຍ" ຜ່ານ Claude AI
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/khopkhua_service.dart';

class NewJobScreen extends StatefulWidget {
  const NewJobScreen({super.key});
  @override State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  int _type = 0; // 0=ສ້າງໂພສ, 1=ຕັດຄລິບ, 2=ແຕ່ງຮູບ, 3=Content, 4=Banner
  bool _loading = false;
  String? _generatedPost;

  // Controllers ສຳລັບ "ສ້າງໂພສຂາຍ"
  final _propTypeCtrl  = TextEditingController(text: 'ດິນ');
  final _locationCtrl  = TextEditingController();
  final _areaCtrl      = TextEditingController();
  final _priceCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _docsCtrl      = TextEditingController();
  final _utilitiesCtrl = TextEditingController();
  final _nearbyCtrl    = TextEditingController();
  final _accessCtrl    = TextEditingController();
  final _highlightCtrl = TextEditingController();

  // Controllers ສຳລັບ job ທົ່ວໄປ
  final _nameCtrl = TextEditingController();
  final _cmdCtrl  = TextEditingController();

  final _types = [
    {'icon': Icons.home_work_rounded,   'label': 'ສ້າງໂພສ',  'color': AppTheme.success},
    {'icon': Icons.videocam_rounded,    'label': 'ຕັດຄລິບ',  'color': AppTheme.purple},
    {'icon': Icons.photo_camera_rounded,'label': 'ແຕ່ງຮູບ',  'color': AppTheme.primary},
    {'icon': Icons.edit_rounded,        'label': 'Content',  'color': AppTheme.warning},
  ];

  Future<void> _generatePost() async {
    if (_locationCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ກະລຸນາໃສ່ ທີ່ຕັ້ງ, ລາຄາ, ເບີໂທ ກ່ອນ',
            style: AppTheme.laoText(size: 13, color: Colors.white)),
        backgroundColor: AppTheme.warning,
      ));
      return;
    }
    setState(() { _loading = true; _generatedPost = null; });
    try {
      final post = await KhopkhuaService.generatePost(
        propType:   _propTypeCtrl.text,
        location:   _locationCtrl.text,
        area:       _areaCtrl.text,
        price:      _priceCtrl.text,
        phone:      _phoneCtrl.text,
        documents:  _docsCtrl.text,
        utilities:  _utilitiesCtrl.text,
        nearby:     _nearbyCtrl.text,
        access:     _accessCtrl.text,
        highlights: _highlightCtrl.text,
      );
      setState(() => _generatedPost = post);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: AppTheme.laoText(size: 13, color: Colors.white)),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _propTypeCtrl.dispose(); _locationCtrl.dispose(); _areaCtrl.dispose();
    _priceCtrl.dispose(); _phoneCtrl.dispose(); _docsCtrl.dispose();
    _utilitiesCtrl.dispose(); _nearbyCtrl.dispose(); _accessCtrl.dispose();
    _highlightCtrl.dispose(); _nameCtrl.dispose(); _cmdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('ສ້າງໂປຣເຈັກໃໝ່',
            style: AppTheme.laoText(size: 16, weight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ---- TYPE SELECTOR ----
          Text('ປະເພດວຽກ', style: AppTheme.laoText(size: 13, weight: FontWeight.w500))
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 10),
          Row(children: _types.asMap().entries.map((e) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() { _type = e.key; _generatedPost = null; }),
              child: AnimatedContainer(
                duration: AppTheme.fast,
                margin: EdgeInsets.only(right: e.key < 3 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == e.key
                      ? (e.value['color'] as Color).withOpacity(0.12)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(
                    color: _type == e.key ? e.value['color'] as Color : AppTheme.border,
                    width: _type == e.key ? 1.5 : 0.8,
                  ),
                ),
                child: Column(children: [
                  Icon(e.value['icon'] as IconData,
                      color: e.value['color'] as Color, size: 24),
                  const SizedBox(height: 5),
                  Text(e.value['label'] as String,
                      style: AppTheme.laoCaption(
                          color: _type == e.key
                              ? e.value['color'] as Color
                              : AppTheme.textSecondary)),
                ]),
              ),
            ),
          )).toList()),

          const SizedBox(height: 20),

          // ---- ສ້າງໂພສຂາຍ (type == 0) ----
          if (_type == 0) ...[
            _field('ປະເພດຊັບ *', 'ດິນ / ເຮືອນ / ຕຶກແຖວ...', _propTypeCtrl),
            _field('ທີ່ຕັ້ງ *', 'ບ້ານ/ເມືອງ/ຈັງຫວັດ', _locationCtrl),
            _field('ເນື້ອທີ່', 'ເຊັ່ນ: 400 ຕ.ມ.', _areaCtrl),
            _field('ລາຄາ *', 'ເຊັ່ນ: 850 ລ້ານກີບ', _priceCtrl),
            _field('ເບີຕິດຕໍ່ *', '020 xxxx xxxx', _phoneCtrl, type: TextInputType.phone),
            _field('ເອກະສານ', 'ໃບຕາດິນ, ໂຉນ...', _docsCtrl),
            _field('ໄຟຟ້າ-ນ້ຳ', 'ພ້ອມ / ບໍ່ພ້ອມ', _utilitiesCtrl),
            _field('ສະຖານທີ່ໃກ້ຄຽງ', 'ໂຮງຮຽນ, ຕະຫລາດ...', _nearbyCtrl),
            _field('ທາງເຂົ້າ', 'ຄອນກຣີດ, ຖະໜົນ 6ແມ...', _accessCtrl),
            _field('ຈຸດເດັ່ນ', 'ທຳເລດີ, ລາຄາຕໍ່ລອງໄດ້...', _highlightCtrl),
            const SizedBox(height: 8),

            // ---- ປຸ່ມ ສ້າງໂພສ ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generatePost,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                    _loading ? 'Claude ກຳລັງຂຽນໂພສ...' : '✍️ ສ້າງໂພສຂາຍ (Claude AI)',
                    style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
              ),
            ),

            // ---- ສະແດງໂພສທີ່ Claude ຂຽນ ----
            if (_generatedPost != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('✅ ໂພສທີ່ Claude ຂຽນ',
                        style: AppTheme.laoText(size: 13, weight: FontWeight.w600,
                            color: AppTheme.success)),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      color: AppTheme.success,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedPost!));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('ຄັດລອກແລ້ວ!',
                              style: AppTheme.laoText(size: 13, color: Colors.white)),
                          backgroundColor: AppTheme.success,
                          duration: const Duration(seconds: 2),
                        ));
                      },
                    ),
                  ]),
                  const Divider(),
                  SelectableText(_generatedPost!,
                      style: AppTheme.laoText(size: 13, height: 1.6)),
                ]),
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _generatePost,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text('ສ້າງໃໝ່', style: AppTheme.laoText(size: 13)),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text('ສຳເລັດ', style: AppTheme.laoText(size: 13, color: Colors.white)),
                )),
              ]),
            ],
          ],

          // ---- ປະເພດວຽກອື່ນ (1,2,3) ----
          if (_type != 0) ...[
            Text('ຊື່ໂປຣເຈັກ', style: AppTheme.laoText(size: 13, weight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: AppTheme.laoText(size: 14),
              decoration: const InputDecoration(hintText: 'ເຊັ່ນ: ຄລິບໂປຣໂມດເດືອນ 7'),
            ),
            const SizedBox(height: 16),
            Text('ຄຳສັ່ງ (ພາສາລາວ)', style: AppTheme.laoText(size: 13, weight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _cmdCtrl,
              style: AppTheme.laoText(size: 14),
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'ອະທິບາຍສິ່ງທີ່ຕ້ອງການ...'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text('ສົ່ງຄຳສັ່ງ',
                    style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.laoText(size: 12, weight: FontWeight.w500,
          color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: AppTheme.laoText(size: 14),
        decoration: InputDecoration(hintText: hint),
      ),
      const SizedBox(height: 12),
    ]);
  }
}
