import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pack_sharing_check.dart';
import 'package:plinkyhub/pages/packs/pattern_section.dart';
import 'package:plinkyhub/pages/packs/preset_slots_grid.dart';
import 'package:plinkyhub/pages/packs/providers/saved_packs_notifier.dart';
import 'package:plinkyhub/pages/packs/samples_section.dart';
import 'package:plinkyhub/pages/packs/wavetable_section.dart';
import 'package:plinkyhub/pages/presets/providers/saved_presets_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/constants.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class CreatePackTab extends ConsumerStatefulWidget {
  const CreatePackTab({super.key});

  @override
  ConsumerState<CreatePackTab> createState() => _CreatePackTabState();
}

class _CreatePackTabState extends ConsumerState<CreatePackTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  bool _isPublic = false;
  final List<({String? presetId, String? sampleId, String? patternId})> _slots =
      List.generate(
        32,
        (_) => (presetId: null, sampleId: null, patternId: null),
      );
  String? _editingPackId;
  String _wavetableId = defaultWavetableId;
  final Map<int, String?> _patternIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  void _loadPack(SavedPack pack) {
    _editingPackId = pack.id;
    _nameController.text = pack.name;
    _descriptionController.text = pack.description;
    _youtubeUrlController.text = pack.youtubeUrl;
    _isPublic = pack.isPublic;
    _wavetableId = pack.wavetableId ?? defaultWavetableId;
    _patternIds.clear();
    for (var i = 0; i < 32; i++) {
      _slots[i] = (presetId: null, sampleId: null, patternId: null);
    }

    // Build a set of sample IDs from the sample slots (56-63).
    final packSampleIds = <String>{};
    for (final slot in pack.slots) {
      if (slot.slotNumber >= sampleSlotStart && slot.sampleId != null) {
        packSampleIds.add(slot.sampleId!);
      }
    }

    // Look up each preset's sample_id from saved presets state.
    final presets = ref.read(
      savedPresetsProvider.select((state) => state.userItems),
    );
    final presetSampleMap = <String, String?>{};
    for (final preset in presets) {
      if (preset.sampleId != null && packSampleIds.contains(preset.sampleId)) {
        presetSampleMap[preset.id] = preset.sampleId;
      }
    }

    for (final slot in pack.slots) {
      if (slot.slotNumber < presetCount) {
        // Preset slot (0-31): resolve sample from preset's sample_id.
        _slots[slot.slotNumber] = (
          presetId: slot.presetId,
          sampleId: slot.presetId != null
              ? presetSampleMap[slot.presetId]
              : null,
          patternId: slot.patternId,
        );
      } else if (slot.slotNumber >= patternSlotStart &&
          slot.slotNumber < sampleSlotStart &&
          slot.patternId != null) {
        // Pattern slot: convert to pattern index.
        final patternIndex = slot.slotNumber - patternSlotStart;
        _patternIds[patternIndex] = slot.patternId;
      }
    }
  }

  void _resetForm() {
    _editingPackId = null;
    _nameController.clear();
    _descriptionController.clear();
    _youtubeUrlController.clear();
    _isPublic = false;
    _wavetableId = defaultWavetableId;
    _patternIds.clear();
    for (var i = 0; i < 32; i++) {
      _slots[i] = (presetId: null, sampleId: null, patternId: null);
    }
  }

  bool get _isEditing => _editingPackId != null;

  @override
  Widget build(BuildContext context) {
    final savedPacksState = ref.watch(savedPacksProvider);

    final editingPack = savedPacksState.editingItem;
    if (editingPack != null && _editingPackId != editingPack.id) {
      _loadPack(editingPack);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(savedPacksProvider.notifier).stopEditing();
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Editing pack',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  PlinkyButton(
                    onPressed: () => setState(_resetForm),
                    icon: Icons.add,
                    label: 'New pack',
                  ),
                ],
              ),
            ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Pack name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _youtubeUrlController,
            decoration: const InputDecoration(
              labelText: 'YouTube URL (optional)',
              hintText: 'https://www.youtube.com/watch?v=...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.play_circle_outline),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Share publicly'),
            value: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value),
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
          SamplesSection(slots: _slots),
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
              onPressed: savedPacksState.isLoading ? null : _savePack,
              icon: Icons.save,
              label: _isEditing ? 'Update Pack' : 'Save Pack',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _savePack() async {
    final uniqueSampleCount = _slots
        .map((slot) => slot.sampleId)
        .whereType<String>()
        .toSet()
        .length;
    if (uniqueSampleCount > sampleCount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A pack can use at most $sampleCount samples. '
              'Currently using $uniqueSampleCount.',
            ),
          ),
        );
      }
      return;
    }

    final slots =
        <
          ({
            int slotNumber,
            String? presetId,
            String? sampleId,
            String? patternId,
          })
        >[];

    // Preset slots (0-31).
    for (var i = 0; i < 32; i++) {
      slots.add((
        slotNumber: presetSlotStart + i,
        presetId: _slots[i].presetId,
        sampleId: null,
        patternId: null,
      ));
    }

    // Pattern slots.
    for (final entry in _patternIds.entries) {
      if (entry.value != null) {
        slots.add((
          slotNumber: patternSlotStart + entry.key,
          presetId: null,
          sampleId: null,
          patternId: entry.value,
        ));
      }
    }

    // Sample slots (56-63) from unique samples in presets.
    final seenSampleIds = <String>{};
    var sampleIndex = 0;
    for (var i = 0; i < 32; i++) {
      final sampleId = _slots[i].sampleId;
      if (sampleId != null && seenSampleIds.add(sampleId)) {
        slots.add((
          slotNumber: sampleSlotStart + sampleIndex,
          presetId: null,
          sampleId: sampleId,
          patternId: null,
        ));
        sampleIndex++;
      }
    }

    if (_isPublic) {
      final userId = ref.read(authenticationProvider).user?.id;
      if (userId != null) {
        final summary = findPrivateItems(
          ref: ref,
          currentUserId: userId,
          slots: slots
              .map(
                (slot) => (
                  presetId: slot.presetId,
                  sampleId: slot.sampleId,
                  patternId: slot.patternId,
                ),
              )
              .toList(),
          wavetableId: _wavetableId,
        );

        if (summary.hasPrivateItems && mounted) {
          final result = await showSharingConflictDialog(
            context,
            summary,
          );
          if (result == null) {
            return;
          }
          if (result == SharingCheckResult.makeAllPublic) {
            await makeItemsPublic(summary);
          } else {
            setState(() => _isPublic = false);
          }
        }
      }
    }

    final notifier = ref.read(savedPacksProvider.notifier);

    if (_isEditing) {
      notifier.updatePackWithSlots(
        _editingPackId!,
        name: _nameController.text,
        description: _descriptionController.text,
        isPublic: _isPublic,
        slots: slots,
        wavetableId: _wavetableId,
        youtubeUrl: _youtubeUrlController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pack updated')),
      );
    } else {
      notifier.savePack(
        _nameController.text,
        description: _descriptionController.text,
        isPublic: _isPublic,
        slots: slots,
        wavetableId: _wavetableId,
        youtubeUrl: _youtubeUrlController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pack saved')),
      );
    }

    setState(_resetForm);
  }
}
