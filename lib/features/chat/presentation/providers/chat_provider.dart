import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../domain/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Conversations list.
final conversationsProvider =
    FutureProvider<List<ConversationModel>>((ref) async {
  return ref.read(chatRepositoryProvider).getConversations();
});

/// Realtime messages stream for a conversation.
final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.read(chatRepositoryProvider).streamMessages(conversationId);
});
