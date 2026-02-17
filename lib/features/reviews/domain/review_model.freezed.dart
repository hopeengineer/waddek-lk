// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) {
  return _ReviewModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_id')
  String get workerId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError; // 1-5 stars
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // Joined data
  @JsonKey(name: 'customer')
  Map<String, dynamic>? get customerData => throw _privateConstructorUsedError;
  @JsonKey(name: 'job')
  Map<String, dynamic>? get jobData => throw _privateConstructorUsedError;

  /// Serializes this ReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewModelCopyWith<ReviewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewModelCopyWith<$Res> {
  factory $ReviewModelCopyWith(
          ReviewModel value, $Res Function(ReviewModel) then) =
      _$ReviewModelCopyWithImpl<$Res, ReviewModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'worker_id') String workerId,
      int rating,
      String? comment,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
      @JsonKey(name: 'job') Map<String, dynamic>? jobData});
}

/// @nodoc
class _$ReviewModelCopyWithImpl<$Res, $Val extends ReviewModel>
    implements $ReviewModelCopyWith<$Res> {
  _$ReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? customerId = null,
    Object? workerId = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
    Object? customerData = freezed,
    Object? jobData = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customerData: freezed == customerData
          ? _value.customerData
          : customerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      jobData: freezed == jobData
          ? _value.jobData
          : jobData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewModelImplCopyWith<$Res>
    implements $ReviewModelCopyWith<$Res> {
  factory _$$ReviewModelImplCopyWith(
          _$ReviewModelImpl value, $Res Function(_$ReviewModelImpl) then) =
      __$$ReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'worker_id') String workerId,
      int rating,
      String? comment,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
      @JsonKey(name: 'job') Map<String, dynamic>? jobData});
}

/// @nodoc
class __$$ReviewModelImplCopyWithImpl<$Res>
    extends _$ReviewModelCopyWithImpl<$Res, _$ReviewModelImpl>
    implements _$$ReviewModelImplCopyWith<$Res> {
  __$$ReviewModelImplCopyWithImpl(
      _$ReviewModelImpl _value, $Res Function(_$ReviewModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? customerId = null,
    Object? workerId = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
    Object? customerData = freezed,
    Object? jobData = freezed,
  }) {
    return _then(_$ReviewModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customerData: freezed == customerData
          ? _value._customerData
          : customerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      jobData: freezed == jobData
          ? _value._jobData
          : jobData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewModelImpl implements _ReviewModel {
  const _$ReviewModelImpl(
      {required this.id,
      @JsonKey(name: 'job_id') required this.jobId,
      @JsonKey(name: 'customer_id') required this.customerId,
      @JsonKey(name: 'worker_id') required this.workerId,
      required this.rating,
      this.comment,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'customer') final Map<String, dynamic>? customerData,
      @JsonKey(name: 'job') final Map<String, dynamic>? jobData})
      : _customerData = customerData,
        _jobData = jobData;

  factory _$ReviewModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'worker_id')
  final String workerId;
  @override
  final int rating;
// 1-5 stars
  @override
  final String? comment;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
// Joined data
  final Map<String, dynamic>? _customerData;
// Joined data
  @override
  @JsonKey(name: 'customer')
  Map<String, dynamic>? get customerData {
    final value = _customerData;
    if (value == null) return null;
    if (_customerData is EqualUnmodifiableMapView) return _customerData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _jobData;
  @override
  @JsonKey(name: 'job')
  Map<String, dynamic>? get jobData {
    final value = _jobData;
    if (value == null) return null;
    if (_jobData is EqualUnmodifiableMapView) return _jobData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, jobId: $jobId, customerId: $customerId, workerId: $workerId, rating: $rating, comment: $comment, createdAt: $createdAt, customerData: $customerData, jobData: $jobData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.workerId, workerId) ||
                other.workerId == workerId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._customerData, _customerData) &&
            const DeepCollectionEquality().equals(other._jobData, _jobData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      jobId,
      customerId,
      workerId,
      rating,
      comment,
      createdAt,
      const DeepCollectionEquality().hash(_customerData),
      const DeepCollectionEquality().hash(_jobData));

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      __$$ReviewModelImplCopyWithImpl<_$ReviewModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewModelImplToJson(
      this,
    );
  }
}

abstract class _ReviewModel implements ReviewModel {
  const factory _ReviewModel(
          {required final String id,
          @JsonKey(name: 'job_id') required final String jobId,
          @JsonKey(name: 'customer_id') required final String customerId,
          @JsonKey(name: 'worker_id') required final String workerId,
          required final int rating,
          final String? comment,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'customer') final Map<String, dynamic>? customerData,
          @JsonKey(name: 'job') final Map<String, dynamic>? jobData}) =
      _$ReviewModelImpl;

  factory _ReviewModel.fromJson(Map<String, dynamic> json) =
      _$ReviewModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  @JsonKey(name: 'worker_id')
  String get workerId;
  @override
  int get rating; // 1-5 stars
  @override
  String? get comment;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Joined data
  @override
  @JsonKey(name: 'customer')
  Map<String, dynamic>? get customerData;
  @override
  @JsonKey(name: 'job')
  Map<String, dynamic>? get jobData;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
