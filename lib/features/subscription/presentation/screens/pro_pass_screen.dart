import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/services/payhere_service.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/features/subscription/presentation/providers/subscription_provider.dart';

/// Pro Pass screen — benefits, pricing, subscribe CTA.
class ProPassScreen extends ConsumerStatefulWidget {
  const ProPassScreen({super.key});

  @override
  ConsumerState<ProPassScreen> createState() => _ProPassScreenState();
}

class _ProPassScreenState extends ConsumerState<ProPassScreen> {
  bool _subscribing = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Waddek Pro Pass')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Hero ──
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonPurple.withOpacity(0.18),
                    AppColors.neonCyan.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.neonPurple.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium,
                      size: 56, color: AppColors.neonPurple),
                  const SizedBox(height: 12),
                  const Text(
                    'Waddek Pro Pass',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The smartest way to grow your business',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  plansAsync.when(
                    loading: () => const LoadingShimmer(),
                    error: (e, _) => Text('$e'),
                    data: (plans) {
                      if (plans.isEmpty) return const SizedBox.shrink();
                      final plan = plans.first;
                      return Text(
                        'Rs. ${plan.price.toStringAsFixed(0)} / month',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Benefits ──
            _benefitCard(
              Icons.money_off,
              'Zero Lead Fees',
              'Unlock customer details for free — up to 50 per month.',
              AppColors.neonGreen,
            ),
            _benefitCard(
              Icons.trending_up,
              'Priority Ranking',
              'Your bids appear first. Get notified before PAYG workers.',
              AppColors.neonCyan,
            ),
            _benefitCard(
              Icons.verified,
              'Verified Badge',
              'Stand out with the Pro badge on your profile and bids.',
              AppColors.neonPurple,
            ),
            _benefitCard(
              Icons.savings,
              'Save Money',
              'Doing 20+ jobs/month? Pro Pass costs less than lead fees.',
              AppColors.neonAmber,
            ),
            const SizedBox(height: 8),

            // ── Break-even ──
            NeonCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lightbulb_outline,
                            color: AppColors.neonAmber, size: 18),
                        SizedBox(width: 6),
                        Text('Break-even calculation',
                            style: TextStyle(
                                color: AppColors.neonAmber,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'At Rs. 75/lead, Pro Pass pays for itself after just 20 unlocks. '
                      'That leaves you 30 more for free!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Subscribe CTA ──
            if (profile?.verificationStatus != 'verified') ...[
              NeonCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: AppColors.neonAmber, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verify your identity to subscribe',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pro Pass is for verified users only. It takes about a minute.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: 'Verify identity',
                        icon: Icons.videocam,
                        onPressed: () => context.pushNamed('verification'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              NeonButton(
                label: 'Subscribe to Pro Pass',
                icon: Icons.workspace_premium,
                isLoading: _subscribing,
                onPressed: () => _subscribe(profile),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cancel anytime. No lock-in.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _benefitCard(
      IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        child: ListTile(
          leading: Icon(icon, color: color, size: 28),
          title: Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
          subtitle: Text(desc,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ),
      ),
    );
  }

  Future<void> _subscribe(dynamic profile) async {
    if (profile == null) return;
    setState(() => _subscribing = true);

    try {
      final payment = PayHereService.buildSubscriptionPayment(
        userId: profile.id,
        amount: 1500, // Pro Pass price
        customerName: profile.fullName ?? '',
        customerPhone: profile.phone,
      );

      // TODO: Call PayHere.startPayment(payment, onCompleted, onError)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PayHere subscription payment initiated'),
            backgroundColor: AppColors.neonCyan,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      setState(() => _subscribing = false);
    }
  }
}
