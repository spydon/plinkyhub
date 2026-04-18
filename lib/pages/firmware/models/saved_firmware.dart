import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_firmware.freezed.dart';
part 'saved_firmware.g.dart';

@freezed
abstract class SavedFirmware with _$SavedFirmware {
  const factory SavedFirmware({
    required String id,
    required String userId,
    required String name,
    required String version,
    required String filePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String description,
    @Default(false) bool isBeta,
    @Default(false) bool isPinned,
    @Default('') @JsonKey(readValue: _readUsername) String username,
  }) = _SavedFirmware;

  factory SavedFirmware.fromJson(Map<String, dynamic> json) =>
      _$SavedFirmwareFromJson(json);
}

Object? _readUsername(Map<dynamic, dynamic> json, String key) {
  final profiles = json['profiles'];
  if (profiles is Map<String, dynamic>) {
    return profiles['username'];
  }
  return json[key];
}
