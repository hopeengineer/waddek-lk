import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute_model.freezed.dart';
part 'dispute_model.g.dart';

/// Dispute raised by a customer or worker.
@freezed
class DisputeModel with _$DisputeModel {
  const factory DisputeModel({
    required String id,
    @JsonKey(name: 'job_id') required String jobId,
    @JsonKey(name: 'raised_by') required String raisedBy,
    required String reason,
    String? description,
    @JsonKey(name: 'evidence_urls') List<String>? evidenceUrls,
    /// 'open', 'investigating', 'resolved', 'dismissed'
    @Default('open') String status,
    String? resolution,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DisputeModel;

  factory DisputeModel.fromJson(Map<String, dynamic> json) =>
      _$DisputeModelFromJson(json);
}
