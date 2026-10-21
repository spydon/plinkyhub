// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_preset.freezed.dart';

@freezed
abstract class SavedPreset with _$SavedPreset implements Searchable {
  const factory SavedPreset({
    required String id,
    required String userId,
    required String name,
    required String category,
    required String presetData,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String slug,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String username,
    @Default(0) int starCount,
    @Default(false) bool isStarred,
    @Default('') String youtubeUrl,
    String? sampleId,
    String? sampleName,
    String? sampleSlug,
    String? sampleUsername,
  }) = _SavedPreset;

  factory SavedPreset.fromRow(
    PostgrestPartialRow<PresetsRow> row, {
    bool isStarred = false,
  }) {
    final sample = row.read(Presets.samples);
    return SavedPreset(
      id: row.read(Presets.id),
      userId: row.read(Presets.userId),
      name: row.read(Presets.name),
      category: row.read(Presets.category),
      presetData: row.read(Presets.presetData),
      createdAt: row.read(Presets.createdAt),
      updatedAt: row.read(Presets.updatedAt),
      slug: row.read(Presets.slug),
      description: row.read(Presets.description),
      isPublic: row.read(Presets.isPublic),
      username: row.read(Presets.profiles)?.read(Profiles.username) ?? '',
      starCount: readStarCount(row, Presets.presetStars, presetStarsTable),
      isStarred: isStarred,
      youtubeUrl: row.read(Presets.youtubeUrl),
      sampleId: row.read(Presets.sampleId),
      sampleName: sample?.read(Samples.name),
      sampleSlug: sample?.read(Samples.slug),
      sampleUsername: sample?.read(Samples.profiles)?.read(Profiles.username),
    );
  }

  /// The columns and relations [SavedPreset.fromRow] reads.
  static final selection = <PostgrestSelectable<PresetsRow>>[
    Presets.id,
    Presets.userId,
    Presets.name,
    Presets.category,
    Presets.presetData,
    Presets.createdAt,
    Presets.updatedAt,
    Presets.slug,
    Presets.description,
    Presets.isPublic,
    Presets.youtubeUrl,
    Presets.sampleId,
    Presets.profiles(Profiles.username),
    Presets.presetStars(presetStarsTable.count),
    Presets.samples.select([
      Samples.name,
      Samples.slug,
      Samples.profiles(Profiles.username),
    ]),
  ];
}
