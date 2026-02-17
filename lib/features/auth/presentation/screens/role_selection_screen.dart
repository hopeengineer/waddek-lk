import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neon_button.dart';
import '../providers/auth_provider.dart';

/// Role selection screen — shown after first-time OTP verification.
/// User chooses "Customer" or "Worker" to define their experience.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).setRole(_selectedRole!);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                Text('I want to…', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Choose how you\'ll use Waddek',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                // Customer card
                _RoleCard(
                  title: 'Find skilled workers',
                  subtitle: 'Post jobs, get quotes, hire nearby workers',
                  icon: Icons.search_rounded,
                  isSelected: _selectedRole == 'customer',
                  onTap: () => setState(() => _selectedRole = 'customer'),
                ),

                const SizedBox(height: 16),

                // Worker card
                _RoleCard(
                  title: 'Offer my services',
                  subtitle: 'Get job leads, place bids, earn money',
                  icon: Icons.construction_rounded,
                  isSelected: _selectedRole == 'worker',
                  glowColor: AppColors.neonPurple,
                  onTap: () => setState(() => _selectedRole = 'worker'),
                ),

                const Spacer(),

                NeonButton(
                  label: 'Continue',
                  onPressed: _selectedRole != null ? _continue : null,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.glowColor = AppColors.neonCyan,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? glowColor.withOpacity(0.08)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? glowColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? AppColors.neonGlow(color: glowColor, blurRadius: 20)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: glowColor.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: glowColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: glowColor, size: 24),
          ],
        ),
      ),
    );
  }
}
