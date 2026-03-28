// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedPreset _$SavedPresetFromJson(Map<String, dynamic> json) => _SavedPreset(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  presetData: json['preset_data'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  description: json['description'] as String? ?? '',
  isPublic: json['is_public'] as bool? ?? false,
  username: _readUsername(json, 'username') as String? ?? '',
  starCount: (_readStarCount(json, 'star_count') as num?)?.toInt() ?? 0,
  isStarred: json['is_starred'] as bool? ?? false,
  sampleId: json['sample_id'] as String?,
);

Map<String, dynamic> _$SavedPresetToJson(_SavedPreset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'preset_data': instance.presetData,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'is_public': instance.isPublic,
      'username': instance.username,
      'star_count': instance.starCount,
      'is_starred': instance.isStarred,
      'sample_id': instance.sampleId,
    };
