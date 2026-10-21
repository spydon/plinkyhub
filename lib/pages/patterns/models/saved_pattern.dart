// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class SavedPattern with Searchable {
  SavedPattern(this.row, {this.isStarred = false, int? starCount})
    : starCount = starCount ?? row.read(Patterns.patternStars.count());

  final PostgrestPartialRow<PatternsRow> row;

  @override
  final bool isStarred;

  @override
  final int starCount;

  @override
  late final String id = row.read(Patterns.id);

  @override
  String get userId => row.read(Patterns.userId);

  @override
  late final String name = row.read(Patterns.name);

  String get filePath => row.read(Patterns.filePath);

  DateTime get createdAt => row.read(Patterns.createdAt);

  @override
  late final DateTime updatedAt = row.read(Patterns.updatedAt);

  String get slug => row.read(Patterns.slug);

  @override
  String get description => row.read(Patterns.description);

  bool get isPublic => row.read(Patterns.isPublic);

  @override
  String get username =>
      row.read(Patterns.profiles)?.read(Profiles.username) ?? '';

  String? get contentHash => row.read(Patterns.contentHash);

  SavedPattern withStar({required bool isStarred, required int starCount}) =>
      SavedPattern(row, isStarred: isStarred, starCount: starCount);

  @override
  bool operator ==(Object other) =>
      other is SavedPattern &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.isStarred == isStarred &&
      other.starCount == starCount;

  @override
  int get hashCode => Object.hash(id, updatedAt, isStarred, starCount);

  /// The columns and relations the getters read.
  static final selection = <PostgrestSelectable<PatternsRow>>[
    Patterns.table.allColumns,
    Patterns.profiles(Profiles.username),
    Patterns.patternStars.count(),
  ];
}
