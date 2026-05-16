import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/rating_stars.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
import '../providers/jobs_provider.dart';
import '../../domain/bid_model.dart';

/// Job detail screen — shows job info + bids (realtime for customers).
class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({required this.jobId, super.key});
  final String jobId;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _broadcasting = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(jobsRepositoryProvider);
    final bidsAsync = ref.watch(jobBidsProvider(widget.jobId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jobDetails)),
      body: FutureBuilder(
        future: repo.getJob(widget.jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingShimmer();
          }
          final job = snapshot.data;
          if (job == null) {
            return Center(child: Text(l10n.jobNotFound));
          }

          final categoryName =
              job.categoryData?['name_en'] as String? ?? l10n.unknown;
          final customerName =
              job.customerData?['full_name'] as String? ?? l10n.customer;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Expanded(
                      child: Text(job.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ),
                    _StatusBadge(status: job.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(l10n.byCustomer(customerName),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    // Phone reveal — visible only when RLS lets the
                    // join hand us a phone (i.e. the caller is the
                    // matched counterparty on this job).
                    Builder(builder: (ctx) {
                      final phone =
                          job.customerData?['phone'] as String?;
                      if (phone == null || phone.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: phone));
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Phone copied: $phone')),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: AppColors.neonGreen,
                                    size: 14),
                                const SizedBox(width: 4),
                                Text(phone,
                                    style: const TextStyle(
                                        color: AppColors.neonGreen,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Info Cards ──
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _detailRow(Icons.category, l10n.category, categoryName),
                        const Divider(color: AppColors.bgSurface, height: 20),
                        if (job.address != null)
                          _detailRow(
                              Icons.location_on, l10n.address, job.address!),
                        if (job.budgetMin != null || job.budgetMax != null) ...[
                          const Divider(
                              color: AppColors.bgSurface, height: 20),
                          _detailRow(
                            Icons.money,
                            l10n.budget,
                            _budgetText(job.budgetMin, job.budgetMax),
                          ),
                        ],
                        if (job.scheduledAt != null) ...[
                          const Divider(
                              color: AppColors.bgSurface, height: 20),
                          _detailRow(Icons.calendar_today, l10n.scheduled,
                              job.scheduledAt!.toString().split(' ').first),
                        ],
                      ],
                    ),
                  ),
                ),

                if (job.description != null &&
                    job.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  NeonCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.description,
                              style: const TextStyle(
                                  color: AppColors.neonCyan,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(job.description!,
                              style: const TextStyle(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Broadcast Button (draft only) ──
                if (job.status == 'draft') ...[
                  const SizedBox(height: 24),
                  NeonButton(
                    label: l10n.broadcastToWorkers,
                    icon: Icons.broadcast_on_personal,
                    isLoading: _broadcasting,
                    onPressed: () => _broadcastJob(job.id),
                  ),
                ],

                // ── Bids Section ──
                const SizedBox(height: 24),
                Text(l10n.bids,
                    style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                bidsAsync.when(
                  loading: () => const LoadingShimmer(),
                  error: (e, _) => Text('${l10n.error}: $e'),
                  data: (bids) {
                    if (bids.isEmpty) {
                      return NeonCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.hourglass_empty,
                                  color: AppColors.textSecondary, size: 36),
                              const SizedBox(height: 8),
                              Text(l10n.noBidsYet,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(l10n.workersWillBid,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: bids
                          .map((b) => _BidCard(
                                bid: b,
                                jobStatus: job.status,
                                onAccept: () => _acceptBid(job.id, b),
                                onReject: () => _rejectBid(b.id),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 18),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14)),
        ),
      ],
    );
  }

  String _budgetText(double? min, double? max) {
    if (min != null && max != null) return 'Rs. ${min.toInt()} – ${max.toInt()}';
    if (min != null) return 'Rs. ${min.toInt()}+';
    if (max != null) return 'Up to Rs. ${max.toInt()}';
    return '';
  }

  Future<void> _broadcastJob(String jobId) async {
    setState(() => _broadcasting = true);
    try {
      await ref.read(customerJobsProvider.notifier).broadcastJob(jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job broadcast to nearby workers.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        setState(() {}); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.neonRed),
        );
      }
    } finally {
      setState(() => _broadcasting = false);
    }
  }

  Future<void> _acceptBid(String jobId, BidModel bid) async {
    try {
      await ref.read(customerJobsProvider.notifier).acceptBidAndMatch(
            jobId: jobId,
            bidId: bid.id,
            workerId: bid.workerId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid accepted. Worker matched.'),
            backgroundColor: AppColors.neonGreen,
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
    }
  }

  Future<void> _rejectBid(String bidId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Decline bid?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'The worker will be notified. You can still accept other bids.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Decline',
                style: TextStyle(color: AppColors.neonRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(customerJobsProvider.notifier).rejectBid(bidId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid declined.'),
            backgroundColor: AppColors.neonAmber,
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
    }
  }
}

/// Status badge widget.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _color() {
    switch (status) {
      case 'draft':
        return AppColors.textSecondary;
      case 'broadcast':
      case 'bidding':
        return AppColors.neonCyan;
      case 'matched':
      case 'in_progress':
        return AppColors.neonAmber;
      case 'completed':
        return AppColors.neonGreen;
      default:
        return AppColors.neonRed;
    }
  }
}

/// Bid card — shows worker info and accept button.
class _BidCard extends StatelessWidget {
  const _BidCard({
    required this.bid,
    required this.jobStatus,
    required this.onAccept,
    required this.onReject,
  });
  final BidModel bid;
  final String jobStatus;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final workerName =
        bid.workerData?['full_name'] as String? ?? 'Worker';
    final rating =
        (bid.workerData?['average_rating'] as num?)?.toDouble() ?? 0;
    final tier = bid.workerData?['tier'] as String? ?? 'waddek';
    final tierIcon = tier == 'supiri'
        ? Icons.workspace_premium
        : tier == 'professional'
            ? Icons.verified_user
            : Icons.bolt;
    final tierColor = tier == 'supiri'
        ? AppColors.neonAmber
        : tier == 'professional'
            ? AppColors.neonCyan
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.bgSurface,
                    backgroundImage: bid.workerData?['avatar_url'] != null
                        ? NetworkImage(
                            bid.workerData!['avatar_url'] as String)
                        : null,
                    child: bid.workerData?['avatar_url'] == null
                        ? const Icon(Icons.person,
                            color: AppColors.neonCyan, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(workerName,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Icon(tierIcon, size: 14, color: tierColor),
                          ],
                        ),
                        if (rating > 0) RatingStars(rating: rating, size: 14),
                      ],
                    ),
                  ),
                  Text(
                    'Rs. ${bid.amount.toInt()}',
                    style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (bid.message != null && bid.message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(bid.message!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
              if (bid.status == 'pending' &&
                  (jobStatus == 'bidding' || jobStatus == 'broadcast')) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onReject,
                      child: const Text('Decline',
                          style: TextStyle(color: AppColors.neonRed)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: AppColors.bgDark,
                      ),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
              if (bid.status == 'accepted')
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle,
                          color: AppColors.neonGreen, size: 14),
                      SizedBox(width: 4),
                      Text('Accepted',
                          style: TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
