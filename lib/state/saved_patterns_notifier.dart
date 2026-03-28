import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/pattern_write.dart';
import 'package:plinkyhub/models/saved_pattern.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_patterns_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPatternsProvider =
    NotifierProvider<SavedPatternsNotifier, SavedPatternsState>(
      SavedPatternsNotifier.new,
    );

class SavedPatternsNotifier extends Notifier<SavedPatternsState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  SavedPatternsState build() {
    final authenticationState = ref.watch(authenticationProvider);
    if (authenticationState.user != null) {
      Future.microtask(fetchUserPatterns);
    }
    return const SavedPatternsState();
  }

  Future<Set<String>> _fetchStarredPatternIds() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return {};
    }
    final stars = await _supabase
        .from('pattern_stars')
        .select('pattern_id')
        .eq('user_id', userId);
    return {
      for (final row in stars as List)
        (row as Map<String, dynamic>)['pattern_id'] as String,
    };
  }

  List<SavedPattern> _applyStarred(
    List<dynamic> response,
    Set<String> starredIds,
  ) {
    return response.map((row) {
      final map = row as Map<String, dynamic>;
      return SavedPattern.fromJson(map).copyWith(
        isStarred: starredIds.contains(map['id']),
      );
    }).toList();
  }

  Future<void> fetchUserPatterns() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('patterns')
          .select('*, profiles(username), pattern_stars(count)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final starredIds = await _fetchStarredPatternIds();
      final patterns = _applyStarred(response as List, starredIds);

      state = state.copyWith(userPatterns: patterns, isLoading: false);
      await fetchStarredPatterns();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> fetchStarredPatterns() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      final starredIds = await _fetchStarredPatternIds();
      if (starredIds.isEmpty) {
        state = state.copyWith(starredPatterns: []);
        return;
      }

      final response = await _supabase
          .from('patterns')
          .select('*, profiles(username), pattern_stars(count)')
          .inFilter('id', starredIds.toList())
          .neq('user_id', userId);

      final patterns = _applyStarred(response as List, starredIds);
      state = state.copyWith(starredPatterns: patterns);
    } on Exception catch (error) {
      debugPrint('$error');
    }
  }

  Future<void> fetchPublicPatterns() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase
          .from('patterns')
          .select('*, profiles(username), pattern_stars(count)')
          .eq('is_public', true);

      final starredIds = await _fetchStarredPatternIds();
      final patterns = _applyStarred(response as List, starredIds);
      state = state.copyWith(publicPatterns: patterns, isLoading: false);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> savePattern(
    SavedPattern pattern, {
    required Uint8List fileBytes,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.storage
          .from('patterns')
          .uploadBinary(
            pattern.filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final write = PatternWrite(
        userId: pattern.userId,
        name: pattern.name,
        filePath: pattern.filePath,
        description: pattern.description,
        isPublic: pattern.isPublic,
      );
      await _supabase.from('patterns').insert(write.toJson());

      await fetchUserPatterns();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> updatePattern(SavedPattern pattern) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final write = PatternWrite(
        userId: pattern.userId,
        name: pattern.name,
        filePath: pattern.filePath,
        description: pattern.description,
        isPublic: pattern.isPublic,
      );
      await _supabase
          .from('patterns')
          .update(write.toJson())
          .eq('id', pattern.id);
      await fetchUserPatterns();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<Uint8List> downloadFile(String filePath) async {
    return _supabase.storage.from('patterns').download(filePath);
  }

  Future<void> deletePattern(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pattern = state.userPatterns.where((p) => p.id == id).firstOrNull;
      if (pattern != null) {
        await _supabase.storage.from('patterns').remove([
          pattern.filePath,
        ]);
      }
      await _supabase.from('patterns').delete().eq('id', id);
      await fetchUserPatterns();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleStar(SavedPattern pattern) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      if (pattern.isStarred) {
        await _supabase
            .from('pattern_stars')
            .delete()
            .eq('pattern_id', pattern.id)
            .eq('user_id', userId);
      } else {
        await _supabase.from('pattern_stars').insert({
          'pattern_id': pattern.id,
          'user_id': userId,
        });
      }

      final delta = pattern.isStarred ? -1 : 1;
      final newIsStarred = !pattern.isStarred;
      final updatedStarred = newIsStarred
          ? [
              ...state.starredPatterns,
              if (pattern.userId != userId)
                pattern.copyWith(
                  isStarred: true,
                  starCount: pattern.starCount + delta,
                ),
            ]
          : state.starredPatterns.where((p) => p.id != pattern.id).toList();
      state = state.copyWith(
        userPatterns: _updateStarInList(
          state.userPatterns,
          pattern.id,
          newIsStarred,
          delta,
        ),
        starredPatterns: updatedStarred,
        publicPatterns: _updateStarInList(
          state.publicPatterns,
          pattern.id,
          newIsStarred,
          delta,
        ),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  List<SavedPattern> _updateStarInList(
    List<SavedPattern> patterns,
    String patternId,
    bool isStarred,
    int delta,
  ) {
    return patterns.map((p) {
      if (p.id == patternId) {
        return p.copyWith(
          isStarred: isStarred,
          starCount: p.starCount + delta,
        );
      }
      return p;
    }).toList();
  }
}
