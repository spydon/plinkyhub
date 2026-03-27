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

  Future<Set<String>> _fetchStarredSampleIds() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return {};
    }
    final stars = await _supabase
        .from('sample_stars')
        .select('sample_id')
        .eq('user_id', userId);
    return {
      for (final row in stars as List)
        (row as Map<String, dynamic>)['sample_id'] as String,
    };
  }

  List<SavedSample> _applyStarred(
    List<dynamic> response,
    Set<String> starredIds,
  ) {
    return response.map((row) {
      final map = row as Map<String, dynamic>;
      return SavedSample.fromJson({
        ...map,
        'is_starred': starredIds.contains(map['id']),
      });
    }).toList();
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
          .select('*, profiles(username), sample_stars(count)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final starredIds = await _fetchStarredSampleIds();
      final samples = _applyStarred(response as List, starredIds);

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
      final response = await _supabase
          .from('samples')
          .select('*, profiles(username), sample_stars(count)')
          .eq('is_public', true);

      final starredIds = await _fetchStarredSampleIds();
      final samples = _applyStarred(response as List, starredIds);
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
          .uploadBinary(
        sample.filePath,
        wavBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      await _supabase.storage.from('samples').uploadBinary(
        sample.pcmFilePath,
        pcmBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final json = sample.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('username')
        ..remove('star_count')
        ..remove('is_starred');
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
            ..remove('created_at')
            ..remove('username')
            ..remove('star_count')
            ..remove('is_starred');
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

  Future<void> toggleStar(SavedSample sample) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      if (sample.isStarred) {
        await _supabase
            .from('sample_stars')
            .delete()
            .eq('sample_id', sample.id)
            .eq('user_id', userId);
      } else {
        await _supabase.from('sample_stars').insert({
          'sample_id': sample.id,
          'user_id': userId,
        });
      }

      final delta = sample.isStarred ? -1 : 1;
      state = state.copyWith(
        userSamples: _updateStarInList(
          state.userSamples, sample.id, !sample.isStarred, delta,
        ),
        publicSamples: _updateStarInList(
          state.publicSamples, sample.id, !sample.isStarred, delta,
        ),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  List<SavedSample> _updateStarInList(
    List<SavedSample> samples,
    String sampleId,
    bool isStarred,
    int delta,
  ) {
    return samples.map((s) {
      if (s.id == sampleId) {
        return s.copyWith(
          isStarred: isStarred,
          starCount: s.starCount + delta,
        );
      }
      return s;
    }).toList();
  }
}
