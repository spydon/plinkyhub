// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/providers/saved_items_notifier.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final savedPatternsProvider =
    NotifierProvider<SavedPatternsNotifier, SavedItemsState<SavedPattern>>(
      SavedPatternsNotifier.new,
    );

class SavedPatternsNotifier
    extends
        SavedItemsNotifier<
          SavedPattern,
          PatternsRow,
          PatternStarsRow,
          PatternStarsInsert
        > {
  @override
  ItemTable<PatternsRow> get itemTable => patternsTable;

  @override
  StarTable<PatternStarsRow, PatternStarsInsert> get starTable =>
      patternStarsTable;

  @override
  List<PostgrestSelectable<PatternsRow>> get selection =>
      SavedPattern.selection;

  @override
  String get itemLabel => 'pattern';

  @override
  SavedPattern fromRow(PostgrestPartialRow<PatternsRow> row) =>
      SavedPattern.fromRow(row);

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
    setLoading();
    try {
      await supabase.storage
          .from('patterns')
          .uploadBinary(
            pattern.filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      await supabase
          .table(Patterns.table)
          .insert(
            PatternsInsert(
              userId: pattern.userId,
              name: pattern.name,
              filePath: pattern.filePath,
              description: pattern.description,
              isPublic: pattern.isPublic,
              contentHash: computeContentHash(fileBytes),
            ),
          );

      await refreshAll();
    } on Exception catch (error) {
      setError(error);
      rethrow;
    }
  }

  Future<void> updatePattern(SavedPattern pattern) async {
    setLoading();
    try {
      await supabase
          .table(Patterns.table)
          .update(
            PatternsUpdate(
              userId: pattern.userId,
              name: pattern.name,
              filePath: pattern.filePath,
              description: pattern.description,
              isPublic: pattern.isPublic,
            ),
          )
          .where(Patterns.id.eq(pattern.id));
      await refreshAll();
    } on Exception catch (error) {
      setError(error);
    }
  }

  Future<Uint8List> downloadFile(String filePath) async {
    return supabase.storage.from('patterns').download(filePath);
  }
}
