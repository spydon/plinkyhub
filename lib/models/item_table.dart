// ignore_for_file: experimental_member_use

import 'package:plinkyhub/models/matched_entry.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The columns shared by the tables of the items users save, star and share:
/// presets, samples, patterns, wavetables and packs.
class ItemTable<Row> {
  const ItemTable({
    required this.table,
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    required this.isPublic,
    required this.updatedAt,
    required this.contentHash,
    required this.profiles,
  });

  final PostgrestTable<Row, Object?, Object?> table;
  final PostgrestColumn<Row, String> id;
  final PostgrestColumn<Row, String> userId;
  final PostgrestColumn<Row, String> name;
  final PostgrestColumn<Row, String> slug;
  final PostgrestColumn<Row, bool> isPublic;
  final PostgrestColumn<Row, DateTime> updatedAt;
  final PostgrestNullableColumn<Row, String> contentHash;
  final PostgrestToOneRelation<Row, ProfilesRow> profiles;

  /// Only the rows owned by the user called [username], for a query that
  /// selects [profiles].
  PostgrestFilter<Row> ownedByUsername(String username) =>
      PostgrestFilter.raw<Row>(
        profiles(Profiles.username).embeddedFilterName,
        'eq.$username',
      ) &
      PostgrestFilter.raw<Row>(profiles.key, 'not.is.null');

  /// The rows whose content hash is one of [hashes], keyed by content hash.
  Future<Map<String, MatchedEntry>> findByContentHashes(
    SupabaseClient supabase,
    Iterable<String> hashes,
  ) async {
    final uniqueHashes = hashes.toSet().toList();
    if (uniqueHashes.isEmpty) {
      return {};
    }
    final rows = await supabase
        .table(table)
        .selectOnly([id, name, contentHash])
        .where(contentHash.inFilter(uniqueHashes));
    return {
      for (final row in rows)
        if (row.read(contentHash) case final hash?)
          hash: MatchedEntry(id: row.read(id), name: row.read(name)),
    };
  }
}

/// The table recording which users starred which items of an [ItemTable].
class StarTable<Row, Insert> {
  const StarTable({
    required this.table,
    required this.itemId,
    required this.userId,
    required this.createInsert,
  });

  final PostgrestTable<Row, Insert, Object?> table;
  final PostgrestColumn<Row, String> itemId;
  final PostgrestColumn<Row, String> userId;
  final Insert Function({required String itemId, required String userId})
  createInsert;

  /// `count` inside an embed of this table, the number of stars PostgREST
  /// counts even with aggregate functions disabled, unlike `count()`.
  PostgrestColumn<Row, int> get count => PostgrestColumn<Row, int>('count');

  /// The ids of the items [userId] starred.
  Future<Set<String>> fetchStarredItemIds(
    SupabaseClient supabase,
    String userId,
  ) async {
    final rows = await supabase
        .table(table)
        .selectOnly([itemId])
        .where(this.userId.eq(userId));
    return {for (final row in rows) row.read(itemId)};
  }

  /// Whether [userId] starred the item with [id].
  Future<bool> isStarred(
    SupabaseClient supabase, {
    required String id,
    required String? userId,
  }) async {
    if (userId == null) {
      return false;
    }
    final row = await supabase
        .table(table)
        .selectOnly([itemId])
        .where(itemId.eq(id) & this.userId.eq(userId))
        .maybeSingle();
    return row != null;
  }
}

/// The number of stars in the embedded rows of [starTable], read through
/// [relation].
int readStarCount<Row, StarRow>(
  PostgrestPartialRow<Row> row,
  PostgrestToManyRelation<Row, StarRow> relation,
  StarTable<StarRow, Object?> starTable,
) => row.read(relation).firstOrNull?.read(starTable.count) ?? 0;

const presetsTable = ItemTable<PresetsRow>(
  table: Presets.table,
  id: Presets.id,
  userId: Presets.userId,
  name: Presets.name,
  slug: Presets.slug,
  isPublic: Presets.isPublic,
  updatedAt: Presets.updatedAt,
  contentHash: Presets.contentHash,
  profiles: Presets.profiles,
);

const samplesTable = ItemTable<SamplesRow>(
  table: Samples.table,
  id: Samples.id,
  userId: Samples.userId,
  name: Samples.name,
  slug: Samples.slug,
  isPublic: Samples.isPublic,
  updatedAt: Samples.updatedAt,
  contentHash: Samples.contentHash,
  profiles: Samples.profiles,
);

const patternsTable = ItemTable<PatternsRow>(
  table: Patterns.table,
  id: Patterns.id,
  userId: Patterns.userId,
  name: Patterns.name,
  slug: Patterns.slug,
  isPublic: Patterns.isPublic,
  updatedAt: Patterns.updatedAt,
  contentHash: Patterns.contentHash,
  profiles: Patterns.profiles,
);

const wavetablesTable = ItemTable<WavetablesRow>(
  table: Wavetables.table,
  id: Wavetables.id,
  userId: Wavetables.userId,
  name: Wavetables.name,
  slug: Wavetables.slug,
  isPublic: Wavetables.isPublic,
  updatedAt: Wavetables.updatedAt,
  contentHash: Wavetables.contentHash,
  profiles: Wavetables.profiles,
);

const packsTable = ItemTable<PacksRow>(
  table: Packs.table,
  id: Packs.id,
  userId: Packs.userId,
  name: Packs.name,
  slug: Packs.slug,
  isPublic: Packs.isPublic,
  updatedAt: Packs.updatedAt,
  contentHash: Packs.contentHash,
  profiles: Packs.profiles,
);

const presetStarsTable = StarTable<PresetStarsRow, PresetStarsInsert>(
  table: PresetStars.table,
  itemId: PresetStars.presetId,
  userId: PresetStars.userId,
  createInsert: _presetStar,
);

const sampleStarsTable = StarTable<SampleStarsRow, SampleStarsInsert>(
  table: SampleStars.table,
  itemId: SampleStars.sampleId,
  userId: SampleStars.userId,
  createInsert: _sampleStar,
);

const patternStarsTable = StarTable<PatternStarsRow, PatternStarsInsert>(
  table: PatternStars.table,
  itemId: PatternStars.patternId,
  userId: PatternStars.userId,
  createInsert: _patternStar,
);

const wavetableStarsTable = StarTable<WavetableStarsRow, WavetableStarsInsert>(
  table: WavetableStars.table,
  itemId: WavetableStars.wavetableId,
  userId: WavetableStars.userId,
  createInsert: _wavetableStar,
);

const packStarsTable = StarTable<PackStarsRow, PackStarsInsert>(
  table: PackStars.table,
  itemId: PackStars.packId,
  userId: PackStars.userId,
  createInsert: _packStar,
);

PresetStarsInsert _presetStar({
  required String itemId,
  required String userId,
}) => PresetStarsInsert(presetId: itemId, userId: userId);

SampleStarsInsert _sampleStar({
  required String itemId,
  required String userId,
}) => SampleStarsInsert(sampleId: itemId, userId: userId);

PatternStarsInsert _patternStar({
  required String itemId,
  required String userId,
}) => PatternStarsInsert(patternId: itemId, userId: userId);

WavetableStarsInsert _wavetableStar({
  required String itemId,
  required String userId,
}) => WavetableStarsInsert(wavetableId: itemId, userId: userId);

PackStarsInsert _packStar({required String itemId, required String userId}) =>
    PackStarsInsert(packId: itemId, userId: userId);
