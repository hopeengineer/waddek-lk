// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameSi: json['name_si'] as String?,
      nameTa: json['name_ta'] as String?,
      icon: json['icon'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.nameEn,
      'name_si': instance.nameSi,
      'name_ta': instance.nameTa,
      'icon': instance.icon,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };
