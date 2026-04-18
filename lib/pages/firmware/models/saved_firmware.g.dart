// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_firmware.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedFirmware _$SavedFirmwareFromJson(Map<String, dynamic> json) =>
    _SavedFirmware(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      filePath: json['file_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String? ?? '',
      isBeta: json['is_beta'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      username: _readUsername(json, 'username') as String? ?? '',
    );

Map<String, dynamic> _$SavedFirmwareToJson(_SavedFirmware instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'version': instance.version,
      'file_path': instance.filePath,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'is_beta': instance.isBeta,
      'is_pinned': instance.isPinned,
      'username': instance.username,
    };
