// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BidModelImpl _$$BidModelImplFromJson(Map<String, dynamic> json) =>
    _$BidModelImpl(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      workerId: json['worker_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'pending',
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      workerData: json['worker'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BidModelImplToJson(_$BidModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_id': instance.jobId,
      'worker_id': instance.workerId,
      'amount': instance.amount,
      'message': instance.message,
      'status': instance.status,
      'is_unlocked': instance.isUnlocked,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'worker': instance.workerData,
    };
