// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:plinkyhub/models/pack_slot.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class SavedPack with Searchable {
  SavedPack(this.row, {this.isStarred = false, int? starCount})
    : starCount = starCount ?? row.read(Packs.packStars.count());

  final PostgrestPartialRow<PacksRow> row;

  @override
  final bool isStarred;

  @override
  final int starCount;

  @override
  late final String id = row.read(Packs.id);

  @override
  String get userId => row.read(Packs.userId);

  @override
  late final String name = row.read(Packs.name);

  DateTime get createdAt => row.read(Packs.createdAt);

  @override
  late final DateTime updatedAt = row.read(Packs.updatedAt);

  String get slug => row.read(Packs.slug);

  @override
  String get description => row.read(Packs.description);

  bool get isPublic => row.read(Packs.isPublic);

  @override
  String get username =>
      row.read(Packs.profiles)?.read(Profiles.username) ?? '';

  late final List<PackSlot> slots = List.unmodifiable([
    for (final slot in row.read(Packs.packSlots)) PackSlot(slot),
  ]);

  String get wavetableId => row.read(Packs.wavetableId);

  String get youtubeUrl => row.read(Packs.youtubeUrl);

  String? get contentHash => row.read(Packs.contentHash);

  SavedPack withStar({required bool isStarred, required int starCount}) =>
      SavedPack(row, isStarred: isStarred, starCount: starCount);

  @override
  bool operator ==(Object other) =>
      other is SavedPack &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.isStarred == isStarred &&
      other.starCount == starCount;

  @override
  int get hashCode => Object.hash(id, updatedAt, isStarred, starCount);

  /// The columns and relations the getters read.
  static final selection = <PostgrestSelectable<PacksRow>>[
    Packs.table.allColumns,
    Packs.packSlots.select(),
    Packs.profiles(Profiles.username),
    Packs.packStars.count(),
  ];
}
