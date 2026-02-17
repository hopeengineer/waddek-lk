import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/notification_model.dart';

/// Data layer for notification operations.
class NotificationsRepository {
  final _client = SupabaseService.client;

  /// Fetch notifications for the current user.
  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from(SupabaseConstants.notifications)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return data
        .map<NotificationModel>((n) => NotificationModel.fromJson(n))
        .toList();
  }

  /// Stream notifications in realtime.
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _client
        .from(SupabaseConstants.notifications)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .map<NotificationModel>((n) => NotificationModel.fromJson(n))
            .toList());
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from(SupabaseConstants.notifications)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all notifications as read for the current user.
  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from(SupabaseConstants.notifications)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Get unread count.
  Future<int> getUnreadCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final data = await _client
        .from(SupabaseConstants.notifications)
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (data as List).length;
  }
}
