// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class SavedPreset with Searchable {
  SavedPreset(this.row, {this.isStarred = false, int? starCount})
    : starCount =
          starCount ??
          readStarCount(row, Presets.presetStars, presetStarsTable);

  final PostgrestPartialRow<PresetsRow> row;

  @override
  final bool isStarred;

  @override
  final int starCount;

  @override
  late final String id = row.read(Presets.id);

  @override
  String get userId => row.read(Presets.userId);

  @override
  late final String name = row.read(Presets.name);

  String get category => row.read(Presets.category);

  String get presetData => row.read(Presets.presetData);

  DateTime get createdAt => row.read(Presets.createdAt);

  @override
  late final DateTime updatedAt = row.read(Presets.updatedAt);

  String get slug => row.read(Presets.slug);

  @override
  String get description => row.read(Presets.description);

  bool get isPublic => row.read(Presets.isPublic);

  @override
  String get username =>
      row.read(Presets.profiles)?.read(Profiles.username) ?? '';

  String get youtubeUrl => row.read(Presets.youtubeUrl);

  String? get sampleId => row.read(Presets.sampleId);

  String? get sampleName => row.read(Presets.samples)?.read(Samples.name);

  String? get sampleSlug => row.read(Presets.samples)?.read(Samples.slug);

  String? get sampleUsername => row
      .read(Presets.samples)
      ?.read(Samples.profiles)
      ?.read(Profiles.username);

  SavedPreset withStar({required bool isStarred, required int starCount}) =>
      SavedPreset(row, isStarred: isStarred, starCount: starCount);

  @override
  bool operator ==(Object other) =>
      other is SavedPreset &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.isStarred == isStarred &&
      other.starCount == starCount;

  @override
  int get hashCode => Object.hash(id, updatedAt, isStarred, starCount);

  /// The columns and relations the getters read.
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
