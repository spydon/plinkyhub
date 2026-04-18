import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/my_plinky/save_my_plinky_dialog.dart';
import 'package:plinkyhub/pages/packs/pattern_section.dart';
import 'package:plinkyhub/pages/packs/preset_slots_grid.dart';
import 'package:plinkyhub/pages/packs/samples_section.dart';
import 'package:plinkyhub/pages/packs/wavetable_section.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/my_plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class MyPlinkyDeviceView extends ConsumerWidget {
  const MyPlinkyDeviceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPlinkyProvider);
    final notifier = ref.read(myPlinkyProvider.notifier);
    final theme = Theme.of(context);
    final matchedPack = state.matchedPack;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matchedPack != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.library_music,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is the ${matchedPack.name} pack.',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      if (matchedPack.username.isNotEmpty)
                        LinkedItemIcon(
                          onTap: () => context.go(
                            AppRoute.packs.itemPage(
                              matchedPack.username,
                              matchedPack.name,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Text(
                'My Plinky',
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              if (state.hasUnsavedChanges)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Unsaved changes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              PlinkyButton(
                onPressed: notifier.connectToPlinky,
                icon: Icons.refresh,
                label: 'Reload',
              ),
              const SizedBox(width: 8),
              PlinkyButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => SaveMyPlinkyDialog(
                    directory: state.directory!,
                    slots: state.slots,
                    patternIds: state.patternIds,
                    wavetableId: state.wavetableId,
                    parsedFlashImage: state.parsedFlashImage!,
                    onSaved: notifier.clearDirtyState,
                  ),
                ),
                icon: Icons.save,
                label: 'Save to Plinky',
              ),
            ],
          ),
          const SizedBox(height: 16),
          PresetSlotsGrid(
            slots: state.slots,
            devicePresets: state.devicePresets,
            dirtySlots: state.dirtySlots,
            onPresetChanged: notifier.updateSlotPreset,
            onSampleChanged: notifier.updateSlotSample,
            onEditPressed: (slotIndex) {
              final preset = state.devicePresets[slotIndex];
              if (preset == null) {
                return;
              }
              final plinkyNotifier = ref.read(plinkyProvider.notifier);
              plinkyNotifier.presetNumber = slotIndex;
              final slot = state.slots[slotIndex];
              plinkyNotifier.loadPresetFromBytes(
                preset.buffer.asUint8List(),
                sourceId: slot.presetId,
                sourceSampleId: slot.sampleId,
              );
              notifier.setEditingSlotIndex(slotIndex);
              context.go(AppRoute.editor.path);
            },
          ),
          if (state.samplesLoaded) ...[
            const SizedBox(height: 16),
            SamplesSection(
              slots: state.slots,
              deviceSampleSlots: state.deviceSampleSlots,
              devicePresets: state.devicePresets,
            ),
          ],
          const SizedBox(height: 16),
          PatternSection(
            patternIds: state.patternIds,
            devicePatternIndices: state.devicePatternIndices.toSet(),
            dirtyPatterns: state.dirtyPatterns,
            onPatternChanged: notifier.updatePattern,
          ),
          const SizedBox(height: 16),
          WavetableSection(
            wavetableId: state.wavetableId,
            deviceHasWavetable: state.deviceHasWavetable,
            showUnknownWhenEmpty: true,
            isDirty: state.dirtyWavetable,
            onChanged: notifier.updateWavetable,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
