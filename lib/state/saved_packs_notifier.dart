import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPacksProvider =
    NotifierProvider<SavedPacksNotifier, SavedPacksState>(
  SavedPacksNotifier.new,
);

class SavedPacksNotifier extends Notifier<SavedPacksState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  SavedPacksState build() {
    final authenticationState = ref.watch(authenticationProvider);
    if (authenticationState.user != null) {
      Future.microtask(fetchUserPacks);
    }
    return const SavedPacksState();
  }

  Future<void> fetchUserPacks() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('packs')
          .select('*, pack_slots(*)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final packs = (response as List).map((row) {
        return SavedPack.fromJson(row as Map<String, dynamic>);
      }).toList();

      state = state.copyWith(userPacks: packs, isLoading: false);
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> fetchPublicPacks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userId = ref.read(authenticationProvider).user?.id;
      var query = _supabase
          .from('packs')
          .select('*, pack_slots(*)')
          .eq('is_public', true);

      if (userId != null) {
        query = query.neq('user_id', userId);
      }

      final response = await query.order('updated_at', ascending: false);

      final packs = (response as List).map((row) {
        return SavedPack.fromJson(row as Map<String, dynamic>);
      }).toList();

      state = state.copyWith(publicPacks: packs, isLoading: false);
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> savePack(
    String name, {
    required List<({int slotNumber, String? patchId, String? sampleId})> slots,
    String description = '',
    bool isPublic = false,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final packResponse = await _supabase
          .from('packs')
          .insert({
            'user_id': userId,
            'name': name,
            'description': description,
            'is_public': isPublic,
          })
          .select('id')
          .single();

      final packId = packResponse['id'] as String;

      final slotRows = slots
          .where((slot) => slot.patchId != null || slot.sampleId != null)
          .map((slot) => {
                'pack_id': packId,
                'slot_number': slot.slotNumber,
                'patch_id': slot.patchId,
                'sample_id': slot.sampleId,
              })
          .toList();

      if (slotRows.isNotEmpty) {
        await _supabase.from('pack_slots').insert(slotRows);
      }

      await fetchUserPacks();
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> updatePack(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) {
        updates['name'] = name;
      }
      if (description != null) {
        updates['description'] = description;
      }
      if (isPublic != null) {
        updates['is_public'] = isPublic;
      }

      await _supabase.from('packs').update(updates).eq('id', id);
      await fetchUserPacks();
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> deletePack(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.from('packs').delete().eq('id', id);
      await fetchUserPacks();
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
