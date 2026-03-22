// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackSlot _$PackSlotFromJson(Map<String, dynamic> json) => _PackSlot(
  id: json['id'] as String,
  packId: json['pack_id'] as String,
  slotNumber: (json['slot_number'] as num).toInt(),
  patchId: json['patch_id'] as String?,
  sampleId: json['sample_id'] as String?,
);

Map<String, dynamic> _$PackSlotToJson(_PackSlot instance) => <String, dynamic>{
  'id': instance.id,
  'pack_id': instance.packId,
  'slot_number': instance.slotNumber,
  'patch_id': instance.patchId,
  'sample_id': instance.sampleId,
};
