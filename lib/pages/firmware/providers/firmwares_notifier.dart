// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/models/firmwares_state.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
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
      final rows = await _supabase
          .table(Firmwares.table)
          .selectOnly(SavedFirmware.selection)
          .order(Firmwares.isPinned.desc())
          .order(Firmwares.createdAt.desc());
      final firmwares = rows.map(SavedFirmware.new).toList();
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

    await _supabase
        .table(Firmwares.table)
        .insert(
          FirmwaresInsert(
            userId: userId,
            name: name,
            version: version,
            description: description,
            isBeta: isBeta,
            filePath: storagePath,
          ),
        );

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
          .table(Firmwares.table)
          .update(
            FirmwaresUpdate(
              name: name,
              version: version,
              description: description,
              isBeta: isBeta,
              isPinned: isPinned,
            ),
          )
          .where(Firmwares.id.eq(id));
      await fetchFirmwares();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> togglePinned(SavedFirmware firmware) async {
    try {
      await _supabase
          .table(Firmwares.table)
          .update(FirmwaresUpdate(isPinned: !firmware.isPinned))
          .where(Firmwares.id.eq(firmware.id));
      await fetchFirmwares();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> deleteFirmware(String id, String filePath) async {
    try {
      await _supabase.storage.from('firmwares').remove([filePath]);
      await _supabase
          .table(Firmwares.table)
          .delete()
          .where(Firmwares.id.eq(id));
      await fetchFirmwares();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }
}
