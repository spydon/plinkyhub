import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/save_wavetable_to_plinky_dialog.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/widgets/confirm_delete_dialog.dart';
import 'package:plinkyhub/widgets/pack_usage_check.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';
import 'package:plinkyhub/widgets/youtube_embed.dart';

class WavetableCard extends ConsumerWidget {
  const WavetableCard({
    required this.wavetable,
    required this.isOwned,
    this.onDeleted,
    super.key,
  });

  final SavedWavetable wavetable;
  final bool isOwned;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: wavetable.username.isNotEmpty
            ? () => context.go(
                AppRoute.wavetables.itemPage(
                  wavetable.username,
                  wavetable.name,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wavetable.name.isEmpty ? '(unnamed)' : wavetable.name,
                style: theme.textTheme.titleMedium,
              ),
              if (wavetable.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  wavetable.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (wavetable.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                YoutubeEmbed(url: wavetable.youtubeUrl),
              ],
              const SizedBox(height: 4),
              UsernameDateLine(
                userId: wavetable.userId,
                username: wavetable.username,
                updatedAt: wavetable.updatedAt,
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
                    isStarred: wavetable.isStarred,
                    starCount: wavetable.starCount,
                    onToggle: () => ref
                        .read(savedWavetablesProvider.notifier)
                        .toggleStar(wavetable),
                  ),
                  if (wavetable.username.isNotEmpty)
                    ShareLinkButton(
                      username: wavetable.username,
                      itemType: 'wavetable',
                      itemName: wavetable.name,
                    ),
                  const Spacer(),
                  if (isOwned) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit wavetable',
                      onPressed: () => context.go(
                        AppRoute.wavetableEditPage(
                          wavetable.username,
                          wavetable.name,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        wavetable.isPublic ? Icons.public : Icons.public_off,
                        size: 20,
                      ),
                      tooltip: wavetable.isPublic
                          ? 'Make private'
                          : 'Make public',
                      onPressed: () {
                        ref
                            .read(savedWavetablesProvider.notifier)
                            .updateWavetable(
                              wavetable.copyWith(
                                isPublic: !wavetable.isPublic,
                              ),
                            );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                      ),
                      tooltip: 'Delete wavetable',
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

  void _saveToPlinky(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveWavetableToPlinkyDialog(wavetable: wavetable),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final referencingPacks = await findPacksUsingWavetable(ref, wavetable.id);
    if (!context.mounted) {
      return;
    }
    if (referencingPacks.isNotEmpty) {
      showItemUsageDialog(
        context,
        itemType: 'wavetable',
        packs: referencingPacks,
      );
      return;
    }

    final confirmed = await showConfirmDeleteDialog(
      context,
      itemType: 'wavetable',
      itemName: wavetable.name,
    );
    if (confirmed) {
      ref.read(savedWavetablesProvider.notifier).deleteItem(wavetable.id);
      onDeleted?.call();
    }
  }
}
