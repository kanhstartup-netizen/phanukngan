import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../services/n8n_service.dart';
import '../../widgets/brand/phanukngan_logo.dart';

class UploadScreen extends StatefulWidget {
  final String jobId;
  final String jobType; // 'video' | 'graphic' | 'content' | 'banner'
  final String jobTitle;

  const UploadScreen({
    super.key,
    required this.jobId,
    required this.jobType,
    required this.jobTitle,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _picker  = ImagePicker();
  final _storage = Supabase.instance.client.storage;

  File?   _selectedFile;
  String? _fileName;
  String? _fileType; // 'image' | 'video'
  double  _progress = 0;
  bool    _uploading = false;
  bool    _done = false;
  String? _error;

  bool get _isVideo => widget.jobType == 'video';

  // ==========================================
  // ເລືອກໄຟລ໌
  // ==========================================
  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (img == null) return;
    setState(() {
      _selectedFile = File(img.path);
      _fileName     = img.name;
      _fileType     = 'image';
      _error        = null;
    });
  }

  Future<void> _pickVideo() async {
    final vid = await _picker.pickVideo(source: ImageSource.gallery);
    if (vid == null) return;
    setState(() {
      _selectedFile = File(vid.path);
      _fileName     = vid.name;
      _fileType     = 'video';
      _error        = null;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg','png','mp4','mov','psd','ai'],
    );
    if (result == null) return;
    setState(() {
      _selectedFile = File(result.files.single.path!);
      _fileName     = result.files.single.name;
      _fileType     = result.files.single.extension == 'mp4' || result.files.single.extension == 'mov'
          ? 'video' : 'image';
      _error = null;
    });
  }

  // ==========================================
  // ອັບໂຫລດ → Supabase Storage → n8n
  // ==========================================
  Future<void> _upload() async {
    if (_selectedFile == null) {
      setState(() => _error = 'ກະລຸນາເລືອກໄຟລ໌ກ່ອນ');
      return;
    }
    setState(() { _uploading = true; _progress = 0; _error = null; });

    try {
      // 1. ອັບໂຫລດໃສ່ Supabase Storage
      final uid      = Supabase.instance.client.auth.currentUser!.id;
      final ext      = _fileName!.split('.').last;
      final path     = '$uid/jobs/${widget.jobId}/$_fileName';

      // Simulate progress (Supabase ຍັງບໍ່ມີ progress callback)
      for (int i = 1; i <= 9; i++) {
        await Future.delayed(150.ms);
        if (mounted) setState(() => _progress = i / 10);
      }

      await _storage.from('job-files').upload(path, _selectedFile!,
        fileOptions: FileOptions(contentType: _fileType == 'video' ? 'video/mp4' : 'image/jpeg'));

      final fileUrl = _storage.from('job-files').getPublicUrl(path);
      setState(() => _progress = 1.0);

      // 2. ອັບເດດ Job ໃນ Database
      await SupabaseService.instance.updateJobStatus(widget.jobId, 'doing',
          resultUrl: null);
      await Supabase.instance.client.from('jobs').update({
        'file_url': fileUrl,
        'status':   'doing',
      }).eq('id', widget.jobId);

      // 3. ສົ່ງ Webhook → n8n ຮັບໄຟລ໌ + ເລີ່ມ Process
      await N8nService.instance.send(
        event: N8nEvent.newJob,
        payload: {
          'job_id':    widget.jobId,
          'type':      widget.jobType,
          'file_url':  fileUrl,
          'file_type': _fileType,
          'title':     widget.jobTitle,
        },
      );

      if (mounted) setState(() { _done = true; _uploading = false; });

    } catch (e) {
      if (mounted) setState(() {
        _error    = 'ອັບໂຫລດບໍ່ສຳເລັດ: ${e.toString().substring(0, 60)}';
        _uploading = false;
        _progress  = 0;
      });
    }
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: PhanuknganColors.navy,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
        title: Row(children: [
          PhanuknganLogo(variant: LogoVariant.iconOnly, size: 28, isDark: true),
          const SizedBox(width: 10),
          Text('ອັບໂຫລດໄຟລ໌', style: AppTheme.laoText(size: 15, weight: FontWeight.w600, color: Colors.white)),
        ]),
      ),

      body: _done ? _buildDone() : _buildUpload(),
    );
  }

  // ==========================================
  // UPLOAD UI
  // ==========================================
  Widget _buildUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ---- Job Info ----
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
          child: Row(children: [
            Icon(_isVideo ? Icons.videocam_rounded : Icons.photo_camera_rounded,
              color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.jobTitle,
                style: AppTheme.laoText(size: 13, weight: FontWeight.w500)),
              Text('Job #${widget.jobId.substring(0, 8)}',
                style: AppTheme.laoCaption()),
            ])),
          ]),
        ).animate().fadeIn().slideY(begin: -0.2),

        const SizedBox(height: 24),

        // ---- Pick Zone ----
        Text('ເລືອກໄຟລ໌', style: AppTheme.laoText(size: 14, weight: FontWeight.w600))
          .animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 10),

        if (_selectedFile == null)
          _buildPickZone()
        else
          _buildFilePreview(),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.danger.withOpacity(0.3))),
            child: Row(children: [
              Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: AppTheme.laoText(size: 12, color: AppTheme.danger))),
            ]),
          ),
        ],

        const SizedBox(height: 24),

        // ---- Upload Progress ----
        if (_uploading) ...[
          Text('ກຳລັງອັບໂຫລດ...', style: AppTheme.laoText(size: 13, color: AppTheme.primary)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text('${(_progress * 100).toInt()}%',
            style: AppTheme.laoCaption(color: AppTheme.primary)),
          const SizedBox(height: 24),
        ],

        // ---- Buttons ----
        if (!_uploading) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _selectedFile != null ? _upload : null,
              icon: const Icon(Icons.cloud_upload_rounded, size: 20),
              label: Text('ອັບໂຫລດ + ສົ່ງໃຫ້ທີມ',
                style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 10),

          if (_selectedFile != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() { _selectedFile = null; _fileName = null; }),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('ເລືອກໄຟລ໌ໃໝ່',
                  style: AppTheme.laoText(size: 13)),
              ),
            ),
        ],
      ]),
    );
  }

  Widget _buildPickZone() {
    return Column(children: [
      // Dashed drop zone
      GestureDetector(
        onTap: _isVideo ? _pickVideo : _pickImage,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5,
              // ຖ້າຕ້ອງ Dashed ໃຊ້ dotted_border package
            ),
          ),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_isVideo ? Icons.videocam_rounded : Icons.photo_rounded,
              size: 44, color: AppTheme.primary.withOpacity(0.4)),
            const SizedBox(height: 10),
            Text('ກົດເພື່ອເລືອກ${_isVideo ? "ວິດີໂອ" : "ຮູບພາບ"}',
              style: AppTheme.laoText(size: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(_isVideo ? 'MP4, MOV ຮອງຮັບ' : 'JPG, PNG, PSD ຮອງຮັບ',
              style: AppTheme.laoCaption()),
          ])),
        ),
      ).animate(delay: 150.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),

      const SizedBox(height: 12),

      // Divider
      Row(children: [
        Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ຫຼື', style: AppTheme.laoCaption())),
        Expanded(child: Divider(color: AppTheme.border)),
      ]),

      const SizedBox(height: 12),

      // Other file types
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.folder_open_rounded, size: 16),
          label: Text('ເລືອກໄຟລ໌', style: AppTheme.laoText(size: 12)),
        )),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton.icon(
          onPressed: () async {
            final img = await _picker.pickImage(source: ImageSource.camera);
            if (img == null) return;
            setState(() {
              _selectedFile = File(img.path);
              _fileName     = img.name;
              _fileType     = 'image';
            });
          },
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: Text('ກ້ອງຖ່າຍ', style: AppTheme.laoText(size: 12)),
        )),
      ]).animate(delay: 250.ms).fadeIn(),
    ]);
  }

  Widget _buildFilePreview() {
    final isImg = _fileType == 'image';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.success.withOpacity(0.3))),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.surfaceAlt,
          ),
          clipBehavior: Clip.antiAlias,
          child: isImg
              ? Image.file(_selectedFile!, fit: BoxFit.cover)
              : const Icon(Icons.videocam_rounded, size: 28, color: AppTheme.purple),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fileName ?? '', style: AppTheme.laoText(size: 12, weight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(isImg ? 'ຮູບພາບ — ພ້ອມອັບໂຫລດ' : 'ວິດີໂອ — ພ້ອມອັບໂຫລດ',
            style: AppTheme.laoCaption(color: AppTheme.success)),
        ])),
        Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
      ]),
    ).animate().fadeIn().scale(begin: const Offset(0.95,0.95));
  }

  // ==========================================
  // DONE SCREEN
  // ==========================================
  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: AppTheme.success, size: 44),
          )
          .animate().scale(begin: const Offset(0,0), curve: Curves.elasticOut, duration: 700.ms)
          .fadeIn(duration: 300.ms),

          const SizedBox(height: 20),
          Text('ອັບໂຫລດສຳເລັດ!',
            style: AppTheme.laoDisplay(size: 22, color: AppTheme.success))
          .animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 8),
          Text('n8n ຮັບໄຟລ໌ແລ້ວ — ທີມ${_isVideo ? "ຕັດຄລິບ" : "ແຕ່ງຮູບ"}ກຳລັງດຳເນີນ\nຈະ Push Notify ເມື່ອສຳເລັດ',
            style: AppTheme.laoText(size: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center)
          .animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 32),

          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_rounded, size: 18),
            label: Text('ກັບໜ້າຫຼັກ', style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)),
          )).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),

          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => context.go('/result'),
            icon: const Icon(Icons.sparkles_rounded, size: 18),
            label: Text('ເບິ່ງຜົນງານ', style: AppTheme.laoText(size: 14)),
          )).animate(delay: 600.ms).fadeIn(),
        ]),
      ),
    );
  }
}
