import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/models/sample_write.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedSamplesProvider =
    NotifierProvider<SavedSamplesNotifier, SavedItemsState<SavedSample>>(
      SavedSamplesNotifier.new,
    );

class SavedSamplesNotifier extends SavedItemsNotifier<SavedSample> {
  @override
  String get tableName => 'samples';

  @override
  String get starTableName => 'sample_stars';

  @override
  String get starIdColumn => 'sample_id';

  @override
  String get selectQuery => '*, profiles(username), sample_stars(count)';

  @override
  String get itemLabel => 'sample';

  @override
  SavedSample fromJson(Map<String, dynamic> json) => SavedSample.fromJson(json);

  @override
  SavedSample withStarUpdate(
    SavedSample item, {
    required bool isStarred,
    required int starCount,
  }) => item.copyWith(isStarred: isStarred, starCount: starCount);

  Future<void> saveSample(
    SavedSample sample, {
    required Uint8List wavBytes,
    required Uint8List pcmBytes,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setLoading();
    try {
      await supabase.storage
          .from('samples')
          .uploadBinary(
            sample.filePath,
            wavBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      await supabase.storage
          .from('samples')
          .uploadBinary(
            sample.pcmFilePath,
            pcmBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final write = SampleWrite(
        userId: sample.userId,
        name: sample.name,
        filePath: sample.filePath,
        pcmFilePath: sample.pcmFilePath,
        description: sample.description,
        isPublic: sample.isPublic,
        slicePoints: sample.slicePoints,
        baseNote: sample.baseNote,
        fineTune: sample.fineTune,
        pitched: sample.pitched,
        sliceNotes: sample.sliceNotes,
        loopMode: sample.loopMode,
        contentHash: computeContentHash(pcmBytes),
      );
      await supabase.from('samples').insert(write.toJson());

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updateSample(SavedSample sample) async {
    setLoading();
    try {
      final write = SampleWrite(
        userId: sample.userId,
        name: sample.name,
        filePath: sample.filePath,
        pcmFilePath: sample.pcmFilePath,
        description: sample.description,
        isPublic: sample.isPublic,
        slicePoints: sample.slicePoints,
        baseNote: sample.baseNote,
        fineTune: sample.fineTune,
        pitched: sample.pitched,
        sliceNotes: sample.sliceNotes,
        loopMode: sample.loopMode,
      );
      await supabase.from('samples').update(write.toJson()).eq('id', sample.id);
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<Uint8List> downloadWav(String filePath) async {
    return supabase.storage.from('samples').download(filePath);
  }

  @override
  Future<void> deleteItem(String id) async {
    setLoading();
    try {
      final sample = state.userItems.where((s) => s.id == id).firstOrNull;
      if (sample != null) {
        await supabase.storage.from('samples').remove([
          sample.filePath,
          if (sample.pcmFilePath.isNotEmpty) sample.pcmFilePath,
        ]);
      }
      await super.deleteItem(id);
    } on Exception catch (error) {
      setError(error);
    }
  }
}
