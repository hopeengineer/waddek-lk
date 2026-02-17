// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DisputeModel _$DisputeModelFromJson(Map<String, dynamic> json) {
  return _DisputeModel.fromJson(json);
}

/// @nodoc
mixin _$DisputeModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_id')
  String get jobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'raised_by')
  String get raisedBy => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'evidence_urls')
  List<String>? get evidenceUrls => throw _privateConstructorUsedError;

  /// 'open', 'investigating', 'resolved', 'dismissed'
  String get status => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DisputeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeModelCopyWith<DisputeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeModelCopyWith<$Res> {
  factory $DisputeModelCopyWith(
          DisputeModel value, $Res Function(DisputeModel) then) =
      _$DisputeModelCopyWithImpl<$Res, DisputeModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'raised_by') String raisedBy,
      String reason,
      String? description,
      @JsonKey(name: 'evidence_urls') List<String>? evidenceUrls,
      String status,
      String? resolution,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$DisputeModelCopyWithImpl<$Res, $Val extends DisputeModel>
    implements $DisputeModelCopyWith<$Res> {
  _$DisputeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? raisedBy = null,
    Object? reason = null,
    Object? description = freezed,
    Object? evidenceUrls = freezed,
    Object? status = null,
    Object? resolution = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      raisedBy: null == raisedBy
          ? _value.raisedBy
          : raisedBy // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      evidenceUrls: freezed == evidenceUrls
          ? _value.evidenceUrls
          : evidenceUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$DisputeModelImplCopyWith<$Res>
    implements $DisputeModelCopyWith<$Res> {
  factory _$$DisputeModelImplCopyWith(
          _$DisputeModelImpl value, $Res Function(_$DisputeModelImpl) then) =
      __$$DisputeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'job_id') String jobId,
      @JsonKey(name: 'raised_by') String raisedBy,
      String reason,
      String? description,
      @JsonKey(name: 'evidence_urls') List<String>? evidenceUrls,
      String status,
      String? resolution,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$DisputeModelImplCopyWithImpl<$Res>
    extends _$DisputeModelCopyWithImpl<$Res, _$DisputeModelImpl>
    implements _$$DisputeModelImplCopyWith<$Res> {
  __$$DisputeModelImplCopyWithImpl(
      _$DisputeModelImpl _value, $Res Function(_$DisputeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? jobId = null,
    Object? raisedBy = null,
    Object? reason = null,
    Object? description = freezed,
    Object? evidenceUrls = freezed,
    Object? status = null,
    Object? resolution = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DisputeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      raisedBy: null == raisedBy
          ? _value.raisedBy
          : raisedBy // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      evidenceUrls: freezed == evidenceUrls
          ? _value._evidenceUrls
          : evidenceUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
@JsonSerializable()
class _$DisputeModelImpl implements _DisputeModel {
  const _$DisputeModelImpl(
      {required this.id,
      @JsonKey(name: 'job_id') required this.jobId,
      @JsonKey(name: 'raised_by') required this.raisedBy,
      required this.reason,
      this.description,
      @JsonKey(name: 'evidence_urls') final List<String>? evidenceUrls,
      this.status = 'open',
      this.resolution,
      @JsonKey(name: 'resolved_by') this.resolvedBy,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _evidenceUrls = evidenceUrls;

  factory _$DisputeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'job_id')
  final String jobId;
  @override
  @JsonKey(name: 'raised_by')
  final String raisedBy;
  @override
  final String reason;
  @override
  final String? description;
  final List<String>? _evidenceUrls;
  @override
  @JsonKey(name: 'evidence_urls')
  List<String>? get evidenceUrls {
    final value = _evidenceUrls;
    if (value == null) return null;
    if (_evidenceUrls is EqualUnmodifiableListView) return _evidenceUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// 'open', 'investigating', 'resolved', 'dismissed'
  @override
  @JsonKey()
  final String status;
  @override
  final String? resolution;
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DisputeModel(id: $id, jobId: $jobId, raisedBy: $raisedBy, reason: $reason, description: $description, evidenceUrls: $evidenceUrls, status: $status, resolution: $resolution, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.raisedBy, raisedBy) ||
                other.raisedBy == raisedBy) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._evidenceUrls, _evidenceUrls) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      jobId,
      raisedBy,
      reason,
      description,
      const DeepCollectionEquality().hash(_evidenceUrls),
      status,
      resolution,
      resolvedBy,
      resolvedAt,
      createdAt,
      updatedAt);

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeModelImplCopyWith<_$DisputeModelImpl> get copyWith =>
      __$$DisputeModelImplCopyWithImpl<_$DisputeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeModelImplToJson(
      this,
    );
  }
}

abstract class _DisputeModel implements DisputeModel {
  const factory _DisputeModel(
          {required final String id,
          @JsonKey(name: 'job_id') required final String jobId,
          @JsonKey(name: 'raised_by') required final String raisedBy,
          required final String reason,
          final String? description,
          @JsonKey(name: 'evidence_urls') final List<String>? evidenceUrls,
          final String status,
          final String? resolution,
          @JsonKey(name: 'resolved_by') final String? resolvedBy,
          @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$DisputeModelImpl;

  factory _DisputeModel.fromJson(Map<String, dynamic> json) =
      _$DisputeModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'job_id')
  String get jobId;
  @override
  @JsonKey(name: 'raised_by')
  String get raisedBy;
  @override
  String get reason;
  @override
  String? get description;
  @override
  @JsonKey(name: 'evidence_urls')
  List<String>? get evidenceUrls;

  /// 'open', 'investigating', 'resolved', 'dismissed'
  @override
  String get status;
  @override
  String? get resolution;
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeModelImplCopyWith<_$DisputeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
