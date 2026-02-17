import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/subscription_repository.dart';
import '../domain/subscription_model.dart';

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

/// Active subscription — realtime stream.
final subscriptionStreamProvider =
    StreamProvider.family<SubscriptionModel?, String>((ref, workerId) {
  return ref
      .read(subscriptionRepositoryProvider)
      .streamSubscription(workerId);
});

/// Subscription plans.
final subscriptionPlansProvider =
    FutureProvider<List<SubscriptionPlan>>((ref) async {
  return ref.read(subscriptionRepositoryProvider).getPlans();
});
