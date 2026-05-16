import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waddek_lk/core/theme/app_colors.dart';
import 'package:waddek_lk/core/widgets/loading_shimmer.dart';
import 'package:waddek_lk/core/widgets/neon_card.dart';
import 'package:waddek_lk/features/chat/presentation/providers/chat_provider.dart';
import 'package:waddek_lk/features/chat/domain/message_model.dart';
import 'package:waddek_lk/features/profile/presentation/providers/profile_provider.dart';
import 'package:waddek_lk/l10n/app_localizations.dart';

/// Conversations list screen.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationsProvider);
    final myId = ref.watch(currentProfileProvider).valueOrNull?.id;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messages)),
      body: convsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text(l10n.noConversations,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(l10n.chatWillAppear,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: conversations.length,
            itemBuilder: (ctx, i) => _ConversationTile(
              conversation: conversations[i],
              myId: myId,
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.myId});
  final ConversationModel conversation;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    // Pick the other party's name/avatar from whichever side I'm NOT on.
    final iAmCustomer = myId != null && myId == conversation.customerId;
    final iAmWorker = myId != null && myId == conversation.workerId;
    final other = iAmCustomer
        ? conversation.workerData
        : iAmWorker
            ? conversation.customerData
            : (conversation.customerData ?? conversation.workerData);
    final otherName = (other?['full_name'] as String?) ?? 'Unknown';
    final avatarUrl = other?['avatar_url'] as String?;
    final jobTitle = conversation.jobData?['title'] ?? 'Job';
    final timeAgo = _formatTimeAgo(conversation.lastMessageAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NeonCard(
        child: ListTile(
          onTap: () =>
              context.push('/chat/${conversation.id}'),
          leading: CircleAvatar(
            backgroundColor: AppColors.neonCyan.withOpacity(0.15),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    otherName.isNotEmpty
                        ? otherName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: AppColors.neonCyan),
                  )
                : null,
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  otherName,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (iAmCustomer || iAmWorker) ...[
                const SizedBox(width: 6),
                _RoleChip(
                  label: iAmWorker ? 'Waddek' : 'Customer',
                  color: iAmWorker
                      ? AppColors.neonGreen
                      : AppColors.neonCyan,
                ),
              ],
            ],
          ),
          subtitle: Text(
            jobTitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(timeAgo,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

/// Tiny pill showing which side of an interaction the current user is on.
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
