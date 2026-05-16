import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Step 1 of password reset: enter phone, receive OTP.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneCtrl.text.trim();
    await ref.read(authProvider.notifier).sendPasswordResetOtp(phone);
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.flowState == AuthFlowState.otpSent) {
      // Reuse the existing OTP screen with the password_reset context.
      context.pushNamed('otp-verify-reset', extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(l10n.resetPasswordTitle, style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  l10n.resetPasswordDesc,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyLarge,
                  validator: Validators.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: AppColors.textSecondary),
                    hintText: l10n.phoneHint,
                  ),
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 24),
                NeonButton(
                  label: l10n.sendResetCode,
                  icon: Icons.sms_outlined,
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
