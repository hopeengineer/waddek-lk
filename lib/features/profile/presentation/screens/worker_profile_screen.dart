import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/rating_stars.dart';
import '../providers/profile_provider.dart';

/// Worker profile screen — view stats, tier, skills, portfolio.
class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.neonCyan),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Profile Header ──
                _buildHeader(profile),
                const SizedBox(height: 24),

                // ── Stats Row ──
                _buildStatsRow(profile),
                const SizedBox(height: 24),

                // ── Verification Status ──
                _buildVerificationCard(profile),
                const SizedBox(height: 16),

                // ── Quick Actions ──
                NeonCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Actions',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _actionTile(Icons.edit, 'Edit Profile', () {}),
                        _actionTile(Icons.photo_library, 'Portfolio', () {}),
                        _actionTile(Icons.category, 'My Skills', () {}),
                        _actionTile(Icons.location_on, 'Update Location', () {}),
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
    final tierEmoji = {
      'waddek': '⚡',
      'professional': '🔷',
      'supiri': '👑',
    }[profile.tier] ?? '⚡';

    return Column(
      children: [
        CircleAvatar(
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
            color: AppColors.neonCyan.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$tierEmoji ${profile.tier.toString().toUpperCase()}',
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (profile.averageRating > 0)
          RatingStars(rating: profile.averageRating),
      ],
    );
  }

  Widget _buildStatsRow(profile) {
    return Row(
      children: [
        _statItem('Jobs Done', profile.jobsCompletedCount.toString()),
        _statItem('Rating',
            profile.averageRating > 0 ? profile.averageRating.toStringAsFixed(1) : '—'),
        _statItem('Status',
            profile.isOnline ? 'Online' : 'Offline'),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: NeonCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard(profile) {
    final status = profile.verificationStatus;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'verified':
        statusColor = AppColors.neonGreen;
        statusIcon = Icons.verified;
        statusText = 'Verified ✓';
        break;
      case 'pending':
        statusColor = AppColors.neonAmber;
        statusIcon = Icons.hourglass_top;
        statusText = 'Verification Pending';
        break;
      case 'rejected':
        statusColor = AppColors.neonRed;
        statusIcon = Icons.cancel;
        statusText = 'Verification Rejected';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.info_outline;
        statusText = 'Not Verified — Submit NIC to get verified';
    }

    return NeonCard(
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
        subtitle: status == 'unverified'
            ? const Text('Upload your NIC to start receiving jobs',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12))
            : null,
        trailing: status == 'unverified'
            ? const Icon(Icons.arrow_forward_ios,
                color: AppColors.neonCyan, size: 16)
            : null,
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
