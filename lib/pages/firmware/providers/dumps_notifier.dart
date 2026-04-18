import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/firmware_admins.dart';
import 'package:plinkyhub/pages/firmware/models/dumps_state.dart';
import 'package:plinkyhub/pages/firmware/models/saved_dump.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dumpsProvider = NotifierProvider<DumpsNotifier, DumpsState>(
  DumpsNotifier.new,
);

class DumpsNotifier extends Notifier<DumpsState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  DumpsState build() {
    final user = ref.watch(
      authenticationProvider.select((authState) => authState.user),
    );
    if (user != null) {
      Future.microtask(fetchDumps);
    }
    return const DumpsState();
  }

  Future<void> fetchDumps() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      state = state.copyWith(dumps: const []);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Firmware admins see dumps from every user so they can help
      // debug devices; RLS grants the extra SELECT access.
      final isAdmin = firmwareAdminIds.contains(userId);
      final query = _supabase.from('dumps').select('*, profiles(username)');
      final response = await (isAdmin ? query : query.eq('user_id', userId))
          .order('created_at', ascending: false);
      final dumps = (response as List)
          .map((row) => SavedDump.fromJson(row as Map<String, dynamic>))
          .toList();
      state = state.copyWith(dumps: dumps, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// Uploads a dump (internal and external flash bytes) to Supabase.
  /// Returns the created [SavedDump].
  Future<SavedDump?> uploadDump({
    required String title,
    required String description,
    Uint8List? internalFlashBytes,
    Uint8List? externalFlashBytes,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return null;
    }
    if (internalFlashBytes == null && externalFlashBytes == null) {
      return null;
    }

    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch.toRadixString(
      36,
    );
    final internalPath = internalFlashBytes != null
        ? '$userId/${uniqueSuffix}_int.bin'
        : null;
    final externalPath = externalFlashBytes != null
        ? '$userId/${uniqueSuffix}_ext.bin'
        : null;

    if (internalPath != null && internalFlashBytes != null) {
      await _supabase.storage
          .from('dumps')
          .uploadBinary(internalPath, internalFlashBytes);
    }
    if (externalPath != null && externalFlashBytes != null) {
      await _supabase.storage
          .from('dumps')
          .uploadBinary(externalPath, externalFlashBytes);
    }

    final inserted = await _supabase
        .from('dumps')
        .insert({
          'user_id': userId,
          'title': title,
          'description': description,
          'internal_flash_path': internalPath,
          'external_flash_path': externalPath,
          'internal_flash_size': internalFlashBytes?.length ?? 0,
          'external_flash_size': externalFlashBytes?.length ?? 0,
        })
        .select('*, profiles(username)')
        .single();

    final dump = SavedDump.fromJson(inserted);
    state = state.copyWith(dumps: [dump, ...state.dumps]);
    return dump;
  }

  Future<void> deleteDump(SavedDump dump) async {
    try {
      final paths = <String>[
        if (dump.internalFlashPath != null) dump.internalFlashPath!,
        if (dump.externalFlashPath != null) dump.externalFlashPath!,
      ];
      if (paths.isNotEmpty) {
        await _supabase.storage.from('dumps').remove(paths);
      }
      await _supabase.from('dumps').delete().eq('id', dump.id);
      state = state.copyWith(
        dumps: state.dumps.where((entry) => entry.id != dump.id).toList(),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<Uint8List> downloadFlash({required String filePath}) async {
    return _supabase.storage.from('dumps').download(filePath);
  }
}
