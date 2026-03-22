// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedPack _$SavedPackFromJson(Map<String, dynamic> json) => _SavedPack(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  description: json['description'] as String? ?? '',
  isPublic: json['is_public'] as bool? ?? false,
  slots:
      (json['pack_slots'] as List<dynamic>?)
          ?.map((e) => PackSlot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SavedPackToJson(_SavedPack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'is_public': instance.isPublic,
      'pack_slots': instance.slots,
    };
