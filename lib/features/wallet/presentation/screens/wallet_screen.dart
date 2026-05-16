import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
import '../providers/wallet_provider.dart';

/// Wallet overview screen — balance, top-up, Pro Pass upsell.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    if (profile == null) return const LoadingShimmer();

    final walletAsync = ref.watch(walletStreamProvider(profile.id));
    final subAsync = ref.watch(subscriptionStreamProvider(profile.id));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Balance Card ──
            walletAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Text('${l10n.error}: $e'),
              data: (wallet) => _BalanceCard(
                balance: wallet?.balance ?? 0,
                onTopUp: () => context.push('/wallet/topup'),
              ),
            ),
            const SizedBox(height: 20),

            // ── Pro Pass Status / Upsell ──
            subAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (sub) {
                if (sub != null) {
                  return _ProPassActiveCard(
                    unlocksUsed: sub.unlocksUsed,
                    periodEnd: sub.currentPeriodEnd,
                    cancelledAt: sub.cancelledAt,
                  );
                }
                return _ProPassUpsellCard(
                  onUpgrade: () => context.push('/propass'),
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Transaction History Link ──
            NeonCard(
              child: ListTile(
                leading:
                    const Icon(Icons.receipt_long, color: AppColors.neonCyan),
                title: Text(l10n.transactionHistory,
                    style: const TextStyle(color: AppColors.textPrimary)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () => context.push('/wallet/transactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Balance display card.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.onTopUp});
  final double balance;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCyan.withOpacity(0.15),
            AppColors.neonPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(l10n.availableBalance,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            'Rs. ${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          NeonButton(label: l10n.topUp, onPressed: onTopUp),
        ],
      ),
    );
  }
}

/// Active Pro Pass card.
class _ProPassActiveCard extends StatelessWidget {
  const _ProPassActiveCard({
    required this.unlocksUsed,
    required this.periodEnd,
    this.cancelledAt,
  });
  final int unlocksUsed;
  final DateTime? periodEnd;
  final DateTime? cancelledAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysLeft = periodEnd != null
        ? periodEnd!.difference(DateTime.now()).inDays
        : 0;

    return NeonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium,
                    color: AppColors.neonCyan, size: 22),
                const SizedBox(width: 8),
                Text(l10n.proPass,
                    style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cancelledAt != null ? l10n.cancelling : l10n.active,
                    style: TextStyle(
                      color: cancelledAt != null
                          ? AppColors.neonAmber
                          : AppColors.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn(l10n.unlocksUsed, '$unlocksUsed / 50'),
                _statColumn(l10n.daysLeft, '$daysLeft'),
              ],
            ),
            if (cancelledAt != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.benefitsActiveUntil,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

/// Pro Pass upsell card (for PAYG workers).
class _ProPassUpsellCard extends StatelessWidget {
  const _ProPassUpsellCard({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NeonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium,
                    color: AppColors.neonAmber, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.upgradeToProPass,
                    style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proPassUpsellDesc,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            NeonButton(
              label: l10n.learnMore,
              onPressed: onUpgrade,
            ),
          ],
        ),
      ),
    );
  }
}
