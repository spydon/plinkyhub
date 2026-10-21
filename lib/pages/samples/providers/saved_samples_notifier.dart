// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedSamplesProvider =
    NotifierProvider<SavedSamplesNotifier, SavedItemsState<SavedSample>>(
      SavedSamplesNotifier.new,
    );

class SavedSamplesNotifier
    extends
        SavedItemsNotifier<
          SavedSample,
          SamplesRow,
          SampleStarsRow,
          SampleStarsInsert
        > {
  @override
  ItemTable<SamplesRow> get itemTable => samplesTable;

  @override
  StarTable<SampleStarsRow, SampleStarsInsert> get starTable =>
      sampleStarsTable;

  @override
  List<PostgrestSelectable<SamplesRow>> get selection => SavedSample.selection;

  @override
  String get itemLabel => 'sample';

  @override
  SavedSample fromRow(PostgrestPartialRow<SamplesRow> row) =>
      SavedSample.fromRow(row);

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

      await supabase
          .table(Samples.table)
          .insert(
            SamplesInsert(
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
            ),
          );

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updateSample(SavedSample sample) async {
    setLoading();
    try {
      await supabase
          .table(Samples.table)
          .update(
            SamplesUpdate(
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
            ),
          )
          .where(Samples.id.eq(sample.id));
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
