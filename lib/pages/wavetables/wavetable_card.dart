import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
import 'package:plinkyhub/pages/wavetables/save_wavetable_to_plinky_dialog.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/widgets/confirm_delete_dialog.dart';
import 'package:plinkyhub/widgets/pack_usage_check.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';
import 'package:plinkyhub/widgets/youtube_embed.dart';

class WavetableCard extends ConsumerStatefulWidget {
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
  ConsumerState<WavetableCard> createState() => _WavetableCardState();
}

class _WavetableCardState extends ConsumerState<WavetableCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wavetable = widget.wavetable;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: wavetable.username.isNotEmpty
            ? () => context.go(
                AppRoute.wavetables.itemPage(
                  wavetable.username,
                  wavetable.slug,
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
                    onToggle: ({required bool wasStarred}) => ref
                        .read(savedWavetablesProvider.notifier)
                        .toggleStar(
                          wavetable.copyWith(isStarred: wasStarred),
                        ),
                  ),
                  if (wavetable.username.isNotEmpty)
                    ShareLinkButton(
                      username: wavetable.username,
                      itemType: 'wavetable',
                      itemSlug: wavetable.slug,
                    ),
                  const Spacer(),
                  if (widget.isOwned) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit wavetable',
                      onPressed: () => context.go(
                        AppRoute.wavetableEditPage(
                          wavetable.username,
                          wavetable.slug,
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
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete wavetable',
                      onPressed: () => _confirmDelete(context),
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
      builder: (context) =>
          SaveWavetableToPlinkyDialog(wavetable: widget.wavetable),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final referencingPacks = await findPacksUsingWavetable(
      ref,
      widget.wavetable.id,
    );
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
      itemName: widget.wavetable.name,
    );
    if (confirmed) {
      ref
          .read(savedWavetablesProvider.notifier)
          .deleteItem(widget.wavetable.id);
      widget.onDeleted?.call();
    }
  }
}
