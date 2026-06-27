// new_job_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class NewJobScreen extends StatefulWidget {
  const NewJobScreen({super.key});
  @override State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  int _type = 0;
  final _nameCtrl = TextEditingController();
  final _cmdCtrl  = TextEditingController();

  final _types = [
    {'icon': Icons.videocam_rounded,    'label': 'ຕັດຄລິບ',  'color': AppTheme.purple},
    {'icon': Icons.photo_camera_rounded,'label': 'ແຕ່ງຮູບ',  'color': AppTheme.primary},
    {'icon': Icons.edit_rounded,        'label': 'Content',  'color': AppTheme.success},
    {'icon': Icons.campaign_rounded,    'label': 'Banner',   'color': AppTheme.warning},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('ສ້າງໂປຣເຈັກໃໝ່', style: AppTheme.laoText(size: 16, weight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text('ປະເພດວຽກ', style: AppTheme.laoText(size: 13, weight: FontWeight.w500))
            .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 10),
          Row(children: _types.asMap().entries.map((e) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = e.key),
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
                    color: _type == e.key
                        ? e.value['color'] as Color
                        : AppTheme.border,
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
          Text('ຊື່ໂປຣເຈັກ', style: AppTheme.laoText(size: 13, weight: FontWeight.w500))
            .animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: AppTheme.laoText(size: 14),
            decoration: const InputDecoration(hintText: 'ເຊັ່ນ: ຄລິບໂປຣໂມດເດືອນ 7'),
          ).animate().fadeIn(delay: 180.ms),

          const SizedBox(height: 16),
          Text('ຄຳສັ່ງ (ພາສາລາວ)', style: AppTheme.laoText(size: 13, weight: FontWeight.w500))
            .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          TextField(
            controller: _cmdCtrl,
            style: AppTheme.laoText(size: 14),
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'ເຊັ່ນ: ຕັດຄລິບ ໃສ່ Subtitle ພາສາລາວ ໃສ່ Logo ທ້າຍ...',
            ),
          ).animate().fadeIn(delay: 220.ms),

          const SizedBox(height: 16),
          // Upload Zone
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
                width: 1.5,
                // dotted ຕ້ອງໃຊ້ dotted_border package
              ),
            ),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.cloud_upload_rounded, size: 36, color: AppTheme.primary.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text('ອັບໂຫລດໄຟລ໌ Footage / ຮູບ', style: AppTheme.laoText(size: 13, color: AppTheme.textSecondary)),
              Text('MP4, MOV, JPG, PNG, PSD', style: AppTheme.laoCaption()),
            ])),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text('ສົ່ງຄຳສັ່ງ', style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, begin: const Offset(0.9,0.9)),
        ]),
      ),
    );
  }
}
