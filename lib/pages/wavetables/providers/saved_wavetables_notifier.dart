// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedWavetablesProvider =
    NotifierProvider<SavedWavetablesNotifier, SavedItemsState<SavedWavetable>>(
      SavedWavetablesNotifier.new,
    );

class SavedWavetablesNotifier
    extends
        SavedItemsNotifier<
          SavedWavetable,
          WavetablesRow,
          WavetableStarsRow,
          WavetableStarsInsert
        > {
  @override
  ItemTable<WavetablesRow> get itemTable => wavetablesTable;

  @override
  StarTable<WavetableStarsRow, WavetableStarsInsert> get starTable =>
      wavetableStarsTable;

  @override
  List<PostgrestSelectable<WavetablesRow>> get selection =>
      SavedWavetable.selection;

  @override
  String get itemLabel => 'wavetable';

  @override
  SavedWavetable fromRow(PostgrestPartialRow<WavetablesRow> row) =>
      SavedWavetable(row);

  @override
  SavedWavetable withStarUpdate(
    SavedWavetable item, {
    required bool isStarred,
    required int starCount,
  }) => item.withStar(isStarred: isStarred, starCount: starCount);

  @override
  Future<void> deleteItem(String id) async {
    setLoading();
    try {
      final wavetable = state.userItems.where((w) => w.id == id).firstOrNull;
      if (wavetable != null) {
        await supabase.storage.from('wavetables').remove([
          wavetable.filePath,
        ]);
      }
      await super.deleteItem(id);
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<SavedWavetable?> saveWavetable({
    required String name,
    required String filePath,
    required String description,
    required bool isPublic,
    required String youtubeUrl,
    required Uint8List uf2Bytes,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return null;
    }

    setLoading();
    try {
      await supabase.storage
          .from('wavetables')
          .uploadBinary(
            filePath,
            uf2Bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final inserted = await supabase
          .table(Wavetables.table)
          .insert(
            WavetablesInsert(
              userId: userId,
              name: name,
              filePath: filePath,
              description: description,
              isPublic: isPublic,
              youtubeUrl: youtubeUrl,
              contentHash: computeContentHash(uf2Bytes),
            ),
          )
          .selectOnly(SavedWavetable.selection)
          .single();

      await refreshAll();
      return SavedWavetable(inserted);
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updateWavetable(String id, WavetablesUpdate update) async {
    setLoading();
    try {
      await supabase
          .table(Wavetables.table)
          .update(update)
          .where(Wavetables.id.eq(id));
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  /// Replaces the file of [wavetable] with [uf2Bytes] and writes the new
  /// content hash along with the given details.
  Future<void> updateWavetableContent(
    SavedWavetable wavetable, {
    required String name,
    required String description,
    required bool isPublic,
    required String youtubeUrl,
    required Uint8List uf2Bytes,
  }) async {
    setLoading();
    try {
      await supabase.storage
          .from('wavetables')
          .uploadBinary(
            wavetable.filePath,
            uf2Bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      await supabase
          .table(Wavetables.table)
          .update(
            WavetablesUpdate(
              name: name,
              description: description,
              isPublic: isPublic,
              youtubeUrl: youtubeUrl,
              contentHash: computeContentHash(uf2Bytes),
            ),
          )
          .where(Wavetables.id.eq(wavetable.id));

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<Uint8List> downloadUf2(String filePath) async {
    return supabase.storage.from('wavetables').download(filePath);
  }
}
