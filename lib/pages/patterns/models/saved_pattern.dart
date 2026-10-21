// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_pattern.freezed.dart';

@freezed
abstract class SavedPattern with _$SavedPattern implements Searchable {
  const factory SavedPattern({
    required String id,
    required String userId,
    required String name,
    required String filePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String slug,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String username,
    @Default(0) int starCount,
    @Default(false) bool isStarred,
    String? contentHash,
  }) = _SavedPattern;

  factory SavedPattern.fromRow(
    PostgrestPartialRow<PatternsRow> row, {
    bool isStarred = false,
  }) => SavedPattern(
    id: row.read(Patterns.id),
    userId: row.read(Patterns.userId),
    name: row.read(Patterns.name),
    filePath: row.read(Patterns.filePath),
    createdAt: row.read(Patterns.createdAt),
    updatedAt: row.read(Patterns.updatedAt),
    slug: row.read(Patterns.slug),
    description: row.read(Patterns.description),
    isPublic: row.read(Patterns.isPublic),
    username: row.read(Patterns.profiles)?.read(Profiles.username) ?? '',
    starCount: readStarCount(row, Patterns.patternStars, patternStarsTable),
    isStarred: isStarred,
    contentHash: row.read(Patterns.contentHash),
  );

  /// The columns and relations [SavedPattern.fromRow] reads.
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
