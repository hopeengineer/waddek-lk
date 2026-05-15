import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/profile/presentation/providers/profile_provider.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/phone_otp_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/home/presentation/screens/customer_home_screen.dart';
import '../../features/profile/presentation/screens/customer_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/my_skills_screen.dart';
import '../../features/profile/presentation/screens/portfolio_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/update_location_screen.dart';
import '../../features/profile/presentation/screens/worker_detail_screen.dart';
import '../../features/profile/presentation/screens/worker_profile_screen.dart';
import '../../features/profile/presentation/screens/worker_onboarding_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';
import '../../features/jobs/presentation/screens/my_jobs_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/worker_bids_screen.dart';
import '../../features/home/presentation/screens/search_screen.dart';
import '../providers/role_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/top_up_screen.dart';
import '../../features/wallet/presentation/screens/transaction_history_screen.dart';
import '../../features/subscription/presentation/screens/pro_pass_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/reviews/presentation/screens/submit_review_screen.dart';
import '../../features/disputes/presentation/screens/raise_dispute_screen.dart';

/// Global key for the root navigator. Used by services (e.g.
/// [NotificationService]) that need to navigate without a BuildContext.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Supabase auth changes + Riverpod state into a
/// [ChangeNotifier] that GoRouter can subscribe to. Without this the
/// router only evaluates redirects on navigation events, so the user
/// could stay on `/auth/login` after a successful sign-in or stay on
/// a customer route after switching to worker mode.
class _AuthRoleListenable extends ChangeNotifier {
  _AuthRoleListenable(this._ref) {
    _sub = SupabaseService.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
    _ref.listen(activeRoleProvider, (_, __) => notifyListeners());
    _ref.listen(currentProfileProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// GoRouter configuration with auth guards and role-based navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthRoleListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: listenable,
    redirect: (context, state) {
      final session = SupabaseService.client.auth.currentSession;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // Not logged in → go to login screen
      if (session == null && !isAuthRoute) {
        return '/auth/login';
      }

      // Logged in but on auth screen → go home
      if (session != null && isAuthRoute) {
        return '/';
      }

      // Role-based guards: prevent cross-role navigation. Skip while
      // the profile is still loading — otherwise the default 'customer'
      // role would yank a worker onto /customer/home on cold boot.
      if (session != null) {
        final profileAsync = ref.read(currentProfileProvider);
        if (profileAsync.isLoading) return null;

        final loc = state.matchedLocation;
        final role = ref.read(activeRoleProvider);
        if (role == 'customer' && loc.startsWith('/worker')) {
          return '/customer/home';
        }
        if (role == 'worker' && loc.startsWith('/customer')) {
          return '/worker/jobs';
        }
      }

      return null;
    },
    routes: [
      // ── Auth Routes ─────────────────────────────────────
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
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
          return OtpVerifyScreen(phone: phone, otpContext: 'signup');
        },
      ),
      GoRoute(
        path: '/auth/verify-2fa',
        name: 'otp-verify-2fa',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyScreen(phone: phone, otpContext: 'login_2fa');
        },
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return RegistrationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/auth/role',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/verify-reset',
        name: 'otp-verify-reset',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyScreen(
              phone: phone, otpContext: 'password_reset');
        },
      ),
      GoRoute(
        path: '/auth/new-password',
        name: 'new-password',
        builder: (context, state) => const NewPasswordScreen(),
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
                const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/jobs',
            name: 'customer-jobs',
            builder: (context, state) => const MyJobsScreen(),
          ),
          GoRoute(
            path: '/customer/messages',
            name: 'customer-messages',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            path: '/customer/notifications',
            name: 'customer-notifications',
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
                const WorkerBidsScreen(),
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
        path: '/search',
        name: 'search',
        builder: (context, state) =>
            SearchScreen(initialCategoryId: state.extra as String?),
      ),
      GoRoute(
        path: '/workers/:id',
        name: 'worker-detail',
        builder: (context, state) =>
            WorkerDetailScreen(workerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/portfolio',
        name: 'portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/profile/skills',
        name: 'my-skills',
        builder: (context, state) => const MySkillsScreen(),
      ),
      GoRoute(
        path: '/profile/location',
        name: 'update-location',
        builder: (context, state) => const UpdateLocationScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
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
      // /conversations is now /customer/messages inside the
      // customer ShellRoute (keeps the bottom nav). /chat/:id stays
      // standalone — individual chats render full-screen.
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/review',
        name: 'submit-review',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return SubmitReviewScreen(
            jobId: extra['jobId']!,
            workerId: extra['workerId']!,
          );
        },
      ),
      GoRoute(
        path: '/dispute/:jobId',
        name: 'raise-dispute',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return RaiseDisputeScreen(jobId: jobId);
        },
      ),
    ],
  );
});
