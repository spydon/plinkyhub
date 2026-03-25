import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/models/saved_patch.dart';
import 'package:plinkyhub/pages/patches/star_button.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/utils/note_names.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PatchCard extends ConsumerWidget {
  const PatchCard({
    required this.patch,
    required this.isOwned,
    super.key,
  });

  final SavedPatch patch;
  final bool isOwned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    patch.name.isEmpty ? '(unnamed)' : patch.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (patch.category.isNotEmpty)
                  Chip(
                    label: Text(
                      patch.category,
                      style: theme.textTheme.bodySmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (patch.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                patch.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              [
                if (patch.username.isNotEmpty)
                  'by ${patch.username}',
                formatDate(patch.updatedAt),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                PlinkyButton(
                  onPressed: () {
                    ref
                        .read(savedPatchesProvider.notifier)
                        .loadPatchIntoEditor(patch);
                    ref.read(selectedPageProvider.notifier).selected =
                        0;
                  },
                  icon: Icons.download,
                  label: 'Load into editor',
                ),
                const SizedBox(width: 8),
                StarButton(patch: patch),
                const Spacer(),
                if (isOwned) ...[
                  IconButton(
                    icon: Icon(
                      patch.isPublic
                          ? Icons.public
                          : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: patch.isPublic
                        ? 'Make private'
                        : 'Make public',
                    onPressed: () {
                      ref
                          .read(savedPatchesProvider.notifier)
                          .updatePatch(
                            patch.id,
                            isPublic: !patch.isPublic,
                          );
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete patch',
                    onPressed: () =>
                        _confirmDelete(context, ref),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete patch?'),
        content: Text(
          'Are you sure you want to delete '
          '"${patch.name.isEmpty ? '(unnamed)' : patch.name}"?',
        ),
        actions: [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.close,
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(savedPatchesProvider.notifier)
                  .deletePatch(patch.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
