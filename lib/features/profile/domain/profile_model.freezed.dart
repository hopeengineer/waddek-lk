// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileModel {
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_online')
  bool get isOnline => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'jobs_completed_count')
  int get jobsCompletedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'verification_status')
  String get verificationStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'nic_front_url')
  String? get nicFrontUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'nic_back_url')
  String? get nicBackUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'nic_number')
  String? get nicNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'fcm_token')
  String? get fcmToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_locale')
  String get preferredLocale => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_text')
  String? get addressText =>
      throw _privateConstructorUsedError; // Location stored as PostGIS point — serialized separately
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
          ProfileModel value, $Res Function(ProfileModel) then) =
      _$ProfileModelCopyWithImpl<$Res, ProfileModel>;
  @useResult
  $Res call(
      {String id,
      String phone,
      String role,
      String tier,
      String? email,
      @JsonKey(name: 'full_name') String? fullName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? bio,
      @JsonKey(name: 'is_online') bool isOnline,
      @JsonKey(name: 'average_rating') double averageRating,
      @JsonKey(name: 'jobs_completed_count') int jobsCompletedCount,
      @JsonKey(name: 'verification_status') String verificationStatus,
      @JsonKey(name: 'nic_front_url') String? nicFrontUrl,
      @JsonKey(name: 'nic_back_url') String? nicBackUrl,
      @JsonKey(name: 'nic_number') String? nicNumber,
      @JsonKey(name: 'fcm_token') String? fcmToken,
      @JsonKey(name: 'preferred_locale') String preferredLocale,
      @JsonKey(name: 'address_text') String? addressText,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res, $Val extends ProfileModel>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? role = null,
    Object? tier = null,
    Object? email = freezed,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? isOnline = null,
    Object? averageRating = null,
    Object? jobsCompletedCount = null,
    Object? verificationStatus = null,
    Object? nicFrontUrl = freezed,
    Object? nicBackUrl = freezed,
    Object? nicNumber = freezed,
    Object? fcmToken = freezed,
    Object? preferredLocale = null,
    Object? addressText = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      jobsCompletedCount: null == jobsCompletedCount
          ? _value.jobsCompletedCount
          : jobsCompletedCount // ignore: cast_nullable_to_non_nullable
              as int,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String,
      nicFrontUrl: freezed == nicFrontUrl
          ? _value.nicFrontUrl
          : nicFrontUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      nicBackUrl: freezed == nicBackUrl
          ? _value.nicBackUrl
          : nicBackUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      nicNumber: freezed == nicNumber
          ? _value.nicNumber
          : nicNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLocale: null == preferredLocale
          ? _value.preferredLocale
          : preferredLocale // ignore: cast_nullable_to_non_nullable
              as String,
      addressText: freezed == addressText
          ? _value.addressText
          : addressText // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileModelImplCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$$ProfileModelImplCopyWith(
          _$ProfileModelImpl value, $Res Function(_$ProfileModelImpl) then) =
      __$$ProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String phone,
      String role,
      String tier,
      String? email,
      @JsonKey(name: 'full_name') String? fullName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? bio,
      @JsonKey(name: 'is_online') bool isOnline,
      @JsonKey(name: 'average_rating') double averageRating,
      @JsonKey(name: 'jobs_completed_count') int jobsCompletedCount,
      @JsonKey(name: 'verification_status') String verificationStatus,
      @JsonKey(name: 'nic_front_url') String? nicFrontUrl,
      @JsonKey(name: 'nic_back_url') String? nicBackUrl,
      @JsonKey(name: 'nic_number') String? nicNumber,
      @JsonKey(name: 'fcm_token') String? fcmToken,
      @JsonKey(name: 'preferred_locale') String preferredLocale,
      @JsonKey(name: 'address_text') String? addressText,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$ProfileModelImplCopyWithImpl<$Res>
    extends _$ProfileModelCopyWithImpl<$Res, _$ProfileModelImpl>
    implements _$$ProfileModelImplCopyWith<$Res> {
  __$$ProfileModelImplCopyWithImpl(
      _$ProfileModelImpl _value, $Res Function(_$ProfileModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? role = null,
    Object? tier = null,
    Object? email = freezed,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? isOnline = null,
    Object? averageRating = null,
    Object? jobsCompletedCount = null,
    Object? verificationStatus = null,
    Object? nicFrontUrl = freezed,
    Object? nicBackUrl = freezed,
    Object? nicNumber = freezed,
    Object? fcmToken = freezed,
    Object? preferredLocale = null,
    Object? addressText = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ProfileModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      jobsCompletedCount: null == jobsCompletedCount
          ? _value.jobsCompletedCount
          : jobsCompletedCount // ignore: cast_nullable_to_non_nullable
              as int,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String,
      nicFrontUrl: freezed == nicFrontUrl
          ? _value.nicFrontUrl
          : nicFrontUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      nicBackUrl: freezed == nicBackUrl
          ? _value.nicBackUrl
          : nicBackUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      nicNumber: freezed == nicNumber
          ? _value.nicNumber
          : nicNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLocale: null == preferredLocale
          ? _value.preferredLocale
          : preferredLocale // ignore: cast_nullable_to_non_nullable
              as String,
      addressText: freezed == addressText
          ? _value.addressText
          : addressText // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$ProfileModelImpl implements _ProfileModel {
  const _$ProfileModelImpl(
      {required this.id,
      required this.phone,
      this.role = 'customer',
      this.tier = 'waddek',
      this.email,
      @JsonKey(name: 'full_name') this.fullName,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      this.bio,
      @JsonKey(name: 'is_online') this.isOnline = false,
      @JsonKey(name: 'average_rating') this.averageRating = 0,
      @JsonKey(name: 'jobs_completed_count') this.jobsCompletedCount = 0,
      @JsonKey(name: 'verification_status')
      this.verificationStatus = 'unverified',
      @JsonKey(name: 'nic_front_url') this.nicFrontUrl,
      @JsonKey(name: 'nic_back_url') this.nicBackUrl,
      @JsonKey(name: 'nic_number') this.nicNumber,
      @JsonKey(name: 'fcm_token') this.fcmToken,
      @JsonKey(name: 'preferred_locale') this.preferredLocale = 'en',
      @JsonKey(name: 'address_text') this.addressText,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  @override
  final String id;
  @override
  final String phone;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final String tier;
  @override
  final String? email;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final String? bio;
  @override
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @override
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @override
  @JsonKey(name: 'jobs_completed_count')
  final int jobsCompletedCount;
  @override
  @JsonKey(name: 'verification_status')
  final String verificationStatus;
  @override
  @JsonKey(name: 'nic_front_url')
  final String? nicFrontUrl;
  @override
  @JsonKey(name: 'nic_back_url')
  final String? nicBackUrl;
  @override
  @JsonKey(name: 'nic_number')
  final String? nicNumber;
  @override
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  @override
  @JsonKey(name: 'preferred_locale')
  final String preferredLocale;
  @override
  @JsonKey(name: 'address_text')
  final String? addressText;
// Location stored as PostGIS point — serialized separately
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ProfileModel(id: $id, phone: $phone, role: $role, tier: $tier, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, bio: $bio, isOnline: $isOnline, averageRating: $averageRating, jobsCompletedCount: $jobsCompletedCount, verificationStatus: $verificationStatus, nicFrontUrl: $nicFrontUrl, nicBackUrl: $nicBackUrl, nicNumber: $nicNumber, fcmToken: $fcmToken, preferredLocale: $preferredLocale, addressText: $addressText, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.jobsCompletedCount, jobsCompletedCount) ||
                other.jobsCompletedCount == jobsCompletedCount) &&
            (identical(other.verificationStatus, verificationStatus) ||
                other.verificationStatus == verificationStatus) &&
            (identical(other.nicFrontUrl, nicFrontUrl) ||
                other.nicFrontUrl == nicFrontUrl) &&
            (identical(other.nicBackUrl, nicBackUrl) ||
                other.nicBackUrl == nicBackUrl) &&
            (identical(other.nicNumber, nicNumber) ||
                other.nicNumber == nicNumber) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.preferredLocale, preferredLocale) ||
                other.preferredLocale == preferredLocale) &&
            (identical(other.addressText, addressText) ||
                other.addressText == addressText) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        phone,
        role,
        tier,
        email,
        fullName,
        avatarUrl,
        bio,
        isOnline,
        averageRating,
        jobsCompletedCount,
        verificationStatus,
        nicFrontUrl,
        nicBackUrl,
        nicNumber,
        fcmToken,
        preferredLocale,
        addressText,
        latitude,
        longitude,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      __$$ProfileModelImplCopyWithImpl<_$ProfileModelImpl>(this, _$identity);
}

abstract class _ProfileModel implements ProfileModel {
  const factory _ProfileModel(
          {required final String id,
          required final String phone,
          final String role,
          final String tier,
          final String? email,
          @JsonKey(name: 'full_name') final String? fullName,
          @JsonKey(name: 'avatar_url') final String? avatarUrl,
          final String? bio,
          @JsonKey(name: 'is_online') final bool isOnline,
          @JsonKey(name: 'average_rating') final double averageRating,
          @JsonKey(name: 'jobs_completed_count') final int jobsCompletedCount,
          @JsonKey(name: 'verification_status') final String verificationStatus,
          @JsonKey(name: 'nic_front_url') final String? nicFrontUrl,
          @JsonKey(name: 'nic_back_url') final String? nicBackUrl,
          @JsonKey(name: 'nic_number') final String? nicNumber,
          @JsonKey(name: 'fcm_token') final String? fcmToken,
          @JsonKey(name: 'preferred_locale') final String preferredLocale,
          @JsonKey(name: 'address_text') final String? addressText,
          final double? latitude,
          final double? longitude,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$ProfileModelImpl;

  @override
  String get id;
  @override
  String get phone;
  @override
  String get role;
  @override
  String get tier;
  @override
  String? get email;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  String? get bio;
  @override
  @JsonKey(name: 'is_online')
  bool get isOnline;
  @override
  @JsonKey(name: 'average_rating')
  double get averageRating;
  @override
  @JsonKey(name: 'jobs_completed_count')
  int get jobsCompletedCount;
  @override
  @JsonKey(name: 'verification_status')
  String get verificationStatus;
  @override
  @JsonKey(name: 'nic_front_url')
  String? get nicFrontUrl;
  @override
  @JsonKey(name: 'nic_back_url')
  String? get nicBackUrl;
  @override
  @JsonKey(name: 'nic_number')
  String? get nicNumber;
  @override
  @JsonKey(name: 'fcm_token')
  String? get fcmToken;
  @override
  @JsonKey(name: 'preferred_locale')
  String get preferredLocale;
  @override
  @JsonKey(name: 'address_text')
  String?
      get addressText; // Location stored as PostGIS point — serialized separately
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) {
  return _CategoryModel.fromJson(json);
}

/// @nodoc
mixin _$CategoryModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_en')
  String get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_si')
  String? get nameSi => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_ta')
  String? get nameTa => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryModelCopyWith<CategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryModelCopyWith<$Res> {
  factory $CategoryModelCopyWith(
          CategoryModel value, $Res Function(CategoryModel) then) =
      _$CategoryModelCopyWithImpl<$Res, CategoryModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'name_en') String nameEn,
      @JsonKey(name: 'name_si') String? nameSi,
      @JsonKey(name: 'name_ta') String? nameTa,
      String? icon,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$CategoryModelCopyWithImpl<$Res, $Val extends CategoryModel>
    implements $CategoryModelCopyWith<$Res> {
  _$CategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameSi = freezed,
    Object? nameTa = freezed,
    Object? icon = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameSi: freezed == nameSi
          ? _value.nameSi
          : nameSi // ignore: cast_nullable_to_non_nullable
              as String?,
      nameTa: freezed == nameTa
          ? _value.nameTa
          : nameTa // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryModelImplCopyWith<$Res>
    implements $CategoryModelCopyWith<$Res> {
  factory _$$CategoryModelImplCopyWith(
          _$CategoryModelImpl value, $Res Function(_$CategoryModelImpl) then) =
      __$$CategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'name_en') String nameEn,
      @JsonKey(name: 'name_si') String? nameSi,
      @JsonKey(name: 'name_ta') String? nameTa,
      String? icon,
      @JsonKey(name: 'sort_order') int sortOrder,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$CategoryModelImplCopyWithImpl<$Res>
    extends _$CategoryModelCopyWithImpl<$Res, _$CategoryModelImpl>
    implements _$$CategoryModelImplCopyWith<$Res> {
  __$$CategoryModelImplCopyWithImpl(
      _$CategoryModelImpl _value, $Res Function(_$CategoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameSi = freezed,
    Object? nameTa = freezed,
    Object? icon = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_$CategoryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameSi: freezed == nameSi
          ? _value.nameSi
          : nameSi // ignore: cast_nullable_to_non_nullable
              as String?,
      nameTa: freezed == nameTa
          ? _value.nameTa
          : nameTa // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryModelImpl implements _CategoryModel {
  const _$CategoryModelImpl(
      {required this.id,
      @JsonKey(name: 'name_en') required this.nameEn,
      @JsonKey(name: 'name_si') this.nameSi,
      @JsonKey(name: 'name_ta') this.nameTa,
      this.icon,
      @JsonKey(name: 'sort_order') this.sortOrder = 0,
      @JsonKey(name: 'is_active') this.isActive = true});

  factory _$CategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'name_en')
  final String nameEn;
  @override
  @JsonKey(name: 'name_si')
  final String? nameSi;
  @override
  @JsonKey(name: 'name_ta')
  final String? nameTa;
  @override
  final String? icon;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'CategoryModel(id: $id, nameEn: $nameEn, nameSi: $nameSi, nameTa: $nameTa, icon: $icon, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameSi, nameSi) || other.nameSi == nameSi) &&
            (identical(other.nameTa, nameTa) || other.nameTa == nameTa) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, nameEn, nameSi, nameTa, icon, sortOrder, isActive);

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryModelImplCopyWith<_$CategoryModelImpl> get copyWith =>
      __$$CategoryModelImplCopyWithImpl<_$CategoryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryModelImplToJson(
      this,
    );
  }
}

abstract class _CategoryModel implements CategoryModel {
  const factory _CategoryModel(
      {required final String id,
      @JsonKey(name: 'name_en') required final String nameEn,
      @JsonKey(name: 'name_si') final String? nameSi,
      @JsonKey(name: 'name_ta') final String? nameTa,
      final String? icon,
      @JsonKey(name: 'sort_order') final int sortOrder,
      @JsonKey(name: 'is_active') final bool isActive}) = _$CategoryModelImpl;

  factory _CategoryModel.fromJson(Map<String, dynamic> json) =
      _$CategoryModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'name_en')
  String get nameEn;
  @override
  @JsonKey(name: 'name_si')
  String? get nameSi;
  @override
  @JsonKey(name: 'name_ta')
  String? get nameTa;
  @override
  String? get icon;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryModelImplCopyWith<_$CategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkerCategoryModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_id')
  String get workerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'experience_years')
  int get experienceYears =>
      throw _privateConstructorUsedError; // Joined category data (optional)
  CategoryModel? get category => throw _privateConstructorUsedError;

  /// Create a copy of WorkerCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkerCategoryModelCopyWith<WorkerCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkerCategoryModelCopyWith<$Res> {
  factory $WorkerCategoryModelCopyWith(
          WorkerCategoryModel value, $Res Function(WorkerCategoryModel) then) =
      _$WorkerCategoryModelCopyWithImpl<$Res, WorkerCategoryModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'worker_id') String workerId,
      @JsonKey(name: 'category_id') String categoryId,
      @JsonKey(name: 'experience_years') int experienceYears,
      CategoryModel? category});

  $CategoryModelCopyWith<$Res>? get category;
}

/// @nodoc
class _$WorkerCategoryModelCopyWithImpl<$Res, $Val extends WorkerCategoryModel>
    implements $WorkerCategoryModelCopyWith<$Res> {
  _$WorkerCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkerCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workerId = null,
    Object? categoryId = null,
    Object? experienceYears = null,
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      experienceYears: null == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
    ) as $Val);
  }

  /// Create a copy of WorkerCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkerCategoryModelImplCopyWith<$Res>
    implements $WorkerCategoryModelCopyWith<$Res> {
  factory _$$WorkerCategoryModelImplCopyWith(_$WorkerCategoryModelImpl value,
          $Res Function(_$WorkerCategoryModelImpl) then) =
      __$$WorkerCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'worker_id') String workerId,
      @JsonKey(name: 'category_id') String categoryId,
      @JsonKey(name: 'experience_years') int experienceYears,
      CategoryModel? category});

  @override
  $CategoryModelCopyWith<$Res>? get category;
}

/// @nodoc
class __$$WorkerCategoryModelImplCopyWithImpl<$Res>
    extends _$WorkerCategoryModelCopyWithImpl<$Res, _$WorkerCategoryModelImpl>
    implements _$$WorkerCategoryModelImplCopyWith<$Res> {
  __$$WorkerCategoryModelImplCopyWithImpl(_$WorkerCategoryModelImpl _value,
      $Res Function(_$WorkerCategoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkerCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workerId = null,
    Object? categoryId = null,
    Object? experienceYears = null,
    Object? category = freezed,
  }) {
    return _then(_$WorkerCategoryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      experienceYears: null == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
    ));
  }
}

/// @nodoc

class _$WorkerCategoryModelImpl implements _WorkerCategoryModel {
  const _$WorkerCategoryModelImpl(
      {required this.id,
      @JsonKey(name: 'worker_id') required this.workerId,
      @JsonKey(name: 'category_id') required this.categoryId,
      @JsonKey(name: 'experience_years') this.experienceYears = 0,
      this.category});

  @override
  final String id;
  @override
  @JsonKey(name: 'worker_id')
  final String workerId;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  @JsonKey(name: 'experience_years')
  final int experienceYears;
// Joined category data (optional)
  @override
  final CategoryModel? category;

  @override
  String toString() {
    return 'WorkerCategoryModel(id: $id, workerId: $workerId, categoryId: $categoryId, experienceYears: $experienceYears, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkerCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workerId, workerId) ||
                other.workerId == workerId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, workerId, categoryId, experienceYears, category);

  /// Create a copy of WorkerCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkerCategoryModelImplCopyWith<_$WorkerCategoryModelImpl> get copyWith =>
      __$$WorkerCategoryModelImplCopyWithImpl<_$WorkerCategoryModelImpl>(
          this, _$identity);
}

abstract class _WorkerCategoryModel implements WorkerCategoryModel {
  const factory _WorkerCategoryModel(
      {required final String id,
      @JsonKey(name: 'worker_id') required final String workerId,
      @JsonKey(name: 'category_id') required final String categoryId,
      @JsonKey(name: 'experience_years') final int experienceYears,
      final CategoryModel? category}) = _$WorkerCategoryModelImpl;

  @override
  String get id;
  @override
  @JsonKey(name: 'worker_id')
  String get workerId;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  @JsonKey(name: 'experience_years')
  int get experienceYears; // Joined category data (optional)
  @override
  CategoryModel? get category;

  /// Create a copy of WorkerCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkerCategoryModelImplCopyWith<_$WorkerCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
