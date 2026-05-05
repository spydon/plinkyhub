import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/packs/sample_picker_dialog.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';

class SamplesSection extends ConsumerWidget {
  const SamplesSection({
    required this.slots,
    this.manualSampleSlots,
    this.onSampleSlotChanged,
    this.deviceSampleSlots = const {},
    this.devicePresets = const {},
    super.key,
  });

  final List<({String? presetId, String? sampleId, String? patternId})> slots;

  /// Explicit per-device-slot sample assignments. When set for a device slot,
  /// it overrides the sample that would be auto-derived from preset-linked
  /// samples for that slot.
  final List<String?>? manualSampleSlots;

  /// When provided, each device sample slot becomes editable: tapping the
  /// tile opens a sample picker. The callback receives the device slot index
  /// (0..sampleCount-1) and the new sample id (or null to clear).
  final void Function(int slotIndex, String? sampleId)? onSampleSlotChanged;

  final Set<int> deviceSampleSlots;
  final Map<int, Preset> devicePresets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedSamplesState = ref.watch(savedSamplesProvider);
    final savedSamples = [
      ...savedSamplesState.userItems,
      ...savedSamplesState.publicItems,
    ];

    // Map device sample slot (0-7) to preset slot numbers via P_SAMPLE.
    final deviceSlotToPresetSlots = <int, List<int>>{};
    for (final presetEntry in devicePresets.entries) {
      final preset = presetEntry.value;
      if (!preset.usesSample) {
        continue;
      }
      final presetRaw = preset.parameterById('P_SAMPLE')?.value;
      if (presetRaw == null || presetRaw == 0) {
        continue;
      }
      final sampleSlot = rawToSampleSlot(presetRaw);
      if (sampleSlot >= 0) {
        deviceSlotToPresetSlots
            .putIfAbsent(sampleSlot, () => [])
            .add(presetEntry.key + 1);
      }
    }

    // Map device sample slot (0-7) to linked sample ID by looking
    // at preset slots that reference each device slot.
    final deviceSlotToSampleId = <int, String>{};
    for (final entry in deviceSlotToPresetSlots.entries) {
      final deviceSlot = entry.key;
      for (final presetSlotNumber in entry.value) {
        final presetIndex = presetSlotNumber - 1;
        if (presetIndex < slots.length) {
          final sampleId = slots[presetIndex].sampleId;
          if (sampleId != null) {
            deviceSlotToSampleId[deviceSlot] = sampleId;
            break;
          }
        }
      }
    }

    // For Create Pack (no device presets), auto-fill device slots from
    // preset-linked samples in order, skipping slots already claimed by
    // a manual assignment.
    final manual = manualSampleSlots;
    final manuallyClaimedSampleIds = <String>{
      if (manual != null)
        for (final id in manual)
          if (id != null) id,
    };
    if (devicePresets.isEmpty) {
      final autoFillIds = <String>[];
      for (var i = 0; i < slots.length; i++) {
        final sampleId = slots[i].sampleId;
        if (sampleId == null) {
          continue;
        }
        if (manuallyClaimedSampleIds.contains(sampleId)) {
          continue;
        }
        if (!autoFillIds.contains(sampleId)) {
          autoFillIds.add(sampleId);
        }
      }
      var autoIndex = 0;
      for (var slot = 0; slot < sampleCount; slot++) {
        if (manual != null && slot < manual.length && manual[slot] != null) {
          continue;
        }
        if (autoIndex >= autoFillIds.length) {
          break;
        }
        deviceSlotToSampleId[slot] = autoFillIds[autoIndex];
        autoIndex++;
      }
    }

    // Apply manual overrides last so they win over any auto-derived value.
    if (manual != null) {
      for (var slot = 0; slot < manual.length && slot < sampleCount; slot++) {
        final id = manual[slot];
        if (id != null) {
          deviceSlotToSampleId[slot] = id;
        }
      }
    }

    // Build sampleId -> preset slot numbers for display.
    final sampleToPresetSlots = <String, List<int>>{};
    for (var i = 0; i < slots.length; i++) {
      final sampleId = slots[i].sampleId;
      if (sampleId != null) {
        sampleToPresetSlots.putIfAbsent(sampleId, () => []).add(i + 1);
      }
    }

    final uniqueSampleCount = {
      ...sampleToPresetSlots.keys,
      ...manuallyClaimedSampleIds,
    }.length;
    final hasOverflow = uniqueSampleCount > sampleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Samples',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (hasOverflow)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'A pack can use at most $sampleCount samples. '
              'Currently using $uniqueSampleCount.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        Row(
          children: List.generate(sampleCount, (deviceSlot) {
            final sampleId = deviceSlotToSampleId[deviceSlot];
            final sample = sampleId != null
                ? savedSamples
                      .where((sample) => sample.id == sampleId)
                      .firstOrNull
                : null;
            final hasDeviceSample = deviceSampleSlots.contains(deviceSlot);

            String displayName;
            if (sample != null) {
              displayName = sample.name;
            } else if (hasDeviceSample) {
              displayName = 'On device';
            } else {
              displayName = 'Empty';
            }

            // Prefer preset slots from sampleId, fall back to device
            // (only if the device actually has sample data in this slot).
            final presetSlots = sampleId != null
                ? sampleToPresetSlots[sampleId]
                : hasDeviceSample
                ? deviceSlotToPresetSlots[deviceSlot]
                : null;

            final isManual =
                manual != null &&
                deviceSlot < manual.length &&
                manual[deviceSlot] != null;

            final tile = Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSampleSlotChanged != null
                    ? () => _showSlotMenu(
                        context,
                        ref,
                        deviceSlot,
                        savedSamples,
                        isManual: isManual,
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${deviceSlot + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (sample != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: _SampleLinkIcon(
                                sample: sample,
                                ref: ref,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (presetSlots != null && presetSlots.isNotEmpty)
                        Text(
                          'Slots: ${presetSlots.join(', ')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            );

            return Expanded(child: tile);
          }),
        ),
      ],
    );
  }

  Future<void> _showSlotMenu(
    BuildContext context,
    WidgetRef ref,
    int deviceSlot,
    List<SavedSample> samples, {
    required bool isManual,
  }) async {
    final callback = onSampleSlotChanged;
    if (callback == null) {
      return;
    }
    // If the slot is empty or auto-derived, jump straight to picker.
    // If a manual sample is set, offer Pick / Clear.
    if (!isManual) {
      await _pickSample(context, ref, deviceSlot, samples, callback);
      return;
    }

    final action = await showDialog<_SlotAction>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Sample slot'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(_SlotAction.pick),
            child: const Text('Pick sample'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(_SlotAction.clear),
            child: const Text('Clear slot'),
          ),
        ],
      ),
    );
    if (action == _SlotAction.pick) {
      if (!context.mounted) {
        return;
      }
      await _pickSample(context, ref, deviceSlot, samples, callback);
    } else if (action == _SlotAction.clear) {
      callback(deviceSlot, null);
    }
  }

  Future<void> _pickSample(
    BuildContext context,
    WidgetRef ref,
    int deviceSlot,
    List<SavedSample> samples,
    void Function(int, String?) callback,
  ) async {
    final currentUserId = ref.read(authenticationProvider).user?.id;
    final selected = await showDialog<SavedSample>(
      context: context,
      builder: (context) => SamplePickerDialog(
        samples: samples,
        currentUserId: currentUserId,
      ),
    );
    if (selected != null) {
      callback(deviceSlot, selected.id);
    }
  }
}

enum _SlotAction { pick, clear }

class _SampleLinkIcon extends StatelessWidget {
  const _SampleLinkIcon({
    required this.sample,
    required this.ref,
  });

  final SavedSample sample;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return LinkedItemIcon(
      onTap: () {
        final currentUserId = ref.read(authenticationProvider).user?.id;
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SampleCard(
                  sample: sample,
                  isOwned: sample.userId == currentUserId,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
