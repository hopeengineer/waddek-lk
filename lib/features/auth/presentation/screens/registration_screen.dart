import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Registration form — shown after successful OTP verification for new users.
/// Collects full name, email, and password.
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key, required this.phone});

  /// The verified phone number from OTP flow.
  final String phone;

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.agreeToTermsRequired)),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          phone: widget.phone,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted) {
      final state = ref.read(authProvider);
      if (state.flowState == AuthFlowState.registered) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SizedBox(
                  width: double.infinity,
                  child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(l10n.createAccount,
                        style: AppTextStyles.h2),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.phoneVerified(widget.phone),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.completeProfile,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Full legal name
                  _buildLabel(l10n.fullLegalName),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.bodyLarge,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.fullNameRequired;
                      }
                      if (v.trim().split(' ').length < 2) {
                        return l10n.firstAndLastNameRequired;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.textSecondary),
                      hintText: l10n.fullNameHint,
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email
                  _buildLabel(l10n.emailAddress),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyLarge,
                    validator: Validators.email,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textSecondary),
                      hintText: l10n.emailHint,
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password
                  _buildLabel(l10n.password),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.bodyLarge,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return l10n.passwordMinLength;
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary),
                      hintText: l10n.passwordHint,
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDisabled),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _PasswordStrengthBar(
                        password: _passwordController.text),
                  ],

                  const SizedBox(height: 20),

                  // Confirm password
                  _buildLabel(l10n.confirmPassword),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: AppTextStyles.bodyLarge,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return l10n.passwordsDontMatch;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary),
                      hintText: l10n.reEnterPassword,
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDisabled),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Terms of service
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) =>
                              setState(() => _agreedToTerms = v ?? false),
                          activeColor: AppColors.neonCyan,
                          checkColor: AppColors.scaffoldDark,
                          side: const BorderSide(
                              color: AppColors.textSecondary, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Text(
                            l10n.termsConsent,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Error message
                  if (authState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      authState.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // CTA
                  NeonButton(
                    label: l10n.createAccountCta,
                    onPressed: authState.isLoading ? null : _register,
                    isLoading: authState.isLoading,
                    icon: Icons.how_to_reg_rounded,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});
  final String password;

  int get _score {
    int s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) s++;
    return s;
  }

  Color get _color {
    if (_score <= 1) return AppColors.neonRed;
    if (_score == 2) return AppColors.neonAmber;
    if (_score == 3) return AppColors.neonCyan;
    return AppColors.neonGreen;
  }

  String _labelFor(AppLocalizations l10n) {
    if (_score <= 1) return l10n.pwWeak;
    if (_score == 2) return l10n.pwFair;
    if (_score == 3) return l10n.pwGood;
    return l10n.pwStrong;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _score / 4,
                  minHeight: 4,
                  backgroundColor: AppColors.bgSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _labelFor(l10n),
              style: TextStyle(color: _color, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

