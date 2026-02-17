import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:waddek_lk/features/wallet/domain/wallet_model.dart';

/// Transaction history screen — shows all wallet transactions.
class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    if (profile == null) return const LoadingShimmer();

    final walletAsync = ref.watch(walletStreamProvider(profile.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: walletAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallet) {
          if (wallet == null) {
            return const Center(child: Text('No wallet found'));
          }
          return _TransactionList(walletId: wallet.id);
        },
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList({required this.walletId});
  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider(walletId));

    return txAsync.when(
      loading: () => const LoadingShimmer(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.receipt_long,
                    color: AppColors.textSecondary, size: 64),
                SizedBox(height: 16),
                Text('No transactions yet',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 18)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (ctx, i) => _TransactionTile(tx: transactions[i]),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});
  final TransactionModel tx;

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.amount >= 0;
    final color = isCredit ? AppColors.neonGreen : AppColors.neonRed;
    final icon = _typeIcon(tx.type);
    final dateStr = tx.createdAt?.toString().split('.').first ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            tx.description ?? tx.type.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(dateStr,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : ""}Rs. ${tx.amount.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (tx.balanceAfter != null)
                Text(
                  'Bal: Rs. ${tx.balanceAfter!.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'top_up':
        return Icons.add_circle;
      case 'lead_fee':
        return Icons.work;
      case 'subscription':
        return Icons.card_membership;
      case 'refund':
        return Icons.replay;
      default:
        return Icons.receipt;
    }
  }
}
