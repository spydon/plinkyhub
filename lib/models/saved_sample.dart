import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/searchable.dart';

part 'saved_sample.freezed.dart';
part 'saved_sample.g.dart';

const defaultSlicePoints = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];

/// Default slice notes: all set to 48 (C4 in Plinky's note scheme, which maps
/// to MIDI note 60).
const defaultSliceNotes = [48, 48, 48, 48, 48, 48, 48, 48];

@freezed
abstract class SavedSample with _$SavedSample implements Searchable {
  const factory SavedSample({
    required String id,
    required String userId,
    required String name,
    required String filePath,
    required String pcmFilePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') @JsonKey(readValue: _readUsername) String username,
    @Default(0) @JsonKey(readValue: _readStarCount) int starCount,
    @Default(false) bool isStarred,
    @Default(defaultSlicePoints) List<double> slicePoints,
    @Default(60) int baseNote,
    @Default(0) int fineTune,
    @Default(false) bool pitched,
    @Default(defaultSliceNotes) List<int> sliceNotes,
  }) = _SavedSample;

  factory SavedSample.fromJson(Map<String, dynamic> json) =>
      _$SavedSampleFromJson(json);
}

Object? _readUsername(Map<dynamic, dynamic> json, String key) {
  final profiles = json['profiles'];
  if (profiles is Map<String, dynamic>) {
    return profiles['username'];
  }
  return json[key];
}

Object? _readStarCount(Map<dynamic, dynamic> json, String key) {
  final starsList = json['sample_stars'];
  if (starsList is List && starsList.isNotEmpty) {
    final first = starsList.first;
    if (first is Map<String, dynamic>) {
      return first['count'];
    }
  }
  return json[key];
}
