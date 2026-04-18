import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';

class SamplesSection extends ConsumerWidget {
  const SamplesSection({
    required this.slots,
    this.deviceSampleSlots = const {},
    this.devicePresets = const {},
    super.key,
  });

  final List<({String? presetId, String? sampleId, String? patternId})> slots;
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

    // Also pick up any linked samples not mapped through device
    // presets (for Create Pack where there are no device presets).
    if (devicePresets.isEmpty) {
      final uniqueSampleIds = <String>[];
      for (var i = 0; i < slots.length; i++) {
        final sampleId = slots[i].sampleId;
        if (sampleId != null && !uniqueSampleIds.contains(sampleId)) {
          uniqueSampleIds.add(sampleId);
        }
      }
      for (var i = 0; i < uniqueSampleIds.length && i < sampleCount; i++) {
        deviceSlotToSampleId[i] = uniqueSampleIds[i];
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

    final uniqueSampleCount = sampleToPresetSlots.length;
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

            return Expanded(
              child: Card(
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
          }),
        ),
      ],
    );
  }
}

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
