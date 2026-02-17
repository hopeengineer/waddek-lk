import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

/// Worker's Waddek Wallet.
@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @Default(0.0) double balance,
    @Default(0) int version,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _WalletModel;

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
}

/// A wallet transaction (top-up, lead fee, subscription, refund).
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'wallet_id') required String walletId,
    /// 'top_up', 'lead_fee', 'subscription', 'refund'
    required String type,
    required double amount,
    @JsonKey(name: 'balance_after') double? balanceAfter,
    String? description,
    @JsonKey(name: 'job_id') String? jobId,
    @JsonKey(name: 'payhere_order_id') String? payhereOrderId,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'idempotency_key') String? idempotencyKey,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

/// Pre-defined top-up package.
@freezed
class TopUpPackage with _$TopUpPackage {
  const factory TopUpPackage({
    required String id,
    required double amount,
    required String label,
    @Default(0.0) double bonus,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _TopUpPackage;

  factory TopUpPackage.fromJson(Map<String, dynamic> json) =>
      _$TopUpPackageFromJson(json);
}
