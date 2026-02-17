import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid_model.freezed.dart';
part 'bid_model.g.dart';

/// Represents a bid placed by a worker on a job.
@freezed
class BidModel with _$BidModel {
  const factory BidModel({
    required String id,
    @JsonKey(name: 'job_id') required String jobId,
    @JsonKey(name: 'worker_id') required String workerId,
    required double amount,
    String? message,
    @Default('pending') String status,
    @JsonKey(name: 'is_unlocked') @Default(false) bool isUnlocked,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Joined worker data (optional — included on customer view)
    @JsonKey(name: 'worker') Map<String, dynamic>? workerData,
  }) = _BidModel;

  factory BidModel.fromJson(Map<String, dynamic> json) =>
      _$BidModelFromJson(json);
}
