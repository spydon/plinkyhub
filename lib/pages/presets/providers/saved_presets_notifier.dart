// ignore_for_file: experimental_member_use

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPresetsProvider =
    NotifierProvider<SavedPresetsNotifier, SavedItemsState<SavedPreset>>(
      SavedPresetsNotifier.new,
    );

class SavedPresetsNotifier
    extends
        SavedItemsNotifier<
          SavedPreset,
          PresetsRow,
          PresetStarsRow,
          PresetStarsInsert
        > {
  @override
  ItemTable<PresetsRow> get itemTable => presetsTable;

  @override
  StarTable<PresetStarsRow, PresetStarsInsert> get starTable =>
      presetStarsTable;

  @override
  List<PostgrestSelectable<PresetsRow>> get selection => SavedPreset.selection;

  @override
  String get itemLabel => 'preset';

  @override
  SavedPreset fromRow(PostgrestPartialRow<PresetsRow> row) => SavedPreset(row);

  @override
  SavedPreset withStarUpdate(
    SavedPreset item, {
    required bool isStarred,
    required int starCount,
  }) => item.withStar(isStarred: isStarred, starCount: starCount);

  Future<void> savePreset(
    Preset preset, {
    String description = '',
    bool isPublic = false,
    String youtubeUrl = '',
    String? sampleId,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setLoading();
    try {
      final presetBytes = Uint8List.view(preset.buffer);
      await supabase
          .table(Presets.table)
          .insert(
            PresetsInsert(
              userId: userId,
              name: preset.name,
              category: preset.category.name,
              presetData: base64Encode(presetBytes),
              description: description,
              isPublic: isPublic,
              youtubeUrl: youtubeUrl,
              sampleId: sampleId,
              contentHash: computePresetContentHash(presetBytes),
            ),
          );
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> overwritePreset(
    String id,
    Preset preset, {
    String? description,
    bool? isPublic,
    String? youtubeUrl,
    String? sampleId,
  }) async {
    final existing = state.userItems.where((p) => p.id == id).firstOrNull;
    if (existing == null) {
      return;
    }

    setLoading();
    try {
      final presetBytes = Uint8List.view(preset.buffer);
      final update = PresetsUpdate(
        userId: existing.userId,
        name: preset.name,
        category: preset.category.name,
        presetData: base64Encode(presetBytes),
        description: description ?? existing.description,
        isPublic: isPublic ?? existing.isPublic,
        youtubeUrl: youtubeUrl ?? existing.youtubeUrl,
        sampleId: sampleId,
        contentHash: computePresetContentHash(presetBytes),
      );
      await supabase
          .table(Presets.table)
          .update(sampleId == null ? update.setSampleIdToNull() : update)
          .where(Presets.id.eq(id));
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> updatePreset(
    String id, {
    String? description,
    bool? isPublic,
    String? youtubeUrl,
    String? sampleId,
    bool clearSample = false,
  }) async {
    setLoading();
    try {
      final update = PresetsUpdate(
        description: description,
        isPublic: isPublic,
        youtubeUrl: youtubeUrl,
        sampleId: sampleId,
      );
      await supabase
          .table(Presets.table)
          .update(
            sampleId == null && clearSample
                ? update.setSampleIdToNull()
                : update,
          )
          .where(Presets.id.eq(id));
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  void loadPresetIntoEditor(SavedPreset savedPreset) {
    final bytes = base64Decode(savedPreset.presetData);
    final userId = ref.read(authenticationProvider).user?.id;
    // Only allow overwriting if the user owns the preset.
    final sourceId = savedPreset.userId == userId ? savedPreset.id : null;
    ref
        .read(plinkyProvider.notifier)
        .loadPresetFromBytes(Uint8List.fromList(bytes), sourceId: sourceId);
  }
}
