import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/models/firmwares_state.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final firmwaresProvider = NotifierProvider<FirmwaresNotifier, FirmwaresState>(
  FirmwaresNotifier.new,
);

class FirmwaresNotifier extends Notifier<FirmwaresState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  FirmwaresState build() {
    Future.microtask(fetchFirmwares);
    return const FirmwaresState();
  }

  Future<void> fetchFirmwares() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('firmwares')
          .select('*, profiles(username)')
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);
      final firmwares = (response as List)
          .map(
            (row) => SavedFirmware.fromJson(row as Map<String, dynamic>),
          )
          .toList();
      state = state.copyWith(firmwares: firmwares, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> uploadFirmware({
    required String name,
    required String version,
    required String description,
    required bool isBeta,
    required Uint8List fileBytes,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    final uuid = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final storagePath = '$userId/$uuid.uf2';
    await _supabase.storage
        .from('firmwares')
        .uploadBinary(storagePath, fileBytes);

    await _supabase.from('firmwares').insert({
      'user_id': userId,
      'name': name,
      'version': version,
      'description': description,
      'is_beta': isBeta,
      'file_path': storagePath,
    });

    await fetchFirmwares();
  }

  Future<void> updateFirmware({
    required String id,
    required String name,
    required String version,
    required String description,
    required bool isBeta,
    required bool isPinned,
  }) async {
    try {
      await _supabase
          .from('firmwares')
          .update({
            'name': name,
            'version': version,
            'description': description,
            'is_beta': isBeta,
            'is_pinned': isPinned,
          })
          .eq('id', id);
      await fetchFirmwares();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> togglePinned(SavedFirmware firmware) async {
    try {
      await _supabase
          .from('firmwares')
          .update({'is_pinned': !firmware.isPinned})
          .eq('id', firmware.id);
      await fetchFirmwares();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> deleteFirmware(String id, String filePath) async {
    try {
      await _supabase.storage.from('firmwares').remove([filePath]);
      await _supabase.from('firmwares').delete().eq('id', id);
      await fetchFirmwares();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }
}
