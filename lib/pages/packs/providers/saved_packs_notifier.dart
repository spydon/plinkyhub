// ignore_for_file: experimental_member_use

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/pack_slot.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPacksProvider =
    NotifierProvider<SavedPacksNotifier, SavedItemsState<SavedPack>>(
      SavedPacksNotifier.new,
    );

class SavedPacksNotifier
    extends
        SavedItemsNotifier<SavedPack, PacksRow, PackStarsRow, PackStarsInsert> {
  @override
  ItemTable<PacksRow> get itemTable => packsTable;

  @override
  StarTable<PackStarsRow, PackStarsInsert> get starTable => packStarsTable;

  @override
  List<PostgrestSelectable<PacksRow>> get selection => SavedPack.selection;

  @override
  String get itemLabel => 'pack';

  @override
  SavedPack fromRow(PostgrestPartialRow<PacksRow> row) => SavedPack(row);

  @override
  SavedPack withStarUpdate(
    SavedPack item, {
    required bool isStarred,
    required int starCount,
  }) => item.withStar(isStarred: isStarred, starCount: starCount);

  void startEditing(SavedPack pack) {
    state = state.copyWith(editingItem: () => pack);
  }

  void stopEditing() {
    state = state.copyWith(editingItem: () => null);
  }

  Future<void> savePack(
    String name, {
    required List<PackSlotEntry> slots,
    String description = '',
    bool isPublic = false,
    String wavetableId = defaultWavetableId,
    String youtubeUrl = '',
    String? contentHash,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setLoading();
    try {
      final pack = await supabase
          .table(Packs.table)
          .insert(
            PacksInsert(
              userId: userId,
              name: name,
              description: description,
              isPublic: isPublic,
              wavetableId: wavetableId,
              youtubeUrl: youtubeUrl,
              contentHash: contentHash,
            ),
          )
          .selectOnly([Packs.id])
          .single();

      await _insertSlots(pack.read(Packs.id), slots);

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> updatePack(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    setLoading();
    try {
      await supabase
          .table(Packs.table)
          .update(
            PacksUpdate(
              name: name,
              description: description,
              isPublic: isPublic,
            ),
          )
          .where(Packs.id.eq(id));
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> _insertSlots(
    String packId,
    List<PackSlotEntry> slots,
  ) async {
    final slotRows = slots
        .where(
          (slot) =>
              slot.presetId != null ||
              slot.sampleId != null ||
              slot.patternId != null,
        )
        .map(
          (slot) => PackSlotsInsert(
            packId: packId,
            slotNumber: slot.slotNumber,
            presetId: slot.presetId,
            sampleId: slot.sampleId,
            patternId: slot.patternId,
          ),
        )
        .toList();

    if (slotRows.isNotEmpty) {
      await supabase.table(PackSlots.table).insertAll(slotRows);
    }
  }

  Future<void> updatePackWithSlots(
    String id, {
    required String name,
    required String description,
    required bool isPublic,
    required List<PackSlotEntry> slots,
    String wavetableId = defaultWavetableId,
    String youtubeUrl = '',
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setLoading();
    try {
      await supabase
          .table(Packs.table)
          .update(
            PacksUpdate(
              userId: userId,
              name: name,
              description: description,
              isPublic: isPublic,
              wavetableId: wavetableId,
              youtubeUrl: youtubeUrl,
            ).setContentHashToNull(),
          )
          .where(Packs.id.eq(id));
      await supabase
          .table(PackSlots.table)
          .delete()
          .where(PackSlots.packId.eq(id));
      await _insertSlots(id, slots);

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }
}
