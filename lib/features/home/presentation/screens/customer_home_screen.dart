import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Customer home screen — browse categories, search, and post jobs.
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profileAsync.valueOrNull?.fullName ?? 'there',
                                  style: AppTextStyles.h2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Avatar
                          GestureDetector(
                            onTap: () => context.go('/customer/profile'),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.neonCyan, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.bgSurface,
                                backgroundImage:
                                    profileAsync.valueOrNull?.avatarUrl != null
                                        ? NetworkImage(profileAsync
                                            .valueOrNull!.avatarUrl!)
                                        : null,
                                child:
                                    profileAsync.valueOrNull?.avatarUrl == null
                                        ? const Icon(Icons.person,
                                            color: AppColors.neonCyan, size: 22)
                                        : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Search Bar ──
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to search screen
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neonCyan.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  color:
                                      AppColors.neonCyan.withOpacity(0.6)),
                              const SizedBox(width: 12),
                              Text(
                                'Find a service or worker...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Actions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      _QuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'Post Job',
                        color: AppColors.neonCyan,
                        onTap: () => context.pushNamed('create-job'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.work_outline,
                        label: 'My Jobs',
                        color: AppColors.neonPurple,
                        onTap: () => context.go('/customer/jobs'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.chat_bubble_outline,
                        label: 'Messages',
                        color: AppColors.neonGreen,
                        onTap: () => context.pushNamed('conversations'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.star_outline,
                        label: 'Pro Pass',
                        color: AppColors.neonAmber,
                        onTap: () => context.pushNamed('propass'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Categories Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Text('Browse Services',
                      style: AppTextStyles.h4),
                ),
              ),

              // ── Categories Grid ──
              categoriesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                          color: AppColors.neonCyan),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Error loading categories: $e',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No categories available',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cat = categories[index];
                          return _CategoryCard(
                            name: cat['name_en'] as String? ?? 'Category',
                            icon: cat['icon'] as String?,
                            onTap: () {
                              // TODO: Navigate to category job list
                            },
                          );
                        },
                        childCount: categories.length,
                      ),
                    ),
                  );
                },
              ),

              // ── Bottom Padding ──
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

/// Quick action button for the home screen.
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: NeonCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Category card with icon and name.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final String? icon;
  final VoidCallback onTap;

  static const _iconMap = <String, IconData>{
    'plumbing': Icons.plumbing,
    'electrical': Icons.electrical_services,
    'cleaning': Icons.cleaning_services,
    'painting': Icons.format_paint,
    'carpentry': Icons.carpenter,
    'ac': Icons.ac_unit,
    'gardening': Icons.grass,
    'moving': Icons.local_shipping,
    'beauty': Icons.spa,
    'cooking': Icons.restaurant,
    'tutoring': Icons.school,
    'driving': Icons.directions_car,
    'photography': Icons.camera_alt,
    'pet_care': Icons.pets,
    'tailoring': Icons.content_cut,
    'tech': Icons.computer,
  };

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = _iconMap[icon?.toLowerCase()] ?? Icons.build;
    // Cycle through accent colors based on hashCode for variety
    final colors = [
      AppColors.neonCyan,
      AppColors.neonPurple,
      AppColors.neonGreen,
      AppColors.neonAmber,
    ];
    final accentColor = colors[name.hashCode.abs() % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(resolvedIcon, color: accentColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
