import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// Ensures user packs are loaded, then returns packs using the preset.
Future<List<SavedPack>> findPacksUsingPreset(
  WidgetRef ref,
  String presetId,
) async {
  await _ensurePacksLoaded(ref);
  return ref
      .read(savedPacksProvider)
      .userItems
      .where((pack) => pack.slots.any((slot) => slot.presetId == presetId))
      .toList();
}

/// Ensures user packs are loaded, then returns packs using the sample.
Future<List<SavedPack>> findPacksUsingSample(
  WidgetRef ref,
  String sampleId,
) async {
  await _ensurePacksLoaded(ref);
  return ref
      .read(savedPacksProvider)
      .userItems
      .where((pack) => pack.slots.any((slot) => slot.sampleId == sampleId))
      .toList();
}

/// Ensures user packs are loaded, then returns packs using the wavetable.
Future<List<SavedPack>> findPacksUsingWavetable(
  WidgetRef ref,
  String wavetableId,
) async {
  await _ensurePacksLoaded(ref);
  return ref
      .read(savedPacksProvider)
      .userItems
      .where((pack) => pack.wavetableId == wavetableId)
      .toList();
}

/// Ensures user packs are loaded, then returns packs using the pattern.
Future<List<SavedPack>> findPacksUsingPattern(
  WidgetRef ref,
  String patternId,
) async {
  await _ensurePacksLoaded(ref);
  return ref
      .read(savedPacksProvider)
      .userItems
      .where((pack) => pack.slots.any((slot) => slot.patternId == patternId))
      .toList();
}

/// Ensures user presets are loaded, then returns presets using the sample.
Future<List<SavedPreset>> findPresetsUsingSample(
  WidgetRef ref,
  String sampleId,
) async {
  await _ensurePresetsLoaded(ref);
  return ref
      .read(savedPresetsProvider)
      .userItems
      .where((preset) => preset.sampleId == sampleId)
      .toList();
}

Future<void> _ensurePacksLoaded(WidgetRef ref) async {
  final state = ref.read(savedPacksProvider);
  if (state.userItems.isEmpty && !state.isLoading) {
    await ref.read(savedPacksProvider.notifier).fetchUserItems();
  }
}

Future<void> _ensurePresetsLoaded(WidgetRef ref) async {
  final state = ref.read(savedPresetsProvider);
  if (state.userItems.isEmpty && !state.isLoading) {
    await ref.read(savedPresetsProvider.notifier).fetchUserItems();
  }
}

/// Shows a dialog informing the user that the item is used in packs
/// and/or presets and must be removed before it can be deleted.
void showItemUsageDialog(
  BuildContext context, {
  required String itemType,
  List<SavedPack> packs = const [],
  List<SavedPreset> presets = const [],
}) {
  final references = <String>[];
  if (packs.isNotEmpty) {
    references.add('${packs.length} ${packs.length == 1 ? 'pack' : 'packs'}');
  }
  if (presets.isNotEmpty) {
    references.add(
      '${presets.length} ${presets.length == 1 ? 'preset' : 'presets'}',
    );
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Cannot delete $itemType'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This $itemType is used in '
            '${references.join(' and ')}. '
            'Remove it from '
            '${_isSingleReference(references, packs, presets) ? 'it' : 'them'}'
            ' first before deleting.',
          ),
          const SizedBox(height: 12),
          for (final pack in packs)
            _ItemLink(
              icon: Icons.inventory_2,
              name: pack.name.isEmpty ? '(unnamed)' : pack.name,
              onTap: pack.username.isNotEmpty
                  ? () {
                      Navigator.of(dialogContext).pop();
                      dialogContext.go(
                        AppRoute.packs.itemPage(pack.username, pack.name),
                      );
                    }
                  : null,
            ),
          for (final preset in presets)
            _ItemLink(
              icon: Icons.piano,
              name: preset.name.isEmpty ? '(unnamed)' : preset.name,
              onTap: preset.username.isNotEmpty
                  ? () {
                      Navigator.of(dialogContext).pop();
                      dialogContext.go(
                        AppRoute.presets.itemPage(
                          preset.username,
                          preset.name,
                        ),
                      );
                    }
                  : null,
            ),
        ],
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          icon: Icons.close,
          label: 'OK',
        ),
      ],
    ),
  );
}

bool _isSingleReference(
  List<String> references,
  List<SavedPack> packs,
  List<SavedPreset> presets,
) => references.length == 1 && packs.length + presets.length == 1;

class _ItemLink extends StatelessWidget {
  const _ItemLink({required this.icon, required this.name, this.onTap});

  final IconData icon;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isClickable = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isClickable
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
