// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_slot_write.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackSlotWrite _$PackSlotWriteFromJson(Map<String, dynamic> json) =>
    _PackSlotWrite(
      packId: json['pack_id'] as String,
      slotNumber: (json['slot_number'] as num).toInt(),
      presetId: json['preset_id'] as String?,
      sampleId: json['sample_id'] as String?,
    );

Map<String, dynamic> _$PackSlotWriteToJson(_PackSlotWrite instance) =>
    <String, dynamic>{
      'pack_id': instance.packId,
      'slot_number': instance.slotNumber,
      'preset_id': instance.presetId,
      'sample_id': instance.sampleId,
    };
