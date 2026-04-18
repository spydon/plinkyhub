// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatternData _$PatternDataFromJson(Map<String, dynamic> json) => _PatternData(
  version: (json['version'] as num?)?.toInt() ?? 1,
  scaleIndex: (json['scale_index'] as num?)?.toInt() ?? 0,
  grid:
      (json['grid'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$PatternDataToJson(_PatternData instance) =>
    <String, dynamic>{
      'version': instance.version,
      'scale_index': instance.scaleIndex,
      'grid': instance.grid,
    };
