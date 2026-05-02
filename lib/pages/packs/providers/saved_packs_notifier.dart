import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/models/pack_slot_write.dart';
import 'package:plinkyhub/pages/packs/models/pack_write.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/utils/constants.dart';

/// A slot entry for creating or updating a pack.
typedef PackSlotEntry = ({
  int slotNumber,
  String? presetId,
  String? sampleId,
  String? patternId,
});

final savedPacksProvider =
    NotifierProvider<SavedPacksNotifier, SavedItemsState<SavedPack>>(
      SavedPacksNotifier.new,
    );

class SavedPacksNotifier extends SavedItemsNotifier<SavedPack> {
  @override
  String get tableName => 'packs';

  @override
  String get starTableName => 'pack_stars';

  @override
  String get starIdColumn => 'pack_id';

  @override
  String get selectQuery =>
      '*, pack_slots(*), profiles(username), pack_stars(count)';

  @override
  String get itemLabel => 'pack';

  @override
  SavedPack fromJson(Map<String, dynamic> json) => SavedPack.fromJson(json);

  @override
  SavedPack withStarUpdate(
    SavedPack item, {
    required bool isStarred,
    required int starCount,
  }) => item.copyWith(isStarred: isStarred, starCount: starCount);

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
      final write = PackWrite(
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
        wavetableId: wavetableId,
        youtubeUrl: youtubeUrl,
        contentHash: contentHash,
      );
      final packResponse = await supabase
          .from('packs')
          .insert(write.toJson())
          .select('id')
          .single();

      final packId = packResponse['id'] as String;
      await _insertSlots(packId, slots);

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
    if (name != null) {}

    setLoading();
    try {
      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
      }
      if (description != null) {
        updates['description'] = description;
      }
      if (isPublic != null) {
        updates['is_public'] = isPublic;
      }

      await supabase.from('packs').update(updates).eq('id', id);
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
          (slot) => PackSlotWrite(
            packId: packId,
            slotNumber: slot.slotNumber,
            presetId: slot.presetId,
            sampleId: slot.sampleId,
            patternId: slot.patternId,
          ).toJson(),
        )
        .toList();

    if (slotRows.isNotEmpty) {
      await supabase.from('pack_slots').insert(slotRows);
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
      final write = PackWrite(
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
        wavetableId: wavetableId,
        youtubeUrl: youtubeUrl,
      );
      await supabase.from('packs').update(write.toJson()).eq('id', id);
      await supabase.from('pack_slots').delete().eq('pack_id', id);
      await _insertSlots(id, slots);

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }
}
