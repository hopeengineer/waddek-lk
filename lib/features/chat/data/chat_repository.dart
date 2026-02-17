import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/message_model.dart';

/// Data layer for chat operations.
class ChatRepository {
  final _client = SupabaseService.client;

  /// Fetch conversations for the current user.
  Future<List<ConversationModel>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from(SupabaseConstants.conversations)
        .select('''
          *,
          customer:profiles!customer_id(id, full_name, avatar_url, phone),
          worker:profiles!worker_id(id, full_name, avatar_url, phone),
          job:jobs!job_id(id, title, status)
        ''')
        .or('customer_id.eq.$userId,worker_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return data
        .map<ConversationModel>((c) => ConversationModel.fromJson(c))
        .toList();
  }

  /// Get or create a conversation for a job match.
  Future<ConversationModel> getOrCreateConversation({
    required String jobId,
    required String customerId,
    required String workerId,
  }) async {
    // Check if exists
    final existing = await _client
        .from(SupabaseConstants.conversations)
        .select()
        .eq('job_id', jobId)
        .maybeSingle();

    if (existing != null) return ConversationModel.fromJson(existing);

    // Create new
    final data = await _client
        .from(SupabaseConstants.conversations)
        .insert({
          'job_id': jobId,
          'customer_id': customerId,
          'worker_id': workerId,
        })
        .select()
        .single();

    return ConversationModel.fromJson(data);
  }

  /// Stream messages for a conversation in realtime.
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _client
        .from(SupabaseConstants.messages)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows
            .map<MessageModel>((m) => MessageModel.fromJson(m))
            .toList());
  }

  /// Send a text message.
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = await _client
        .from(SupabaseConstants.messages)
        .insert({
          'conversation_id': conversationId,
          'sender_id': userId,
          'content': content,
          'type': type,
        })
        .select()
        .single();

    // Update conversation's last_message_at
    await _client
        .from(SupabaseConstants.conversations)
        .update({'last_message_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);

    return MessageModel.fromJson(data);
  }

  /// Mark messages as read.
  Future<void> markMessagesAsRead(String conversationId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from(SupabaseConstants.messages)
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }
}
