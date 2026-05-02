import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base notifier for any saved-item type (presets, samples, patterns,
/// wavetables, packs).
///
/// Provides generic implementations of fetch (user / starred / public),
/// star toggling, name uniqueness checks, and simple delete.
/// Subclasses supply table names and model-specific operations.
abstract class SavedItemsNotifier<T extends Searchable>
    extends Notifier<SavedItemsState<T>> {
  SupabaseClient get supabase => Supabase.instance.client;

  // ---- Configuration (override in subclasses) ----

  /// Main database table (e.g. `'presets'`).
  String get tableName;

  /// Star join table (e.g. `'preset_stars'`).
  String get starTableName;

  /// Foreign-key column in the star table (e.g. `'preset_id'`).
  String get starIdColumn;

  /// Supabase select expression including relations
  /// (e.g. `'*, profiles(username), preset_stars(count)'`).
  String get selectQuery;

  /// Singular label used in error messages (e.g. `'preset'`).
  String get itemLabel;

  /// Deserialise a row from the database.
  T fromJson(Map<String, dynamic> json);

  /// Return a copy of [item] with updated star fields.
  T withStarUpdate(T item, {required bool isStarred, required int starCount});

  // ---- Lifecycle ----

  @override
  SavedItemsState<T> build() {
    final authenticationState = ref.watch(authenticationProvider);
    if (authenticationState.user != null) {
      Future.microtask(fetchUserItems);
    }
    return SavedItemsState<T>();
  }

  // ---- Star helpers ----

  Future<Set<String>> fetchStarredIds() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return {};
    }
    final stars = await supabase
        .from(starTableName)
        .select(starIdColumn)
        .eq('user_id', userId);
    return {
      for (final row in stars as List)
        (row as Map<String, dynamic>)[starIdColumn] as String,
    };
  }

  List<T> applyStarred(List<dynamic> response, Set<String> starredIds) {
    return response.map((row) {
      final map = row as Map<String, dynamic>;
      final item = fromJson(map);
      if (starredIds.contains(map['id'])) {
        return withStarUpdate(item, isStarred: true, starCount: item.starCount);
      }
      return item;
    }).toList();
  }

  // ---- Fetch ----

  Future<void> fetchUserItems() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final response = await supabase
          .from(tableName)
          .select(selectQuery)
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      final starredIds = await fetchStarredIds();
      final items = applyStarred(response as List, starredIds);

      state = state.copyWith(
        userItems: items,
        isLoading: false,
        hasLoadedUserItems: true,
      );
      await fetchStarredItems();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        hasLoadedUserItems: true,
        errorMessage: error.toString,
      );
    }
  }

  Future<void> fetchStarredItems() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    try {
      final starredIds = await fetchStarredIds();
      if (starredIds.isEmpty) {
        state = state.copyWith(starredItems: []);
        return;
      }

      final response = await supabase
          .from(tableName)
          .select(selectQuery)
          .inFilter('id', starredIds.toList())
          .neq('user_id', userId);

      final items = (response as List).map((row) {
        final item = fromJson(row as Map<String, dynamic>);
        return withStarUpdate(
          item,
          isStarred: true,
          starCount: item.starCount,
        );
      }).toList();
      state = state.copyWith(starredItems: items);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(errorMessage: error.toString);
    }
  }

  Future<void> fetchPublicItems() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final response = await supabase
          .from(tableName)
          .select(selectQuery)
          .eq('is_public', true);

      final starredIds = await fetchStarredIds();
      final items = applyStarred(response as List, starredIds);
      state = state.copyWith(
        publicItems: items,
        isLoading: false,
        hasLoadedPublicItems: true,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        hasLoadedPublicItems: true,
        errorMessage: error.toString,
      );
    }
  }

  // ---- Delete ----

  /// Deletes an item by ID. Subclasses that need to remove storage files
  /// should override this and call `super.deleteItem(id)` after cleanup.
  Future<void> deleteItem(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      await supabase.from(tableName).delete().eq('id', id);
      await fetchUserItems();
      await fetchPublicItems();
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString,
      );
    }
  }

  // ---- Star toggling ----

  Future<void> toggleStar(T item) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    final savedState = state;
    final delta = item.isStarred ? -1 : 1;
    final newIsStarred = !item.isStarred;

    // Optimistic update
    state = state.copyWith(
      userItems: _updateStarInList(
        state.userItems,
        item.id,
        newIsStarred,
        delta,
      ),
      starredItems: newIsStarred
          ? [
              ...state.starredItems,
              if (item.userId != userId)
                withStarUpdate(
                  item,
                  isStarred: true,
                  starCount: item.starCount + delta,
                ),
            ]
          : state.starredItems.where((i) => i.id != item.id).toList(),
      publicItems: _updateStarInList(
        state.publicItems,
        item.id,
        newIsStarred,
        delta,
      ),
    );

    try {
      if (item.isStarred) {
        await supabase
            .from(starTableName)
            .delete()
            .eq(starIdColumn, item.id)
            .eq('user_id', userId);
      } else {
        await supabase.from(starTableName).insert({
          starIdColumn: item.id,
          'user_id': userId,
        });
      }
    } on Exception catch (error) {
      debugPrint('$error');
      state = savedState.copyWith(errorMessage: error.toString);
    }
  }

  List<T> _updateStarInList(
    List<T> items,
    String itemId,
    bool isStarred,
    int delta,
  ) {
    return items.map((item) {
      if (item.id == itemId) {
        return withStarUpdate(
          item,
          isStarred: isStarred,
          starCount: item.starCount + delta,
        );
      }
      return item;
    }).toList();
  }

  // ---- Helpers for subclasses ----

  /// Convenience for setting loading + clearing error before an operation.
  void setLoading() {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
  }

  /// Convenience for setting error state after a failed operation.
  void setError(Object error) {
    debugPrint('$error');
    state = state.copyWith(
      isLoading: false,
      errorMessage: () => error.toString(),
    );
  }

  /// Re-fetches both user and public item lists.
  Future<void> refreshAll() async {
    await fetchUserItems();
    await fetchPublicItems();
  }
}

/// Returns whether the signed-in user has starred the given item.
///
/// [starTableName] is the star join table (e.g. `'preset_stars'`).
/// [idColumn] is the item FK column (e.g. `'preset_id'`).
Future<bool> fetchIsStarred({
  required String starTableName,
  required String idColumn,
  required String itemId,
  required String? userId,
}) async {
  if (userId == null) {
    return false;
  }
  final result = await Supabase.instance.client
      .from(starTableName)
      .select(idColumn)
      .eq(idColumn, itemId)
      .eq('user_id', userId)
      .maybeSingle();
  return result != null;
}
