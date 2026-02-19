import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../jobs/domain/bid_model.dart';
import '../../../jobs/data/jobs_repository.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Provider for the current worker's bids.
final workerBidsProvider =
    FutureProvider<List<BidModel>>((ref) async {
  final profile = ref.watch(currentProfileProvider).valueOrNull;
  if (profile == null) return [];
  final repo = JobsRepository();
  return repo.getWorkerBids(profile.id);
});

/// Worker bids screen — view all bids placed and their statuses.
class WorkerBidsScreen extends ConsumerWidget {
  const WorkerBidsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(workerBidsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonCyan),
            onPressed: () => ref.invalidate(workerBidsProvider),
          ),
        ],
      ),
      body: bidsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.neonRed, size: 48),
              const SizedBox(height: 16),
              Text('Error loading bids',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(workerBidsProvider),
                child:
                    const Text('Retry', style: TextStyle(color: AppColors.neonCyan)),
              ),
            ],
          ),
        ),
        data: (bids) {
          if (bids.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group bids by status
          final pendingBids =
              bids.where((b) => b.status == 'pending').toList();
          final acceptedBids =
              bids.where((b) => b.status == 'accepted').toList();
          final rejectedBids =
              bids.where((b) => b.status == 'rejected').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Summary Stats ──
              _buildSummaryRow(bids.length, pendingBids.length,
                  acceptedBids.length),
              const SizedBox(height: 20),

              // ── Accepted Bids ──
              if (acceptedBids.isNotEmpty) ...[
                _sectionTitle('Accepted', AppColors.neonGreen,
                    acceptedBids.length),
                ...acceptedBids
                    .map((b) => _BidCard(bid: b, key: ValueKey(b.id))),
                const SizedBox(height: 16),
              ],

              // ── Pending Bids ──
              if (pendingBids.isNotEmpty) ...[
                _sectionTitle('Pending', AppColors.neonAmber,
                    pendingBids.length),
                ...pendingBids
                    .map((b) => _BidCard(bid: b, key: ValueKey(b.id))),
                const SizedBox(height: 16),
              ],

              // ── Rejected Bids ──
              if (rejectedBids.isNotEmpty) ...[
                _sectionTitle(
                    'Rejected', AppColors.neonRed, rejectedBids.length),
                ...rejectedBids
                    .map((b) => _BidCard(bid: b, key: ValueKey(b.id))),
              ],

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.handshake_outlined,
                  color: AppColors.neonCyan, size: 56),
            ),
            const SizedBox(height: 24),
            Text('No bids yet', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Browse available jobs and start placing bids to earn.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/worker/jobs'),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Browse Jobs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: AppColors.scaffoldDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int total, int pending, int accepted) {
    return Row(
      children: [
        _SummaryChip(
            label: 'Total', count: total, color: AppColors.neonCyan),
        const SizedBox(width: 10),
        _SummaryChip(
            label: 'Pending', count: pending, color: AppColors.neonAmber),
        const SizedBox(width: 10),
        _SummaryChip(
            label: 'Won', count: accepted, color: AppColors.neonGreen),
      ],
    );
  }

  Widget _sectionTitle(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Summary stat chip.
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual bid card with status badge and details.
class _BidCard extends StatelessWidget {
  const _BidCard({required this.bid, super.key});
  final BidModel bid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        child: InkWell(
          onTap: () => context.pushNamed('job-detail',
              pathParameters: {'id': bid.jobId}),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status badge
                    _StatusBadge(status: bid.status),
                    const Spacer(),
                    // Amount
                    Text(
                      'Rs. ${bid.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                if (bid.message != null && bid.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    bid.message!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        color: AppColors.textDisabled, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(bid.createdAt),
                      style: AppTextStyles.labelSmall,
                    ),
                    if (!bid.isUnlocked) ...[
                      const Spacer(),
                      Icon(Icons.lock_outline,
                          color: AppColors.textDisabled, size: 14),
                      const SizedBox(width: 4),
                      Text('Locked',
                          style: AppTextStyles.labelSmall),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

/// Colored status badge.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'accepted':
        color = AppColors.neonGreen;
        label = 'Accepted';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppColors.neonRed;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.neonAmber;
        label = 'Pending';
        icon = Icons.hourglass_top;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
