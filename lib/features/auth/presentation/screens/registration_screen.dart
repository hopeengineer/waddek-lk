import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/neon_button.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text('Create Your Account',
                        style: AppTextStyles.h2),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Phone verified: ${widget.phone}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Complete your profile to get started',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Full legal name
                  _buildLabel('Full Legal Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.bodyLarge,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your full name';
                      }
                      if (v.trim().split(' ').length < 2) {
                        return 'Enter first and last name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.textSecondary),
                      hintText: 'e.g. Kamal Perera',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email
                  _buildLabel('Email Address'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyLarge,
                    validator: Validators.email,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textSecondary),
                      hintText: 'you@example.com',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.bodyLarge,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary),
                      hintText: 'Min 8 characters',
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

                  const SizedBox(height: 20),

                  // Confirm password
                  _buildLabel('Confirm Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: AppTextStyles.bodyLarge,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary),
                      hintText: 'Re-enter password',
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
                            'I agree to the Terms of Service and Privacy Policy',
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
                    label: 'Create Account',
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
