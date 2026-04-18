// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_wavetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedWavetable _$SavedWavetableFromJson(Map<String, dynamic> json) =>
    _SavedWavetable(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      username: _readUsername(json, 'username') as String? ?? '',
      starCount: (_readStarCount(json, 'star_count') as num?)?.toInt() ?? 0,
      isStarred: json['is_starred'] as bool? ?? false,
      youtubeUrl: json['youtube_url'] as String? ?? '',
      contentHash: json['content_hash'] as String?,
    );

Map<String, dynamic> _$SavedWavetableToJson(_SavedWavetable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'is_public': instance.isPublic,
      'username': instance.username,
      'star_count': instance.starCount,
      'is_starred': instance.isStarred,
      'youtube_url': instance.youtubeUrl,
      'content_hash': instance.contentHash,
    };
