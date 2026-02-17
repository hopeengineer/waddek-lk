import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/subscription_model.dart';

/// Data layer for subscription operations.
class SubscriptionRepository {
  final _client = SupabaseService.client;

  /// Fetch worker's active subscription.
  Future<SubscriptionModel?> getActiveSubscription(String workerId) async {
    final data = await _client
        .from(SupabaseConstants.subscriptions)
        .select()
        .eq('worker_id', workerId)
        .eq('status', 'active')
        .maybeSingle();
    if (data == null) return null;
    return SubscriptionModel.fromJson(data);
  }

  /// Fetch subscription plans.
  Future<List<SubscriptionPlan>> getPlans() async {
    final data = await _client
        .from(SupabaseConstants.subscriptionPlans)
        .select()
        .eq('is_active', true);
    return data
        .map<SubscriptionPlan>((p) => SubscriptionPlan.fromJson(p))
        .toList();
  }

  /// Stream subscription status.
  Stream<SubscriptionModel?> streamSubscription(String workerId) {
    return _client
        .from(SupabaseConstants.subscriptions)
        .stream(primaryKey: ['id'])
        .eq('worker_id', workerId)
        .map((rows) {
      final active = rows.where((r) => r['status'] == 'active');
      if (active.isEmpty) return null;
      return SubscriptionModel.fromJson(active.first);
    });
  }

  /// Cancel subscription (sets cancelled_at, stays active until period end).
  Future<void> cancelSubscription(String subscriptionId) async {
    await _client
        .from(SupabaseConstants.subscriptions)
        .update({'cancelled_at': DateTime.now().toIso8601String()})
        .eq('id', subscriptionId);
  }
}
