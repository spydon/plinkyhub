import 'package:plinkyhub/models/searchable.dart';

/// Generic state for any saved-items notifier.
///
/// Replaces the individual freezed state classes
/// (SavedPresetsState, SavedSamplesState, etc.) with a single generic.
class SavedItemsState<T extends Searchable> {
  const SavedItemsState({
    this.userItems = const [],
    this.starredItems = const [],
    this.publicItems = const [],
    this.isLoading = false,
    this.hasLoadedUserItems = false,
    this.hasLoadedPublicItems = false,
    this.errorMessage,
    this.editingItem,
  });

  final List<T> userItems;
  final List<T> starredItems;
  final List<T> publicItems;
  final bool isLoading;
  final bool hasLoadedUserItems;
  final bool hasLoadedPublicItems;
  final String? errorMessage;

  /// Used by packs for editing state; null for other item types.
  final T? editingItem;

  /// Deduplicated union of the user's own items, starred items, and public
  /// items (in that order so own/starred entries win on duplicate IDs).
  List<T> get allItems {
    final seen = <String>{};
    final combined = <T>[];
    for (final item in [...userItems, ...starredItems, ...publicItems]) {
      if (seen.add(item.id)) {
        combined.add(item);
      }
    }
    return combined;
  }

  SavedItemsState<T> copyWith({
    List<T>? userItems,
    List<T>? starredItems,
    List<T>? publicItems,
    bool? isLoading,
    bool? hasLoadedUserItems,
    bool? hasLoadedPublicItems,
    String? Function()? errorMessage,
    T? Function()? editingItem,
  }) {
    return SavedItemsState<T>(
      userItems: userItems ?? this.userItems,
      starredItems: starredItems ?? this.starredItems,
      publicItems: publicItems ?? this.publicItems,
      isLoading: isLoading ?? this.isLoading,
      hasLoadedUserItems: hasLoadedUserItems ?? this.hasLoadedUserItems,
      hasLoadedPublicItems: hasLoadedPublicItems ?? this.hasLoadedPublicItems,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      editingItem: editingItem != null ? editingItem() : this.editingItem,
    );
  }
}
