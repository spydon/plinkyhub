import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/models/sort_order.dart';
import 'package:plinkyhub/widgets/category_filter_button.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:plinkyhub/widgets/sort_order_button.dart';

class SearchableItemList<T extends Searchable> extends ConsumerStatefulWidget {
  const SearchableItemList({
    required this.items,
    required this.isLoading,
    required this.isOwned,
    required this.onRefresh,
    required this.itemBuilder,
    required this.itemLabel,
    this.starredItems = const [],
    this.categories,
    this.categoryOf,
    super.key,
  }) : assert(
         (categories == null) == (categoryOf == null),
         'categories and categoryOf must be provided together',
       );

  final List<T> items;
  final List<T> starredItems;
  final bool isLoading;
  final bool isOwned;
  final VoidCallback onRefresh;
  final Widget Function(T item) itemBuilder;
  final String itemLabel;
  final List<String>? categories;
  final String Function(T item)? categoryOf;

  @override
  ConsumerState<SearchableItemList<T>> createState() =>
      _SearchableItemListState<T>();
}

class _SearchableItemListState<T extends Searchable>
    extends ConsumerState<SearchableItemList<T>> {
  final _searchController = TextEditingController();
  String _query = '';
  SortOrder _sortOrder = SortOrder.stars;
  bool _includeStarred = true;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasStarredItems => widget.starredItems.isNotEmpty;

  List<T> get _combinedItems {
    if (!_includeStarred || !_hasStarredItems) {
      return widget.items;
    }
    return [...widget.items, ...widget.starredItems];
  }

  List<T> get _filteredItems {
    var items = _combinedItems.toList();

    final selectedCategory = _selectedCategory;
    final categoryOf = widget.categoryOf;
    if (selectedCategory != null && categoryOf != null) {
      items = items
          .where((item) => categoryOf(item) == selectedCategory)
          .toList();
    }

    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      items = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(lower) ||
                item.username.toLowerCase().contains(lower) ||
                item.description.toLowerCase().contains(lower),
          )
          .toList();
    }

    items.sort((a, b) {
      if (_query.isNotEmpty) {
        final lower = _query.toLowerCase();
        final aExact = a.name.toLowerCase() == lower ? 0 : 1;
        final bExact = b.name.toLowerCase() == lower ? 0 : 1;
        final exactCmp = aExact.compareTo(bExact);
        if (exactCmp != 0) {
          return exactCmp;
        }
      }
      return switch (_sortOrder) {
        SortOrder.stars => _compareByStarsThenName(a, b),
        SortOrder.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        SortOrder.newest => b.updatedAt.compareTo(a.updatedAt),
      };
    });
    return items;
  }

  int _compareByStarsThenName(T a, T b) {
    final starCmp = b.starCount.compareTo(a.starCount);
    if (starCmp != 0) {
      return starCmp;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return const Center(child: PlinkyLoadingAnimation());
    }

    if (widget.items.isEmpty && widget.starredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isOwned
                  ? 'No saved ${widget.itemLabel}s yet'
                  : 'No community ${widget.itemLabel}s yet',
            ),
            const SizedBox(height: 8),
            PlinkyButton(
              onPressed: widget.onRefresh,
              icon: Icons.refresh,
              label: 'Refresh',
            ),
          ],
        ),
      );
    }

    final filtered = _filteredItems;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search ${widget.itemLabel}s...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onRefresh(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} '
                          '${widget.itemLabel}'
                          '${filtered.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        if (widget.isOwned)
                          Tooltip(
                            message: 'Include starred',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: _includeStarred && _hasStarredItems
                                      ? Colors.amber
                                      : null,
                                ),
                                SizedBox(
                                  height: 24,
                                  child: Switch(
                                    value: _includeStarred && _hasStarredItems,
                                    onChanged: _hasStarredItems
                                        ? (value) => setState(
                                            () => _includeStarred = value,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.categories != null)
                          CategoryFilterButton(
                            categories: widget.categories!,
                            value: _selectedCategory,
                            onChanged: (category) =>
                                setState(() => _selectedCategory = category),
                          ),
                        SortOrderButton(
                          value: _sortOrder,
                          onChanged: (order) =>
                              setState(() => _sortOrder = order),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: widget.onRefresh,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    childCount: filtered.length,
                    itemBuilder: (context, index) =>
                        widget.itemBuilder(filtered[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
