import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/neon_button.dart';
import '../providers/auth_provider.dart';

/// OTP verification screen — user enters the 6-digit code sent to their phone.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendSeconds--;
          if (_resendSeconds <= 0) {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length != 6) return;

    final success = await ref.read(authProvider.notifier).verifyOtp(code);
    if (success && mounted) {
      final needsOnboarding =
          await ref.read(authProvider.notifier).needsOnboarding();
      if (needsOnboarding) {
        context.goNamed('role-selection');
      } else {
        context.go('/');
      }
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
                ),

                const Spacer(),

                // Title
                Text('Verify your number', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Code sent to ${Helpers.maskPhone(widget.phone)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // OTP input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTextStyles.h3.copyWith(color: AppColors.neonCyan),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.cardDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.neonCyan,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          // Auto-verify when all 6 digits entered
                          if (_otpCode.length == 6) {
                            _verify();
                          }
                        },
                      ),
                    );
                  }),
                ),

                // Error
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      authState.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Verify button
                NeonButton(
                  label: 'Verify',
                  onPressed: authState.isLoading ? null : _verify,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 16),

                // Resend
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _resend,
                          child: Text(
                            'Resend code',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.neonCyan,
                            ),
                          ),
                        )
                      : Text(
                          'Resend in ${_resendSeconds}s',
                          style: AppTextStyles.bodySmall,
                        ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
