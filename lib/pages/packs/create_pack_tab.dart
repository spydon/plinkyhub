import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/pages/packs/pack_sharing_check.dart';
import 'package:plinkyhub/pages/packs/pack_slot_tile.dart';
import 'package:plinkyhub/pages/packs/pattern_picker_dialog.dart';
import 'package:plinkyhub/pages/packs/samples_section.dart';
import 'package:plinkyhub/pages/packs/wavetable_picker_dialog.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/state/saved_patterns_notifier.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class CreatePackTab extends ConsumerStatefulWidget {
  const CreatePackTab({super.key});

  @override
  ConsumerState<CreatePackTab> createState() => _CreatePackTabState();
}

class _CreatePackTabState extends ConsumerState<CreatePackTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  final List<({String? presetId, String? sampleId})> _slots = List.generate(
    32,
    (_) => (presetId: null, sampleId: null),
  );
  String? _editingPackId;
  String? _wavetableId;
  String? _patternId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadPack(SavedPack pack) {
    _editingPackId = pack.id;
    _nameController.text = pack.name;
    _descriptionController.text = pack.description;
    _isPublic = pack.isPublic;
    _wavetableId = pack.wavetableId;
    _patternId = pack.patternId;
    for (var i = 0; i < 32; i++) {
      _slots[i] = (presetId: null, sampleId: null);
    }
    for (final slot in pack.slots) {
      _slots[slot.slotNumber] = (
        presetId: slot.presetId,
        sampleId: slot.sampleId,
      );
    }
  }

  void _resetForm() {
    _editingPackId = null;
    _nameController.clear();
    _descriptionController.clear();
    _isPublic = false;
    _wavetableId = null;
    _patternId = null;
    for (var i = 0; i < 32; i++) {
      _slots[i] = (presetId: null, sampleId: null);
    }
  }

  bool get _isEditing => _editingPackId != null;

  @override
  Widget build(BuildContext context) {
    final savedPacksState = ref.watch(savedPacksProvider);

    final editingPack = savedPacksState.editingPack;
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
          SwitchListTile(
            title: const Text('Share publicly'),
            value: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value),
          ),
          const SizedBox(height: 16),
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
              // Column-major order: 1-8 first column, 9-16 second,
              // etc.
              final row = index ~/ 4;
              final column = index % 4;
              final slotIndex = column * 8 + row;
              return PackSlotTile(
                slotNumber: slotIndex,
                presetId: _slots[slotIndex].presetId,
                sampleId: _slots[slotIndex].sampleId,
                onPresetChanged: (presetId) {
                  setState(() {
                    _slots[slotIndex] = (
                      presetId: presetId,
                      sampleId: _slots[slotIndex].sampleId,
                    );
                  });
                },
                onSampleChanged: (sampleId) {
                  setState(() {
                    _slots[slotIndex] = (
                      presetId: _slots[slotIndex].presetId,
                      sampleId: sampleId,
                    );
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          SamplesSection(slots: _slots),
          const SizedBox(height: 16),
          _WavetableSection(
            wavetableId: _wavetableId,
            onChanged: (wavetableId) =>
                setState(() => _wavetableId = wavetableId),
          ),
          const SizedBox(height: 16),
          _PatternSection(
            patternId: _patternId,
            onChanged: (patternId) => setState(() => _patternId = patternId),
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
    final slots = <({int slotNumber, String? presetId, String? sampleId})>[];
    for (var i = 0; i < 32; i++) {
      slots.add((
        slotNumber: i,
        presetId: _slots[i].presetId,
        sampleId: _slots[i].sampleId,
      ));
    }

    if (_isPublic) {
      final userId = ref.read(authenticationProvider).user?.id;
      if (userId != null) {
        final summary = findPrivateItems(
          ref: ref,
          currentUserId: userId,
          slots: _slots
              .map(
                (slot) => (
                  presetId: slot.presetId,
                  sampleId: slot.sampleId,
                ),
              )
              .toList(),
          wavetableId: _wavetableId,
          patternId: _patternId,
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
        patternId: _patternId,
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
        patternId: _patternId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pack saved')),
      );
    }

    setState(_resetForm);
  }
}

class _WavetableSection extends ConsumerWidget {
  const _WavetableSection({
    required this.wavetableId,
    required this.onChanged,
  });

  final String? wavetableId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wavetablesState = ref.watch(savedWavetablesProvider);
    final wavetableName = wavetableId != null
        ? wavetablesState.userWavetables
                  .where((wavetable) => wavetable.id == wavetableId)
                  .firstOrNull
                  ?.name ??
              wavetablesState.publicWavetables
                  .where(
                    (wavetable) => wavetable.id == wavetableId,
                  )
                  .firstOrNull
                  ?.name
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wavetable',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                wavetableName ?? 'None',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (wavetableId != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Remove wavetable',
                onPressed: () => onChanged(null),
              ),
            PlinkyButton(
              onPressed: () async {
                final allWavetables = {
                  ...wavetablesState.userWavetables,
                  ...wavetablesState.publicWavetables,
                }.toList();
                final selectedId = await showDialog<String>(
                  context: context,
                  builder: (context) => WavetablePickerDialog(
                    wavetables: allWavetables,
                  ),
                );
                if (selectedId != null) {
                  onChanged(selectedId);
                }
              },
              icon: Icons.waves,
              label: 'Choose',
            ),
          ],
        ),
      ],
    );
  }
}

class _PatternSection extends ConsumerWidget {
  const _PatternSection({
    required this.patternId,
    required this.onChanged,
  });

  final String? patternId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternsState = ref.watch(savedPatternsProvider);
    final patternName = patternId != null
        ? patternsState.userPatterns
                  .where((pattern) => pattern.id == patternId)
                  .firstOrNull
                  ?.name ??
              patternsState.publicPatterns
                  .where(
                    (pattern) => pattern.id == patternId,
                  )
                  .firstOrNull
                  ?.name
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patterns',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                patternName ?? 'None',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (patternId != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Remove patterns',
                onPressed: () => onChanged(null),
              ),
            PlinkyButton(
              onPressed: () async {
                final allPatterns = {
                  ...patternsState.userPatterns,
                  ...patternsState.publicPatterns,
                }.toList();
                final selectedId = await showDialog<String>(
                  context: context,
                  builder: (context) => PatternPickerDialog(
                    patterns: allPatterns,
                  ),
                );
                if (selectedId != null) {
                  onChanged(selectedId);
                }
              },
              icon: Icons.grid_view,
              label: 'Choose',
            ),
          ],
        ),
      ],
    );
  }
}
