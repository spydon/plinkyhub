// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class SavedPattern with Searchable {
  SavedPattern(this.row, {this.isStarred = false, int? starCount})
    : starCount =
          starCount ??
          readStarCount(row, Patterns.patternStars, patternStarsTable);

  final PostgrestPartialRow<PatternsRow> row;

  @override
  final bool isStarred;

  @override
  final int starCount;

  @override
  String get id => row.read(Patterns.id);

  @override
  String get userId => row.read(Patterns.userId);

  @override
  String get name => row.read(Patterns.name);

  String get filePath => row.read(Patterns.filePath);

  DateTime get createdAt => row.read(Patterns.createdAt);

  @override
  DateTime get updatedAt => row.read(Patterns.updatedAt);

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
    Patterns.id,
    Patterns.userId,
    Patterns.name,
    Patterns.filePath,
    Patterns.createdAt,
    Patterns.updatedAt,
    Patterns.slug,
    Patterns.description,
    Patterns.isPublic,
    Patterns.contentHash,
    Patterns.profiles(Profiles.username),
    Patterns.patternStars(patternStarsTable.count),
  ];
}
