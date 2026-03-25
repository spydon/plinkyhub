import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/utils/note_names.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PackCard extends ConsumerWidget {
  const PackCard({
    required this.pack,
    required this.isOwned,
    super.key,
  });

  final SavedPack pack;
  final bool isOwned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filledSlots = pack.slots.length;

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
                    pack.name.isEmpty ? '(unnamed)' : pack.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    '$filledSlots/32 patches',
                    style: theme.textTheme.bodySmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (pack.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                pack.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              formatDate(pack.updatedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isOwned) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      pack.isPublic
                          ? Icons.public
                          : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: pack.isPublic
                        ? 'Make private'
                        : 'Make public',
                    onPressed: () {
                      ref
                          .read(savedPacksProvider.notifier)
                          .updatePack(
                            pack.id,
                            isPublic: !pack.isPublic,
                          );
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete pack',
                    onPressed: () =>
                        _confirmDelete(context, ref),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete pack?'),
        content: Text(
          'Are you sure you want to delete '
          '"${pack.name.isEmpty ? '(unnamed)' : pack.name}"?',
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
                  .read(savedPacksProvider.notifier)
                  .deletePack(pack.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
