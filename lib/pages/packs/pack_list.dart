import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/sort_order.dart';
import 'package:plinkyhub/pages/packs/pack_card.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/sort_order_button.dart';

class PackList extends ConsumerStatefulWidget {
  const PackList({
    required this.packs,
    required this.isLoading,
    required this.isOwned,
    required this.onRefresh,
    super.key,
  });

  final List<SavedPack> packs;
  final bool isLoading;
  final bool isOwned;
  final VoidCallback onRefresh;

  @override
  ConsumerState<PackList> createState() => _PackListState();
}

class _PackListState extends ConsumerState<PackList> {
  final _searchController = TextEditingController();
  String _query = '';
  SortOrder _sortOrder = SortOrder.stars;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedPack> get _filteredPacks {
    var packs = widget.packs.toList();

    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      packs = packs
          .where(
            (pack) =>
                pack.name.toLowerCase().contains(lower) ||
                pack.username.toLowerCase().contains(lower) ||
                pack.description.toLowerCase().contains(lower),
          )
          .toList();
    }

    packs.sort((a, b) {
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
        SortOrder.name =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        SortOrder.newest => b.updatedAt.compareTo(a.updatedAt),
      };
    });
    return packs;
  }

  int _compareByStarsThenName(SavedPack a, SavedPack b) {
    final starCmp = b.starCount.compareTo(a.starCount);
    if (starCmp != 0) {
      return starCmp;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.packs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.packs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isOwned
                  ? 'No saved packs yet'
                  : 'No community packs yet',
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

    final filtered = _filteredPacks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search packs...',
              prefixIcon: Icon(Icons.search, size: 20),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} '
                          'pack${filtered.length == 1 ? '' : 's'}',
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        SortOrderButton(
                          value: _sortOrder,
                          onChanged: (order) =>
                              setState(() => _sortOrder = order),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.refresh, size: 20),
                          onPressed: widget.onRefresh,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  );
                }

                final pack = filtered[index - 1];
                return PackCard(
                  pack: pack,
                  isOwned: widget.isOwned,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
