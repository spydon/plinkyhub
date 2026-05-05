import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/pages/presets/providers/saved_presets_notifier.dart';
import 'package:plinkyhub/pages/presets/save_preset_to_plinky_dialog.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/widgets/confirm_delete_dialog.dart';
import 'package:plinkyhub/widgets/pack_usage_check.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';
import 'package:plinkyhub/widgets/youtube_embed.dart';

class PresetCard extends ConsumerStatefulWidget {
  const PresetCard({
    required this.preset,
    required this.isOwned,
    this.onDeleted,
    super.key,
  });

  final SavedPreset preset;
  final bool isOwned;
  final VoidCallback? onDeleted;

  @override
  ConsumerState<PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends ConsumerState<PresetCard> {
  bool get _hasSample => widget.preset.sampleName != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preset = widget.preset;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: preset.username.isNotEmpty
            ? () => context.go(
                AppRoute.presets.itemPage(preset.username, preset.slug),
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
                      preset.name.isEmpty ? '(unnamed)' : preset.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (preset.category.isNotEmpty)
                    Chip(
                      label: Text(
                        PresetCategory.fromName(preset.category)?.label ??
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
              if (preset.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                YoutubeEmbed(url: preset.youtubeUrl),
              ],
              const SizedBox(height: 4),
              UsernameDateLine(
                username: preset.username,
                updatedAt: preset.updatedAt,
              ),
              if (_hasSample) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap:
                      preset.sampleUsername != null && preset.sampleSlug != null
                      ? () => context.go(
                          AppRoute.samples.itemPage(
                            preset.sampleUsername!,
                            preset.sampleSlug!,
                          ),
                        )
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.audio_file,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        preset.sampleName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: preset.sampleUsername != null
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    isStarred: preset.isStarred,
                    starCount: preset.starCount,
                    onToggle: ({required bool wasStarred}) => ref
                        .read(savedPresetsProvider.notifier)
                        .toggleStar(preset.copyWith(isStarred: wasStarred)),
                  ),
                  if (preset.username.isNotEmpty)
                    ShareLinkButton(
                      username: preset.username,
                      itemType: 'preset',
                      itemSlug: preset.slug,
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Edit in editor',
                    onPressed: () {
                      ref
                          .read(savedPresetsProvider.notifier)
                          .loadPresetIntoEditor(preset);
                      context.go(AppRoute.editor.path);
                    },
                  ),
                  const Spacer(),
                  if (widget.isOwned) ...[
                    IconButton(
                      icon: Icon(
                        preset.isPublic ? Icons.public : Icons.public_off,
                        size: 20,
                      ),
                      tooltip: preset.isPublic ? 'Make private' : 'Make public',
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
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete preset',
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
      builder: (context) => SavePresetToPlinkyDialog(preset: widget.preset),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final referencingPacks = await findPacksUsingPreset(ref, widget.preset.id);
    if (!context.mounted) {
      return;
    }
    if (referencingPacks.isNotEmpty) {
      showItemUsageDialog(
        context,
        itemType: 'preset',
        packs: referencingPacks,
      );
      return;
    }

    final confirmed = await showConfirmDeleteDialog(
      context,
      itemType: 'preset',
      itemName: widget.preset.name,
    );
    if (confirmed) {
      ref.read(savedPresetsProvider.notifier).deleteItem(widget.preset.id);
      widget.onDeleted?.call();
    }
  }
}
