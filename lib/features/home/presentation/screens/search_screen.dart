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
final workerSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Selected category id (set when a category chip is tapped).
final workerSearchCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final workerSearchResultsProvider =
    FutureProvider.autoDispose<List<ProfileModel>>((ref) async {
  final query = ref.watch(workerSearchQueryProvider);
  final categoryId = ref.watch(workerSearchCategoryProvider);
  if (query.length < 2 && categoryId == null) return [];
  final repo = ProfileRepository();
  return repo.searchWorkers(query: query, categoryId: categoryId);
});

/// Search screen — find workers by name, skill, or category.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.initialCategoryId, super.key});

  /// When non-null, the search opens pre-filtered to this category
  /// (e.g. from a category tile on the customer home).
  final String? initialCategoryId;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Apply initial category before focusing the search field.
      if (widget.initialCategoryId != null) {
        ref.read(workerSearchCategoryProvider.notifier).state =
            widget.initialCategoryId;
        ref.read(workerSearchQueryProvider.notifier).state = '';
      } else {
        _focusNode.requestFocus();
      }
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
    final categoryId = ref.watch(workerSearchCategoryProvider);
    final resultsAsync = ref.watch(workerSearchResultsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final hasFilter = query.isNotEmpty || categoryId != null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          onChanged: _onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search workers, services...',
            hintStyle: TextStyle(color: AppColors.textDisabled),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        actions: [
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: () {
                _searchCtrl.clear();
                ref.read(workerSearchQueryProvider.notifier).state = '';
                ref.read(workerSearchCategoryProvider.notifier).state = null;
              },
            ),
        ],
      ),
      body: hasFilter
          ? _buildResults(resultsAsync, categoryId, categoriesAsync)
          : _buildCategorySuggestions(categoriesAsync),
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
              final id = cat['id'] as String?;
              return ActionChip(
                label: Text(name),
                labelStyle: const TextStyle(color: AppColors.neonCyan),
                backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                side: BorderSide(color: AppColors.neonCyan.withOpacity(0.2)),
                onPressed: () {
                  ref.read(workerSearchCategoryProvider.notifier).state = id;
                  ref.read(workerSearchQueryProvider.notifier).state = '';
                  _searchCtrl.clear();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    AsyncValue<List<ProfileModel>> resultsAsync,
    String? categoryId,
    AsyncValue<List<Map<String, dynamic>>> categoriesAsync,
  ) {
    final categoryName = categoryId == null
        ? null
        : categoriesAsync.maybeWhen(
            data: (cats) => cats.firstWhere(
                  (c) => c['id'] == categoryId,
                  orElse: () => <String, dynamic>{},
                )['name_en'] as String?,
            orElse: () => null,
          );

    return Column(
      children: [
        if (categoryName != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.filter_alt,
                    size: 16, color: AppColors.neonCyan),
                label: Text(categoryName),
                labelStyle: const TextStyle(color: AppColors.neonCyan),
                backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                side: BorderSide(color: AppColors.neonCyan.withOpacity(0.3)),
                deleteIconColor: AppColors.neonCyan,
                onDeleted: () => ref
                    .read(workerSearchCategoryProvider.notifier)
                    .state = null,
              ),
            ),
          ),
        Expanded(child: _buildResultsList(resultsAsync)),
      ],
    );
  }

  Widget _buildResultsList(AsyncValue<List<ProfileModel>> resultsAsync) {
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
    final tierIcon = _tierIcon(worker.tier);
    final tierColor = _tierColor(worker.tier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        child: InkWell(
          // Worker detail screen not yet built — disable tap rather
          // than show a button that does nothing.
          onTap: null,
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
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: tierColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tierIcon, size: 12, color: tierColor),
                                const SizedBox(width: 4),
                                Text(
                                  worker.tier.toUpperCase(),
                                  style: TextStyle(
                                      color: tierColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Rating
                          if (worker.averageRating > 0) ...[
                            const Icon(Icons.star,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _tierIcon(String tier) {
    switch (tier) {
      case 'supiri':
        return Icons.workspace_premium;
      case 'professional':
        return Icons.verified_user;
      default:
        return Icons.bolt;
    }
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'supiri':
        return AppColors.neonAmber;
      case 'professional':
        return AppColors.neonCyan;
      default:
        return AppColors.textSecondary;
    }
  }
}
