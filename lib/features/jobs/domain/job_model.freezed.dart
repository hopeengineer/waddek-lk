// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$JobModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'budget_min')
  double? get budgetMin => throw _privateConstructorUsedError;
  @JsonKey(name: 'budget_max')
  double? get budgetMax => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'matched_worker_id')
  String? get matchedWorkerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_urls')
  List<String>? get photoUrls => throw _privateConstructorUsedError;
  @JsonKey(name: 'broadcast_radius_km')
  int get broadcastRadiusKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Location — parsed from PostGIS geography
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Joined data (optional)
  @JsonKey(name: 'customer')
  Map<String, dynamic>? get customerData => throw _privateConstructorUsedError;
  @JsonKey(name: 'category')
  Map<String, dynamic>? get categoryData => throw _privateConstructorUsedError;
  @JsonKey(name: 'bid_count')
  int? get bidCount => throw _privateConstructorUsedError;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobModelCopyWith<JobModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobModelCopyWith<$Res> {
  factory $JobModelCopyWith(JobModel value, $Res Function(JobModel) then) =
      _$JobModelCopyWithImpl<$Res, JobModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'category_id') String categoryId,
      String title,
      String? description,
      String? address,
      @JsonKey(name: 'budget_min') double? budgetMin,
      @JsonKey(name: 'budget_max') double? budgetMax,
      String status,
      @JsonKey(name: 'matched_worker_id') String? matchedWorkerId,
      @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
      @JsonKey(name: 'photo_urls') List<String>? photoUrls,
      @JsonKey(name: 'broadcast_radius_km') int broadcastRadiusKm,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
      @JsonKey(name: 'category') Map<String, dynamic>? categoryData,
      @JsonKey(name: 'bid_count') int? bidCount});
}

/// @nodoc
class _$JobModelCopyWithImpl<$Res, $Val extends JobModel>
    implements $JobModelCopyWith<$Res> {
  _$JobModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? categoryId = null,
    Object? title = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? status = null,
    Object? matchedWorkerId = freezed,
    Object? scheduledAt = freezed,
    Object? photoUrls = freezed,
    Object? broadcastRadiusKm = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? customerData = freezed,
    Object? categoryData = freezed,
    Object? bidCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as double?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      matchedWorkerId: freezed == matchedWorkerId
          ? _value.matchedWorkerId
          : matchedWorkerId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoUrls: freezed == photoUrls
          ? _value.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      broadcastRadiusKm: null == broadcastRadiusKm
          ? _value.broadcastRadiusKm
          : broadcastRadiusKm // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      customerData: freezed == customerData
          ? _value.customerData
          : customerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      categoryData: freezed == categoryData
          ? _value.categoryData
          : categoryData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bidCount: freezed == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobModelImplCopyWith<$Res>
    implements $JobModelCopyWith<$Res> {
  factory _$$JobModelImplCopyWith(
          _$JobModelImpl value, $Res Function(_$JobModelImpl) then) =
      __$$JobModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'category_id') String categoryId,
      String title,
      String? description,
      String? address,
      @JsonKey(name: 'budget_min') double? budgetMin,
      @JsonKey(name: 'budget_max') double? budgetMax,
      String status,
      @JsonKey(name: 'matched_worker_id') String? matchedWorkerId,
      @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
      @JsonKey(name: 'photo_urls') List<String>? photoUrls,
      @JsonKey(name: 'broadcast_radius_km') int broadcastRadiusKm,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
      @JsonKey(name: 'category') Map<String, dynamic>? categoryData,
      @JsonKey(name: 'bid_count') int? bidCount});
}

/// @nodoc
class __$$JobModelImplCopyWithImpl<$Res>
    extends _$JobModelCopyWithImpl<$Res, _$JobModelImpl>
    implements _$$JobModelImplCopyWith<$Res> {
  __$$JobModelImplCopyWithImpl(
      _$JobModelImpl _value, $Res Function(_$JobModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? categoryId = null,
    Object? title = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? status = null,
    Object? matchedWorkerId = freezed,
    Object? scheduledAt = freezed,
    Object? photoUrls = freezed,
    Object? broadcastRadiusKm = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? customerData = freezed,
    Object? categoryData = freezed,
    Object? bidCount = freezed,
  }) {
    return _then(_$JobModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as double?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      matchedWorkerId: freezed == matchedWorkerId
          ? _value.matchedWorkerId
          : matchedWorkerId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoUrls: freezed == photoUrls
          ? _value._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      broadcastRadiusKm: null == broadcastRadiusKm
          ? _value.broadcastRadiusKm
          : broadcastRadiusKm // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      customerData: freezed == customerData
          ? _value._customerData
          : customerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      categoryData: freezed == categoryData
          ? _value._categoryData
          : categoryData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bidCount: freezed == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$JobModelImpl implements _JobModel {
  const _$JobModelImpl(
      {required this.id,
      @JsonKey(name: 'customer_id') required this.customerId,
      @JsonKey(name: 'category_id') required this.categoryId,
      required this.title,
      this.description,
      this.address,
      @JsonKey(name: 'budget_min') this.budgetMin,
      @JsonKey(name: 'budget_max') this.budgetMax,
      this.status = 'draft',
      @JsonKey(name: 'matched_worker_id') this.matchedWorkerId,
      @JsonKey(name: 'scheduled_at') this.scheduledAt,
      @JsonKey(name: 'photo_urls') final List<String>? photoUrls,
      @JsonKey(name: 'broadcast_radius_km') this.broadcastRadiusKm = 5,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'customer') final Map<String, dynamic>? customerData,
      @JsonKey(name: 'category') final Map<String, dynamic>? categoryData,
      @JsonKey(name: 'bid_count') this.bidCount})
      : _photoUrls = photoUrls,
        _customerData = customerData,
        _categoryData = categoryData;

  @override
  final String id;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? address;
  @override
  @JsonKey(name: 'budget_min')
  final double? budgetMin;
  @override
  @JsonKey(name: 'budget_max')
  final double? budgetMax;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'matched_worker_id')
  final String? matchedWorkerId;
  @override
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;
  final List<String>? _photoUrls;
  @override
  @JsonKey(name: 'photo_urls')
  List<String>? get photoUrls {
    final value = _photoUrls;
    if (value == null) return null;
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'broadcast_radius_km')
  final int broadcastRadiusKm;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// Location — parsed from PostGIS geography
  @override
  final double? latitude;
  @override
  final double? longitude;
// Joined data (optional)
  final Map<String, dynamic>? _customerData;
// Joined data (optional)
  @override
  @JsonKey(name: 'customer')
  Map<String, dynamic>? get customerData {
    final value = _customerData;
    if (value == null) return null;
    if (_customerData is EqualUnmodifiableMapView) return _customerData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _categoryData;
  @override
  @JsonKey(name: 'category')
  Map<String, dynamic>? get categoryData {
    final value = _categoryData;
    if (value == null) return null;
    if (_categoryData is EqualUnmodifiableMapView) return _categoryData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'bid_count')
  final int? bidCount;

  @override
  String toString() {
    return 'JobModel(id: $id, customerId: $customerId, categoryId: $categoryId, title: $title, description: $description, address: $address, budgetMin: $budgetMin, budgetMax: $budgetMax, status: $status, matchedWorkerId: $matchedWorkerId, scheduledAt: $scheduledAt, photoUrls: $photoUrls, broadcastRadiusKm: $broadcastRadiusKm, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, customerData: $customerData, categoryData: $categoryData, bidCount: $bidCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.budgetMin, budgetMin) ||
                other.budgetMin == budgetMin) &&
            (identical(other.budgetMax, budgetMax) ||
                other.budgetMax == budgetMax) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.matchedWorkerId, matchedWorkerId) ||
                other.matchedWorkerId == matchedWorkerId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls) &&
            (identical(other.broadcastRadiusKm, broadcastRadiusKm) ||
                other.broadcastRadiusKm == broadcastRadiusKm) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality()
                .equals(other._customerData, _customerData) &&
            const DeepCollectionEquality()
                .equals(other._categoryData, _categoryData) &&
            (identical(other.bidCount, bidCount) ||
                other.bidCount == bidCount));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        customerId,
        categoryId,
        title,
        description,
        address,
        budgetMin,
        budgetMax,
        status,
        matchedWorkerId,
        scheduledAt,
        const DeepCollectionEquality().hash(_photoUrls),
        broadcastRadiusKm,
        createdAt,
        updatedAt,
        latitude,
        longitude,
        const DeepCollectionEquality().hash(_customerData),
        const DeepCollectionEquality().hash(_categoryData),
        bidCount
      ]);

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobModelImplCopyWith<_$JobModelImpl> get copyWith =>
      __$$JobModelImplCopyWithImpl<_$JobModelImpl>(this, _$identity);
}

abstract class _JobModel implements JobModel {
  const factory _JobModel(
      {required final String id,
      @JsonKey(name: 'customer_id') required final String customerId,
      @JsonKey(name: 'category_id') required final String categoryId,
      required final String title,
      final String? description,
      final String? address,
      @JsonKey(name: 'budget_min') final double? budgetMin,
      @JsonKey(name: 'budget_max') final double? budgetMax,
      final String status,
      @JsonKey(name: 'matched_worker_id') final String? matchedWorkerId,
      @JsonKey(name: 'scheduled_at') final DateTime? scheduledAt,
      @JsonKey(name: 'photo_urls') final List<String>? photoUrls,
      @JsonKey(name: 'broadcast_radius_km') final int broadcastRadiusKm,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      final double? latitude,
      final double? longitude,
      @JsonKey(name: 'customer') final Map<String, dynamic>? customerData,
      @JsonKey(name: 'category') final Map<String, dynamic>? categoryData,
      @JsonKey(name: 'bid_count') final int? bidCount}) = _$JobModelImpl;

  @override
  String get id;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get address;
  @override
  @JsonKey(name: 'budget_min')
  double? get budgetMin;
  @override
  @JsonKey(name: 'budget_max')
  double? get budgetMax;
  @override
  String get status;
  @override
  @JsonKey(name: 'matched_worker_id')
  String? get matchedWorkerId;
  @override
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt;
  @override
  @JsonKey(name: 'photo_urls')
  List<String>? get photoUrls;
  @override
  @JsonKey(name: 'broadcast_radius_km')
  int get broadcastRadiusKm;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // Location — parsed from PostGIS geography
  @override
  double? get latitude;
  @override
  double? get longitude; // Joined data (optional)
  @override
  @JsonKey(name: 'customer')
  Map<String, dynamic>? get customerData;
  @override
  @JsonKey(name: 'category')
  Map<String, dynamic>? get categoryData;
  @override
  @JsonKey(name: 'bid_count')
  int? get bidCount;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobModelImplCopyWith<_$JobModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
