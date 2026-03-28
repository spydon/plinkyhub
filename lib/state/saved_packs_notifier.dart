import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/pack_slot_write.dart';
import 'package:plinkyhub/models/pack_write.dart';
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

  Future<Set<String>> _fetchStarredPackIds() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return {};
    }
    final stars = await _supabase
        .from('pack_stars')
        .select('pack_id')
        .eq('user_id', userId);
    return {
      for (final row in stars as List)
        (row as Map<String, dynamic>)['pack_id'] as String,
    };
  }

  List<SavedPack> _applyStarred(
    List<dynamic> response,
    Set<String> starredIds,
  ) {
    return response.map((row) {
      final map = row as Map<String, dynamic>;
      return SavedPack.fromJson({
        ...map,
        'is_starred': starredIds.contains(map['id']),
      });
    }).toList();
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
          .select('*, pack_slots(*), profiles(username), pack_stars(count)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final starredIds = await _fetchStarredPackIds();
      final packs = _applyStarred(response as List, starredIds);

      state = state.copyWith(userPacks: packs, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> fetchPublicPacks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('packs')
          .select('*, pack_slots(*), profiles(username), pack_stars(count)')
          .eq('is_public', true);

      final starredIds = await _fetchStarredPackIds();
      final packs = _applyStarred(response as List, starredIds);
      state = state.copyWith(publicPacks: packs, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> savePack(
    String name, {
    required List<({int slotNumber, String? presetId, String? sampleId})> slots,
    String description = '',
    bool isPublic = false,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final write = PackWrite(
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      final packResponse = await _supabase
          .from('packs')
          .insert(write.toJson())
          .select('id')
          .single();

      final packId = packResponse['id'] as String;
      await _insertSlots(packId, slots);

      await fetchUserPacks();
    } on Exception catch (error) {
      debugPrint('$error');
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
      final updates = <String, dynamic>{};
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
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _insertSlots(
    String packId,
    List<({int slotNumber, String? presetId, String? sampleId})> slots,
  ) async {
    final slotRows = slots
        .where((slot) => slot.presetId != null || slot.sampleId != null)
        .map(
          (slot) => PackSlotWrite(
            packId: packId,
            slotNumber: slot.slotNumber,
            presetId: slot.presetId,
            sampleId: slot.sampleId,
          ).toJson(),
        )
        .toList();

    if (slotRows.isNotEmpty) {
      await _supabase.from('pack_slots').insert(slotRows);
    }
  }

  Future<void> updatePackWithSlots(
    String id, {
    required String name,
    required String description,
    required bool isPublic,
    required List<({int slotNumber, String? presetId, String? sampleId})> slots,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userId = ref.read(authenticationProvider).user?.id;
      if (userId == null) {
        return;
      }

      final write = PackWrite(
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      await _supabase.from('packs').update(write.toJson()).eq('id', id);
      await _supabase.from('pack_slots').delete().eq('pack_id', id);
      await _insertSlots(id, slots);

      await fetchUserPacks();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void startEditing(SavedPack pack) {
    state = state.copyWith(editingPack: pack);
  }

  void stopEditing() {
    state = state.copyWith(editingPack: null);
  }

  Future<void> deletePack(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.from('packs').delete().eq('id', id);
      await fetchUserPacks();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleStar(SavedPack pack) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      if (pack.isStarred) {
        await _supabase
            .from('pack_stars')
            .delete()
            .eq('pack_id', pack.id)
            .eq('user_id', userId);
      } else {
        await _supabase.from('pack_stars').insert({
          'pack_id': pack.id,
          'user_id': userId,
        });
      }

      final delta = pack.isStarred ? -1 : 1;
      state = state.copyWith(
        userPacks: _updateStarInList(
          state.userPacks, pack.id, !pack.isStarred, delta,
        ),
        publicPacks: _updateStarInList(
          state.publicPacks, pack.id, !pack.isStarred, delta,
        ),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  List<SavedPack> _updateStarInList(
    List<SavedPack> packs,
    String packId,
    bool isStarred,
    int delta,
  ) {
    return packs.map((p) {
      if (p.id == packId) {
        return p.copyWith(
          isStarred: isStarred,
          starCount: p.starCount + delta,
        );
      }
      return p;
    }).toList();
  }
}
