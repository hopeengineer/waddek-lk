import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/neon_card.dart';
import '../presentation/providers/chat_provider.dart';
import '../domain/message_model.dart';

/// Conversations list screen.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: convsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline,
                      color: AppColors.textSecondary, size: 64),
                  SizedBox(height: 16),
                  Text('No conversations yet',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 18)),
                  SizedBox(height: 4),
                  Text(
                      'Chat will appear when you match with a job',
                      style: TextStyle(
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
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});
  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    final otherName =
        conversation.customerData?['full_name'] ??
            conversation.workerData?['full_name'] ??
            'Unknown';
    final avatarUrl =
        conversation.customerData?['avatar_url'] ??
            conversation.workerData?['avatar_url'];
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
          title: Text(
            otherName,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600),
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
