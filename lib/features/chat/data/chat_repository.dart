import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/message_model.dart';

/// Data layer for chat operations.
class ChatRepository {
  final _client = SupabaseService.client;

  /// Fetch a single conversation by id (with joined party + job).
  /// We DO request `phone` in the joined select — the
  /// "Profiles: counterparty can read" RLS policy only returns a
  /// non-null row when a `matched` (or later) job exists between
  /// the two parties, so phone is naturally null before agreement.
  Future<ConversationModel?> getConversation(String id) async {
    final row = await _client
        .from(SupabaseConstants.conversations)
        .select('''
          *,
          customer:profiles!customer_id(id, full_name, avatar_url, phone),
          worker:profiles!worker_id(id, full_name, avatar_url, phone),
          job:jobs!job_id(id, title, status)
        ''')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return ConversationModel.fromJson(row);
  }

  /// Send a job-proposal message — encoded as JSON in `content` so
  /// the chat bubble can render the title/price/date without an
  /// extra fetch. The bound job_id stays in the payload so the
  /// worker's Accept button knows which job to flip.
  Future<MessageModel> sendJobProposal({
    required String conversationId,
    required String jobId,
    required String title,
    double? price,
    DateTime? scheduledAt,
    String? categoryName,
  }) async {
    final payload = {
      'job_id': jobId,
      'title': title,
      if (price != null) 'price': price,
      if (scheduledAt != null)
        'scheduled_at': scheduledAt.toIso8601String(),
      if (categoryName != null) 'category_name': categoryName,
    };
    return sendMessage(
      conversationId: conversationId,
      content: jsonEncode(payload),
      type: 'job_proposal',
    );
  }

  /// Fetch conversations for the current user.
  Future<List<ConversationModel>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from(SupabaseConstants.conversations)
        .select('''
          *,
          customer:profiles!customer_id(id, full_name, avatar_url),
          worker:profiles!worker_id(id, full_name, avatar_url),
          job:jobs!job_id(id, title, status)
        ''')
        .or('customer_id.eq.$userId,worker_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return data
        .map<ConversationModel>((c) => ConversationModel.fromJson(c))
        .toList();
  }

  /// Find or create the canonical chat thread between the current
  /// user and a worker. Reuses the most recent conversation between
  /// the pair in EITHER direction (so prior threads where the roles
  /// were swapped still surface), regardless of the bound job's
  /// status — message history should stay accessible even after a
  /// job completes. Only inserts a new row when no thread exists.
  Future<ConversationModel> findOrCreateConversationWith(
      String workerId) async {
    final me = _client.auth.currentUser?.id;
    if (me == null) throw Exception('Not authenticated');

    final existing = await _client
        .from(SupabaseConstants.conversations)
        .select()
        .or(
          'and(customer_id.eq.$me,worker_id.eq.$workerId),'
          'and(customer_id.eq.$workerId,worker_id.eq.$me)',
        )
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false)
        .limit(1);
    if (existing.isNotEmpty) {
      return ConversationModel.fromJson(existing.first);
    }

    // No thread exists yet — create one with me as customer.
    final data = await _client
        .from(SupabaseConstants.conversations)
        .insert({
          'customer_id': me,
          'worker_id': workerId,
        })
        .select()
        .single();
    return ConversationModel.fromJson(data);
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

    // No manual conversations.last_message_at update — the
    // `trg_messages_bump_conversation` trigger keeps it current.

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
