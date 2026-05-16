import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/providers/role_provider.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/rating_stars.dart';
import 'package:waddek_lk/core/widgets/trust_badges.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';
import '../providers/profile_provider.dart';

/// Worker profile screen — view stats, tier, skills, portfolio.
class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l10n.noProfileFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Profile Header ──
                _buildHeader(profile),
                const SizedBox(height: 24),

                // ── Stats Row ──
                _buildStatsRow(profile, ref, l10n),
                const SizedBox(height: 24),

                // ── Verification CTA ── (hidden once verified; the
                // avatar already carries the verified badge)
                if (profile.verificationStatus != 'verified') ...[
                  _VerificationCard(profile: profile),
                  const SizedBox(height: 16),
                ],

                // ── Quick Actions ──
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.quickActions,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _actionTile(Icons.edit, l10n.editProfile,
                            () => context.push('/profile/edit')),
                        _actionTile(Icons.photo_library, l10n.portfolio,
                            () => context.push('/profile/portfolio')),
                        _actionTile(Icons.category, l10n.mySkills,
                            () => context.push('/profile/skills')),
                        _actionTile(Icons.location_on, l10n.updateLocation,
                            () => context.push('/profile/location')),
                        _actionTile(Icons.settings, l10n.settings,
                            () => context.push('/settings')),
                        const Divider(
                            color: AppColors.bgSurface, height: 16),
                        _actionTile(Icons.swap_horiz, l10n.switchToCustomerMode, () {
                          ref.read(activeRoleProvider.notifier).switchRole('customer');
                          context.go('/customer/home');
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(profile) {
    final tier = profile.tier.toString();
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
        TrustBadges(
          avatarRadius: 48,
          isVerified: profile.verificationStatus == 'verified',
          isPro: profile.isPro,
          tier: tier,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.bgSurface,
            backgroundImage: profile.avatarUrl != null
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl == null
                ? const Icon(Icons.person, size: 44,
                    color: AppColors.neonCyan)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.fullName ?? 'No name',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: tierColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tierIcon, size: 14, color: tierColor),
              const SizedBox(width: 6),
              Text(
                tier.toUpperCase(),
                style: TextStyle(
                  color: tierColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (profile.averageRating > 0)
          RatingStars(rating: profile.averageRating),
      ],
    );
  }

  Widget _buildStatsRow(profile, WidgetRef ref, AppLocalizations l10n) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statItem(l10n.jobs, profile.jobsCompletedCount.toString()),
          const SizedBox(width: 10),
          _statItem(
            l10n.rating,
            profile.averageRating > 0
                ? profile.averageRating.toStringAsFixed(1)
                : '—',
          ),
          const SizedBox(width: 10),
          _statItem(
            l10n.status,
            profile.isOnline ? l10n.online : l10n.offline,
            valueColor: profile.isOnline
                ? AppColors.neonGreen
                : AppColors.textSecondary,
            onTap: () => ref
                .read(currentProfileProvider.notifier)
                .updateProfile({'is_online': !profile.isOnline}),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value,
      {Color? valueColor, VoidCallback? onTap}) {
    return Expanded(
      child: NeonCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: valueColor ?? AppColors.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.neonCyan),
      title: Text(label,
          style: const TextStyle(color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.profile});
  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = profile.verificationStatus as String;
    final reason = profile.shuftiproDeclineReason as String?;

    late final Color color;
    late final IconData icon;
    late final String title;
    late final String? subtitle;
    late final VoidCallback? tapHandler;

    switch (status) {
      case 'verified':
        color = AppColors.neonPurple;
        icon = Icons.verified;
        title = l10n.verifiedLabel;
        subtitle = null;
        tapHandler = null;
        break;
      case 'pending':
        color = AppColors.neonAmber;
        icon = Icons.hourglass_top;
        title = 'Verification in progress';
        subtitle = 'Complete the verification in your browser tab.';
        tapHandler = () => context.pushNamed('verification');
        break;
      case 'duplicate_detected':
        color = AppColors.neonAmber;
        icon = Icons.account_circle;
        title = 'Existing account detected';
        subtitle = 'Choose how to continue.';
        tapHandler = () => context.pushNamed('duplicate-recovery');
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.shield_outlined;
        title = l10n.verifyIdentity;
        subtitle = reason != null && reason.isNotEmpty
            ? reason
            : 'Required for Pro Pass, builds trust with customers.';
        tapHandler = () => context.pushNamed('verification');
    }

    return NeonCard(
      child: InkWell(
        onTap: tapHandler,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.w600)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
          trailing: tapHandler == null
              ? null
              : const Icon(Icons.arrow_forward_ios,
                  color: AppColors.neonCyan, size: 16),
        ),
      ),
    );
  }
}
