import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/theme/app_text_styles.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_button.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/rating_stars.dart';
import 'package:waddek_lk/features/reviews/presentation/providers/reviews_provider.dart';
import '../providers/profile_provider.dart';

/// Public worker profile — what customers see when they tap a worker
/// in search results. Aggregates profile, skills, portfolio, reviews.
class WorkerDetailScreen extends ConsumerWidget {
  const WorkerDetailScreen({super.key, required this.workerId});

  final String workerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerAsync = ref.watch(workerProfileProvider(workerId));
    final skillsAsync = ref.watch(workerSkillsProvider(workerId));
    final portfolioAsync = ref.watch(workerPortfolioProvider(workerId));
    final reviewsAsync = ref.watch(workerReviewsProvider(workerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Profile')),
      body: workerAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Could not load worker: $e')),
        data: (worker) {
          if (worker == null) {
            return const Center(child: Text('Worker not found'));
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Header(worker: worker),
                    const SizedBox(height: 20),
                    _StatsRow(worker: worker),
                    const SizedBox(height: 20),
                    if (worker.bio != null && worker.bio!.isNotEmpty) ...[
                      _SectionTitle('About'),
                      const SizedBox(height: 8),
                      NeonCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(worker.bio!,
                              style: AppTextStyles.bodyMedium),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _SectionTitle('Skills'),
                    const SizedBox(height: 8),
                    skillsAsync.when(
                      loading: () => const SizedBox(
                        height: 40,
                        child: LoadingShimmer(),
                      ),
                      error: (e, _) => Text('Could not load skills: $e',
                          style: AppTextStyles.bodySmall),
                      data: (skills) {
                        if (skills.isEmpty) {
                          return Text('No skills listed yet.',
                              style: AppTextStyles.bodySmall);
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skills.map((s) {
                            final cat = s['categories'] as Map<String, dynamic>?;
                            final name =
                                cat?['name_en'] as String? ?? 'Skill';
                            final years =
                                (s['experience_years'] as num?)?.toInt() ?? 0;
                            return Chip(
                              backgroundColor:
                                  AppColors.neonCyan.withOpacity(0.1),
                              side: BorderSide(
                                  color: AppColors.neonCyan.withOpacity(0.3)),
                              label: Text(
                                years > 0 ? '$name · ${years}y' : name,
                                style: const TextStyle(
                                    color: AppColors.neonCyan, fontSize: 12),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Portfolio'),
                    const SizedBox(height: 8),
                    portfolioAsync.when(
                      loading: () => const SizedBox(
                          height: 120, child: LoadingShimmer()),
                      error: (e, _) => Text('Could not load portfolio: $e',
                          style: AppTextStyles.bodySmall),
                      data: (images) {
                        if (images.isEmpty) {
                          return Text('No portfolio images yet.',
                              style: AppTextStyles.bodySmall);
                        }
                        return SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final url = images[i]['image_url'] as String?;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: url == null
                                    ? Container(
                                        width: 120,
                                        color: AppColors.bgSurface)
                                    : Image.network(url,
                                        width: 120, fit: BoxFit.cover),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('Reviews'),
                    const SizedBox(height: 8),
                    reviewsAsync.when(
                      loading: () => const SizedBox(
                          height: 60, child: LoadingShimmer()),
                      error: (e, _) => Text('Could not load reviews: $e',
                          style: AppTextStyles.bodySmall),
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Text('No reviews yet.',
                              style: AppTextStyles.bodySmall);
                        }
                        return Column(
                          children: reviews
                              .take(5)
                              .map((r) => _ReviewTile(
                                    rating: r.rating,
                                    comment: r.comment,
                                    customerName:
                                        r.customerData?['full_name']
                                                as String? ??
                                            'Customer',
                                    customerAvatar:
                                        r.customerData?['avatar_url']
                                            as String?,
                                    createdAt: r.createdAt,
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    NeonButton(
                      label: 'Post a job for this worker',
                      icon: Icons.send,
                      onPressed: () =>
                          context.push('/jobs/create', extra: workerId),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.worker});
  final dynamic worker;

  @override
  Widget build(BuildContext context) {
    final tier = worker.tier.toString();
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

    return Column(
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: AppColors.bgSurface,
          backgroundImage: worker.avatarUrl != null
              ? NetworkImage(worker.avatarUrl!)
              : null,
          child: worker.avatarUrl == null
              ? const Icon(Icons.person,
                  size: 50, color: AppColors.neonCyan)
              : null,
        ),
        const SizedBox(height: 12),
        Text(worker.fullName ?? 'Worker', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tierIcon, color: tierColor, size: 14),
                  const SizedBox(width: 6),
                  Text(tier.toUpperCase(),
                      style: TextStyle(
                          color: tierColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1)),
                ],
              ),
            ),
            if (worker.verificationStatus == 'verified') ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified,
                  color: AppColors.neonGreen, size: 20),
            ],
          ],
        ),
        if (worker.averageRating > 0) ...[
          const SizedBox(height: 10),
          RatingStars(rating: worker.averageRating, size: 18),
        ],
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.worker});
  final dynamic worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: 'Jobs Done',
          value: '${worker.jobsCompletedCount}',
        ),
        _StatTile(
          label: 'Rating',
          value: worker.averageRating > 0
              ? worker.averageRating.toStringAsFixed(1)
              : '—',
        ),
        _StatTile(
          label: 'Status',
          value: worker.isOnline ? 'Online' : 'Offline',
          color: worker.isOnline
              ? AppColors.neonGreen
              : AppColors.textSecondary,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: NeonCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                      color: color ?? AppColors.neonCyan,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.h4);
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.rating,
    required this.customerName,
    this.comment,
    this.customerAvatar,
    this.createdAt,
  });

  final int rating;
  final String customerName;
  final String? comment;
  final String? customerAvatar;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.bgSurface,
                    backgroundImage: customerAvatar != null
                        ? NetworkImage(customerAvatar!)
                        : null,
                    child: customerAvatar == null
                        ? const Icon(Icons.person,
                            color: AppColors.neonCyan, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(customerName,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                  RatingStars(rating: rating.toDouble(), size: 12),
                ],
              ),
              if (comment != null && comment!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(comment!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
