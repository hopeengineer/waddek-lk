import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

/// Represents a user profile (customer or worker).
@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    required String phone,
    @Default('customer') String role,
    @Default('waddek') String tier,
    String? email,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    @JsonKey(name: 'average_rating') @Default(0) double averageRating,
    @JsonKey(name: 'jobs_completed_count') @Default(0) int jobsCompletedCount,
    @JsonKey(name: 'verification_status')
    @Default('unverified')
    String verificationStatus,
    @JsonKey(name: 'nic_front_url') String? nicFrontUrl,
    @JsonKey(name: 'nic_back_url') String? nicBackUrl,
    @JsonKey(name: 'nic_number') String? nicNumber,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'preferred_locale') @Default('en') String preferredLocale,
    @JsonKey(name: 'address_text') String? addressText,
    // Location stored as PostGIS point — serialized separately
    double? latitude,
    double? longitude,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Extract lat/lng from PostGIS geography if present
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
    return _$ProfileModelFromJson({
      ...json,
      'latitude': lat ?? json['latitude'],
      'longitude': lng ?? json['longitude'],
    });
  }
}

/// Represents a category for worker skills / job types.
@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    @JsonKey(name: 'name_en') required String nameEn,
    @JsonKey(name: 'name_si') String? nameSi,
    @JsonKey(name: 'name_ta') String? nameTa,
    String? icon,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

/// Worker-category link with experience.
@freezed
class WorkerCategoryModel with _$WorkerCategoryModel {
  const factory WorkerCategoryModel({
    required String id,
    @JsonKey(name: 'worker_id') required String workerId,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'experience_years') @Default(0) int experienceYears,
    // Joined category data (optional)
    CategoryModel? category,
  }) = _WorkerCategoryModel;

  factory WorkerCategoryModel.fromJson(Map<String, dynamic> json) {
    // Handle nested category join from Supabase
    final catData = json['categories'];
    return _$WorkerCategoryModelFromJson({
      ...json,
      if (catData is Map<String, dynamic>) 'category': catData,
    });
  }
}
