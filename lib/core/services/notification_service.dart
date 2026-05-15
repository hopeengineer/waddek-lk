import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';

/// OneSignal push notification service.
///
/// Prerequisites:
///   - OneSignal app configured at dashboard.onesignal.com
///   - google-services.json in android/app/
///   - ONESIGNAL_APP_ID in .env
///   - ONESIGNAL_REST_API_KEY as Supabase secret (for Edge Functions)
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  bool _initialized = false;

  /// Initialize OneSignal.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // App ID from .env or hardcode during development
    const appId = String.fromEnvironment(
      'ONESIGNAL_APP_ID',
      defaultValue: '', // Set via --dart-define=ONESIGNAL_APP_ID=xxx
    );

    if (appId.isEmpty) {
      debugPrint('[NotificationService] ONESIGNAL_APP_ID not set — skipping');
      return;
    }

    // Initialize OneSignal
    OneSignal.initialize(appId);

    // Request push permission
    OneSignal.Notifications.requestPermission(true);

    // Listen for notification clicks
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      debugPrint('[NotificationService] Tapped: $data');
      _routeFromPayload(data);
    });

    // Listen for push subscription changes
    OneSignal.User.pushSubscription.addObserver((state) {
      final token = state.current.id;
      if (token != null) {
        debugPrint('[NotificationService] Push token: $token');
        _saveTokenToProfile(token);
      }
    });

    // Set external user ID for targeting from Edge Functions
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      OneSignal.login(userId);
    }

    debugPrint('[NotificationService] OneSignal initialized');
  }

  /// Call this after user logs in to link OneSignal with Supabase user.
  void setUserId(String userId) {
    OneSignal.login(userId);
  }

  /// Call on logout.
  void clearUser() {
    OneSignal.logout();
  }

  /// Route based on push payload. Keep keys in sync with the
  /// `data` field set by the broadcast-job / payhere-notify edge functions.
  void _routeFromPayload(Map<String, dynamic>? data) {
    if (data == null) return;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;

    final type = data['type'] as String?;
    switch (type) {
      case 'new_job':
      case 'bid_accepted':
      case 'bid_rejected':
        final jobId = data['job_id'] as String?;
        if (jobId != null) ctx.push('/jobs/$jobId');
        return;
      case 'job_matched':
      case 'new_message':
        final convId = data['conversation_id'] as String?;
        if (convId != null) ctx.push('/chat/$convId');
        return;
      case 'wallet':
      case 'subscription':
        ctx.push('/wallet');
        return;
      case 'dispute':
        final jobId = data['job_id'] as String?;
        if (jobId != null) ctx.push('/dispute/$jobId');
        return;
      default:
        ctx.push('/notifications');
    }
  }

  /// Save OneSignal player ID to the user's profile for targeting.
  Future<void> _saveTokenToProfile(String playerId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('profiles').update({
        'push_token': playerId,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('[NotificationService] Failed to save token: $e');
    }
  }
}
