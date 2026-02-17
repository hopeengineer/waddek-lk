import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications_repository.dart';
import '../domain/notification_model.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

/// Realtime notification stream.
final notificationsStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return ref.read(notificationsRepositoryProvider).streamNotifications(userId);
});

/// Unread count.
final unreadCountProvider = FutureProvider<int>((ref) async {
  return ref.read(notificationsRepositoryProvider).getUnreadCount();
});
