import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_upload_request.freezed.dart';
part 'pack_upload_request.g.dart';

@Freezed(fromJson: false, toJson: true)
abstract class PackUploadRequest with _$PackUploadRequest {
  const factory PackUploadRequest({
    required PackUploadPack packData,
    @Default([]) List<PackUploadSample> samplesData,
    @Default([]) List<PackUploadPreset> presetsData,
    PackUploadWavetable? wavetableData,
    @Default([]) List<PackUploadPattern> patternsData,
    @Default([]) List<PackUploadSlot> packSlotsData,
  }) = _PackUploadRequest;
}

@Freezed(fromJson: false, toJson: true)
abstract class PackUploadPack with _$PackUploadPack {
  const factory PackUploadPack({
    required String userId,
    required String name,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _PackUploadPack;
}

@Freezed(fromJson: false, toJson: true)
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
}

@Freezed(fromJson: false, toJson: true)
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
}

@Freezed(fromJson: false, toJson: true)
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
}

@Freezed(fromJson: false, toJson: true)
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
}

@Freezed(fromJson: false, toJson: true)
abstract class PackUploadSlot with _$PackUploadSlot {
  const factory PackUploadSlot({
    required int slotNumber,
    int? presetSlotIndex,
    int? sampleSlotIndex,
    int? patternIndex,
  }) = _PackUploadSlot;
}
