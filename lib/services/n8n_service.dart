import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// ==========================================
// n8n EVENT TYPES
// ==========================================
enum N8nEvent {
  newJob,         // ສ່ົງວຽກໃໝ່
  jobComplete,    // ວຽກສຳເລັດ
  approveContent, // Approve Caption/Content
  schedulePost,   // ກຳນົດໂພສ
  requestReport,  // ຂໍ Report
  teamAction,     // ສ່ົງທີມ
  cancelJob,      // ຍົກເລີກວຽກ
}

extension N8nEventX on N8nEvent {
  String get key => switch (this) {
    N8nEvent.newJob         => 'new_job',
    N8nEvent.jobComplete    => 'job_complete',
    N8nEvent.approveContent => 'approve_content',
    N8nEvent.schedulePost   => 'schedule_post',
    N8nEvent.requestReport  => 'request_report',
    N8nEvent.teamAction     => 'team_action',
    N8nEvent.cancelJob      => 'cancel_job',
  };
  String get labelLao => switch (this) {
    N8nEvent.newJob         => 'ສ່ົງວຽກໃໝ່',
    N8nEvent.jobComplete    => 'ວຽກສຳເລັດ',
    N8nEvent.approveContent => 'Approve Content',
    N8nEvent.schedulePost   => 'ກຳນົດໂພສ',
    N8nEvent.requestReport  => 'ຂໍ Report',
    N8nEvent.teamAction     => 'ສ່ົງທີມ',
    N8nEvent.cancelJob      => 'ຍົກເລີກ',
  };
}

// ==========================================
// WEBHOOK RESULT
// ==========================================
class N8nResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final String? error;

  const N8nResult({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory N8nResult.ok(Map<String, dynamic>? data, [String? msg]) =>
      N8nResult(success: true, data: data, message: msg);

  factory N8nResult.fail(String err) =>
      N8nResult(success: false, error: err);
}

// ==========================================
// n8n SERVICE
// ==========================================
class N8nService {
  static N8nService? _instance;
  N8nService._();
  static N8nService get instance => _instance ??= N8nService._();

  // ✏️ ປ່ຽນ URL ນີ້ ເປັນ n8n Webhook URL ຂອງທ່ານ
  // Railway n8n URL
  static const String _baseUrl = 'https://n8n-production-f688.up.railway.app';
  static const String _webhookPath = '/webhook/khopkhua-post';

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'X-App-Name': 'PHANUKNGAN',
      'X-App-Version': '1.0.0',
    },
  ))
    ..interceptors.add(_LogInterceptor());

  // ==========================================
  // MAIN SEND METHOD
  // ==========================================
  Future<N8nResult> send({
    required N8nEvent event,
    required Map<String, dynamic> payload,
    int retries = 2,
  }) async {
    final body = {
      'event': event.key,
      'timestamp': DateTime.now().toIso8601String(),
      'app': 'phanukngan',
      'payload': payload,
    };

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final res = await _dio.post(_webhookPath, data: body);

        if (res.statusCode == 200 || res.statusCode == 201) {
          return N8nResult.ok(
            res.data is Map ? Map<String, dynamic>.from(res.data) : null,
            res.data?['message'] as String?,
          );
        }
        return N8nResult.fail('Server error: ${res.statusCode}');

      } on DioException catch (e) {
        if (attempt < retries) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        return N8nResult.fail(_errorMsg(e));
      } catch (e) {
        return N8nResult.fail('ຜິດພາດທີ່ບໍ່ຄາດ: $e');
      }
    }
    return N8nResult.fail('ບໍ່ສາມາດເຊື່ອມ n8n ໄດ້');
  }

  String _errorMsg(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout => 'ໝົດເວລາເຊື່ອມ — ກວດ WiFi',
    DioExceptionType.connectionError   => 'ເຊື່ອມ n8n ບໍ່ໄດ້ — ກວດ URL',
    DioExceptionType.receiveTimeout    => 'n8n ໃຊ້ເວລາດົນໄປ',
    _                                  => 'ຜິດພາດ: ${e.message}',
  };

  // ==========================================
  // CONVENIENCE METHODS
  // ==========================================

  /// ສ່ົງວຽກໃໝ່ → n8n ແຈກຈ່າຍທີມ
  Future<N8nResult> sendNewJob({
    required String title,
    required String type,     // video, graphic, content, banner
    required String command,  // ຄຳສັ່ງພາສາລາວ
    String? deadline,
    String? filePath,
  }) => send(
    event: N8nEvent.newJob,
    payload: {
      'title': title,
      'type': type,
      'command': command,
      if (deadline != null) 'deadline': deadline,
      if (filePath != null) 'file_path': filePath,
    },
  );

  /// Approve Content → n8n ສ່ົງໂພສ
  Future<N8nResult> approveContent({
    required String jobId,
    required String caption,
    required List<String> platforms,
    DateTime? scheduleTime,
  }) => send(
    event: N8nEvent.approveContent,
    payload: {
      'job_id': jobId,
      'caption': caption,
      'platforms': platforms,
      if (scheduleTime != null)
        'schedule_time': scheduleTime.toIso8601String(),
    },
  );

  /// ກຳນົດໂພສ Social Media
  Future<N8nResult> schedulePost({
    required String jobId,
    required List<String> platforms,
    required DateTime scheduleTime,
  }) => send(
    event: N8nEvent.schedulePost,
    payload: {
      'job_id': jobId,
      'platforms': platforms,
      'schedule_time': scheduleTime.toIso8601String(),
    },
  );

  /// ຂໍ Weekly Report
  Future<N8nResult> requestReport({String period = 'week'}) => send(
    event: N8nEvent.requestReport,
    payload: {'period': period},
  );

  /// ທົດສອບ Connection
  Future<bool> ping() async {
    // ທົດສອບ webhook URL ໂດຍກົງ (GET request)
    try {
      final res = await Dio().get(
        'https://n8n-production-f688.up.railway.app/webhook/khopkhua-post',
        options: Options(
          validateStatus: (s) => s != null && s < 500,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      // 404 = webhook ຂຶ້ນທຽວ ແຕ່ GET ຖືກປະຕິເສດ (ຕ້ອງ POST) = connected ✅
      return res.statusCode == 404 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ==========================================
// LOG INTERCEPTOR
// ==========================================
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (kDebugMode) {
      debugPrint('→ n8n [${o.method}] ${o.path}');
      debugPrint('   body: ${o.data}');
    }
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    if (kDebugMode) debugPrint('← n8n ${r.statusCode}: ${r.data}');
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    if (kDebugMode) debugPrint('✕ n8n error: ${e.message}');
    h.next(e);
  }
}
