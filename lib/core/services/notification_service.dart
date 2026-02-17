import 'package:flutter/foundation.dart';

/// FCM + Local notification service.
///
/// Prerequisites:
///   - `firebase_messaging` in pubspec.yaml
///   - `flutter_local_notifications` in pubspec.yaml
///   - Firebase project configured (google-services.json / GoogleService-Info.plist)
///
/// This class provides the initialization and token management.
/// Actual FCM integration requires `firebase_messaging` — marked as TODO until
/// Firebase is configured for this project.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  bool _initialized = false;

  /// Initialize FCM and local notifications.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // TODO: Initialize firebase_messaging
    // final messaging = FirebaseMessaging.instance;
    //
    // 1. Request permission
    // await messaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    //
    // 2. Get FCM token
    // final token = await messaging.getToken();
    // debugPrint('FCM Token: $token');
    //
    // 3. Listen for token refresh
    // messaging.onTokenRefresh.listen((newToken) {
    //   // Update profile with new FCM token
    // });
    //
    // 4. Handle foreground messages
    // FirebaseMessaging.onMessage.listen((message) {
    //   _showLocalNotification(message);
    // });
    //
    // 5. Handle background/terminated tap
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   _handleNotificationTap(message);
    // });

    debugPrint('[NotificationService] Initialized (FCM pending Firebase setup)');
  }

  /// Get the current FCM token (or null if not initialized).
  Future<String?> getToken() async {
    // TODO: return FirebaseMessaging.instance.getToken();
    return null;
  }
}
