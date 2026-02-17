import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/phone_otp_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/profile/presentation/screens/customer_profile_screen.dart';
import '../../features/profile/presentation/screens/worker_profile_screen.dart';
import '../../features/profile/presentation/screens/worker_onboarding_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';
import '../../features/jobs/presentation/screens/my_jobs_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../services/supabase_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/top_up_screen.dart';
import '../../features/wallet/presentation/screens/transaction_history_screen.dart';
import '../../features/subscription/presentation/screens/pro_pass_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

/// GoRouter configuration with auth guards and role-based navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = SupabaseService.client.auth.currentSession;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // Not logged in → go to OTP screen
      if (session == null && !isAuthRoute) {
        return '/auth/phone';
      }

      // Logged in but on auth screen → go home
      if (session != null && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // ── Auth Routes ─────────────────────────────────────
      GoRoute(
        path: '/auth/phone',
        name: 'phone-otp',
        builder: (context, state) => const PhoneOtpScreen(),
      ),
      GoRoute(
        path: '/auth/verify',
        name: 'otp-verify',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/auth/role',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // ── Onboarding ──────────────────────────────────────
      GoRoute(
        path: '/onboarding/worker',
        name: 'worker-onboarding',
        builder: (context, state) => const WorkerOnboardingScreen(),
      ),

      // ── Main (Customer) ─────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            AppBottomNav(isWorker: false, child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'customer-home',
            redirect: (context, state) => '/customer/home',
          ),
          GoRoute(
            path: '/customer/home',
            name: 'customer-home-tab',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Home'),
          ),
          GoRoute(
            path: '/customer/jobs',
            name: 'customer-jobs',
            builder: (context, state) => const MyJobsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/customer/profile',
            name: 'customer-profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
        ],
      ),

      // ── Main (Worker) ───────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            AppBottomNav(isWorker: true, child: child),
        routes: [
          GoRoute(
            path: '/worker/jobs',
            name: 'worker-jobs',
            builder: (context, state) => const AvailableJobsScreen(),
          ),
          GoRoute(
            path: '/worker/bids',
            name: 'worker-bids',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'My Bids'),
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/worker/profile',
            name: 'worker-profile',
            builder: (context, state) => const WorkerProfileScreen(),
          ),
        ],
      ),

      // ── Standalone Screens ──────────────────────────────
      GoRoute(
        path: '/jobs/create',
        name: 'create-job',
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: '/jobs/:id',
        name: 'job-detail',
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/wallet/topup',
        name: 'topup',
        builder: (context, state) => const TopUpScreen(),
      ),
      GoRoute(
        path: '/wallet/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/propass',
        name: 'propass',
        builder: (context, state) => const ProPassScreen(),
      ),
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
    ],
  );
});

/// Temporary placeholder used until feature screens are built.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
