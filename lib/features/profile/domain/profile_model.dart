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
    @JsonKey(name: 'active_role') @Default('customer') String activeRole,
    @JsonKey(name: 'registration_completed') @Default(false) bool registrationCompleted,
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
    // Pending contact changes — staged until OTP / link is verified.
    @JsonKey(name: 'pending_phone') String? pendingPhone,
    @JsonKey(name: 'pending_email') String? pendingEmail,
    // ID verification — only `dateOfBirth` is sensitive and never
    // surfaced in public_profiles; `age` is computed there instead.
    @JsonKey(name: 'id_doc_type') String? idDocType,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    String? gender,
    String? nationality,
    int? age,
    @JsonKey(name: 'identity_locked') @Default(false) bool identityLocked,
    @JsonKey(name: 'verification_attempts')
    @Default(0)
    int verificationAttempts,
    @JsonKey(name: 'verification_locked_until')
    DateTime? verificationLockedUntil,
    @JsonKey(name: 'duplicate_target_user_id') String? duplicateTargetUserId,
    @JsonKey(name: 'shuftipro_decline_reason') String? shuftiproDeclineReason,
    @JsonKey(name: 'is_pro') @Default(false) bool isPro,
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
    return ProfileModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      activeRole: json['active_role'] as String? ?? json['role'] as String? ?? 'customer',
      registrationCompleted: json['registration_completed'] as bool? ?? false,
      tier: json['tier'] as String? ?? 'waddek',
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      jobsCompletedCount: (json['jobs_completed_count'] as num?)?.toInt() ?? 0,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      nicFrontUrl: json['nic_front_url'] as String?,
      nicBackUrl: json['nic_back_url'] as String?,
      nicNumber: json['nic_number'] as String?,
      fcmToken: json['fcm_token'] as String?,
      preferredLocale: json['preferred_locale'] as String? ?? 'en',
      addressText: json['address_text'] as String?,
      pendingPhone: json['pending_phone'] as String?,
      pendingEmail: json['pending_email'] as String?,
      idDocType: json['id_doc_type'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      age: (json['age'] as num?)?.toInt(),
      identityLocked: json['identity_locked'] as bool? ?? false,
      verificationAttempts:
          (json['verification_attempts'] as num?)?.toInt() ?? 0,
      verificationLockedUntil: json['verification_locked_until'] != null
          ? DateTime.parse(json['verification_locked_until'] as String)
          : null,
      duplicateTargetUserId: json['duplicate_target_user_id'] as String?,
      shuftiproDeclineReason: json['shuftipro_decline_reason'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      latitude: lat ?? (json['latitude'] as num?)?.toDouble(),
      longitude: lng ?? (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
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
    return WorkerCategoryModel(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      categoryId: json['category_id'] as String,
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      category: catData is Map<String, dynamic> ? CategoryModel.fromJson(catData) : null,
    );
  }
}
