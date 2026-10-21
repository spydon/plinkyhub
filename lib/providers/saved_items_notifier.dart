// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/item_table.dart';
import 'package:plinkyhub/models/saved_items_state.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base notifier for any saved-item type (presets, samples, patterns,
/// wavetables, packs).
///
/// Provides generic implementations of fetch (user / starred / public),
/// star toggling, name uniqueness checks, and simple delete.
/// Subclasses supply the tables and model-specific operations.
abstract class SavedItemsNotifier<
  T extends Searchable,
  Row,
  StarRow,
  StarInsert
>
    extends Notifier<SavedItemsState<T>> {
  SupabaseClient get supabase => Supabase.instance.client;

  // ---- Configuration (override in subclasses) ----

  /// Main database table (e.g. [presetsTable]).
  ItemTable<Row> get itemTable;

  /// Star join table (e.g. [presetStarsTable]).
  StarTable<StarRow, StarInsert> get starTable;

  /// The columns and relations a row of [itemTable] is read with.
  List<PostgrestSelectable<Row>> get selection;

  /// Singular label used in error messages (e.g. `'preset'`).
  String get itemLabel;

  /// Read an item from a row selected with [selection].
  T fromRow(PostgrestPartialRow<Row> row);

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
    return starTable.fetchStarredItemIds(supabase, userId);
  }

  List<T> applyStarred(
    List<PostgrestPartialRow<Row>> rows,
    Set<String> starredIds,
  ) {
    return rows.map((row) {
      final item = fromRow(row);
      if (starredIds.contains(item.id)) {
        return withStarUpdate(item, isStarred: true, starCount: item.starCount);
      }
      return item;
    }).toList();
  }

  // ---- Fetch ----

  Future<void> fetchUserItems({bool force = false}) async {
    if (!force && state.hasLoadedUserItems) {
      return;
    }

    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final rows = await supabase
          .table(itemTable.table)
          .selectOnly(selection)
          .where(itemTable.userId.eq(userId))
          .order(itemTable.updatedAt.desc());

      final starredIds = await fetchStarredIds();
      final items = applyStarred(rows, starredIds);

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

      final rows = await supabase
          .table(itemTable.table)
          .selectOnly(selection)
          .where(
            itemTable.id.inFilter(starredIds.toList()) &
                itemTable.userId.neq(userId),
          );

      final items = rows.map((row) {
        final item = fromRow(row);
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

  Future<void> fetchPublicItems({bool force = false}) async {
    if (!force && state.hasLoadedPublicItems) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final rows = await supabase
          .table(itemTable.table)
          .selectOnly(selection)
          .where(itemTable.isPublic.isTrue());

      final starredIds = await fetchStarredIds();
      final items = applyStarred(rows, starredIds);
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
      await supabase.table(itemTable.table).delete().where(itemTable.id.eq(id));
      await fetchUserItems(force: true);
      await fetchPublicItems(force: true);
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
            .table(starTable.table)
            .delete()
            .where(
              starTable.itemId.eq(item.id) & starTable.userId.eq(userId),
            );
      } else {
        await supabase
            .table(starTable.table)
            .insert(starTable.createInsert(itemId: item.id, userId: userId));
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

  /// Re-fetches both user and public item lists, bypassing the cache.
  Future<void> refreshAll() async {
    await fetchUserItems(force: true);
    await fetchPublicItems(force: true);
  }
}
