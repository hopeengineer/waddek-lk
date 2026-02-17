import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_model.freezed.dart';

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
    return JobModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'draft',
      matchedWorkerId: json['matched_worker_id'] as String?,
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at'] as String) : null,
      photoUrls: (json['photo_urls'] as List?)?.cast<String>(),
      broadcastRadiusKm: (json['broadcast_radius_km'] as num?)?.toInt() ?? 5,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      latitude: lat ?? (json['latitude'] as num?)?.toDouble(),
      longitude: lng ?? (json['longitude'] as num?)?.toDouble(),
      customerData: json['customer'] as Map<String, dynamic>?,
      categoryData: json['category'] as Map<String, dynamic>?,
      bidCount: (json['bid_count'] as num?)?.toInt(),
    );
  }
}
