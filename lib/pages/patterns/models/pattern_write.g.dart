// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_write.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatternWrite _$PatternWriteFromJson(Map<String, dynamic> json) =>
    _PatternWrite(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      contentHash: json['content_hash'] as String?,
    );

Map<String, dynamic> _$PatternWriteToJson(_PatternWrite instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'description': instance.description,
      'is_public': instance.isPublic,
      'content_hash': instance.contentHash,
    };
