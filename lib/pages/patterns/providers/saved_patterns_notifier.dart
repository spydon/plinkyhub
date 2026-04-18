import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/pages/patterns/models/pattern_write.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPatternsProvider =
    NotifierProvider<SavedPatternsNotifier, SavedItemsState<SavedPattern>>(
      SavedPatternsNotifier.new,
    );

class SavedPatternsNotifier extends SavedItemsNotifier<SavedPattern> {
  @override
  String get tableName => 'patterns';

  @override
  String get starTableName => 'pattern_stars';

  @override
  String get starIdColumn => 'pattern_id';

  @override
  String get selectQuery => '*, profiles(username), pattern_stars(count)';

  @override
  String get itemLabel => 'pattern';

  @override
  SavedPattern fromJson(Map<String, dynamic> json) =>
      SavedPattern.fromJson(json);

  @override
  SavedPattern withStarUpdate(
    SavedPattern item, {
    required bool isStarred,
    required int starCount,
  }) => item.copyWith(isStarred: isStarred, starCount: starCount);

  @override
  Future<void> deleteItem(String id) async {
    setLoading();
    try {
      final pattern = state.userItems.where((p) => p.id == id).firstOrNull;
      if (pattern != null) {
        await supabase.storage.from('patterns').remove([pattern.filePath]);
      }
      await super.deleteItem(id);
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<void> savePattern(
    SavedPattern pattern, {
    required Uint8List fileBytes,
  }) async {
    throwIfNameExists(pattern.name);

    setLoading();
    try {
      await supabase.storage
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
        contentHash: computeContentHash(fileBytes),
      );
      await supabase.from('patterns').insert(write.toJson());

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updatePattern(SavedPattern pattern) async {
    throwIfNameExists(pattern.name, excludeId: pattern.id);

    setLoading();
    try {
      final write = PatternWrite(
        userId: pattern.userId,
        name: pattern.name,
        filePath: pattern.filePath,
        description: pattern.description,
        isPublic: pattern.isPublic,
      );
      await supabase
          .from('patterns')
          .update(write.toJson())
          .eq('id', pattern.id);
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<Uint8List> downloadFile(String filePath) async {
    return supabase.storage.from('patterns').download(filePath);
  }
}
