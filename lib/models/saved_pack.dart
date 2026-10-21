// ignore_for_file: experimental_member_use

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/pack_slot.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_pack.freezed.dart';

@freezed
abstract class SavedPack with _$SavedPack implements Searchable {
  const factory SavedPack({
    required String id,
    required String userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String slug,
    @Default('') String description,
    @Default(false) bool isPublic,
    @Default('') String username,
    @Default(0) int starCount,
    @Default(false) bool isStarred,
    @Default([]) List<PackSlot> slots,
    String? wavetableId,
    @Default('') String youtubeUrl,
    String? contentHash,
  }) = _SavedPack;

  factory SavedPack.fromRow(
    PostgrestPartialRow<PacksRow> row, {
    bool isStarred = false,
  }) => SavedPack(
    id: row.read(Packs.id),
    userId: row.read(Packs.userId),
    name: row.read(Packs.name),
    createdAt: row.read(Packs.createdAt),
    updatedAt: row.read(Packs.updatedAt),
    slug: row.read(Packs.slug),
    description: row.read(Packs.description),
    isPublic: row.read(Packs.isPublic),
    username: row.read(Packs.profiles)?.read(Profiles.username) ?? '',
    starCount: readStarCount(row, Packs.packStars, packStarsTable),
    isStarred: isStarred,
    slots: [
      for (final slot in row.read(Packs.packSlots)) PackSlot.fromRow(slot),
    ],
    wavetableId: row.read(Packs.wavetableId),
    youtubeUrl: row.read(Packs.youtubeUrl),
    contentHash: row.read(Packs.contentHash),
  );

  /// The columns and relations [SavedPack.fromRow] reads.
  static final selection = <PostgrestSelectable<PacksRow>>[
    Packs.id,
    Packs.userId,
    Packs.name,
    Packs.createdAt,
    Packs.updatedAt,
    Packs.slug,
    Packs.description,
    Packs.isPublic,
    Packs.wavetableId,
    Packs.youtubeUrl,
    Packs.contentHash,
    Packs.packSlots.select(),
    Packs.profiles(Profiles.username),
    Packs.packStars(packStarsTable.count),
  ];
}
