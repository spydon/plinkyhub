import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/preset_write.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/saved_presets_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPresetsProvider =
    NotifierProvider<SavedPresetsNotifier, SavedPresetsState>(
      SavedPresetsNotifier.new,
    );

class SavedPresetsNotifier extends Notifier<SavedPresetsState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  SavedPresetsState build() {
    final authenticationState = ref.watch(authenticationProvider);
    if (authenticationState.user != null) {
      Future.microtask(fetchUserPresets);
    }
    return const SavedPresetsState();
  }

  Future<List<SavedPreset>> _parsePresetRows(List<dynamic> response) async {
    final userId = ref.read(authenticationProvider).user?.id;
    final starredPresetIds = <String>{};

    if (userId != null) {
      final stars = await _supabase
          .from('preset_stars')
          .select('preset_id')
          .eq('user_id', userId);
      starredPresetIds.addAll([
        for (final row in stars as List)
          (row as Map<String, dynamic>)['preset_id'] as String,
      ]);
    }

    return response.map((row) {
      final map = row as Map<String, dynamic>;
      return SavedPreset.fromJson({
        ...map,
        'is_starred': starredPresetIds.contains(map['id']),
      });
    }).toList();
  }

  Future<void> fetchUserPresets() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('presets')
          .select('*, profiles(username), preset_stars(count)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final presets = await _parsePresetRows(response as List);
      state = state.copyWith(userPresets: presets, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> fetchPublicPresets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('presets')
          .select('*, profiles(username), preset_stars(count)')
          .eq('is_public', true);

      final presets = await _parsePresetRows(response as List);
      state = state.copyWith(publicPresets: presets, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> savePreset(
    Preset preset, {
    String description = '',
    bool isPublic = false,
    String? sampleId,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final write = PresetWrite(
        userId: userId,
        name: preset.name,
        category: preset.category.name,
        presetData: base64Encode(Uint8List.view(preset.buffer)),
        description: description,
        isPublic: isPublic,
        sampleId: sampleId,
      );
      await _supabase.from('presets').insert(write.toJson());
      await fetchUserPresets();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> overwritePreset(
    String id,
    Preset preset, {
    String? description,
    String? sampleId,
  }) async {
    final existing = state.userPresets
        .where((p) => p.id == id)
        .firstOrNull;
    if (existing == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final write = PresetWrite(
        userId: existing.userId,
        name: preset.name,
        category: preset.category.name,
        presetData: base64Encode(Uint8List.view(preset.buffer)),
        description: description ?? existing.description,
        isPublic: existing.isPublic,
        sampleId: sampleId,
      );
      final json = write.toJson();
      await _supabase.from('presets').update(json).eq('id', id);
      await fetchUserPresets();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updatePreset(
    String id, {
    String? description,
    bool? isPublic,
    String? sampleId,
    bool clearSample = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updates = <String, dynamic>{};
      if (description != null) {
        updates['description'] = description;
      }
      if (isPublic != null) {
        updates['is_public'] = isPublic;
      }
      if (sampleId != null) {
        updates['sample_id'] = sampleId;
      } else if (clearSample) {
        updates['sample_id'] = null;
      }

      await _supabase.from('presets').update(updates).eq('id', id);
      await fetchUserPresets();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> deletePreset(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.from('presets').delete().eq('id', id);
      await fetchUserPresets();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleStar(SavedPreset preset) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      if (preset.isStarred) {
        await _supabase
            .from('preset_stars')
            .delete()
            .eq('preset_id', preset.id)
            .eq('user_id', userId);
      } else {
        await _supabase.from('preset_stars').insert({
          'preset_id': preset.id,
          'user_id': userId,
        });
      }

      // Optimistically update both lists.
      final delta = preset.isStarred ? -1 : 1;
      state = state.copyWith(
        userPresets: _updateStarInList(
          state.userPresets,
          preset.id,
          !preset.isStarred,
          delta,
        ),
        publicPresets: _updateStarInList(
          state.publicPresets,
          preset.id,
          !preset.isStarred,
          delta,
        ),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  List<SavedPreset> _updateStarInList(
    List<SavedPreset> presets,
    String presetId,
    bool isStarred,
    int delta,
  ) {
    return presets.map((preset) {
      if (preset.id == presetId) {
        return preset.copyWith(
          isStarred: isStarred,
          starCount: preset.starCount + delta,
        );
      }
      return preset;
    }).toList();
  }

  void loadPresetIntoEditor(SavedPreset savedPreset) {
    final bytes = base64Decode(savedPreset.presetData);
    final userId = ref.read(authenticationProvider).user?.id;
    // Only allow overwriting if the user owns the preset.
    final sourceId =
        savedPreset.userId == userId ? savedPreset.id : null;
    ref
        .read(plinkyProvider.notifier)
        .loadPresetFromBytes(Uint8List.fromList(bytes), sourceId: sourceId);
  }
}
