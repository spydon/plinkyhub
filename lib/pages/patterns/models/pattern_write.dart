import 'package:freezed_annotation/freezed_annotation.dart';

part 'pattern_write.freezed.dart';
part 'pattern_write.g.dart';

@freezed
abstract class PatternWrite with _$PatternWrite {
  const factory PatternWrite({
    required String userId,
    required String name,
    required String filePath,
    @Default('') String description,
    @Default(false) bool isPublic,
    String? contentHash,
  }) = _PatternWrite;

  factory PatternWrite.fromJson(Map<String, dynamic> json) =>
      _$PatternWriteFromJson(json);
}
