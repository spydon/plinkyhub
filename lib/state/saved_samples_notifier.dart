import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_samples_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedSamplesProvider =
    NotifierProvider<SavedSamplesNotifier, SavedSamplesState>(
      SavedSamplesNotifier.new,
    );

class SavedSamplesNotifier extends Notifier<SavedSamplesState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  SavedSamplesState build() {
    final authenticationState = ref.watch(authenticationProvider);
    if (authenticationState.user != null) {
      Future.microtask(fetchUserSamples);
    }
    return const SavedSamplesState();
  }

  Future<void> fetchUserSamples() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('samples')
          .select('*, profiles(username)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final samples = (response as List).map((row) {
        return SavedSample.fromJson(row as Map<String, dynamic>);
      }).toList();

      state = state.copyWith(userSamples: samples, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> fetchPublicSamples() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userId = ref.read(authenticationProvider).user?.id;
      var query = _supabase
          .from('samples')
          .select('*, profiles(username)')
          .eq('is_public', true);

      if (userId != null) {
        query = query.neq('user_id', userId);
      }

      final response = await query.order('updated_at', ascending: false);

      final samples = (response as List).map((row) {
        return SavedSample.fromJson(row as Map<String, dynamic>);
      }).toList();

      state = state.copyWith(publicSamples: samples, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> saveSample(
    SavedSample sample, {
    required Uint8List wavBytes,
    required Uint8List pcmBytes,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.storage
          .from('samples')
          .uploadBinary(sample.filePath, wavBytes, fileOptions: const FileOptions(upsert: true));
      await _supabase.storage
          .from('samples')
          .uploadBinary(sample.pcmFilePath, pcmBytes, fileOptions: const FileOptions(upsert: true));

      final json = sample.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('username');
      await _supabase.from('samples').insert(json);

      await fetchUserSamples();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateSample(SavedSample sample) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final json =
          sample
              .copyWith(
                updatedAt: DateTime.now(),
              )
              .toJson()
            ..remove('id')
            ..remove('created_at');
      await _supabase.from('samples').update(json).eq('id', sample.id);
      await fetchUserSamples();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<Uint8List> downloadWav(String filePath) async {
    return _supabase.storage.from('samples').download(filePath);
  }

  Future<void> deleteSample(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final sample = state.userSamples.where((s) => s.id == id).firstOrNull;
      if (sample != null) {
        await _supabase.storage.from('samples').remove([
          sample.filePath,
          if (sample.pcmFilePath.isNotEmpty) sample.pcmFilePath,
        ]);
      }
      await _supabase.from('samples').delete().eq('id', id);
      await fetchUserSamples();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
