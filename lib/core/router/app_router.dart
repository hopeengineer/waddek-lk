import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/phone_otp_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../services/supabase_service.dart';

/// GoRouter configuration with auth guards.
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

      // ── Main Shell (Customer / Worker) ──────────────────
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
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
