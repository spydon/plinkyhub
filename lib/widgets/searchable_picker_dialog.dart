import 'package:flutter/material.dart';
import 'package:plinkyhub/models/searchable.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// A generic picker dialog with search functionality.
///
/// Items are sorted with the current user's own items first,
/// then starred items, then everything else (by star count).
class SearchablePickerDialog<T extends Searchable> extends StatefulWidget {
  const SearchablePickerDialog({
    required this.title,
    required this.items,
    this.currentUserId,
    this.emptyMessage = 'No items found',
    this.itemSubtitle,
    this.itemLeading,
    this.itemTrailing,
    this.headerWidget,
    this.onSelected,
    super.key,
  });

  final String title;
  final List<T> items;
  final String? currentUserId;
  final String emptyMessage;
  final String Function(T item)? itemSubtitle;
  final Widget Function(T item)? itemLeading;
  final Widget Function(T item)? itemTrailing;

  /// Optional widget shown above the list (e.g. an upload button).
  final Widget? headerWidget;

  /// Optional callback invoked instead of popping with the item.
  /// When provided, the dialog does not auto-close on selection.
  final void Function(T item)? onSelected;

  @override
  State<SearchablePickerDialog<T>> createState() =>
      _SearchablePickerDialogState<T>();
}

class _SearchablePickerDialogState<T extends Searchable>
    extends State<SearchablePickerDialog<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredAndSortedItems {
    var items = widget.items.toList();

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
      final aOwned = a.userId == widget.currentUserId;
      final bOwned = b.userId == widget.currentUserId;
      if (aOwned != bOwned) {
        return aOwned ? -1 : 1;
      }

      if (a.isStarred != b.isStarred) {
        return a.isStarred ? -1 : 1;
      }

      if (_query.isNotEmpty) {
        final lower = _query.toLowerCase();
        final aExact = a.name.toLowerCase() == lower ? 0 : 1;
        final bExact = b.name.toLowerCase() == lower ? 0 : 1;
        final exactComparison = aExact.compareTo(bExact);
        if (exactComparison != 0) {
          return exactComparison;
        }
      }

      final starComparison = b.starCount.compareTo(a.starCount);
      if (starComparison != 0) {
        return starComparison;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAndSortedItems;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _query = value),
              autofocus: true,
            ),
            if (widget.headerWidget != null) ...[
              const SizedBox(height: 8),
              widget.headerWidget!,
            ],
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(widget.emptyMessage))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isOwned = item.userId == widget.currentUserId;
                        return ListTile(
                          leading: widget.itemLeading?.call(item),
                          title: Text(
                            item.name.isEmpty ? '(unnamed)' : item.name,
                          ),
                          subtitle: _buildSubtitle(item, isOwned),
                          trailing:
                              widget.itemTrailing?.call(item) ??
                              _buildStarCount(context, item),
                          dense: true,
                          onTap: () {
                            if (widget.onSelected != null) {
                              widget.onSelected!(item);
                            } else {
                              Navigator.of(context).pop(item);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
      ],
    );
  }

  Widget? _buildSubtitle(T item, bool isOwned) {
    final parts = <String>[];

    if (isOwned) {
      parts.add('yours');
    } else if (item.username.isNotEmpty) {
      parts.add(item.username);
    }

    final customSubtitle = widget.itemSubtitle?.call(item);
    if (customSubtitle != null && customSubtitle.isNotEmpty) {
      parts.add(customSubtitle);
    }

    return parts.isEmpty ? null : Text(parts.join(' \u2022 '));
  }

  Widget? _buildStarCount(BuildContext context, T item) {
    if (item.starCount <= 0) {
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.isStarred ? Icons.star : Icons.star_border,
          size: 16,
          color: item.isStarred ? Colors.amber : null,
        ),
        const SizedBox(width: 2),
        Text(
          '${item.starCount}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
