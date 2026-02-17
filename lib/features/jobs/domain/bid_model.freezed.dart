// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BidModel _$BidModelFromJson(Map<String, dynamic> json) {
  return _BidModel.fromJson(json);
}

/// @nodoc
mixin _$BidModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_id')
  String get workerId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Joined worker data (optional — included on customer view)
  @JsonKey(name: 'worker')
  Map<String, dynamic>? get workerData => throw _privateConstructorUsedError;

  /// Serializes this BidModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BidModelCopyWith<BidModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BidModelCopyWith<$Res> {
  factory $BidModelCopyWith(BidModel value, $Res Function(BidModel) then) =
      _$BidModelCopyWithImpl<$Res, BidModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'worker_id') String workerId,
      double amount,
      String? message,
      String status,
      @JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'worker') Map<String, dynamic>? workerData});
}

/// @nodoc
class _$BidModelCopyWithImpl<$Res, $Val extends BidModel>
    implements $BidModelCopyWith<$Res> {
  _$BidModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? workerId = null,
    Object? amount = null,
    Object? message = freezed,
    Object? status = null,
    Object? isUnlocked = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? workerData = freezed,
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
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      workerData: freezed == workerData
          ? _value.workerData
          : workerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BidModelImplCopyWith<$Res>
    implements $BidModelCopyWith<$Res> {
  factory _$$BidModelImplCopyWith(
          _$BidModelImpl value, $Res Function(_$BidModelImpl) then) =
      __$$BidModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'worker_id') String workerId,
      double amount,
      String? message,
      String status,
      @JsonKey(name: 'is_unlocked') bool isUnlocked,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'worker') Map<String, dynamic>? workerData});
}

/// @nodoc
class __$$BidModelImplCopyWithImpl<$Res>
    extends _$BidModelCopyWithImpl<$Res, _$BidModelImpl>
    implements _$$BidModelImplCopyWith<$Res> {
  __$$BidModelImplCopyWithImpl(
      _$BidModelImpl _value, $Res Function(_$BidModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? workerId = null,
    Object? amount = null,
    Object? message = freezed,
    Object? status = null,
    Object? isUnlocked = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? workerData = freezed,
  }) {
    return _then(_$BidModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      workerId: null == workerId
          ? _value.workerId
          : workerId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      workerData: freezed == workerData
          ? _value._workerData
          : workerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BidModelImpl implements _BidModel {
  const _$BidModelImpl(
      {required this.id,
      @JsonKey(name: 'job_id') required this.jobId,
      @JsonKey(name: 'worker_id') required this.workerId,
      required this.amount,
      this.message,
      this.status = 'pending',
      @JsonKey(name: 'is_unlocked') this.isUnlocked = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'worker') final Map<String, dynamic>? workerData})
      : _workerData = workerData;

  factory _$BidModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BidModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  @JsonKey(name: 'worker_id')
  final String workerId;
  @override
  final double amount;
  @override
  final String? message;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// Joined worker data (optional — included on customer view)
  final Map<String, dynamic>? _workerData;
// Joined worker data (optional — included on customer view)
  @override
  @JsonKey(name: 'worker')
  Map<String, dynamic>? get workerData {
    final value = _workerData;
    if (value == null) return null;
    if (_workerData is EqualUnmodifiableMapView) return _workerData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BidModel(id: $id, jobId: $jobId, workerId: $workerId, amount: $amount, message: $message, status: $status, isUnlocked: $isUnlocked, createdAt: $createdAt, updatedAt: $updatedAt, workerData: $workerData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BidModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.workerId, workerId) ||
                other.workerId == workerId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other._workerData, _workerData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      jobId,
      workerId,
      amount,
      message,
      status,
      isUnlocked,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_workerData));

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BidModelImplCopyWith<_$BidModelImpl> get copyWith =>
      __$$BidModelImplCopyWithImpl<_$BidModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BidModelImplToJson(
      this,
    );
  }
}

abstract class _BidModel implements BidModel {
  const factory _BidModel(
          {required final String id,
          @JsonKey(name: 'job_id') required final String jobId,
          @JsonKey(name: 'worker_id') required final String workerId,
          required final double amount,
          final String? message,
          final String status,
          @JsonKey(name: 'is_unlocked') final bool isUnlocked,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt,
          @JsonKey(name: 'worker') final Map<String, dynamic>? workerData}) =
      _$BidModelImpl;

  factory _BidModel.fromJson(Map<String, dynamic> json) =
      _$BidModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  @JsonKey(name: 'worker_id')
  String get workerId;
  @override
  double get amount;
  @override
  String? get message;
  @override
  String get status;
  @override
  @JsonKey(name: 'is_unlocked')
  bool get isUnlocked;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime?
      get updatedAt; // Joined worker data (optional — included on customer view)
  @override
  @JsonKey(name: 'worker')
  Map<String, dynamic>? get workerData;

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BidModelImplCopyWith<_$BidModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
