// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewModelImpl _$$ReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$ReviewModelImpl(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      customerId: json['customer_id'] as String,
      workerId: json['worker_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      customerData: json['customer'] as Map<String, dynamic>?,
      jobData: json['job'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ReviewModelImplToJson(_$ReviewModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_id': instance.jobId,
      'customer_id': instance.customerId,
      'worker_id': instance.workerId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt?.toIso8601String(),
      'customer': instance.customerData,
      'job': instance.jobData,
    };
