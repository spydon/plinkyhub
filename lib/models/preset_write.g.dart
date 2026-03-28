// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset_write.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresetWrite _$PresetWriteFromJson(Map<String, dynamic> json) => _PresetWrite(
  userId: json['user_id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  presetData: json['preset_data'] as String,
  description: json['description'] as String? ?? '',
  isPublic: json['is_public'] as bool? ?? false,
  sampleId: json['sample_id'] as String?,
);

Map<String, dynamic> _$PresetWriteToJson(_PresetWrite instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'preset_data': instance.presetData,
      'description': instance.description,
      'is_public': instance.isPublic,
      'sample_id': instance.sampleId,
    };
