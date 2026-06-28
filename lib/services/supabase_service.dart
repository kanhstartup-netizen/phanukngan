import 'package:supabase_flutter/supabase_flutter.dart';

// ໃຊ້ getter ເພື່ອໃຫ້ປະເມີນຕອນເອີ້ນໃຊ້ (ຫລັງ Supabase.initialize ສຳເລັດ)
// ບໍ່ໃຊ້ top-level variable ເພາະມັນ run ກ່ອນ init → crash ໃນ web
SupabaseClient get supabase => Supabase.instance.client;

// ==========================================
// JOB MODEL
// ==========================================
class Job {
  final String id;
  final String title;
  final String? titleLao;
  final String type;
  final String? command;
  final String status;
  final String? teamId;
  final String? fileUrl;
  final String? resultUrl;
  final String? caption;
  final List<String> platforms;
  final DateTime? scheduleTime;
  final int priority;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.title,
    this.titleLao,
    required this.type,
    this.command,
    required this.status,
    this.teamId,
    this.fileUrl,
    this.resultUrl,
    this.caption,
    this.platforms = const [],
    this.scheduleTime,
    this.priority = 3,
    required this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> m) => Job(
    id:           m['id'],
    title:        m['title'],
    titleLao:     m['title_lao'],
    type:         m['type'],
    command:      m['command'],
    status:       m['status'] ?? 'pending',
    teamId:       m['team_id'],
    fileUrl:      m['file_url'],
    resultUrl:    m['result_url'],
    caption:      m['caption'],
    platforms:    List<String>.from(m['platforms'] ?? []),
    scheduleTime: m['schedule_time'] != null
        ? DateTime.parse(m['schedule_time']) : null,
    priority:     m['priority'] ?? 3,
    createdAt:    DateTime.parse(m['created_at']),
  );

  String get statusLao => switch (status) {
    'pending'   => 'ລໍຖ້າ',
    'doing'     => 'ດຳເນີນຢູ່',
    'qc'        => 'QC ກວດ',
    'done'      => 'ສຳເລັດແລ້ວ',
    'cancelled' => 'ຍົກເລີກ',
    _           => status,
  };
}

// ==========================================
// NOTIFICATION MODEL
// ==========================================
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? type;
  final String? jobId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.jobId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
    id:        m['id'],
    title:     m['title'],
    body:      m['body'],
    type:      m['type'],
    jobId:     m['job_id'],
    isRead:    m['is_read'] ?? false,
    createdAt: DateTime.parse(m['created_at']),
  );
}

// ==========================================
// SUPABASE SERVICE
// ==========================================
class SupabaseService {
  static SupabaseService? _i;
  SupabaseService._();
  static SupabaseService get instance => _i ??= SupabaseService._();

  String? get userId => supabase.auth.currentUser?.id;

  // JOBS
  Future<List<Job>> getJobs({String? status}) async {
    final data = await supabase
        .from('jobs')
        .select()
        .order('created_at', ascending: false);
    final list = data as List;
    if (status != null) {
      return list
          .where((j) => j['status'] == status)
          .map((e) => Job.fromMap(e))
          .toList();
    }
    return list.map((e) => Job.fromMap(e)).toList();
  }

  Future<Job> createJob({
    required String title,
    required String type,
    String? titleLao,
    String? command,
    String? fileUrl,
    int priority = 3,
    List<String> platforms = const [],
    DateTime? deadline,
  }) async {
    final data = await supabase.from('jobs').insert({
      'owner_id':  userId,
      'title':     title,
      'title_lao': titleLao ?? title,
      'type':      type,
      'command':   command,
      'file_url':  fileUrl,
      'status':    'pending',
      'priority':  priority,
      'platforms': platforms,
      'deadline':  deadline?.toIso8601String(),
    }).select().single();
    return Job.fromMap(data);
  }

  Future<void> updateJobStatus(String jobId, String status, {
    String? resultUrl,
    String? caption,
    DateTime? postedAt,
  }) async {
    await supabase.from('jobs').update({
      'status': status,
      if (resultUrl != null) 'result_url': resultUrl,
      if (caption   != null) 'caption':    caption,
      if (postedAt  != null) 'posted_at':  postedAt.toIso8601String(),
    }).eq('id', jobId);
  }

  Future<Map<String, int>> getStats() async {
    final all = await supabase.from('jobs').select('status');
    final list = all as List;
    return {
      'total':  list.length,
      'done':   list.where((j) => j['status'] == 'done').length,
      'active': list.where((j) => j['status'] == 'doing').length,
      'team':   100,
    };
  }

  // NOTIFICATIONS
  Future<List<AppNotification>> getNotifications() async {
    final data = await supabase
        .from('notifications')
        .select()
        .eq('owner_id', userId ?? '')
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((e) => AppNotification.fromMap(e)).toList();
  }

  Future<void> markAllRead() async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('owner_id', userId ?? '');
  }

  // REALTIME
  RealtimeChannel listenJobs(void Function(Job job) onUpdate) {
    return supabase
        .channel('jobs-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'jobs',
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              onUpdate(Job.fromMap(payload.newRecord));
            }
          },
        )
        .subscribe();
  }

  // PROFILE
  Future<Map<String, dynamic>?> getProfile() async {
    if (userId == null) return null;
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId!)
        .maybeSingle();
    return data;
  }

  Future<void> upsertProfile({
    required String brandName,
    String? contact,
  }) async {
    await supabase.from('profiles').upsert({
      'id':         userId,
      'brand_name': brandName,
      'contact':    contact,
    });
  }

  // SEND JOB (wrapper)
  Future<void> sendNewJob({
    required String title,
    required String type,
    required String command,
  }) async {
    await createJob(title: title, type: type, command: command);
  }
}
