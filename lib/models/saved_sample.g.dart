// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_sample.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedSample _$SavedSampleFromJson(Map<String, dynamic> json) => _SavedSample(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  filePath: json['file_path'] as String,
  pcmFilePath: json['pcm_file_path'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  slug: json['slug'] as String? ?? '',
  description: json['description'] as String? ?? '',
  isPublic: json['is_public'] as bool? ?? false,
  username: _readUsername(json, 'username') as String? ?? '',
  starCount: (_readStarCount(json, 'star_count') as num?)?.toInt() ?? 0,
  isStarred: json['is_starred'] as bool? ?? false,
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
  loopMode: (json['loop_mode'] as num?)?.toInt() ?? 0,
  contentHash: json['content_hash'] as String?,
);

Map<String, dynamic> _$SavedSampleToJson(_SavedSample instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'pcm_file_path': instance.pcmFilePath,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'slug': instance.slug,
      'description': instance.description,
      'is_public': instance.isPublic,
      'username': instance.username,
      'star_count': instance.starCount,
      'is_starred': instance.isStarred,
      'slice_points': instance.slicePoints,
      'base_note': instance.baseNote,
      'fine_tune': instance.fineTune,
      'pitched': instance.pitched,
      'slice_notes': instance.sliceNotes,
      'loop_mode': instance.loopMode,
      'content_hash': instance.contentHash,
    };
