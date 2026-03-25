import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/pages/patches/patch_card.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PatchList extends ConsumerStatefulWidget {
  const PatchList({
    required this.patches,
    required this.isLoading,
    required this.isOwned,
    required this.onRefresh,
    super.key,
  });

  final List<SavedPatch> patches;
  final bool isLoading;
  final bool isOwned;
  final VoidCallback onRefresh;

  @override
  ConsumerState<PatchList> createState() => _PatchListState();
}

class _PatchListState extends ConsumerState<PatchList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedPatch> get _filteredPatches {
    final patches = widget.patches;
    if (_query.isEmpty) {
      return patches;
    }
    final lower = _query.toLowerCase();
    final filtered = patches
        .where(
          (patch) =>
              patch.name.toLowerCase().contains(lower) ||
              patch.username.toLowerCase().contains(lower) ||
              patch.description.toLowerCase().contains(lower),
        )
        .toList();
    filtered.sort((a, b) {
      final aExact = a.name.toLowerCase() == lower ? 0 : 1;
      final bExact = b.name.toLowerCase() == lower ? 0 : 1;
      final exactCmp = aExact.compareTo(bExact);
      if (exactCmp != 0) {
        return exactCmp;
      }
      return b.starCount.compareTo(a.starCount);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.patches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.patches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isOwned
                  ? 'No saved patches yet'
                  : 'No community patches yet',
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

    final filtered = _filteredPatches;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search patches...',
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
                          'patch${filtered.length == 1 ? '' : 'es'}',
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
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

                final patch = filtered[index - 1];
                return PatchCard(
                  patch: patch,
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
