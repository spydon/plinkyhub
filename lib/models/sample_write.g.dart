// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_write.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SampleWrite _$SampleWriteFromJson(Map<String, dynamic> json) => _SampleWrite(
  userId: json['user_id'] as String,
  name: json['name'] as String,
  filePath: json['file_path'] as String,
  pcmFilePath: json['pcm_file_path'] as String,
  description: json['description'] as String? ?? '',
  isPublic: json['is_public'] as bool? ?? false,
  slicePoints:
      (json['slice_points'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      defaultSlicePoints,
  baseNote: (json['base_note'] as num?)?.toInt() ?? 60,
  fineTune: (json['fine_tune'] as num?)?.toInt() ?? 0,
  pitched: json['pitched'] as bool? ?? false,
  sliceNotes:
      (json['slice_notes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      defaultSliceNotes,
);

Map<String, dynamic> _$SampleWriteToJson(_SampleWrite instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'pcm_file_path': instance.pcmFilePath,
      'description': instance.description,
      'is_public': instance.isPublic,
      'slice_points': instance.slicePoints,
      'base_note': instance.baseNote,
      'fine_tune': instance.fineTune,
      'pitched': instance.pitched,
      'slice_notes': instance.sliceNotes,
    };
