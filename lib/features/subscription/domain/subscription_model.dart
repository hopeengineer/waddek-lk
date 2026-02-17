import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Waddek Pro Pass subscription.
@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    @JsonKey(name: 'worker_id') required String workerId,
    @JsonKey(name: 'plan_id') required String planId,
    /// 'active', 'past_due', 'cancelled', 'expired'
    @Default('active') String status,
    @JsonKey(name: 'payhere_subscription_id') String? payhereSubscriptionId,
    @JsonKey(name: 'current_period_start') DateTime? currentPeriodStart,
    @JsonKey(name: 'current_period_end') DateTime? currentPeriodEnd,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'unlocks_used') @Default(0) int unlocksUsed,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

/// Subscription plan (e.g. Waddek Pro Pass).
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required double price,
    @JsonKey(name: 'period_days') @Default(30) int periodDays,
    @JsonKey(name: 'unlock_cap') @Default(50) int unlockCap,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}
