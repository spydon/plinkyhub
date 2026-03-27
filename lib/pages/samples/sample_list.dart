import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/models/sort_order.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/pages/samples/upload_sample_dialog.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/sort_order_button.dart';

class SampleList extends ConsumerStatefulWidget {
  const SampleList({
    required this.samples,
    required this.isLoading,
    required this.isOwned,
    required this.onRefresh,
    super.key,
  });

  final List<SavedSample> samples;
  final bool isLoading;
  final bool isOwned;
  final VoidCallback onRefresh;

  @override
  ConsumerState<SampleList> createState() => _SampleListState();
}

class _SampleListState extends ConsumerState<SampleList> {
  final _searchController = TextEditingController();
  String _query = '';
  SortOrder _sortOrder = SortOrder.stars;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedSample> get _filteredSamples {
    var samples = widget.samples.toList();

    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      samples = samples
          .where(
            (sample) =>
                sample.name.toLowerCase().contains(lower) ||
                sample.username.toLowerCase().contains(lower) ||
                sample.description.toLowerCase().contains(lower),
          )
          .toList();
    }

    samples.sort((a, b) {
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
    return samples;
  }

  int _compareByStarsThenName(SavedSample a, SavedSample b) {
    final starCmp = b.starCount.compareTo(a.starCount);
    if (starCmp != 0) {
      return starCmp;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.samples.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.samples.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isOwned
                  ? 'No saved samples yet'
                  : 'No community samples yet',
            ),
            const SizedBox(height: 8),
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isOwned) ...[
                    PlinkyButton(
                      onPressed: () =>
                          _showUploadDialog(context),
                      icon: Icons.upload_file,
                      label: 'Upload sample',
                    ),
                    const SizedBox(height: 8),
                  ],
                  PlinkyButton(
                    onPressed: widget.onRefresh,
                    icon: Icons.refresh,
                    label: 'Refresh',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredSamples;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search samples...',
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
                          'sample${filtered.length == 1 ? '' : 's'}',
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        SortOrderButton(
                          value: _sortOrder,
                          onChanged: (order) =>
                              setState(() => _sortOrder = order),
                        ),
                        if (widget.isOwned)
                          IconButton(
                            icon: const Icon(
                              Icons.upload_file,
                              size: 20,
                            ),
                            onPressed: () =>
                                _showUploadDialog(context),
                            tooltip: 'Upload sample',
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

                final sample = filtered[index - 1];
                return SampleCard(
                  sample: sample,
                  isOwned: widget.isOwned,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UploadSampleDialog(),
    );
  }
}
