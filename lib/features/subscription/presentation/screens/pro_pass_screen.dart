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
import 'package:waddek_lk/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proPass)),
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
                    AppColors.neonAmber.withOpacity(0.18),
                    AppColors.neonCyan.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.neonAmber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium,
                      size: 56, color: AppColors.neonAmber),
                  const SizedBox(height: 12),
                  Text(
                    l10n.proPass,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.proPassTagline,
                    style: const TextStyle(
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
                        l10n.proPassPriceMonthly(
                            plan.price.toStringAsFixed(0)),
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
              l10n.zeroLeadFees,
              l10n.zeroLeadFeesDesc,
              AppColors.neonGreen,
            ),
            _benefitCard(
              Icons.trending_up,
              l10n.priorityRanking,
              l10n.priorityRankingDesc,
              AppColors.neonCyan,
            ),
            _benefitCard(
              Icons.verified,
              l10n.verifiedBadgeBenefit,
              l10n.verifiedBadgeBenefitDesc,
              AppColors.neonPurple,
            ),
            _benefitCard(
              Icons.savings,
              l10n.saveMoney,
              l10n.saveMoneyDesc,
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
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.neonAmber, size: 18),
                        const SizedBox(width: 6),
                        Text(l10n.breakEvenTitle,
                            style: const TextStyle(
                                color: AppColors.neonAmber,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.breakEvenDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: AppColors.neonAmber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.verifyToSubscribe,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.proPassOnlyForVerified,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      NeonButton(
                        label: l10n.verifyIdentity,
                        icon: Icons.videocam,
                        onPressed: () => context.pushNamed('verification'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              NeonButton(
                label: l10n.subscribeToProPass,
                icon: Icons.workspace_premium,
                isLoading: _subscribing,
                onPressed: () => _subscribe(profile),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.cancelAnytime,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.payHereInitiated),
            backgroundColor: AppColors.neonCyan,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      setState(() => _subscribing = false);
    }
  }
}
