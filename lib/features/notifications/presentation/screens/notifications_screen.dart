import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:waddek_lk/features/notifications/domain/notification_model.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';

/// Notifications screen — realtime feed with mark-all-read.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    if (profile == null) return const LoadingShimmer();

    final notifsAsync =
        ref.watch(notificationsStreamProvider(profile.id));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(notificationsRepositoryProvider)
                  .markAllAsRead();
            },
            child: Text(l10n.markAllRead,
                style: const TextStyle(
                    color: AppColors.neonCyan, fontSize: 12)),
          ),
        ],
      ),
      body: notifsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text(l10n.noNotificationsYet,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(l10n.wellNotifyYou,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (ctx, i) =>
                _NotificationTile(notification: notifications[i], ref: ref),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.ref});
  final NotificationModel notification;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcon(notification.type);
    final color = _typeColor(notification.type);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.bgCard
            : AppColors.neonCyan.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead
            ? null
            : Border.all(color: AppColors.neonCyan.withOpacity(0.15)),
      ),
      child: ListTile(
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationsRepositoryProvider)
                .markAsRead(notification.id);
          }
          // Navigate based on notification type + data
          final data = notification.data;
          switch (notification.type) {
            case 'new_job':
            case 'bid_accepted':
              final jobId = data?['job_id'] as String?;
              if (jobId != null) {
                context.pushNamed('job-detail',
                    pathParameters: {'id': jobId});
              }
              break;
            case 'job_matched':
              final convId = data?['conversation_id'] as String?;
              if (convId != null) {
                context.push('/chat/$convId');
              }
              break;
            case 'wallet':
            case 'subscription':
              context.push('/wallet');
              break;
            default:
              break;
          }
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                notification.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ..._roleChipFor(notification.type),
          ],
        ),
        subtitle: notification.body != null
            ? Text(
                notification.body!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeAgo,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.neonCyan,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'new_job':
        return Icons.work_outline;
      case 'bid_accepted':
        return Icons.check_circle_outline;
      case 'job_matched':
        return Icons.handshake;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'subscription':
        return Icons.card_membership;
      case 'review':
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'new_job':
        return AppColors.neonCyan;
      case 'bid_accepted':
        return AppColors.neonGreen;
      case 'job_matched':
        return AppColors.neonPurple;
      case 'wallet':
        return AppColors.neonAmber;
      case 'subscription':
        return AppColors.neonCyan;
      case 'review':
        return AppColors.neonAmber;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  /// Return a role chip widget (wrapped in a leading spacer) for types
  /// we can confidently classify. Ambiguous types get no chip.
  List<Widget> _roleChipFor(String type) {
    switch (type) {
      case 'new_job':
      case 'bid_accepted':
      case 'subscription':
        return [
          const SizedBox(width: 6),
          const _RoleChip(label: 'Waddek', color: AppColors.neonGreen),
        ];
      default:
        return const [];
    }
  }
}

/// Tiny pill showing which side of an interaction this item belongs to.
class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.35), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
