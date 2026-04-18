import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/searchable.dart';

part 'saved_wavetable.freezed.dart';
part 'saved_wavetable.g.dart';

@freezed
abstract class SavedWavetable with _$SavedWavetable implements Searchable {
  const factory SavedWavetable({
    required String id,
    required String userId,
    required String name,
    required String filePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') @JsonKey(readValue: _readUsername) String username,
    @Default(0) @JsonKey(readValue: _readStarCount) int starCount,
    @Default(false) bool isStarred,
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _SavedWavetable;

  factory SavedWavetable.fromJson(Map<String, dynamic> json) =>
      _$SavedWavetableFromJson(json);
}

Object? _readUsername(Map<dynamic, dynamic> json, String key) {
  final profiles = json['profiles'];
  if (profiles is Map<String, dynamic>) {
    return profiles['username'];
  }
  return json[key];
}

Object? _readStarCount(Map<dynamic, dynamic> json, String key) {
  final starsList = json['wavetable_stars'];
  if (starsList is List && starsList.isNotEmpty) {
    final first = starsList.first;
    if (first is Map<String, dynamic>) {
      return first['count'];
    }
  }
  return json[key];
}
