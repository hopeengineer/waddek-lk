// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletModelImpl _$$WalletModelImplFromJson(Map<String, dynamic> json) =>
    _$WalletModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$WalletModelImplToJson(_$WalletModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'balance': instance.balance,
      'version': instance.version,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
      description: json['description'] as String?,
      jobId: json['job_id'] as String?,
      payhereOrderId: json['payhere_order_id'] as String?,
      paymentMethod: json['payment_method'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wallet_id': instance.walletId,
      'type': instance.type,
      'amount': instance.amount,
      'balance_after': instance.balanceAfter,
      'description': instance.description,
      'job_id': instance.jobId,
      'payhere_order_id': instance.payhereOrderId,
      'payment_method': instance.paymentMethod,
      'idempotency_key': instance.idempotencyKey,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$TopUpPackageImpl _$$TopUpPackageImplFromJson(Map<String, dynamic> json) =>
    _$TopUpPackageImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      label: json['label'] as String,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$TopUpPackageImplToJson(_$TopUpPackageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'label': instance.label,
      'bonus': instance.bonus,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };
