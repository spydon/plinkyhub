// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/users/models/user_profile_state.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
      UserProfileNotifier.new,
    );

final userProfileByUsernameProvider = FutureProvider.autoDispose
    .family<UserProfileState, String>((ref, username) async {
      final supabase = Supabase.instance.client;
      final currentUserId = ref.read(authenticationProvider).user?.id;

      final profile = await supabase
          .table(Profiles.table)
          .selectOnly([Profiles.id])
          .where(Profiles.username.eq(username))
          .maybeSingle();

      if (profile == null) {
        throw Exception('User "$username" not found');
      }

      final userId = profile.read(Profiles.id);

      final (presets, packs, samples) = await (
        _fetchItems(
          supabase,
          itemTable: presetsTable,
          starTable: presetStarsTable,
          selection: SavedPreset.selection,
          fromRow: SavedPreset.fromRow,
          userId: userId,
          currentUserId: currentUserId,
        ),
        _fetchItems(
          supabase,
          itemTable: packsTable,
          starTable: packStarsTable,
          selection: SavedPack.selection,
          fromRow: SavedPack.fromRow,
          userId: userId,
          currentUserId: currentUserId,
        ),
        _fetchItems(
          supabase,
          itemTable: samplesTable,
          starTable: sampleStarsTable,
          selection: SavedSample.selection,
          fromRow: SavedSample.fromRow,
          userId: userId,
          currentUserId: currentUserId,
        ),
      ).wait;

      return UserProfileState(
        userId: userId,
        username: username,
        presets: presets,
        packs: packs,
        samples: samples,
      );
    });

/// The items of [itemTable] owned by [userId], newest first, marked as starred
/// when [currentUserId] starred them. Only public items are included unless
/// [currentUserId] is the owner.
Future<List<T>> _fetchItems<T, Row>(
  SupabaseClient supabase, {
  required ItemTable<Row> itemTable,
  required StarTable<Object?, Object?> starTable,
  required List<PostgrestSelectable<Row>> selection,
  required T Function(PostgrestPartialRow<Row> row, {bool isStarred}) fromRow,
  required String userId,
  required String? currentUserId,
}) async {
  var filter = itemTable.userId.eq(userId);
  if (currentUserId != userId) {
    filter = filter & itemTable.isPublic.isTrue();
  }
  final rows = await supabase
      .table(itemTable.table)
      .selectOnly(selection)
      .where(filter)
      .order(itemTable.updatedAt.desc());
  final starredIds = currentUserId == null
      ? const <String>{}
      : await starTable.fetchStarredItemIds(supabase, currentUserId);
  return [
    for (final row in rows)
      fromRow(row, isStarred: starredIds.contains(row.read(itemTable.id))),
  ];
}

class UserProfileNotifier extends Notifier<UserProfileState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  UserProfileState build() => const UserProfileState();

  Future<void> loadUserProfile(String userId, String username) async {
    state = UserProfileState(
      userId: userId,
      username: username,
      isLoading: true,
    );

    try {
      final currentUserId = ref.read(authenticationProvider).user?.id;

      final (presets, packs, samples) = await (
        _fetchItems(
          _supabase,
          itemTable: presetsTable,
          starTable: presetStarsTable,
          selection: SavedPreset.selection,
          fromRow: SavedPreset.fromRow,
          userId: userId,
          currentUserId: currentUserId,
        ),
        _fetchItems(
          _supabase,
          itemTable: packsTable,
          starTable: packStarsTable,
          selection: SavedPack.selection,
          fromRow: SavedPack.fromRow,
          userId: userId,
          currentUserId: currentUserId,
        ),
        _fetchItems(
          _supabase,
          itemTable: samplesTable,
          starTable: sampleStarsTable,
          selection: SavedSample.selection,
          fromRow: SavedSample.fromRow,
          userId: userId,
          currentUserId: currentUserId,
        ),
      ).wait;

      state = state.copyWith(
        presets: presets,
        packs: packs,
        samples: samples,
        isLoading: false,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
