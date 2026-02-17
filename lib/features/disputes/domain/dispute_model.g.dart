// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisputeModelImpl _$$DisputeModelImplFromJson(Map<String, dynamic> json) =>
    _$DisputeModelImpl(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      raisedBy: json['raised_by'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      status: json['status'] as String? ?? 'open',
      resolution: json['resolution'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$DisputeModelImplToJson(_$DisputeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_id': instance.jobId,
      'raised_by': instance.raisedBy,
      'reason': instance.reason,
      'description': instance.description,
      'evidence_urls': instance.evidenceUrls,
      'status': instance.status,
      'resolution': instance.resolution,
      'resolved_by': instance.resolvedBy,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
