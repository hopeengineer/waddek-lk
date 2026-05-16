import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';

/// Bottom-sheet shown when a verified user tries to change something
/// that's been locked by the identity-verification flow (currently
/// just the profile picture, but reusable for future locked fields).
///
/// Two outcomes:
///  * Tap "Keep current" → sheet dismisses with `false` — nothing
///    changes. This is the default path.
///  * Tap "Continue to re-verify" → sheet returns `true`. The caller
///    is expected to route the user to the verification flow. PayHere
///    payment is deferred; today the screen surfaces a clear "payment
///    integration pending" message, with no charge incurred.
///
/// Returns null on barrier-dismiss (treat as cancel).
Future<bool?> showReVerifyRequiredSheet(
  BuildContext context, {
  required String lockedField,
  String costLabel = 'Rs 300 / ~\$1',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.bgCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            const Icon(Icons.lock_person,
                size: 48, color: AppColors.neonAmber),
            const SizedBox(height: 12),

            Text(
              'Re-verification required',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your $lockedField is locked because it was set from the ID you verified with. To change it, you need to re-verify your identity.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Cost row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments,
                      color: AppColors.neonCyan, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Re-verification fee',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ),
                  Text(
                    costLabel,
                    style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            NeonButton(
              label: 'Continue to re-verify',
              icon: Icons.videocam,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Keep current picture',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper: invoke the re-verify flow once the user agreed in the
/// sheet above. Today this just surfaces a "payment integration
/// pending" message and does not actually start verification, because
/// shufti-start-verification refuses when verification_status is
/// already 'verified' until PayHere is wired in.
void handleReVerifyChoice(BuildContext context, bool? choseToReVerify) {
  if (choseToReVerify != true) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
          'Payment integration is being finalised — you will be able to pay and re-verify here shortly.'),
      backgroundColor: AppColors.neonAmber,
      duration: Duration(seconds: 4),
    ),
  );
  // Route to the verification screen anyway so the user can see the
  // unified flow for context, even though the start button will be
  // gated server-side until payment lands.
  context.pushNamed('verification');
}
