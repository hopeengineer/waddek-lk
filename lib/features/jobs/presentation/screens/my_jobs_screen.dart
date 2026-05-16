import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
import '../providers/jobs_provider.dart';
import '../../domain/job_model.dart';

/// Customer view: list of their posted jobs.
class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentProfileProvider).valueOrNull;
      if (profile != null) {
        ref.read(customerJobsProvider.notifier).loadJobs(profile.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(customerJobsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myJobs)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/jobs/create'),
        icon: const Icon(Icons.add),
        label: Text(l10n.postJob),
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.bgDark,
      ),
      body: jobsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_off,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text(l10n.noJobsYet,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(l10n.postFirstJob,
                      style: const TextStyle(
                          color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final profile =
                  ref.read(currentProfileProvider).valueOrNull;
              if (profile != null) {
                await ref
                    .read(customerJobsProvider.notifier)
                    .loadJobs(profile.id);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (ctx, i) => _JobListTile(
                job: jobs[i],
                onTap: () => context.push('/jobs/${jobs[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Worker view: list of available jobs in their category area.
class AvailableJobsScreen extends ConsumerStatefulWidget {
  const AvailableJobsScreen({super.key});

  @override
  ConsumerState<AvailableJobsScreen> createState() =>
      _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends ConsumerState<AvailableJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;
    final cats = await ref
        .read(profileRepositoryProvider)
        .getWorkerCategories(profile.id);
    final categoryIds =
        cats.map<String>((c) => c['category_id'] as String).toList();
    await ref.read(availableJobsProvider.notifier).loadJobs(
          workerId: profile.id,
          categoryIds: categoryIds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(availableJobsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.availableJobs)),
      body: jobsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (jobs) {
          if (jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            color: AppColors.textSecondary, size: 64),
                        const SizedBox(height: 16),
                        Text(l10n.noAvailableJobs,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(l10n.noJobsNotifyDesc,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (ctx, i) => _JobListTile(
                job: jobs[i],
                onTap: () => context.push('/jobs/${jobs[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shared job list tile widget.
class _JobListTile extends StatelessWidget {
  const _JobListTile({required this.job, required this.onTap});
  final JobModel job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(job.status);
    final categoryName =
        job.categoryData?['name_en'] as String? ?? l10n.unknown;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(job.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job.status.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category,
                        color: AppColors.neonPurple, size: 14),
                    const SizedBox(width: 4),
                    Text(categoryName,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const Spacer(),
                    if (job.budgetMin != null || job.budgetMax != null) ...[
                      const Icon(Icons.money,
                          color: AppColors.neonGreen, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _budgetText(job.budgetMin, job.budgetMax),
                        style: const TextStyle(
                            color: AppColors.neonGreen, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                if (job.address != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(job.address!,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _budgetText(double? min, double? max) {
    if (min != null && max != null) {
      return 'Rs. ${min.toInt()} – ${max.toInt()}';
    }
    if (min != null) return 'Rs. ${min.toInt()}+';
    if (max != null) return 'Up to Rs. ${max.toInt()}';
    return '';
  }

  Color _statusColor(String status) {
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
      case 'cancelled':
        return AppColors.neonRed;
      case 'disputed':
        return AppColors.neonRed;
      default:
        return AppColors.textSecondary;
    }
  }
}
