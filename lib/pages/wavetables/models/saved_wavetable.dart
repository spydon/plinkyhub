// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_wavetable.freezed.dart';

@freezed
abstract class SavedWavetable with _$SavedWavetable implements Searchable {
  const factory SavedWavetable({
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
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _SavedWavetable;

  factory SavedWavetable.fromRow(
    PostgrestPartialRow<WavetablesRow> row, {
    bool isStarred = false,
  }) => SavedWavetable(
    id: row.read(Wavetables.id),
    userId: row.read(Wavetables.userId),
    name: row.read(Wavetables.name),
    filePath: row.read(Wavetables.filePath),
    createdAt: row.read(Wavetables.createdAt),
    updatedAt: row.read(Wavetables.updatedAt),
    slug: row.read(Wavetables.slug),
    description: row.read(Wavetables.description),
    isPublic: row.read(Wavetables.isPublic),
    username: row.read(Wavetables.profiles)?.read(Profiles.username) ?? '',
    starCount: readStarCount(
      row,
      Wavetables.wavetableStars,
      wavetableStarsTable,
    ),
    isStarred: isStarred,
    youtubeUrl: row.read(Wavetables.youtubeUrl),
    contentHash: row.read(Wavetables.contentHash),
  );

  /// Reads a full row, such as the one an insert returns. It carries no
  /// relations, so [username] and [starCount] keep their defaults.
  factory SavedWavetable.fromFullRow(WavetablesRow row) => SavedWavetable(
    id: row.id,
    userId: row.userId,
    name: row.name,
    filePath: row.filePath,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    slug: row.slug,
    description: row.description,
    isPublic: row.isPublic,
    youtubeUrl: row.youtubeUrl,
    contentHash: row.contentHash,
  );

  /// The columns and relations [SavedWavetable.fromRow] reads.
  static final selection = <PostgrestSelectable<WavetablesRow>>[
    Wavetables.id,
    Wavetables.userId,
    Wavetables.name,
    Wavetables.filePath,
    Wavetables.createdAt,
    Wavetables.updatedAt,
    Wavetables.slug,
    Wavetables.description,
    Wavetables.isPublic,
    Wavetables.youtubeUrl,
    Wavetables.contentHash,
    Wavetables.profiles(Profiles.username),
    Wavetables.wavetableStars(wavetableStarsTable.count),
  ];
}
