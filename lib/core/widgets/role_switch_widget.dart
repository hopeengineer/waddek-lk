import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/role_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A compact role toggle widget for switching between Customer and Worker modes.
///
/// Shows current role with an animated toggle. Worker → Customer is instant;
/// Customer → Worker requires verification (handled by the caller).
class RoleSwitchWidget extends ConsumerWidget {
  const RoleSwitchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(activeRoleProvider);
    final isWorker = activeRole == 'worker';

    return GestureDetector(
      onTap: () => _handleSwitch(context, ref, isWorker),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isWorker
              ? const LinearGradient(
                  colors: [Color(0xFF1A3A2E), Color(0xFF0F2E1F)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF1A1A3D), Color(0xFF222250)],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isWorker
                ? AppColors.neonGreen.withOpacity(0.4)
                : AppColors.neonCyan.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isWorker ? AppColors.neonGreen : AppColors.neonCyan)
                  .withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWorker ? Icons.construction : Icons.person,
              color: isWorker ? AppColors.neonGreen : AppColors.neonCyan,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isWorker ? 'Worker' : 'Customer',
              style: AppTextStyles.labelMedium.copyWith(
                color: isWorker ? AppColors.neonGreen : AppColors.neonCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz,
              color: (isWorker ? AppColors.neonGreen : AppColors.neonCyan)
                  .withOpacity(0.6),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSwitch(BuildContext context, WidgetRef ref, bool isCurrentlyWorker) {
    if (isCurrentlyWorker) {
      // Worker → Customer: one-click (workers are already verified)
      ref.read(activeRoleProvider.notifier).switchRole('customer');
      context.go('/customer/home');
    } else {
      // Customer → Worker: check if they have worker verification
      _showWorkerActivationDialog(context, ref);
    }
  }

  void _showWorkerActivationDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.construction, color: AppColors.neonGreen, size: 48),
            const SizedBox(height: 16),
            Text(
              'Become a Worker',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'To offer services on Waddek, you need to complete worker verification including NIC upload and skill selection.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pushNamed('worker-onboarding');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.scaffoldDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('Start Verification',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.scaffoldDark)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Not Now',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
