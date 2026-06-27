import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/n8n_service.dart';
import '../widgets/effects/ui_effects.dart';
import '../widgets/brand/phanukngan_logo.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false, _sending = false;

  final List<Map<String, dynamic>> _msgs = [{
    'isMe': false, 'text': 'ສະບາຍດີ ເຈົ້ານາຍ!\nn8n AI Brain + ທີມ 100 ຄົນ ພ້ອມ.\nສັ່ງງານພາສາລາວ — Webhook ຈະສົ່ງທີມທັນທີ!',
    'time': '09:00',
  }];

  final _quick = ['ຕັດຄລິບໂປຣໂມດ ໃສ່ Subtitle ລາວ','ແຕ່ງຮູບ + Watermark','ຂຽນ Caption Facebook','ອອກແບບ Banner'];
  final _replies = {
    'ຕັດຄລິບ': 'ຮັບຄຳສັ່ງແລ້ວ!\nVideo Editor 20 ຄົນ ພ້ອມ:\n• Subtitle ລາວ + Logo\n• Watermark + QC\nn8n Push Notify ເມື່ອສຳເລັດ.',
    'ຮູບ': 'ຮັບຄຳສັ່ງແລ້ວ!\nGraphic Design ພ້ອມ:\n• Watermark + Contact\n• Claude ຂຽນ Caption ລາວ\nອັບໂຫລດຮູບດິບໄດ້ເລີຍ!',
    'Caption': 'Content Creator ຮັບແລ້ວ!\n• Caption ລາວ 100%\n• Hashtag ທີ່ Trend\n• QC ກວດ Spelling',
    'Banner': 'Marketing Team ຮັບແລ້ວ!\n• 1080×1080 Professional\n• 3 Version ໃຫ້ເລືອກ\nຄາດ 1-2 ຊົ່ວໂມງ.',
  };

  String _reply(String t) {
    for (final k in _replies.keys) if (t.contains(k)) return _replies[k]!;
    return 'ຮັບຄຳສັ່ງ "$t" ແລ້ວ!\nClaude AI ກຳລັງຈັດສັນທີມ...\nຈະ Push Notify ເມື່ອມີຄວາມຄືບໜ້າ.';
  }

  String _detectType(String t) {
    if (t.contains('ຄລິບ')) return 'video';
    if (t.contains('ຮູບ')) return 'graphic';
    if (t.contains('Caption')) return 'content';
    return 'general';
  }

  String get _now {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _ctrl.clear();
    setState(() {
      _msgs.add({'isMe':true,'text':text.trim(),'time':_now});
      _typing = true; _sending = true;
    });
    _scrollEnd();
    N8nService.instance.sendNewJob(title:text.trim(),type:_detectType(text),command:text.trim());
    await Future.delayed(1500.ms);
    if (!mounted) return;
    setState(() {
      _typing = false; _sending = false;
      _msgs.add({'isMe':false,'text':_reply(text),'time':_now});
    });
    _scrollEnd();
  }

  void _scrollEnd() => Future.delayed(100.ms, () {
    if (_scroll.hasClients) _scroll.animateTo(
      _scroll.position.maxScrollExtent, duration: AppTheme.normal, curve: AppTheme.easeOut);
  });

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bot = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(children: [
        // ---- HEADER ກັບ LOGO ----
        Container(
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0B2545), Color(0xFF1A73E8)])),
          child: Row(children: [
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18))),
            const SizedBox(width: 12),
            // ---- Logo ຂະໜາດນ້ອຍໃນ Chat Header ----
            PhanuknganLogo(variant: LogoVariant.iconOnly, size: 38, isDark: true),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PHANUKNGAN AI',
                style: AppTheme.laoText(size: 14, weight: FontWeight.w600, color: Colors.white)),
              Row(children: [
                Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF69F0AE), shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('n8n + 100 ທີມ ອອນລາຍ',
                  style: AppTheme.laoCaption(color: Colors.white.withOpacity(0.8))),
              ]),
            ])),
            WebhookBadge(connected: true),
          ])),
        // Quick chips
        Container(color: AppTheme.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: _quick.map((q) => GestureDetector(onTap: () => _send(q),
              child: Container(margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  color: AppTheme.primary.withOpacity(0.06)),
                child: Text(q, style: AppTheme.laoText(size: 11, color: AppTheme.primary))))).toList()))),
        // Messages
        Expanded(child: ListView.builder(
          controller: _scroll, padding: const EdgeInsets.all(16),
          itemCount: _msgs.length + (_typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (_typing && i == _msgs.length) return _TypingBubble();
            final m = _msgs[i];
            return _Bubble(text: m['text'], isMe: m['isMe'], time: m['time'], index: i);
          })),
        // Input
        Container(
          padding: EdgeInsets.fromLTRB(12, 10, 12, bot + 10),
          decoration: BoxDecoration(color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border))),
          child: Row(children: [
            Expanded(child: Container(
              decoration: BoxDecoration(color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppTheme.border)),
              child: TextField(controller: _ctrl, onSubmitted: _send,
                style: AppTheme.laoText(size: 14),
                decoration: InputDecoration(
                  hintText: 'ພິມຄຳສັ່ງພາສາລາວ...',
                  hintStyle: AppTheme.laoCaption(),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                textInputAction: TextInputAction.send, maxLines: null))),
            const SizedBox(width: 8),
            NeonButton(label: '', icon: Icons.send_rounded, color: AppTheme.primary, loading: _sending, small: true, onTap: () => _send(_ctrl.text)),
          ])),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text, time; final bool isMe; final int index;
  const _Bubble({required this.text, required this.isMe, required this.time, required this.index});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe)...[
          // ---- Logo ນ້ອຍໃນ Chat Bubble ----
          PhanuknganLogo(variant: LogoVariant.iconOnly, size: 30),
          const SizedBox(width: 8),
        ],
        Flexible(child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radius),
                  topRight: const Radius.circular(AppTheme.radius),
                  bottomLeft: Radius.circular(isMe ? AppTheme.radius : 3),
                  bottomRight: Radius.circular(isMe ? 3 : AppTheme.radius)),
                border: isMe ? null : Border.all(color: AppTheme.border)),
              child: Text(text, style: AppTheme.laoText(size: 13,
                color: isMe ? Colors.white : AppTheme.textPrimary, height: 1.65))),
            const SizedBox(height: 4),
            Text(time, style: AppTheme.laoCaption()),
          ])),
      ]),
  ).animate(delay: 50.ms).fadeIn(duration: 300.ms)
   .slideY(begin: 0.2, end: 0, duration: 300.ms, curve: AppTheme.easeOut);
}

class _TypingBubble extends StatefulWidget {
  @override State<_TypingBubble> createState() => _TS();
}
class _TS extends State<_TypingBubble> with TickerProviderStateMixin {
  final List<AnimationController> _d = [];
  @override void initState() { super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(vsync: this, duration: 500.ms); _d.add(c);
      Future.delayed(Duration(milliseconds: i * 150), () => mounted ? c.repeat(reverse: true) : null);
    }}
  @override void dispose() { for (var c in _d) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      PhanuknganLogo(variant: LogoVariant.iconOnly, size: 30),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(color: AppTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radius), topRight: Radius.circular(AppTheme.radius),
            bottomRight: Radius.circular(AppTheme.radius), bottomLeft: Radius.circular(3)),
          border: Border.all(color: AppTheme.border)),
        child: Row(mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => AnimatedBuilder(
            animation: _d[i], builder: (_, __) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7, height: 7 + _d[i].value * 5,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withOpacity(0.4 + _d[i].value * 0.6),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull))))))),
    ])).animate().fadeIn(duration: 200.ms);
}
