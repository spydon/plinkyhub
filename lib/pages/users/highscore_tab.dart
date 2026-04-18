import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/highscores_notifier.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';

enum HighscoreSortField { stars, uploads }

class HighscoreTab extends ConsumerStatefulWidget {
  const HighscoreTab({super.key});

  @override
  ConsumerState<HighscoreTab> createState() => _HighscoreTabState();
}

class _HighscoreTabState extends ConsumerState<HighscoreTab> {
  HighscoreSortField _sortField = HighscoreSortField.stars;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(highscoresProvider);
      if (!state.hasLoaded) {
        ref.read(highscoresProvider.notifier).fetch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(highscoresProvider);
    final theme = Theme.of(context);

    if (state.isLoading && !state.hasLoaded) {
      return const Center(child: PlinkyLoadingAnimation());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }

    final sorted = List.of(state.highscores);
    switch (_sortField) {
      case HighscoreSortField.stars:
        sorted.sort((a, b) => b.totalStars.compareTo(a.totalStars));
      case HighscoreSortField.uploads:
        sorted.sort((a, b) => b.totalUploads.compareTo(a.totalUploads));
    }

    if (sorted.isEmpty) {
      return const Center(child: Text('No highscores yet'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SegmentedButton<HighscoreSortField>(
            segments: const [
              ButtonSegment(
                value: HighscoreSortField.stars,
                label: Text('Stars'),
                icon: Icon(Icons.star, size: 18),
              ),
              ButtonSegment(
                value: HighscoreSortField.uploads,
                label: Text('Uploads'),
                icon: Icon(Icons.cloud_upload, size: 18),
              ),
            ],
            selected: {_sortField},
            onSelectionChanged: (selection) {
              setState(() => _sortField = selection.first);
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(highscoresProvider.notifier).fetch(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final entry = sorted[index];
                return _HighscoreTile(
                  rank: index + 1,
                  entry: entry,
                  highlightField: _sortField,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HighscoreTile extends StatelessWidget {
  const _HighscoreTile({
    required this.rank,
    required this.entry,
    required this.highlightField,
  });

  final int rank;
  final UserHighscore entry;
  final HighscoreSortField highlightField;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '#$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: switch (rank) {
                  1 => Colors.amber,
                  2 => Colors.grey.shade400,
                  3 => Colors.brown.shade300,
                  _ => theme.colorScheme.onSurfaceVariant,
                },
              ),
            ),
          ),
        ),
        title: Text(entry.username),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatChip(
              icon: Icons.star,
              value: entry.totalStars,
              isHighlighted: highlightField == HighscoreSortField.stars,
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.cloud_upload,
              value: entry.totalUploads,
              isHighlighted: highlightField == HighscoreSortField.uploads,
            ),
          ],
        ),
        onTap: () => context.go(AppRoute.userPage(entry.username)),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.isHighlighted,
  });

  final IconData icon;
  final int value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isHighlighted
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isHighlighted ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
