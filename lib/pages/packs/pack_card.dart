import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pack_sharing_check.dart';
import 'package:plinkyhub/pages/packs/pattern_section.dart';
import 'package:plinkyhub/pages/packs/preset_slots_grid.dart';
import 'package:plinkyhub/pages/packs/providers/saved_packs_notifier.dart';
import 'package:plinkyhub/pages/packs/samples_section.dart';
import 'package:plinkyhub/pages/packs/save_to_plinky_dialog.dart';
import 'package:plinkyhub/pages/packs/wavetable_section.dart';
import 'package:plinkyhub/pages/presets/providers/saved_presets_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/confirm_delete_dialog.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/share_link_button.dart';
import 'package:plinkyhub/widgets/star_button.dart';
import 'package:plinkyhub/widgets/username_date_line.dart';
import 'package:plinkyhub/widgets/youtube_embed.dart';

class PackCard extends ConsumerStatefulWidget {
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
  ConsumerState<PackCard> createState() => _PackCardState();
}

class _PackCardState extends ConsumerState<PackCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pack = widget.pack;
    final filledSlots = pack.slots
        .where((slot) => slot.presetId != null)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: pack.username.isNotEmpty
            ? () => context.go(
                AppRoute.packs.itemPage(pack.username, pack.slug),
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
                    onToggle: ({required bool wasStarred}) => ref
                        .read(savedPacksProvider.notifier)
                        .toggleStar(pack.copyWith(isStarred: wasStarred)),
                  ),
                  if (pack.username.isNotEmpty)
                    ShareLinkButton(
                      username: pack.username,
                      itemType: 'pack',
                      itemSlug: pack.slug,
                    ),
                  const Spacer(),
                  if (widget.isOwned) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit pack',
                      onPressed: () {
                        ref
                            .read(savedPacksProvider.notifier)
                            .startEditing(pack);
                        widget.onEdit?.call();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        pack.isPublic ? Icons.public : Icons.public_off,
                        size: 20,
                      ),
                      tooltip: pack.isPublic ? 'Make private' : 'Make public',
                      onPressed: () => _togglePublic(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete pack',
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                  IconButton(
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                    tooltip: _expanded ? 'Hide contents' : 'Show contents',
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _PackContentsSection(pack: pack),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _togglePublic(BuildContext context) async {
    final pack = widget.pack;
    if (pack.isPublic) {
      ref
          .read(savedPacksProvider.notifier)
          .updatePack(pack.id, isPublic: false);
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
        final result = await showSharingConflictDialog(context, summary);
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

    ref.read(savedPacksProvider.notifier).updatePack(pack.id, isPublic: true);
  }

  void _saveToPlinky(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveToPlinkyDialog(pack: widget.pack),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      itemType: 'pack',
      itemName: widget.pack.name,
    );
    if (confirmed) {
      ref.read(savedPacksProvider.notifier).deleteItem(widget.pack.id);
      widget.onDeleted?.call();
    }
  }
}

class _PackContentsSection extends ConsumerWidget {
  const _PackContentsSection({required this.pack});

  final SavedPack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPresets = ref.watch(
      savedPresetsProvider.select(
        (s) => [...s.userItems, ...s.publicItems],
      ),
    );

    // Sample IDs live in sample slots (56-63), not in preset slots.
    // Derive sampleId per preset slot the same way the edit tab does.
    final packSampleIds = pack.slots
        .where((s) => s.slotNumber >= sampleSlotStart && s.sampleId != null)
        .map((s) => s.sampleId!)
        .toSet();

    final presetSampleMap = <String, String>{};
    for (final preset in allPresets) {
      if (preset.sampleId != null && packSampleIds.contains(preset.sampleId)) {
        presetSampleMap[preset.id] = preset.sampleId!;
      }
    }

    final presetSlots = List.generate(32, (i) {
      final slot = pack.slots.where((s) => s.slotNumber == i).firstOrNull;
      final presetId = slot?.presetId;
      return (
        presetId: presetId,
        sampleId: presetId != null ? presetSampleMap[presetId] : null,
        patternId: slot?.patternId,
      );
    });

    final patternIds = Map.fromEntries(
      pack.slots
          .where(
            (s) =>
                s.slotNumber >= patternSlotStart &&
                s.slotNumber < sampleSlotStart,
          )
          .map((s) => MapEntry(s.slotNumber - patternSlotStart, s.patternId)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PresetSlotsGrid(
          slots: presetSlots,
          onPresetChanged: (_, __) {},
          onSampleChanged: (_, __) {},
          readOnly: true,
        ),
        const SizedBox(height: 16),
        SamplesSection(slots: presetSlots),
        const SizedBox(height: 16),
        PatternSection(
          patternIds: patternIds,
          onPatternChanged: (_, __) {},
          readOnly: true,
        ),
        const SizedBox(height: 16),
        WavetableSection(
          wavetableId: pack.wavetableId,
          onChanged: (_) {},
          readOnly: true,
        ),
      ],
    );
  }
}
