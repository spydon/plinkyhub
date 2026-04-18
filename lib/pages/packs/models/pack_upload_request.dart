import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_upload_request.freezed.dart';
part 'pack_upload_request.g.dart';

@freezed
abstract class PackUploadRequest with _$PackUploadRequest {
  const factory PackUploadRequest({
    required PackUploadPack packData,
    @Default([]) List<PackUploadSample> samplesData,
    @Default([]) List<PackUploadPreset> presetsData,
    PackUploadWavetable? wavetableData,
    @Default([]) List<PackUploadPattern> patternsData,
    @Default([]) List<PackUploadSlot> packSlotsData,
  }) = _PackUploadRequest;

  factory PackUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$PackUploadRequestFromJson(json);
}

@freezed
abstract class PackUploadPack with _$PackUploadPack {
  const factory PackUploadPack({
    required String userId,
    required String name,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _PackUploadPack;

  factory PackUploadPack.fromJson(Map<String, dynamic> json) =>
      _$PackUploadPackFromJson(json);
}

@freezed
abstract class PackUploadSample with _$PackUploadSample {
  const factory PackUploadSample({
    required int slotIndex,
    required String userId,
    required String name,
    required String filePath,
    required String pcmFilePath,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default([]) List<double> slicePoints,
    @Default(60) int baseNote,
    @Default(0) int fineTune,
    @Default(false) bool pitched,
    @Default([]) List<int> sliceNotes,
    String? contentHash,
    String? existingId,
  }) = _PackUploadSample;

  factory PackUploadSample.fromJson(Map<String, dynamic> json) =>
      _$PackUploadSampleFromJson(json);
}

@freezed
abstract class PackUploadPreset with _$PackUploadPreset {
  const factory PackUploadPreset({
    required int slotIndex,
    required String userId,
    required String name,
    required String category,
    required String presetData,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? contentHash,
    String? existingId,
    int? sampleSlotIndex,
  }) = _PackUploadPreset;

  factory PackUploadPreset.fromJson(Map<String, dynamic> json) =>
      _$PackUploadPresetFromJson(json);
}

@freezed
abstract class PackUploadWavetable with _$PackUploadWavetable {
  const factory PackUploadWavetable({
    required String userId,
    required String name,
    required String filePath,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? contentHash,
    String? existingId,
  }) = _PackUploadWavetable;

  factory PackUploadWavetable.fromJson(Map<String, dynamic> json) =>
      _$PackUploadWavetableFromJson(json);
}

@freezed
abstract class PackUploadPattern with _$PackUploadPattern {
  const factory PackUploadPattern({
    required int patternIndex,
    required String userId,
    required String name,
    required String filePath,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? contentHash,
    String? existingId,
  }) = _PackUploadPattern;

  factory PackUploadPattern.fromJson(Map<String, dynamic> json) =>
      _$PackUploadPatternFromJson(json);
}

@freezed
abstract class PackUploadSlot with _$PackUploadSlot {
  const factory PackUploadSlot({
    required int slotNumber,
    int? presetSlotIndex,
    int? sampleSlotIndex,
    int? patternIndex,
  }) = _PackUploadSlot;

  factory PackUploadSlot.fromJson(Map<String, dynamic> json) =>
      _$PackUploadSlotFromJson(json);
}
