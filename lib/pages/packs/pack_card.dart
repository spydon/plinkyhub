import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pack_sharing_check.dart';
import 'package:plinkyhub/pages/packs/save_to_plinky_dialog.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/widgets/confirm_delete_dialog.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';
import 'package:plinkyhub/widgets/youtube_embed.dart';

class PackCard extends ConsumerWidget {
  const PackCard({
    required this.pack,
    required this.isOwned,
    this.onEdit,
    this.onDeleted,
    super.key,
  });

  final SavedPack pack;
  final bool isOwned;
  final VoidCallback? onDeleted;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filledSlots = pack.slots
        .where((slot) => slot.presetId != null)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: pack.username.isNotEmpty
            ? () => context.go(
                AppRoute.packs.itemPage(pack.username, pack.name),
              )
            : null,
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
              if (pack.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                YoutubeEmbed(url: pack.youtubeUrl),
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
                  PlinkyButton(
                    onPressed: () => _saveToPlinky(context),
                    icon: Icons.upload,
                    label: 'Upload to Plinky',
                  ),
                  const SizedBox(width: 8),
                  StarButton(
                    isStarred: pack.isStarred,
                    starCount: pack.starCount,
                    onToggle: () =>
                        ref.read(savedPacksProvider.notifier).toggleStar(pack),
                  ),
                  if (pack.username.isNotEmpty)
                    ShareLinkButton(
                      username: pack.username,
                      itemType: 'pack',
                      itemName: pack.name,
                    ),
                  const Spacer(),
                  if (isOwned) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit pack',
                      onPressed: () {
                        ref
                            .read(savedPacksProvider.notifier)
                            .startEditing(pack);
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
              patternId: slot.patternId,
            ),
          )
          .toList();
      final summary = findPrivateItems(
        ref: ref,
        currentUserId: userId,
        slots: slots,
        wavetableId: pack.wavetableId,
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      itemType: 'pack',
      itemName: pack.name,
    );
    if (confirmed) {
      ref.read(savedPacksProvider.notifier).deleteItem(pack.id);
      onDeleted?.call();
    }
  }
}
