import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset_write.freezed.dart';
part 'preset_write.g.dart';

@freezed
abstract class PresetWrite with _$PresetWrite {
  const factory PresetWrite({
    required String userId,
    required String name,
    required String category,
    required String presetData,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? sampleId,
  }) = _PresetWrite;

  factory PresetWrite.fromJson(Map<String, dynamic> json) =>
      _$PresetWriteFromJson(json);
}
