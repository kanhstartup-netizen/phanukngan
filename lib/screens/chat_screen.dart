import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/khopkhua_service.dart';
import '../services/n8n_service.dart';
import '../widgets/effects/ui_effects.dart';
import '../widgets/brand/phanukngan_logo.dart';

// ==========================================
// CHAT MODES
// ==========================================
enum _ChatMode { normal, collectingProperty }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false, _sending = false;

  _ChatMode _mode = _ChatMode.normal;
  final Map<String, String> _propData = {}; // ເກັບຂໍ້ມູນຊັບທີ່ກຳລັງກວດ
  int _propStep = 0; // ຂັ້ນຕອນກວດຂໍ້ມູນ

  // ຄຳຖາມ 5 ລາຍການຫລັກ (ຖ້ານ້ອຍໄວ)
  final _propQuestions = [
    {'key': 'propType',  'q': '📋 ປະເພດຊັບ?\n(ດິນ / ເຮືອນ / ຕຶກແຖວ / ອາພາດເມັ້ນ / ອື່ນໆ)'},
    {'key': 'location',  'q': '📍 ທີ່ຕັ້ງ?\n(ບ້ານ, ເມືອງ, ຈັງຫວັດ)'},
    {'key': 'area',      'q': '📐 ເນື້ອທີ່?\n(ເຊັ່ນ: 400 ຕ.ມ. ຫລື 1 ໄຮ່)'},
    {'key': 'price',     'q': '💰 ລາຄາ?\n(ເຊັ່ນ: 850 ລ້ານກີບ ຫລື \$45,000)'},
    {'key': 'phone',     'q': '📞 ເບີຕິດຕໍ່ເຈົ້າຂອງ?'},
  ];

  final List<Map<String, dynamic>> _msgs = [{
    'isMe': false,
    'text': 'ສະບາຍດີ ເຈົ້ານາຍ!\nn8n AI Brain + ທີມ 100 ຄົນ ພ້ອມ.\nສັ່ງງານພາສາລາວ — Webhook ຈະສົ່ງທີມທັນທີ!',
    'time': '09:00',
    'isPost': false,
  }];

  final _quick = [
    'ສ້າງໂພສ',
    'ຕັດຄລິບໂປຣໂມດ ໃສ່ Subtitle ລາວ',
    'ແຕ່ງຮູບ + Watermark',
    'ຂຽນ Caption Facebook',
  ];

  String get _now {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  // ==========================================
  // SEND MESSAGE
  // ==========================================
  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _ctrl.clear();
    final msg = text.trim();

    setState(() {
      _msgs.add({'isMe': true, 'text': msg, 'time': _now, 'isPost': false});
      _typing = true; _sending = true;
    });
    _scrollEnd();

    await Future.delayed(600.ms);
    if (!mounted) return;

    // ==========================================
    // MODE: ກຳລັງເກັບຂໍ້ມູນຊັບ
    // ==========================================
    if (_mode == _ChatMode.collectingProperty) {
      final key = _propQuestions[_propStep]['key']!;
      _propData[key] = msg;
      _propStep++;

      if (_propStep < _propQuestions.length) {
        // ຖາມຄຳຖາມຖັດໄປ
        final nextQ = _propQuestions[_propStep]['q']!;
        setState(() {
          _typing = false; _sending = false;
          _msgs.add({'isMe': false, 'text': nextQ, 'time': _now, 'isPost': false});
        });
      } else {
        // ຄົບ 5 ລາຍການ → ສ້າງໂພສ
        setState(() => _msgs.add({
          'isMe': false,
          'text': '✅ ຂໍ້ມູນຄົບ! Claude AI ກຳລັງຂຽນໂພສ...\n⏳ ລໍຖ້າ 10-15 ວິນາທີ',
          'time': _now, 'isPost': false,
        }));
        _scrollEnd();

        try {
          final post = await KhopkhuaService.generatePost(
            propType: _propData['propType'] ?? '',
            location: _propData['location'] ?? '',
            area:     _propData['area'] ?? '',
            price:    _propData['price'] ?? '',
            phone:    _propData['phone'] ?? '',
          );

          if (!mounted) return;
          setState(() {
            _typing = false; _sending = false;
            _mode = _ChatMode.normal; _propStep = 0; _propData.clear();
            _msgs.add({'isMe': false, 'text': post, 'time': _now, 'isPost': true});
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _typing = false; _sending = false;
            _mode = _ChatMode.normal; _propStep = 0; _propData.clear();
            _msgs.add({'isMe': false,
              'text': '❌ ສ້າງໂພສບໍ່ສຳເລັດ: $e\nລອງໃໝ່ຫລື ພິມ "ສ້າງໂພສ"',
              'time': _now, 'isPost': false});
          });
        }
      }
      _scrollEnd();
      return;
    }

    // ==========================================
    // MODE: ປົກກະຕິ
    // ==========================================
    if (msg.contains('ສ້າງໂພສ') || msg.contains('ຂຽນໂພສ') || msg.contains('ໂພສຂາຍ')) {
      // ເລີ່ມ collect ຂໍ້ມູນຊັບ
      _mode = _ChatMode.collectingProperty;
      _propStep = 0; _propData.clear();
      setState(() {
        _typing = false; _sending = false;
        _msgs.add({'isMe': false,
          'text': '🏠 ສ້າງໂພສຂາຍຊັບ!\nນ້ອງຂຽນໂພສຈະຖາມຂໍ້ມູນ 5 ລາຍການ\n\n${_propQuestions[0]['q']}',
          'time': _now, 'isPost': false});
      });
    } else {
      // ຄຳສັ່ງທົ່ວໄປ → ສົ່ງ n8n + await ຄຳຕອບ Claude ຈິງ
      try {
        final reply = await N8nService.instance.chat(msg);
        if (!mounted) return;
        setState(() {
          _typing = false; _sending = false;
          _msgs.add({'isMe': false, 'text': reply, 'time': _now, 'isPost': false});
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _typing = false; _sending = false;
          _msgs.add({'isMe': false,
            'text': '❌ ເຊື່ອມ n8n ບໍ່ສຳເລັດ\nກວດ: n8n workflow "phanukngan-chat" ເປີດຢູ່ບໍ?',
            'time': _now, 'isPost': false});
        });
      }
    }
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
        // HEADER
        Container(
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0B2545), Color(0xFF1A73E8)])),
          child: Row(children: [
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18))),
            const SizedBox(width: 12),
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
            child: Row(children: _quick.map((q) => GestureDetector(
              onTap: () => _send(q),
              child: Container(margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  color: q == 'ສ້າງໂພສ'
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.primary.withOpacity(0.06)),
                child: Text(q, style: AppTheme.laoText(size: 11,
                  color: q == 'ສ້າງໂພສ' ? AppTheme.success : AppTheme.primary))))).toList()))),

        // Messages
        Expanded(child: ListView.builder(
          controller: _scroll, padding: const EdgeInsets.all(16),
          itemCount: _msgs.length + (_typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (_typing && i == _msgs.length) return _TypingBubble();
            final m = _msgs[i];
            return _Bubble(
              text: m['text'], isMe: m['isMe'], time: m['time'],
              isPost: m['isPost'] ?? false, index: i);
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
                  hintText: _mode == _ChatMode.collectingProperty
                      ? 'ໃສ່ຂໍ້ມູນ...' : 'ພິມຄຳສັ່ງພາສາລາວ...',
                  hintStyle: AppTheme.laoCaption(),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                textInputAction: TextInputAction.send, maxLines: null))),
            const SizedBox(width: 8),
            NeonButton(label: '', icon: Icons.send_rounded,
              color: AppTheme.primary, loading: _sending, small: true,
              onTap: () => _send(_ctrl.text)),
          ])),
      ]),
    );
  }
}

// ==========================================
// BUBBLE WIDGET — ຮອງຮັບ isPost (ໂພສ Claude)
// ==========================================
class _Bubble extends StatelessWidget {
  final String text, time;
  final bool isMe, isPost;
  final int index;
  const _Bubble({required this.text, required this.isMe, required this.time,
    required this.isPost, required this.index});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          PhanuknganLogo(variant: LogoVariant.iconOnly, size: 30),
          const SizedBox(width: 8),
        ],
        Flexible(child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isPost ? AppTheme.success.withOpacity(0.08)
                    : isMe ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radius),
                  topRight: const Radius.circular(AppTheme.radius),
                  bottomLeft: Radius.circular(isMe ? AppTheme.radius : 3),
                  bottomRight: Radius.circular(isMe ? 3 : AppTheme.radius)),
                border: isPost
                    ? Border.all(color: AppTheme.success.withOpacity(0.4), width: 1.5)
                    : isMe ? null : Border.all(color: AppTheme.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (isPost) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('✅ ໂພສຂາຍ (Claude AI)',
                      style: AppTheme.laoText(size: 11, weight: FontWeight.w600,
                        color: AppTheme.success)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('ຄັດລອກໂພສແລ້ວ! 📋',
                            style: AppTheme.laoText(size: 13, color: Colors.white)),
                          backgroundColor: AppTheme.success,
                          duration: const Duration(seconds: 2)));
                      },
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.copy_rounded, size: 14, color: AppTheme.success),
                        const SizedBox(width: 4),
                        Text('Copy', style: AppTheme.laoText(size: 11, color: AppTheme.success)),
                      ])),
                  ]),
                  const Divider(height: 12),
                ],
                SelectableText(text,
                  style: AppTheme.laoText(size: 13,
                    color: isMe ? Colors.white : AppTheme.textPrimary, height: 1.65)),
              ])),
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
