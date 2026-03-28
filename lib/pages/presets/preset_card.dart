import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/pages/presets/star_button.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/utils/note_names.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PresetCard extends ConsumerWidget {
  const PresetCard({
    required this.preset,
    required this.isOwned,
    super.key,
  });

  final SavedPreset preset;
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
                    preset.name.isEmpty ? '(unnamed)' : preset.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (preset.category.isNotEmpty)
                  Chip(
                    label: Text(
                      preset.category,
                      style: theme.textTheme.bodySmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (preset.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                preset.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              [
                if (preset.username.isNotEmpty)
                  'by ${preset.username}',
                formatDate(preset.updatedAt),
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
                        .read(savedPresetsProvider.notifier)
                        .loadPresetIntoEditor(preset);
                    ref.read(selectedPageProvider.notifier).selected =
                        1;
                  },
                  icon: Icons.download,
                  label: 'Load into editor',
                ),
                const SizedBox(width: 8),
                PresetStarButton(preset: preset),
                const Spacer(),
                if (isOwned) ...[
                  IconButton(
                    icon: Icon(
                      preset.isPublic
                          ? Icons.public
                          : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: preset.isPublic
                        ? 'Make private'
                        : 'Make public',
                    onPressed: () {
                      ref
                          .read(savedPresetsProvider.notifier)
                          .updatePreset(
                            preset.id,
                            isPublic: !preset.isPublic,
                          );
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete preset',
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
        title: const Text('Delete preset?'),
        content: Text(
          'Are you sure you want to delete '
          '"${preset.name.isEmpty ? '(unnamed)' : preset.name}"?',
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
                  .read(savedPresetsProvider.notifier)
                  .deletePreset(preset.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
