// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wavetable_write.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WavetableWrite _$WavetableWriteFromJson(Map<String, dynamic> json) =>
    _WavetableWrite(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      youtubeUrl: json['youtube_url'] as String? ?? '',
      contentHash: json['content_hash'] as String?,
    );

Map<String, dynamic> _$WavetableWriteToJson(_WavetableWrite instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'description': instance.description,
      'is_public': instance.isPublic,
      'youtube_url': instance.youtubeUrl,
      'content_hash': instance.contentHash,
    };
