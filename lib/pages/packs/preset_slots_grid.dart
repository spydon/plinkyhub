import 'package:flutter/material.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/pages/packs/pack_slot_tile.dart';

class PresetSlotsGrid extends StatelessWidget {
  const PresetSlotsGrid({
    required this.slots,
    required this.onPresetChanged,
    required this.onSampleChanged,
    this.devicePresets = const {},
    this.onEditPressed,
    this.dirtySlots = const {},
    this.readOnly = false,
    super.key,
  });

  final List<({String? presetId, String? sampleId, String? patternId})> slots;
  final void Function(int slotIndex, String? presetId) onPresetChanged;
  final void Function(int slotIndex, String? sampleId) onSampleChanged;
  final Map<int, Preset> devicePresets;
  final void Function(int slotIndex)? onEditPressed;
  final Set<int> dirtySlots;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preset Slots',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 64,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 32,
          itemBuilder: (context, index) {
            final row = index ~/ 4;
            final column = index % 4;
            final slotIndex = column * 8 + row;
            return PackSlotTile(
              slotNumber: slotIndex,
              presetId: slots[slotIndex].presetId,
              sampleId: slots[slotIndex].sampleId,
              devicePreset: devicePresets[slotIndex],
              onPresetChanged: (presetId) =>
                  onPresetChanged(slotIndex, presetId),
              onSampleChanged: (sampleId) =>
                  onSampleChanged(slotIndex, sampleId),
              onEditPressed: onEditPressed != null
                  ? () => onEditPressed!(slotIndex)
                  : null,
              isDirty: dirtySlots.contains(slotIndex),
              readOnly: readOnly,
            );
          },
        ),
      ],
    );
  }
}
