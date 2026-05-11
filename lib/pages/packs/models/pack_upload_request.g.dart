// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$PackUploadRequestToJson(_PackUploadRequest instance) =>
    <String, dynamic>{
      'pack_data': instance.packData,
      'samples_data': instance.samplesData,
      'presets_data': instance.presetsData,
      'wavetable_data': instance.wavetableData,
      'patterns_data': instance.patternsData,
      'pack_slots_data': instance.packSlotsData,
    };

Map<String, dynamic> _$PackUploadPackToJson(_PackUploadPack instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'is_public': instance.isPublic,
      'youtube_url': instance.youtubeUrl,
      'content_hash': instance.contentHash,
    };

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
      'loop_mode': instance.loopMode,
      'content_hash': instance.contentHash,
      'existing_id': instance.existingId,
    };

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

Map<String, dynamic> _$PackUploadSlotToJson(_PackUploadSlot instance) =>
    <String, dynamic>{
      'slot_number': instance.slotNumber,
      'preset_slot_index': instance.presetSlotIndex,
      'sample_slot_index': instance.sampleSlotIndex,
      'pattern_index': instance.patternIndex,
    };
