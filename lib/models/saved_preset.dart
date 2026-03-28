import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_preset.freezed.dart';
part 'saved_preset.g.dart';

@freezed
abstract class SavedPreset with _$SavedPreset {
  const factory SavedPreset({
    required String id,
    required String userId,
    required String name,
    required String category,
    required String presetData,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('')
    @JsonKey(readValue: _readUsername)
    String username,
    @Default(0)
    @JsonKey(readValue: _readStarCount)
    int starCount,
    @Default(false) bool isStarred,
    String? sampleId,
  }) = _SavedPreset;

  factory SavedPreset.fromJson(Map<String, dynamic> json) =>
      _$SavedPresetFromJson(json);
}

Object? _readUsername(Map<dynamic, dynamic> json, String key) {
  final profiles = json['profiles'];
  if (profiles is Map<String, dynamic>) {
    return profiles['username'];
  }
  return json[key];
}

Object? _readStarCount(Map<dynamic, dynamic> json, String key) {
  final starsList = json['patch_stars'];
  if (starsList is List && starsList.isNotEmpty) {
    final first = starsList.first;
    if (first is Map<String, dynamic>) {
      return first['count'];
    }
  }
  return json[key];
}
