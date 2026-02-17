import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/services/payhere_service.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/features/wallet/presentation/providers/wallet_provider.dart';

/// Top-up screen — select a package and pay via PayHere.
class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  String? _selectedPackageId;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(topUpPackagesProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Wallet')),
      body: packagesAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (packages) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a package',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bigger packages come with bonus credits!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // ── Package Cards ──
                ...packages.map((pkg) => _PackageCard(
                      package: pkg,
                      isSelected: _selectedPackageId == pkg.id,
                      onTap: () =>
                          setState(() => _selectedPackageId = pkg.id),
                    )),

                const SizedBox(height: 24),

                // ── Payment Methods ──
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Methods',
                            style: TextStyle(
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: const [
                            _PaymentMethodChip(
                                icon: Icons.credit_card, label: 'Card'),
                            _PaymentMethodChip(
                                icon: Icons.phone_android,
                                label: 'eZ Cash'),
                            _PaymentMethodChip(
                                icon: Icons.phone_android,
                                label: 'mCash'),
                            _PaymentMethodChip(
                                icon: Icons.qr_code, label: 'Lanka QR'),
                            _PaymentMethodChip(
                                icon: Icons.account_balance,
                                label: 'Bank'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Pay Button ──
                NeonButton(
                  label: 'Pay Now',
                  isLoading: _processing,
                  onPressed: _selectedPackageId == null
                      ? null
                      : () => _processPayment(packages, profile),
                ),

                const SizedBox(height: 12),
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: AppColors.neonGreen, size: 14),
                      SizedBox(width: 4),
                      Text('Secured by PayHere',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processPayment(List packages, dynamic profile) async {
    if (profile == null || _selectedPackageId == null) return;
    setState(() => _processing = true);

    try {
      final pkg = packages.firstWhere((p) => p.id == _selectedPackageId);

      final payment = PayHereService.buildTopUpPayment(
        userId: profile.id,
        packageId: pkg.id,
        amount: pkg.amount,
        itemName: pkg.label,
        customerName: profile.fullName ?? '',
        customerPhone: profile.phone,
      );

      // TODO: Call PayHere.startPayment(payment, onCompleted, onError)
      // For now, show what would happen:
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'PayHere payment initiated for ${pkg.label} '
                '(sandbox: ${PayHereService.isSandbox})'),
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
      setState(() => _processing = false);
    }
  }
}

/// Package card widget.
class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });
  final dynamic package;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = package.amount + package.bonus;
    final hasBonus = package.bonus > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonCyan.withOpacity(0.1)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.neonCyan : AppColors.bgSurface,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected ? true : null,
                onChanged: (_) => onTap(),
                activeColor: AppColors.neonCyan,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasBonus)
                      Text(
                        '+ Rs. ${package.bonus.toStringAsFixed(0)} bonus!',
                        style: const TextStyle(
                            color: AppColors.neonGreen, fontSize: 13),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '~${(total / 75).floor()} leads',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payment method chip.
class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: AppColors.neonCyan, size: 16),
      label: Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      backgroundColor: AppColors.bgSurface,
      side: BorderSide.none,
    );
  }
}
