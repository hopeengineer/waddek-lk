import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// Job review (customer → worker).
@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    @JsonKey(name: 'job_id') required String jobId,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'worker_id') required String workerId,
    required int rating, // 1-5 stars
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Joined data
    @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
    @JsonKey(name: 'job') Map<String, dynamic>? jobData,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}
