import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/new_job_screen.dart';
import 'screens/jobs/upload_screen.dart';
import 'screens/jobs/job_progress_screen.dart';
import 'screens/other_screens.dart';
import 'services/notification_service.dart';

// ==========================================
// SUPABASE CONFIG — ຂອງທ່ານ
// ==========================================
const _supabaseUrl     = 'https://ezpprrhfrdskrtybezze.supabase.co';
const _supabaseAnonKey = 'sb_publishable_3hws1cdfDtIFC1UW0HSjXA_u_W6SRk3';
const kDemoMode        = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: PhanuknganApp()));
}

// ==========================================
// ROUTER
// ==========================================
final _router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    try {
      final session     = Supabase.instance.client.auth.currentSession;
      final goingToAuth = state.matchedLocation == '/login';
      final splash      = state.matchedLocation == '/splash';
      if (session == null && !goingToAuth && !splash) return '/login';
      if (session != null && goingToAuth) return '/home';
    } catch (_) {}
    return null;
  },
  routes: [
    GoRoute(path: '/splash',    builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/profile',   builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/home',      builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/chat',      builder: (_, __) => const ChatScreen()),
    GoRoute(path: '/new-job',   builder: (_, __) => const NewJobScreen()),
    GoRoute(path: '/upload', builder: (_, s) {
      final extra = s.extra as Map<String, String>? ?? {};
      return UploadScreen(
        jobId:    extra['jobId']    ?? '',
        jobType:  extra['jobType']  ?? 'graphic',
        jobTitle: extra['jobTitle'] ?? '',
      );
    }),
    GoRoute(path: '/progress', builder: (_, s) =>
        JobProgressScreen(jobId: s.extra as String? ?? '')),
    GoRoute(path: '/result',    builder: (_, s) =>
        ResultScreen(jobId: s.extra as String? ?? '')),
    GoRoute(path: '/scheduler', builder: (_, __) => const SchedulerScreen()),
    GoRoute(path: '/team',      builder: (_, __) => const TeamScreen()),
  ],
);

// ==========================================
// APP
// ==========================================
class PhanuknganApp extends StatefulWidget {
  const PhanuknganApp({super.key});
  @override State<PhanuknganApp> createState() => _PhanuknganAppState();
}

class _PhanuknganAppState extends State<PhanuknganApp> {
  @override
  void initState() {
    super.initState();
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedOut) {
          _router.go('/login');
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PHANUKNGAN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
