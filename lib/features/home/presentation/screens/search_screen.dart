import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Debounced search provider for workers.
final workerSearchQueryProvider = StateProvider<String>((ref) => '');

final workerSearchResultsProvider =
    FutureProvider<List<ProfileModel>>((ref) async {
  final query = ref.watch(workerSearchQueryProvider);
  if (query.length < 2) return [];
  final repo = ProfileRepository();
  return repo.searchWorkers(query: query);
});

/// Search screen — find workers by name, skill, or category.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(workerSearchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(workerSearchQueryProvider);
    final resultsAsync = ref.watch(workerSearchResultsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          onChanged: _onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search workers, services...',
            hintStyle: TextStyle(color: AppColors.textDisabled),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        actions: [
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: () {
                _searchCtrl.clear();
                ref.read(workerSearchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? _buildCategorySuggestions(categoriesAsync)
          : _buildResults(resultsAsync),
    );
  }

  Widget _buildCategorySuggestions(
      AsyncValue<List<Map<String, dynamic>>> categoriesAsync) {
    return categoriesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Popular Services',
              style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final name = cat['name_en'] as String? ?? 'Category';
              return ActionChip(
                label: Text(name),
                labelStyle: const TextStyle(color: AppColors.neonCyan),
                backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                side: BorderSide(color: AppColors.neonCyan.withOpacity(0.2)),
                onPressed: () {
                  _searchCtrl.text = name;
                  ref.read(workerSearchQueryProvider.notifier).state = name;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AsyncValue<List<ProfileModel>> resultsAsync) {
    return resultsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.neonRed, size: 48),
            const SizedBox(height: 16),
            Text('Search failed', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
      data: (workers) {
        if (workers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off,
                    color: AppColors.textDisabled, size: 64),
                const SizedBox(height: 16),
                Text('No workers found',
                    style: AppTextStyles.h4
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Try a different search term',
                    style: TextStyle(
                        color: AppColors.textDisabled, fontSize: 13)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workers.length,
          itemBuilder: (ctx, i) => _WorkerResultCard(worker: workers[i]),
        );
      },
    );
  }
}

/// Worker result card showing avatar, name, rating, tier, and verification.
class _WorkerResultCard extends StatelessWidget {
  const _WorkerResultCard({required this.worker});
  final ProfileModel worker;

  @override
  Widget build(BuildContext context) {
    final tierEmoji = {
      'waddek': '⚡',
      'professional': '🔷',
      'supiri': '👑',
    }[worker.tier] ?? '⚡';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        child: InkWell(
          onTap: () {
            // TODO: Navigate to worker detail/booking screen
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.bgSurface,
                  backgroundImage: worker.avatarUrl != null
                      ? NetworkImage(worker.avatarUrl!)
                      : null,
                  child: worker.avatarUrl == null
                      ? Text(
                          (worker.fullName ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              worker.fullName ?? 'Unknown',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (worker.verificationStatus == 'verified') ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.neonGreen, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Tier
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$tierEmoji ${worker.tier.toUpperCase()}',
                              style: const TextStyle(
                                  color: AppColors.neonCyan, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Rating
                          if (worker.averageRating > 0) ...[
                            Icon(Icons.star,
                                color: AppColors.neonAmber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              worker.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppColors.neonAmber, fontSize: 12),
                            ),
                          ],
                          const SizedBox(width: 8),
                          // Jobs count
                          Text(
                            '${worker.jobsCompletedCount} jobs',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
