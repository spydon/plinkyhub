import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/pages/presets/models/preset_write.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/utils/content_hash.dart';

final savedPresetsProvider =
    NotifierProvider<SavedPresetsNotifier, SavedItemsState<SavedPreset>>(
      SavedPresetsNotifier.new,
    );

class SavedPresetsNotifier extends SavedItemsNotifier<SavedPreset> {
  @override
  String get tableName => 'presets';

  @override
  String get starTableName => 'preset_stars';

  @override
  String get starIdColumn => 'preset_id';

  @override
  String get selectQuery =>
      '*, profiles(username), preset_stars(count), '
      'samples(name, profiles(username))';

  @override
  String get itemLabel => 'preset';

  @override
  SavedPreset fromJson(Map<String, dynamic> json) => SavedPreset.fromJson(json);

  @override
  SavedPreset withStarUpdate(
    SavedPreset item, {
    required bool isStarred,
    required int starCount,
  }) => item.copyWith(isStarred: isStarred, starCount: starCount);

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

    throwIfNameExists(preset.name);

    setLoading();
    try {
      final presetBytes = Uint8List.view(preset.buffer);
      final write = PresetWrite(
        userId: userId,
        name: preset.name,
        category: preset.category.name,
        presetData: base64Encode(presetBytes),
        description: description,
        isPublic: isPublic,
        youtubeUrl: youtubeUrl,
        sampleId: sampleId,
        contentHash: computePresetContentHash(presetBytes),
      );
      await supabase.from('presets').insert(write.toJson());
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

    throwIfNameExists(preset.name, excludeId: id);

    setLoading();
    try {
      final presetBytes = Uint8List.view(preset.buffer);
      final write = PresetWrite(
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
      final json = write.toJson();
      await supabase.from('presets').update(json).eq('id', id);
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
      final updates = <String, dynamic>{};
      if (description != null) {
        updates['description'] = description;
      }
      if (isPublic != null) {
        updates['is_public'] = isPublic;
      }
      if (youtubeUrl != null) {
        updates['youtube_url'] = youtubeUrl;
      }
      if (sampleId != null) {
        updates['sample_id'] = sampleId;
      } else if (clearSample) {
        updates['sample_id'] = null;
      }

      await supabase.from('presets').update(updates).eq('id', id);
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
