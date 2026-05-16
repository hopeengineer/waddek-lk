import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../../core/utils/i18n_helpers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Inline-search query for the customer home. When length >= 2, the
/// discovery body switches from nearby workers to search results.
final homeSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Search results fetched by the home page's inline search bar.
/// Empty when query is too short.
final homeSearchResultsProvider =
    FutureProvider.autoDispose<List<ProfileModel>>((ref) async {
  final query = ref.watch(homeSearchQueryProvider);
  final categoryId = ref.watch(selectedDiscoveryCategoryProvider);
  if (query.length < 2) return [];
  final repo = ref.read(profileRepositoryProvider);
  return repo.searchWorkers(query: query, categoryId: categoryId);
});

/// Customer home — discovery feed of nearby workers, filterable by
/// category chip and an online-only toggle. Replaces the old static
/// "Browse Services" grid.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final locationAsync = ref.watch(customerLocationProvider);
    final workersAsync = ref.watch(nearbyWorkersProvider);
    final selectedCat = ref.watch(selectedDiscoveryCategoryProvider);
    final onlineOnly = ref.watch(discoveryOnlineOnlyProvider);
    final searchQuery = ref.watch(homeSearchQueryProvider);
    final isSearching = searchQuery.length >= 2;
    final searchResults = ref.watch(homeSearchResultsProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.neonCyan,
            onRefresh: () async {
              ref.invalidate(customerLocationProvider);
              ref.invalidate(nearbyWorkersProvider);
              await ref.read(customerLocationProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _Header(
                      name: profileAsync.valueOrNull?.fullName,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Search bar ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const _SearchBar(),
                  ),
                ),

                // ── Quick actions ──────────────────────────────
                // Quick actions kept lean — My Jobs / Messages /
                // Profile all live in the bottom nav or top avatar.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    // Default CrossAxisAlignment.center — Row inside a
                    // sliver has unbounded vertical extent, and
                    // .stretch tries to force children to fill that
                    // infinite height, throwing "BoxConstraints
                    // forces an infinite height".
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_circle_outline,
                            label: l10n.postJobShort,
                            color: AppColors.neonCyan,
                            onTap: () => context.pushNamed('create-job'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.workspace_premium,
                            label: l10n.proPassShort,
                            color: AppColors.neonAmber,
                            onTap: () => context.pushNamed('propass'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Discovery header + online toggle ───────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l10n.nearestWorkers,
                              style: AppTextStyles.h4),
                        ),
                        Text(l10n.onlineOnly,
                            style: AppTextStyles.bodySmall),
                        const SizedBox(width: 6),
                        // Don't wrap in Transform.scale — on
                        // desktop/web that makes the Switch's hit
                        // region and visual region disagree, which
                        // makes Flutter's MouseTracker fire its
                        // re-entrancy assert on every hover event
                        // (mouse_tracker.dart:199). shrinkWrap alone
                        // gives the tighter footprint we want.
                        Switch.adaptive(
                          value: onlineOnly,
                          activeColor: AppColors.neonCyan,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (v) => ref
                              .read(discoveryOnlineOnlyProvider.notifier)
                              .state = v,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Category chips row ─────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: categoriesAsync.when(
                      loading: () => const Center(
                          child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                  color: AppColors.neonCyan))),
                      error: (e, _) => Center(
                          child: Text('Categories: $e',
                              style: AppTextStyles.bodySmall)),
                      data: (cats) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cats.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          if (i == 0) {
                            return _CategoryChip(
                              label: l10n.all,
                              selected: selectedCat == null,
                              onTap: () => ref
                                  .read(selectedDiscoveryCategoryProvider
                                      .notifier)
                                  .state = null,
                            );
                          }
                          final cat = cats[i - 1];
                          final id = cat['id'] as String;
                          return _CategoryChip(
                            label: localizedCategoryName(cat, locale),
                            selected: selectedCat == id,
                            onTap: () => ref
                                .read(selectedDiscoveryCategoryProvider
                                    .notifier)
                                .state = id,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Body: search results OR location-aware list ──
                if (isSearching)
                  _buildSearchBody(context, searchResults, l10n)
                else
                  _buildDiscoveryBody(
                    context: context,
                    ref: ref,
                    locationAsync: locationAsync,
                    workersAsync: workersAsync,
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header (name + avatar) ───────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({this.name});
  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.morningGreeting
        : hour < 17
            ? l10n.afternoonGreeting
            : l10n.eveningGreeting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(name ?? l10n.fallbackName,
            style: AppTextStyles.h2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ── Inline search bar ────────────────────────────────────────────
class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Sync local controller with any pre-existing query in provider
    // (e.g. tab change → return).
    final existing = ref.read(homeSearchQueryProvider);
    if (existing.isNotEmpty) _ctrl.text = existing;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(homeSearchQueryProvider.notifier).state = value.trim();
    });
    setState(() {}); // refresh the suffix clear icon
  }

  void _clear() {
    _ctrl.clear();
    _debounce?.cancel();
    ref.read(homeSearchQueryProvider.notifier).state = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _ctrl.text.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.neonCyan.withOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)!.findServiceOrWorker,
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (hasQuery)
              IconButton(
                icon: const Icon(Icons.clear,
                    color: AppColors.textSecondary, size: 20),
                onPressed: _clear,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Category chip ────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.neonCyan
          : AppColors.bgCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? AppColors.bgDark : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Search body: results from the inline search bar ─────────────
//
// Renders a sliver of worker tiles built from `ProfileModel` results.
// We adapt each `ProfileModel` into the `Map<String, dynamic>` shape
// that `_WorkerTile` already consumes, so the visual format stays
// identical to nearby results. Search results don't have a
// `distance_m` or `categories` list (different RPC), so those parts
// of the tile gracefully fall back to empty.
Widget _buildSearchBody(BuildContext context,
    AsyncValue<List<ProfileModel>> resultsAsync, AppLocalizations l10n) {
  return resultsAsync.when(
    loading: () => const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      ),
    ),
    error: (e, _) => SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(l10n.searchFailed,
            style: AppTextStyles.bodySmall),
      ),
    ),
    data: (workers) {
      if (workers.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.search_off,
                      color: AppColors.textDisabled, size: 64),
                  const SizedBox(height: 12),
                  Text(l10n.noWorkersFound,
                      style: AppTextStyles.h4
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(l10n.tryDifferentSearch,
                      style: const TextStyle(
                          color: AppColors.textDisabled, fontSize: 13)),
                ],
              ),
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final w = workers[i];
              return _WorkerTile(worker: _profileToMap(w));
            },
            childCount: workers.length,
          ),
        ),
      );
    },
  );
}

/// Adapter so `_WorkerTile` (which reads from a Map) can render a
/// `ProfileModel` returned by the search RPC.
Map<String, dynamic> _profileToMap(ProfileModel p) {
  return {
    'id': p.id,
    'full_name': p.fullName,
    'avatar_url': p.avatarUrl,
    'tier': p.tier,
    'average_rating': p.averageRating,
    'jobs_completed_count': p.jobsCompletedCount,
    'verification_status': p.verificationStatus,
    'is_online': p.isOnline,
    'is_pro': p.isPro,
    // search RPC doesn't expose distance or categories
    'distance_m': null,
    'categories': const <Map<String, dynamic>>[],
  };
}

// ── Discovery body: handles permission states ────────────────────
// Must be a function, not a ConsumerWidget — it returns a Sliver, and
// CustomScrollView.slivers only accepts widgets whose Element produces
// a RenderSliver. Wrapping the returned sliver inside a ConsumerWidget
// (RenderBox) makes the viewport silently render nothing.
Widget _buildDiscoveryBody({
  required BuildContext context,
  required WidgetRef ref,
  required AsyncValue<({double lat, double lng})?> locationAsync,
  required AsyncValue<List<Map<String, dynamic>>> workersAsync,
}) {
  return locationAsync.when(
    loading: () => const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      ),
    ),
    error: (e, _) => SliverToBoxAdapter(
      child: _LocationPrompt(
        onRetry: () => ref.invalidate(customerLocationProvider),
      ),
    ),
    data: (loc) {
      if (loc == null) {
        return SliverToBoxAdapter(
          child: _LocationPrompt(
            onRetry: () => ref.invalidate(customerLocationProvider),
          ),
        );
      }
      return workersAsync.when(
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LoadingShimmer(),
          ),
        ),
        error: (e, _) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Could not load workers: $e',
                style: AppTextStyles.bodySmall),
          ),
        ),
        data: (workers) {
          if (workers.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.location_searching,
                          color: AppColors.textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text(l10n.noWorkersMatch,
                          style: const TextStyle(
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                          l10n.tryDifferentCategory,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _WorkerTile(worker: workers[i]),
                childCount: workers.length,
              ),
            ),
          );
        },
      );
    },
  );
}

// ── Location permission prompt ───────────────────────────────────
class _LocationPrompt extends StatelessWidget {
  const _LocationPrompt({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_off,
                      color: AppColors.neonAmber, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.enableLocation,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.enableLocationDesc,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.my_location,
                      color: AppColors.neonCyan, size: 16),
                  label: Text(AppLocalizations.of(context)!.tryAgain,
                      style: const TextStyle(color: AppColors.neonCyan)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Worker tile ──────────────────────────────────────────────────
class _WorkerTile extends StatelessWidget {
  const _WorkerTile({required this.worker});
  final Map<String, dynamic> worker;

  @override
  Widget build(BuildContext context) {
    final tier = worker['tier'] as String? ?? 'waddek';
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
    final rating = (worker['average_rating'] as num?)?.toDouble() ?? 0;
    final distanceM =
        (worker['distance_m'] as num?)?.toDouble() ?? double.nan;
    final isOnline = worker['is_online'] == true;
    final jobs = (worker['jobs_completed_count'] as num?)?.toInt() ?? 0;
    final avatarUrl = worker['avatar_url'] as String?;
    final name = worker['full_name'] as String? ?? 'Worker';
    final id = worker['id'] as String;
    final verified = worker['verification_status'] == 'verified';
    final isPro = worker['is_pro'] == true;
    final locale = Localizations.localeOf(context);
    final categoriesRaw = worker['categories'];
    final categories = (categoriesRaw is List)
        ? categoriesRaw
            .whereType<Map<String, dynamic>>()
            .map((c) => localizedCategoryName(c, locale))
            .where((s) => s.isNotEmpty && s != '?')
            .toList()
        : const <String>[];

    // distanceM is NaN when the row came from the search RPC (which
    // doesn't compute distance). Empty label in that case.
    final distanceLabel = distanceM.isNaN
        ? ''
        : distanceM < 1000
            ? '${distanceM.round()} m'
            : '${(distanceM / 1000).toStringAsFixed(distanceM < 10000 ? 1 : 0)} km';

    return NeonCard(
      onTap: () => GoRouter.of(context).push('/workers/$id'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.bgSurface,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.neonCyan,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.bgDark, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(name,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: AppColors.neonPurple, size: 14),
                          ],
                          if (isPro) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.workspace_premium,
                                color: AppColors.neonAmber, size: 14),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(tierIcon, size: 12, color: tierColor),
                          const SizedBox(width: 4),
                          Text(tier.toUpperCase(),
                              style: TextStyle(
                                  color: tierColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          if (rating > 0) ...[
                            const Icon(Icons.star,
                                color: AppColors.neonAmber, size: 13),
                            const SizedBox(width: 2),
                            Text(rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: AppColors.neonAmber,
                                    fontSize: 12)),
                            const SizedBox(width: 10),
                          ],
                          Text(
                              AppLocalizations.of(context)!.jobsCountLabel(jobs),
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      if (categories.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          categories.join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.2),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(distanceLabel,
                        style: const TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ],
            ),
    );
  }
}

// ── Quick action button ──────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Padding halved from the previous values (v:12/h:6 → v:6/h:3)
      // so the card auto-fits the available column width from
      // Expanded, including on small-width phones.
      child: NeonCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
