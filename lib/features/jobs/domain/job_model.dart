import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

/// Represents a job posted by a customer.
@freezed
class JobModel with _$JobModel {
  const factory JobModel({
    required String id,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'category_id') required String categoryId,
    required String title,
    String? description,
    String? address,
    @JsonKey(name: 'budget_min') double? budgetMin,
    @JsonKey(name: 'budget_max') double? budgetMax,
    @Default('draft') String status,
    @JsonKey(name: 'matched_worker_id') String? matchedWorkerId,
    @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    @JsonKey(name: 'photo_urls') List<String>? photoUrls,
    @JsonKey(name: 'broadcast_radius_km') @Default(5) int broadcastRadiusKm,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Location — parsed from PostGIS geography
    double? latitude,
    double? longitude,
    // Joined data (optional)
    @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
    @JsonKey(name: 'category') Map<String, dynamic>? categoryData,
    @JsonKey(name: 'bid_count') int? bidCount,
  }) = _JobModel;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    double? lat;
    double? lng;
    if (location is Map) {
      final coords = location['coordinates'] as List?;
      if (coords != null && coords.length == 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }
    return _$JobModelFromJson({
      ...json,
      'latitude': lat ?? json['latitude'],
      'longitude': lng ?? json['longitude'],
    });
  }
}
