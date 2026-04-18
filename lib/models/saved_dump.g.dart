// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_dump.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedDump _$SavedDumpFromJson(Map<String, dynamic> json) => _SavedDump(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  internalFlashPath: json['internal_flash_path'] as String?,
  externalFlashPath: json['external_flash_path'] as String?,
  description: json['description'] as String? ?? '',
  internalFlashSize: (json['internal_flash_size'] as num?)?.toInt() ?? 0,
  externalFlashSize: (json['external_flash_size'] as num?)?.toInt() ?? 0,
  username: _readUsername(json, 'username') as String? ?? '',
);

Map<String, dynamic> _$SavedDumpToJson(_SavedDump instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'internal_flash_path': instance.internalFlashPath,
      'external_flash_path': instance.externalFlashPath,
      'description': instance.description,
      'internal_flash_size': instance.internalFlashSize,
      'external_flash_size': instance.externalFlashSize,
      'username': instance.username,
    };
