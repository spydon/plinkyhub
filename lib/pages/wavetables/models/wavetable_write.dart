import 'package:freezed_annotation/freezed_annotation.dart';

part 'wavetable_write.freezed.dart';
part 'wavetable_write.g.dart';

@freezed
abstract class WavetableWrite with _$WavetableWrite {
  const factory WavetableWrite({
    required String userId,
    required String name,
    required String filePath,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _WavetableWrite;

  factory WavetableWrite.fromJson(Map<String, dynamic> json) =>
      _$WavetableWriteFromJson(json);
}
