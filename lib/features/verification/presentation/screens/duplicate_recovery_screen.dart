import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/verification_provider.dart';

/// Shown when a verification result reveals the ID is already linked
/// to another account. The user picks between logging in to that
/// account (sign-out → login screen) or recovering it (transfer this
/// phone/email onto the existing account).
class DuplicateRecoveryScreen extends ConsumerStatefulWidget {
  const DuplicateRecoveryScreen({super.key});

  @override
  ConsumerState<DuplicateRecoveryScreen> createState() =>
      _DuplicateRecoveryScreenState();
}

class _DuplicateRecoveryScreenState
    extends ConsumerState<DuplicateRecoveryScreen> {
  bool _recovering = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Existing account found'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.account_circle,
                size: 72, color: AppColors.neonAmber),
            const SizedBox(height: 16),
            const Text(
              'This ID is already linked to another account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your verification proves you own the ID. Pick how to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // ── Option 1: Log in ──
            NeonCard(
              child: InkWell(
                onTap: _recovering ? null : _logInToExisting,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.login, color: AppColors.neonCyan, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Log in to the existing account',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            SizedBox(height: 4),
                            Text(
                              'Use the phone or email associated with the older account.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Option 2: Recover ──
            NeonCard(
              child: InkWell(
                onTap: _recovering ? null : _recover,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz,
                          color: AppColors.neonGreen, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Recover with this phone/email',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            SizedBox(height: 4),
                            Text(
                              'Move your current phone/email onto the existing account. Your old history stays intact.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (_recovering)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.neonGreen),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.neonRed),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logInToExisting() async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) context.go('/auth/login');
  }

  Future<void> _recover() async {
    setState(() {
      _recovering = true;
      _error = null;
    });
    try {
      final result =
          await ref.read(verificationRepositoryProvider).recoverAccountById();

      // The caller's auth user has been deleted server-side. Try the
      // returned magic-link token to upgrade the session to the
      // recovered (target) account without round-tripping login.
      final tokenHash = result['token_hash'] as String?;
      if (tokenHash != null && tokenHash.isNotEmpty) {
        await SupabaseService.client.auth.verifyOTP(
          token: tokenHash,
          type: OtpType.magiclink,
        );
        if (!mounted) return;
        context.go('/');
        return;
      }
      // Fallback: ask the user to log in to the recovered account.
      if (!mounted) return;
      await ref.read(authProvider.notifier).signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Account recovered. Please log in to continue.'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
      context.go('/auth/login');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _recovering = false;
      });
    }
  }
}
