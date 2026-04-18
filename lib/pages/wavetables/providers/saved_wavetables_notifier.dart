import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/models/wavetable_write.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedWavetablesProvider =
    NotifierProvider<SavedWavetablesNotifier, SavedItemsState<SavedWavetable>>(
      SavedWavetablesNotifier.new,
    );

class SavedWavetablesNotifier extends SavedItemsNotifier<SavedWavetable> {
  @override
  String get tableName => 'wavetables';

  @override
  String get starTableName => 'wavetable_stars';

  @override
  String get starIdColumn => 'wavetable_id';

  @override
  String get selectQuery => '*, profiles(username), wavetable_stars(count)';

  @override
  String get itemLabel => 'wavetable';

  @override
  SavedWavetable fromJson(Map<String, dynamic> json) =>
      SavedWavetable.fromJson(json);

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

  Future<void> saveWavetable(
    SavedWavetable wavetable, {
    required Uint8List uf2Bytes,
  }) async {
    throwIfNameExists(wavetable.name);

    setLoading();
    try {
      await supabase.storage
          .from('wavetables')
          .uploadBinary(
            wavetable.filePath,
            uf2Bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final write = WavetableWrite(
        userId: wavetable.userId,
        name: wavetable.name,
        filePath: wavetable.filePath,
        description: wavetable.description,
        isPublic: wavetable.isPublic,
        youtubeUrl: wavetable.youtubeUrl,
        contentHash: computeContentHash(uf2Bytes),
      );
      await supabase.from('wavetables').insert(write.toJson());

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updateWavetable(SavedWavetable wavetable) async {
    throwIfNameExists(wavetable.name, excludeId: wavetable.id);

    setLoading();
    try {
      final write = WavetableWrite(
        userId: wavetable.userId,
        name: wavetable.name,
        filePath: wavetable.filePath,
        description: wavetable.description,
        isPublic: wavetable.isPublic,
        youtubeUrl: wavetable.youtubeUrl,
      );
      await supabase
          .from('wavetables')
          .update(write.toJson())
          .eq('id', wavetable.id);
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> updateWavetableContent(
    SavedWavetable wavetable, {
    required Uint8List uf2Bytes,
  }) async {
    throwIfNameExists(wavetable.name, excludeId: wavetable.id);

    setLoading();
    try {
      await supabase.storage
          .from('wavetables')
          .uploadBinary(
            wavetable.filePath,
            uf2Bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final write = WavetableWrite(
        userId: wavetable.userId,
        name: wavetable.name,
        filePath: wavetable.filePath,
        description: wavetable.description,
        isPublic: wavetable.isPublic,
        youtubeUrl: wavetable.youtubeUrl,
        contentHash: computeContentHash(uf2Bytes),
      );
      await supabase
          .from('wavetables')
          .update(write.toJson())
          .eq('id', wavetable.id);

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
