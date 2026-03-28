import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pack_sharing_check.dart';
import 'package:plinkyhub/pages/packs/save_to_plinky_dialog.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';

class PackCard extends ConsumerWidget {
  const PackCard({
    required this.pack,
    required this.isOwned,
    this.onEdit,
    super.key,
  });

  final SavedPack pack;
  final bool isOwned;
  final VoidCallback? onEdit;

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
                    '$filledSlots/32 presets',
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
            UsernameDateLine(
              userId: pack.userId,
              username: pack.username,
              updatedAt: pack.updatedAt,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StarButton(
                  isStarred: pack.isStarred,
                  starCount: pack.starCount,
                  onToggle: () =>
                      ref.read(savedPacksProvider.notifier).toggleStar(pack),
                ),
                IconButton(
                  icon: const Icon(Icons.usb, size: 20),
                  tooltip: 'Save to Plinky',
                  onPressed: () => _saveToPlinky(context),
                ),
                const Spacer(),
                if (isOwned) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Edit pack',
                    onPressed: () {
                      ref.read(savedPacksProvider.notifier).startEditing(pack);
                      onEdit?.call();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      pack.isPublic ? Icons.public : Icons.public_off,
                      size: 20,
                    ),
                    tooltip: pack.isPublic ? 'Make private' : 'Make public',
                    onPressed: () => _togglePublic(context, ref),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete pack',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePublic(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (pack.isPublic) {
      ref
          .read(savedPacksProvider.notifier)
          .updatePack(
            pack.id,
            isPublic: false,
          );
      return;
    }

    final userId = ref.read(authenticationProvider).user?.id;
    if (userId != null) {
      final slots = pack.slots
          .map(
            (slot) => (
              presetId: slot.presetId,
              sampleId: slot.sampleId,
            ),
          )
          .toList();
      final summary = findPrivateItems(
        ref: ref,
        currentUserId: userId,
        slots: slots,
        wavetableId: pack.wavetableId,
        patternId: pack.patternId,
      );

      if (summary.hasPrivateItems) {
        final result = await showSharingConflictDialog(
          context,
          summary,
        );
        if (result == null) {
          return;
        }
        if (result == SharingCheckResult.makeAllPublic) {
          await makeItemsPublic(summary);
        } else {
          return;
        }
      }
    }

    ref
        .read(savedPacksProvider.notifier)
        .updatePack(
          pack.id,
          isPublic: true,
        );
  }

  void _saveToPlinky(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveToPlinkyDialog(pack: pack),
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
              ref.read(savedPacksProvider.notifier).deletePack(pack.id);
            },
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}
