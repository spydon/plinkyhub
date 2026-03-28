// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_write.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatchWrite _$PatchWriteFromJson(Map<String, dynamic> json) => _PatchWrite(
  userId: json['user_id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  patchData: json['patch_data'] as String,
  description: json['description'] as String? ?? '',
  isPublic: json['is_public'] as bool? ?? false,
  sampleId: json['sample_id'] as String?,
);

Map<String, dynamic> _$PatchWriteToJson(_PatchWrite instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'patch_data': instance.patchData,
      'description': instance.description,
      'is_public': instance.isPublic,
      'sample_id': instance.sampleId,
    };
