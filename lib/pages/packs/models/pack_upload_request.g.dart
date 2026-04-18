// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackUploadRequest _$PackUploadRequestFromJson(
  Map<String, dynamic> json,
) => _PackUploadRequest(
  packData: PackUploadPack.fromJson(json['pack_data'] as Map<String, dynamic>),
  samplesData:
      (json['samples_data'] as List<dynamic>?)
          ?.map((e) => PackUploadSample.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  presetsData:
      (json['presets_data'] as List<dynamic>?)
          ?.map((e) => PackUploadPreset.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  wavetableData: json['wavetable_data'] == null
      ? null
      : PackUploadWavetable.fromJson(
          json['wavetable_data'] as Map<String, dynamic>,
        ),
  patternsData:
      (json['patterns_data'] as List<dynamic>?)
          ?.map((e) => PackUploadPattern.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  packSlotsData:
      (json['pack_slots_data'] as List<dynamic>?)
          ?.map((e) => PackUploadSlot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PackUploadRequestToJson(_PackUploadRequest instance) =>
    <String, dynamic>{
      'pack_data': instance.packData,
      'samples_data': instance.samplesData,
      'presets_data': instance.presetsData,
      'wavetable_data': instance.wavetableData,
      'patterns_data': instance.patternsData,
      'pack_slots_data': instance.packSlotsData,
    };

_PackUploadPack _$PackUploadPackFromJson(Map<String, dynamic> json) =>
    _PackUploadPack(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      youtubeUrl: json['youtube_url'] as String? ?? '',
      contentHash: json['content_hash'] as String?,
    );

Map<String, dynamic> _$PackUploadPackToJson(_PackUploadPack instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'is_public': instance.isPublic,
      'youtube_url': instance.youtubeUrl,
      'content_hash': instance.contentHash,
    };

_PackUploadSample _$PackUploadSampleFromJson(Map<String, dynamic> json) =>
    _PackUploadSample(
      slotIndex: (json['slot_index'] as num).toInt(),
      userId: json['user_id'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      pcmFilePath: json['pcm_file_path'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      slicePoints:
          (json['slice_points'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      baseNote: (json['base_note'] as num?)?.toInt() ?? 60,
      fineTune: (json['fine_tune'] as num?)?.toInt() ?? 0,
      pitched: json['pitched'] as bool? ?? false,
      sliceNotes:
          (json['slice_notes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      contentHash: json['content_hash'] as String?,
      existingId: json['existing_id'] as String?,
    );

Map<String, dynamic> _$PackUploadSampleToJson(_PackUploadSample instance) =>
    <String, dynamic>{
      'slot_index': instance.slotIndex,
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'pcm_file_path': instance.pcmFilePath,
      'description': instance.description,
      'is_public': instance.isPublic,
      'slice_points': instance.slicePoints,
      'base_note': instance.baseNote,
      'fine_tune': instance.fineTune,
      'pitched': instance.pitched,
      'slice_notes': instance.sliceNotes,
      'content_hash': instance.contentHash,
      'existing_id': instance.existingId,
    };

_PackUploadPreset _$PackUploadPresetFromJson(Map<String, dynamic> json) =>
    _PackUploadPreset(
      slotIndex: (json['slot_index'] as num).toInt(),
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      presetData: json['preset_data'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      contentHash: json['content_hash'] as String?,
      existingId: json['existing_id'] as String?,
      sampleSlotIndex: (json['sample_slot_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PackUploadPresetToJson(_PackUploadPreset instance) =>
    <String, dynamic>{
      'slot_index': instance.slotIndex,
      'user_id': instance.userId,
      'name': instance.name,
      'category': instance.category,
      'preset_data': instance.presetData,
      'description': instance.description,
      'is_public': instance.isPublic,
      'content_hash': instance.contentHash,
      'existing_id': instance.existingId,
      'sample_slot_index': instance.sampleSlotIndex,
    };

_PackUploadWavetable _$PackUploadWavetableFromJson(Map<String, dynamic> json) =>
    _PackUploadWavetable(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      contentHash: json['content_hash'] as String?,
      existingId: json['existing_id'] as String?,
    );

Map<String, dynamic> _$PackUploadWavetableToJson(
  _PackUploadWavetable instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'name': instance.name,
  'file_path': instance.filePath,
  'description': instance.description,
  'is_public': instance.isPublic,
  'content_hash': instance.contentHash,
  'existing_id': instance.existingId,
};

_PackUploadPattern _$PackUploadPatternFromJson(Map<String, dynamic> json) =>
    _PackUploadPattern(
      patternIndex: (json['pattern_index'] as num).toInt(),
      userId: json['user_id'] as String,
      name: json['name'] as String,
      filePath: json['file_path'] as String,
      description: json['description'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      contentHash: json['content_hash'] as String?,
      existingId: json['existing_id'] as String?,
    );

Map<String, dynamic> _$PackUploadPatternToJson(_PackUploadPattern instance) =>
    <String, dynamic>{
      'pattern_index': instance.patternIndex,
      'user_id': instance.userId,
      'name': instance.name,
      'file_path': instance.filePath,
      'description': instance.description,
      'is_public': instance.isPublic,
      'content_hash': instance.contentHash,
      'existing_id': instance.existingId,
    };

_PackUploadSlot _$PackUploadSlotFromJson(Map<String, dynamic> json) =>
    _PackUploadSlot(
      slotNumber: (json['slot_number'] as num).toInt(),
      presetSlotIndex: (json['preset_slot_index'] as num?)?.toInt(),
      sampleSlotIndex: (json['sample_slot_index'] as num?)?.toInt(),
      patternIndex: (json['pattern_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PackUploadSlotToJson(_PackUploadSlot instance) =>
    <String, dynamic>{
      'slot_number': instance.slotNumber,
      'preset_slot_index': instance.presetSlotIndex,
      'sample_slot_index': instance.sampleSlotIndex,
      'pattern_index': instance.patternIndex,
    };
