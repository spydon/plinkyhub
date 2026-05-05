import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset_write.freezed.dart';
part 'preset_write.g.dart';

@Freezed(fromJson: false, toJson: true)
abstract class PresetWrite with _$PresetWrite {
  const factory PresetWrite({
    required String userId,
    required String name,
    required String category,
    required String presetData,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String youtubeUrl,
    String? sampleId,
    String? contentHash,
  }) = _PresetWrite;
}
