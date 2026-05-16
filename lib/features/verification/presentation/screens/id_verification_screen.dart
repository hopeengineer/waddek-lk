import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/verification_provider.dart';

/// Verify-your-identity screen. Picks the ID document type, launches
/// the Shufti hosted page, then polls profile state until the webhook
/// either marks the user verified, flags a duplicate, or declines.
class IdVerificationScreen extends ConsumerStatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  ConsumerState<IdVerificationScreen> createState() =>
      _IdVerificationScreenState();
}

class _IdVerificationScreenState extends ConsumerState<IdVerificationScreen> {
  String _selectedType = 'nic';

  static const _docTypes = [
    ('nic', 'National Identity Card', Icons.badge),
    ('driving_licence', 'Driving Licence', Icons.directions_car),
    ('passport', 'Passport', Icons.public),
  ];

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final verState = ref.watch(verificationProvider);

    // Route on terminal profile states.
    ref.listen(currentProfileProvider, (_, next) {
      final p = next.valueOrNull;
      if (p == null) return;
      if (p.verificationStatus == 'duplicate_detected' && mounted) {
        context.pushReplacementNamed('duplicate-recovery');
      }
    });

    final profile = profileAsync.valueOrNull;
    final lockedUntil = profile?.verificationLockedUntil;
    final isLocked =
        lockedUntil != null && lockedUntil.isAfter(DateTime.now());
    final declineReason = profile?.shuftiproDeclineReason;

    return Scaffold(
      appBar: AppBar(title: const Text('Identity verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ExplainerCard(),
            const SizedBox(height: 20),
            if (profile?.verificationStatus == 'verified')
              const _VerifiedBanner()
            else ...[
              if (isLocked)
                _LockedCard(lockedUntil: lockedUntil)
              else ...[
                const Text('Pick the document you will use',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                ..._docTypes.map((t) => _DocTile(
                      label: t.$2,
                      icon: t.$3,
                      selected: _selectedType == t.$1,
                      onTap: () => setState(() => _selectedType = t.$1),
                    )),
                const SizedBox(height: 20),
                if (declineReason != null && declineReason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeonCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.neonAmber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Last attempt: $declineReason',
                                style: const TextStyle(
                                    color: AppColors.neonAmber,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (verState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(verState.error!,
                        style:
                            const TextStyle(color: AppColors.neonRed)),
                  ),
                NeonButton(
                  label: verState.polling
                      ? 'Waiting for verification…'
                      : 'Start verification',
                  icon: Icons.videocam,
                  isLoading: verState.starting,
                  onPressed: verState.polling ? null : _start,
                ),
                if (verState.polling) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Complete the verification in the browser tab — this screen will update automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
                if (profile != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Attempts used: ${profile.verificationAttempts} of 3',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    final url = await ref.read(verificationProvider.notifier).start(_selectedType);
    if (url == null || !mounted) return;
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open verification page in browser.'),
          backgroundColor: AppColors.neonRed,
        ),
      );
    }
  }
}

class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.shield, color: AppColors.neonCyan, size: 20),
                SizedBox(width: 8),
                Text('Why we ask for this',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'A short video and a photo of your ID confirms you are a real person. '
              'After verification:\n'
              '  • You get the Verified badge\n'
              '  • You can subscribe to Pro Pass\n'
              '  • Your name, age and nationality come from the ID and become locked.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.neonCyan.withOpacity(0.12)
                : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.neonCyan
                  : AppColors.bgSurface,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: selected
                      ? AppColors.neonCyan
                      : AppColors.textSecondary,
                  size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: selected
                            ? AppColors.neonCyan
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500)),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.neonCyan
                    : AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBanner extends StatelessWidget {
  const _VerifiedBanner();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.verified, color: AppColors.neonGreen, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You\'re verified. The verified badge is now visible to others.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.lockedUntil});
  final DateTime lockedUntil;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.lock, color: AppColors.neonRed, size: 20),
                SizedBox(width: 8),
                Text('Verification locked',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'You have used all 3 verification attempts. Contact support to reset.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
