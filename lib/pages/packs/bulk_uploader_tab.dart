import 'package:flutter/material.dart';
import 'package:plinkyhub/models/pack_slot.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pattern_section.dart';
import 'package:plinkyhub/pages/packs/preset_slots_grid.dart';
import 'package:plinkyhub/pages/packs/samples_section.dart';
import 'package:plinkyhub/pages/packs/save_to_plinky_dialog.dart';
import 'package:plinkyhub/pages/packs/wavetable_section.dart';
import 'package:plinkyhub/utils/constants.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class BulkUploaderTab extends StatefulWidget {
  const BulkUploaderTab({super.key});

  @override
  State<BulkUploaderTab> createState() => _BulkUploaderTabState();
}

class _BulkUploaderTabState extends State<BulkUploaderTab> {
  final List<({String? presetId, String? sampleId, String? patternId})> _slots =
      List.generate(
        32,
        (_) => (presetId: null, sampleId: null, patternId: null),
      );
  String _wavetableId = defaultWavetableId;
  final Map<int, String?> _patternIds = {};
  final List<String?> _sampleSlots = List<String?>.filled(sampleCount, null);

  bool get _hasContent {
    if (_slots.any(
      (slot) =>
          slot.presetId != null ||
          slot.sampleId != null ||
          slot.patternId != null,
    )) {
      return true;
    }
    if (_patternIds.values.any((id) => id != null)) {
      return true;
    }
    if (_sampleSlots.any((id) => id != null)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick presets, samples, patterns, and a wavetable, '
            'then upload them directly to your Plinky.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          PresetSlotsGrid(
            slots: _slots,
            onPresetChanged: (slotIndex, presetId) {
              setState(() {
                _slots[slotIndex] = (
                  presetId: presetId,
                  sampleId: _slots[slotIndex].sampleId,
                  patternId: _slots[slotIndex].patternId,
                );
              });
            },
            onSampleChanged: (slotIndex, sampleId) {
              setState(() {
                _slots[slotIndex] = (
                  presetId: _slots[slotIndex].presetId,
                  sampleId: sampleId,
                  patternId: _slots[slotIndex].patternId,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          SamplesSection(
            slots: _slots,
            manualSampleSlots: _sampleSlots,
            onSampleSlotChanged: (deviceSlot, sampleId) {
              setState(() {
                _sampleSlots[deviceSlot] = sampleId;
              });
            },
          ),
          const SizedBox(height: 16),
          PatternSection(
            patternIds: _patternIds,
            onPatternChanged: (patternIndex, patternId) {
              setState(() {
                _patternIds[patternIndex] = patternId;
              });
            },
          ),
          const SizedBox(height: 16),
          WavetableSection(
            wavetableId: _wavetableId,
            onChanged: (wavetableId) => setState(
              () => _wavetableId = wavetableId ?? defaultWavetableId,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: PlinkyButton(
              onPressed: _hasContent ? _uploadToPlinky : null,
              icon: Icons.cloud_upload,
              label: 'Upload to Plinky',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _uploadToPlinky() async {
    final uniqueSampleCount = {
      ..._slots.map((slot) => slot.sampleId).whereType<String>(),
      ..._sampleSlots.whereType<String>(),
    }.length;
    if (uniqueSampleCount > sampleCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can upload at most $sampleCount samples. '
            'Currently using $uniqueSampleCount.',
          ),
        ),
      );
      return;
    }

    final pack = _buildTransientPack();

    await showDialog<void>(
      context: context,
      builder: (context) => SaveToPlinkyDialog(pack: pack),
    );
  }

  SavedPack _buildTransientPack() {
    final slots = <PackSlot>[];

    for (var i = 0; i < 32; i++) {
      final presetId = _slots[i].presetId;
      if (presetId != null) {
        slots.add(
          PackSlot(
            id: '',
            packId: '',
            slotNumber: presetSlotStart + i,
            presetId: presetId,
          ),
        );
      }
    }

    for (final entry in _patternIds.entries) {
      final patternId = entry.value;
      if (patternId != null) {
        slots.add(
          PackSlot(
            id: '',
            packId: '',
            slotNumber: patternSlotStart + entry.key,
            patternId: patternId,
          ),
        );
      }
    }

    final assignedSampleSlots = List<String?>.filled(sampleCount, null);
    final seenSampleIds = <String>{};
    for (var i = 0; i < sampleCount && i < _sampleSlots.length; i++) {
      final manualSampleId = _sampleSlots[i];
      if (manualSampleId != null) {
        assignedSampleSlots[i] = manualSampleId;
        seenSampleIds.add(manualSampleId);
      }
    }
    var nextAutoSlot = 0;
    for (var i = 0; i < 32; i++) {
      final sampleId = _slots[i].sampleId;
      if (sampleId == null || !seenSampleIds.add(sampleId)) {
        continue;
      }
      while (nextAutoSlot < sampleCount &&
          assignedSampleSlots[nextAutoSlot] != null) {
        nextAutoSlot++;
      }
      if (nextAutoSlot >= sampleCount) {
        break;
      }
      assignedSampleSlots[nextAutoSlot] = sampleId;
      nextAutoSlot++;
    }
    for (var i = 0; i < sampleCount; i++) {
      final sampleId = assignedSampleSlots[i];
      if (sampleId != null) {
        slots.add(
          PackSlot(
            id: '',
            packId: '',
            slotNumber: sampleSlotStart + i,
            sampleId: sampleId,
          ),
        );
      }
    }

    final now = DateTime.now();
    return SavedPack(
      id: '',
      userId: '',
      name: '',
      createdAt: now,
      updatedAt: now,
      slots: slots,
      wavetableId: _wavetableId,
    );
  }
}
