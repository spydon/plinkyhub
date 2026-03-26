import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/patch.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/saved_patches_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPatchesProvider =
    NotifierProvider<SavedPatchesNotifier, SavedPatchesState>(
      SavedPatchesNotifier.new,
    );

class SavedPatchesNotifier extends Notifier<SavedPatchesState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  SavedPatchesState build() {
    final authenticationState = ref.watch(authenticationProvider);
    if (authenticationState.user != null) {
      Future.microtask(fetchUserPatches);
    }
    return const SavedPatchesState();
  }

  Future<List<SavedPatch>> _parsePatchRows(List<dynamic> response) async {
    final userId = ref.read(authenticationProvider).user?.id;
    final starredPatchIds = <String>{};

    if (userId != null) {
      final stars = await _supabase
          .from('patch_stars')
          .select('patch_id')
          .eq('user_id', userId);
      starredPatchIds.addAll([
        for (final row in stars as List)
          (row as Map<String, dynamic>)['patch_id'] as String,
      ]);
    }

    return response.map((row) {
      final map = row as Map<String, dynamic>;
      return SavedPatch.fromJson({
        ...map,
        'is_starred': starredPatchIds.contains(map['id']),
      });
    }).toList();
  }

  Future<void> fetchUserPatches() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('patches')
          .select('*, profiles(username), patch_stars(count)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final patches = await _parsePatchRows(response as List);
      state = state.copyWith(userPatches: patches, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> fetchPublicPatches() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userId = ref.read(authenticationProvider).user?.id;
      var query = _supabase
          .from('patches')
          .select('*, profiles(username), patch_stars(count)')
          .eq('is_public', true);

      // Exclude own patches from community list.
      if (userId != null) {
        query = query.neq('user_id', userId);
      }

      final response = await query.order('updated_at', ascending: false);

      final patches = await _parsePatchRows(response as List);
      state = state.copyWith(publicPatches: patches, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> savePatch(
    Patch patch, {
    String description = '',
    bool isPublic = false,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final patchData = base64Encode(Uint8List.view(patch.buffer));
      await _supabase.from('patches').insert({
        'user_id': userId,
        'name': patch.name,
        'category': patch.category.name,
        'patch_data': patchData,
        'description': description,
        'is_public': isPublic,
      });

      await fetchUserPatches();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updatePatch(
    String id, {
    String? description,
    bool? isPublic,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (description != null) {
        updates['description'] = description;
      }
      if (isPublic != null) {
        updates['is_public'] = isPublic;
      }

      await _supabase.from('patches').update(updates).eq('id', id);
      await fetchUserPatches();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> deletePatch(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.from('patches').delete().eq('id', id);
      await fetchUserPatches();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleStar(SavedPatch patch) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      if (patch.isStarred) {
        await _supabase
            .from('patch_stars')
            .delete()
            .eq('patch_id', patch.id)
            .eq('user_id', userId);
      } else {
        await _supabase.from('patch_stars').insert({
          'patch_id': patch.id,
          'user_id': userId,
        });
      }

      // Optimistically update both lists.
      final delta = patch.isStarred ? -1 : 1;
      state = state.copyWith(
        userPatches: _updateStarInList(
          state.userPatches,
          patch.id,
          !patch.isStarred,
          delta,
        ),
        publicPatches: _updateStarInList(
          state.publicPatches,
          patch.id,
          !patch.isStarred,
          delta,
        ),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  List<SavedPatch> _updateStarInList(
    List<SavedPatch> patches,
    String patchId,
    bool isStarred,
    int delta,
  ) {
    return patches.map((patch) {
      if (patch.id == patchId) {
        return patch.copyWith(
          isStarred: isStarred,
          starCount: patch.starCount + delta,
        );
      }
      return patch;
    }).toList();
  }

  void loadPatchIntoEditor(SavedPatch savedPatch) {
    final bytes = base64Decode(savedPatch.patchData);
    ref
        .read(plinkyProvider.notifier)
        .loadPatchFromBytes(Uint8List.fromList(bytes));
  }
}
