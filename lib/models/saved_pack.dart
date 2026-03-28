import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/pack_slot.dart';
import 'package:plinkyhub/models/searchable.dart';

part 'saved_pack.freezed.dart';
part 'saved_pack.g.dart';

@freezed
abstract class SavedPack with _$SavedPack implements Searchable {
  const factory SavedPack({
    required String id,
    required String userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') @JsonKey(readValue: _readUsername) String username,
    @Default(0) @JsonKey(readValue: _readStarCount) int starCount,
    @Default(false) bool isStarred,
    @Default([]) @JsonKey(name: 'pack_slots') List<PackSlot> slots,
    String? wavetableId,
  }) = _SavedPack;

  factory SavedPack.fromJson(Map<String, dynamic> json) =>
      _$SavedPackFromJson(json);
}

Object? _readUsername(Map<dynamic, dynamic> json, String key) {
  final profiles = json['profiles'];
  if (profiles is Map<String, dynamic>) {
    return profiles['username'];
  }
  return json[key];
}

Object? _readStarCount(Map<dynamic, dynamic> json, String key) {
  final starsList = json['pack_stars'];
  if (starsList is List && starsList.isNotEmpty) {
    final first = starsList.first;
    if (first is Map<String, dynamic>) {
      return first['count'];
    }
  }
  return json[key];
}
