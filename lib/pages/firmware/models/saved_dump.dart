import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_dump.freezed.dart';
part 'saved_dump.g.dart';

@freezed
abstract class SavedDump with _$SavedDump {
  const factory SavedDump({
    required String id,
    required String userId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? internalFlashPath,
    String? externalFlashPath,
    @Default('') String description,
    @Default(0) int internalFlashSize,
    @Default(0) int externalFlashSize,
    @Default('') @JsonKey(readValue: _readUsername) String username,
  }) = _SavedDump;

  factory SavedDump.fromJson(Map<String, dynamic> json) =>
      _$SavedDumpFromJson(json);
}

Object? _readUsername(Map<dynamic, dynamic> json, String key) {
  final profiles = json['profiles'];
  if (profiles is Map<String, dynamic>) {
    return profiles['username'];
  }
  return json[key];
}
