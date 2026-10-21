// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
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
      SavedWavetable.fromRow(row);

  @override
  SavedWavetable withStarUpdate(
    SavedWavetable item, {
    required bool isStarred,
    required int starCount,
  }) => item.copyWith(isStarred: isStarred, starCount: starCount);

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

  Future<SavedWavetable?> saveWavetable(
    SavedWavetable wavetable, {
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

      final inserted = await supabase
          .table(Wavetables.table)
          .insert(
            WavetablesInsert(
              userId: wavetable.userId,
              name: wavetable.name,
              filePath: wavetable.filePath,
              description: wavetable.description,
              isPublic: wavetable.isPublic,
              youtubeUrl: wavetable.youtubeUrl,
              contentHash: computeContentHash(uf2Bytes),
            ),
          )
          .select()
          .single();

      await refreshAll();
      return SavedWavetable.fromFullRow(inserted);
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updateWavetable(SavedWavetable wavetable) async {
    setLoading();
    try {
      await supabase
          .table(Wavetables.table)
          .update(
            WavetablesUpdate(
              userId: wavetable.userId,
              name: wavetable.name,
              filePath: wavetable.filePath,
              description: wavetable.description,
              isPublic: wavetable.isPublic,
              youtubeUrl: wavetable.youtubeUrl,
            ),
          )
          .where(Wavetables.id.eq(wavetable.id));
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> updateWavetableContent(
    SavedWavetable wavetable, {
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
              userId: wavetable.userId,
              name: wavetable.name,
              filePath: wavetable.filePath,
              description: wavetable.description,
              isPublic: wavetable.isPublic,
              youtubeUrl: wavetable.youtubeUrl,
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
