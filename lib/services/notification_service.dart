// ==========================================
// notification_service.dart
// ==========================================
// pubspec.yaml ຕ້ອງໃສ່:
//   firebase_core: ^2.27.0
//   firebase_messaging: ^14.7.19
//   flutter_local_notifications: ^17.0.0
//
// ຕັ້ງ Firebase:
//   flutterfire configure
//   → ເລືອກ Project → ໄດ້ google-services.json ອັດຕະໂນມັດ

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

// ==========================================
// NOTIFICATION SERVICE
// ==========================================
class NotificationService {
  static NotificationService? _i;
  NotificationService._();
  static NotificationService get instance => _i ??= NotificationService._();

  // ==========================================
  // SUPABASE REALTIME LISTENER
  // ==========================================
  // ໃຊ້ Supabase Realtime ແທນ Firebase ສຳລັບ In-App
  // (ງ່າຍກວ່າ + ບໍ່ຕ້ອງ Setup Firebase ເພີ່ມ)

  RealtimeChannel? _notifChannel;

  void startListening(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    _notifChannel = Supabase.instance.client
        .channel('notifications-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'owner_id',
            value: uid,
          ),
          callback: (payload) {
            if (context.mounted) {
              _showInAppBanner(context, payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  void stopListening() {
    _notifChannel?.unsubscribe();
    _notifChannel = null;
  }

  // ==========================================
  // IN-APP NOTIFICATION BANNER
  // ==========================================
  void _showInAppBanner(BuildContext context, Map<String, dynamic> data) {
    final type  = data['type'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final body  = data['body']  as String? ?? '';

    final color = switch (type) {
      'job_complete'       => AppTheme.success,
      'approval_required'  => AppTheme.warning,
      'morning_plan'       => AppTheme.primary,
      'weekly_report'      => AppTheme.purple,
      _                    => AppTheme.primary,
    };

    final icon = switch (type) {
      'job_complete'       => Icons.check_circle_rounded,
      'approval_required'  => Icons.pending_rounded,
      'morning_plan'       => Icons.wb_sunny_rounded,
      'weekly_report'      => Icons.bar_chart_rounded,
      _                    => Icons.notifications_rounded,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        content: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: AppTheme.laoText(size: 13, weight: FontWeight.w600,
              color: AppTheme.textPrimary)),
            Text(body, style: AppTheme.laoCaption(), maxLines: 2),
          ])),
        ]),
      ),
    );
  }

  // ==========================================
  // ສ້າງ Notification ຈາກ n8n Webhook
  // ==========================================
  // n8n ຈະ POST ໄປ /phanukngan/notify → Supabase INSERT
  // → Realtime ແຈ້ງ Flutter ອັດຕະໂນມັດ
}

// ==========================================
// NOTIFICATION SCREEN (ໜ້າ Bell)
// ==========================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override State<NotificationScreen> createState() => _NSState();
}

class _NSState extends State<NotificationScreen> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await SupabaseService.instance.getNotifications();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  Future<void> _markRead() async {
    await SupabaseService.instance.markAllRead();
    await _load();
  }

  Color _typeColor(String? t) => switch (t) {
    'job_complete'      => AppTheme.success,
    'approval_required' => AppTheme.warning,
    'morning_plan'      => AppTheme.primary,
    'weekly_report'     => AppTheme.purple,
    _                   => AppTheme.primary,
  };

  IconData _typeIcon(String? t) => switch (t) {
    'job_complete'      => Icons.check_circle_rounded,
    'approval_required' => Icons.pending_rounded,
    'morning_plan'      => Icons.wb_sunny_rounded,
    'weekly_report'     => Icons.bar_chart_rounded,
    _                   => Icons.notifications_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: PhanuknganColors.navy,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
        title: Text('ການແຈ້ງເຕືອນ',
          style: AppTheme.laoText(size: 15, weight: FontWeight.w600, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _markRead,
            child: Text('ອ່ານທັງໝົດ',
              style: AppTheme.laoText(size: 12, color: Colors.white.withOpacity(0.8))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _NotifCard(
                      notif: _items[i],
                      color: _typeColor(_items[i].type),
                      icon: _typeIcon(_items[i].type),
                    ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1),
                  ),
                ),
    );
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.notifications_none_rounded, size: 56, color: AppTheme.textMuted),
      const SizedBox(height: 12),
      Text('ຍັງບໍ່ມີການແຈ້ງເຕືອນ',
        style: AppTheme.laoText(size: 14, color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Text('n8n ຈະ Push ເມື່ອວຽກສຳເລັດ',
        style: AppTheme.laoCaption()),
    ]));
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final Color color;
  final IconData icon;

  const _NotifCard({required this.notif, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? AppTheme.surface : color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: notif.isRead ? AppTheme.border : color.withOpacity(0.25),
          width: notif.isRead ? 0.5 : 1)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(notif.title,
              style: AppTheme.laoText(size: 13, weight: FontWeight.w500))),
            if (!notif.isRead) Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 3),
          Text(notif.body, style: AppTheme.laoText(size: 12, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 5),
          Text(_timeAgo(notif.createdAt), style: AppTheme.laoCaption()),
        ])),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} ນາທີກ່ອນ';
    if (diff.inHours   < 24) return '${diff.inHours} ຊົ່ວໂມງກ່ອນ';
    return '${diff.inDays} ວັນກ່ອນ';
  }
}
