// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class SavedWavetable with Searchable {
  SavedWavetable(this.row, {this.isStarred = false, int? starCount})
    : starCount = starCount ?? row.read(Wavetables.wavetableStars.count());

  final PostgrestPartialRow<WavetablesRow> row;

  @override
  final bool isStarred;

  @override
  final int starCount;

  @override
  late final String id = row.read(Wavetables.id);

  @override
  String get userId => row.read(Wavetables.userId);

  @override
  late final String name = row.read(Wavetables.name);

  String get filePath => row.read(Wavetables.filePath);

  DateTime get createdAt => row.read(Wavetables.createdAt);

  @override
  late final DateTime updatedAt = row.read(Wavetables.updatedAt);

  String get slug => row.read(Wavetables.slug);

  @override
  String get description => row.read(Wavetables.description);

  bool get isPublic => row.read(Wavetables.isPublic);

  @override
  String get username =>
      row.read(Wavetables.profiles)?.read(Profiles.username) ?? '';

  String get youtubeUrl => row.read(Wavetables.youtubeUrl);

  String? get contentHash => row.read(Wavetables.contentHash);

  SavedWavetable withStar({required bool isStarred, required int starCount}) =>
      SavedWavetable(row, isStarred: isStarred, starCount: starCount);

  @override
  bool operator ==(Object other) =>
      other is SavedWavetable &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.isStarred == isStarred &&
      other.starCount == starCount;

  @override
  int get hashCode => Object.hash(id, updatedAt, isStarred, starCount);

  /// The columns and relations the getters read.
  static final selection = <PostgrestSelectable<WavetablesRow>>[
    Wavetables.table.allColumns,
    Wavetables.profiles(Profiles.username),
    Wavetables.wavetableStars.count(),
  ];
}
