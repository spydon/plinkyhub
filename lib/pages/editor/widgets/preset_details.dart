import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/plinky_state.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/my_plinky/providers/my_plinky_notifier.dart';
import 'package:plinkyhub/pages/my_plinky/save_device_sample_dialog.dart';
import 'package:plinkyhub/pages/packs/sample_picker_dialog.dart';
import 'package:plinkyhub/pages/presets/providers/saved_presets_notifier.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PresetDetailsHeader extends ConsumerWidget {
  const PresetDetailsHeader({required this.preset, super.key});

  final Preset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameters',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: TextEditingController(
                  text: preset.name,
                ),
                maxLength: 8,
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(plinkyProvider.notifier).presetName = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<PresetCategory>(
                initialValue: preset.category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: PresetCategory.values.map((category) {
                  return DropdownMenuItem<PresetCategory>(
                    value: category,
                    child: Text(
                      category.label.isEmpty ? '(none)' : category.label,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(plinkyProvider.notifier).presetCategory = value;
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            _SaveToCloudButton(preset: preset),
            const SizedBox(width: 8),
            _SaveToMyPlinkyButton(preset: preset),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const _RandomizeDialog(),
              ),
              icon: Icons.shuffle,
              label: 'Randomize preset',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.music_note, size: 20),
                const SizedBox(width: 4),
                DropdownButton<bool>(
                  value: preset.arp,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Arp: On', style: TextStyle(fontSize: 15)),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Arp: Off', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(plinkyProvider.notifier).presetArp = value;
                    }
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 20),
                const SizedBox(width: 4),
                DropdownButton<bool>(
                  value: preset.latch,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Latch: On', style: TextStyle(fontSize: 15)),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('Latch: Off', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(plinkyProvider.notifier).presetLatch = value;
                    }
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.first_page, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Loop start: ${preset.loopStart}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.straighten, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Loop length: ${preset.loopLength}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            if (preset.usesSample) _SampleIndicator(preset: preset),
          ],
        ),
      ],
    );
  }
}

class _SampleIndicator extends ConsumerWidget {
  const _SampleIndicator({required this.preset});

  final Preset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceSampleId = ref.watch(
      plinkyProvider.select((state) => state.sourceSampleId),
    );
    final samplesState = ref.watch(savedSamplesProvider);
    final sampleName = sourceSampleId != null
        ? [...samplesState.userItems, ...samplesState.publicItems]
                  .where((sample) => sample.id == sourceSampleId)
                  .firstOrNull
                  ?.name ??
              '(unknown)'
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.audio_file, size: 20),
        const SizedBox(width: 4),
        Text(
          sampleName != null
              ? 'Sample: $sampleName'
              : 'Sample #${preset.sampleSlot}',
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}

class _SaveToCloudButton extends ConsumerWidget {
  const _SaveToCloudButton({required this.preset});

  final Preset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plinkyState = ref.watch(plinkyProvider);
    final isSignedIn = ref.watch(authenticationProvider).user != null;

    return PlinkyButton(
      onPressed: isSignedIn
          ? () => _showSaveDialog(context, ref, plinkyState)
          : null,
      icon: Icons.cloud_upload,
      label: isSignedIn ? 'Save to cloud' : 'Sign in to save',
    );
  }

  void _showSaveDialog(
    BuildContext context,
    WidgetRef ref,
    PlinkyState plinkyState,
  ) {
    final nameController = TextEditingController(text: preset.name);
    final descriptionController = TextEditingController();
    final youtubeUrlController = TextEditingController();
    final sourcePresetId = plinkyState.sourcePresetId;
    final userPresets = ref.read(savedPresetsProvider).userItems;

    // When overwriting an existing preset, inherit its public setting;
    // otherwise default to public.
    final sourcePreset = sourcePresetId != null
        ? userPresets.where((p) => p.id == sourcePresetId).firstOrNull
        : null;
    var isPublic = sourcePreset?.isPublic ?? true;
    var selectedSampleId = sourcePreset?.sampleId ?? plinkyState.sourceSampleId;
    if (sourcePreset != null) {
      descriptionController.text = sourcePreset.description;
      youtubeUrlController.text = sourcePreset.youtubeUrl;
    }

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final samples = ref.read(savedSamplesProvider).userItems;
          final name = nameController.text.trim();
          final existingByName = userPresets
              .where(
                (p) => p.name == name && p.id != sourcePresetId,
              )
              .firstOrNull;
          final canOverwriteSource = sourcePresetId != null;
          final canOverwriteByName = existingByName != null;

          return AlertDialog(
            title: const Text('Save preset to cloud'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 8,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 3,
                    maxLines: null,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: youtubeUrlController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube URL (optional)',
                      hintText: 'https://www.youtube.com/watch?v=...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.play_circle_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SampleSelector(
                    samples: samples,
                    selectedSampleId: selectedSampleId,
                    currentUserId: ref.read(authenticationProvider).user?.id,
                    onChanged: (value) {
                      setDialogState(
                        () => selectedSampleId = value,
                      );
                    },
                  ),
                  if (preset.usesSample && selectedSampleId == null)
                    _SampleMissingWarning(
                      preset: preset,
                      onSampleSaved: (sampleId) {
                        setDialogState(
                          () => selectedSampleId = sampleId,
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Share publicly'),
                    subtitle: const Text(
                      'Allow others to find and load this preset',
                    ),
                    value: isPublic,
                    onChanged: (value) {
                      setDialogState(() => isPublic = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              PlinkyButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icons.close,
                label: 'Cancel',
              ),
              if (canOverwriteSource)
                PlinkyButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    preset.name = nameController.text;
                    ref
                        .read(savedPresetsProvider.notifier)
                        .overwritePreset(
                          sourcePresetId,
                          preset,
                          description: descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                          isPublic: isPublic,
                          youtubeUrl: youtubeUrlController.text.trim(),
                          sampleId: selectedSampleId,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preset overwritten'),
                      ),
                    );
                  },
                  icon: Icons.save,
                  label: 'Overwrite',
                ),
              if (canOverwriteByName)
                PlinkyButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    preset.name = nameController.text;
                    ref
                        .read(savedPresetsProvider.notifier)
                        .overwritePreset(
                          existingByName.id,
                          preset,
                          description: descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                          isPublic: isPublic,
                          youtubeUrl: youtubeUrlController.text.trim(),
                          sampleId: selectedSampleId,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preset overwritten'),
                      ),
                    );
                  },
                  icon: Icons.save,
                  label: 'Overwrite "${existingByName.name}"',
                ),
              if (!canOverwriteByName)
                PlinkyButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    preset.name = nameController.text;
                    ref
                        .read(savedPresetsProvider.notifier)
                        .savePreset(
                          preset,
                          description: descriptionController.text,
                          isPublic: isPublic,
                          youtubeUrl: youtubeUrlController.text.trim(),
                          sampleId: selectedSampleId,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preset saved to cloud'),
                      ),
                    );
                  },
                  icon: Icons.add,
                  label: 'Save new',
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SaveToMyPlinkyButton extends ConsumerWidget {
  const _SaveToMyPlinkyButton({required this.preset});

  final Preset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editingSlotIndex = ref.watch(
      myPlinkyProvider.select((state) => state.editingSlotIndex),
    );
    if (editingSlotIndex == null) {
      return const SizedBox.shrink();
    }

    return PlinkyButton(
      onPressed: () {
        final copiedBytes = Uint8List.fromList(
          preset.buffer.asUint8List(),
        );
        final presetCopy = Preset(copiedBytes.buffer);
        ref
            .read(myPlinkyProvider.notifier)
            .updatePresetFromEditor(editingSlotIndex, presetCopy);
        context.go(AppRoute.myPlinky.path);
      },
      icon: Icons.save,
      label: 'Save to My Plinky',
    );
  }
}

class _SampleMissingWarning extends ConsumerWidget {
  const _SampleMissingWarning({
    required this.preset,
    required this.onSampleSaved,
  });

  final Preset preset;
  final ValueChanged<String> onSampleSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPlinkyState = ref.watch(myPlinkyProvider);
    final sampleSlot = preset.sampleSlot;
    final hasPcmData =
        sampleSlot >= 0 &&
        myPlinkyState.deviceSamplePcmData.containsKey(sampleSlot);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This preset uses a sample that has not '
                  'been saved to the cloud. Save the sample '
                  'first so others can use this preset.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (hasPcmData)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: PlinkyButton(
                onPressed: () async {
                  final pcmBytes =
                      myPlinkyState.deviceSamplePcmData[sampleSlot]!;
                  final sampleInfo =
                      myPlinkyState.parsedFlashImage?.sampleInfos[sampleSlot];
                  final sampleId = await showDialog<String>(
                    context: context,
                    builder: (context) => SaveDeviceSampleDialog(
                      pcmBytes: pcmBytes,
                      sampleInfo: sampleInfo,
                    ),
                  );
                  if (sampleId != null) {
                    onSampleSaved(sampleId);
                  }
                },
                icon: Icons.cloud_upload,
                label: 'Save sample to cloud',
              ),
            ),
        ],
      ),
    );
  }
}

class _RandomizeDialog extends ConsumerStatefulWidget {
  const _RandomizeDialog();

  @override
  ConsumerState<_RandomizeDialog> createState() => _RandomizeDialogState();
}

class _RandomizeDialogState extends ConsumerState<_RandomizeDialog> {
  final Set<RandomizeGroup> _selectedGroups = Set.of(RandomizeGroup.values);

  void _selectAll() {
    setState(() {
      _selectedGroups.addAll(RandomizeGroup.values);
    });
  }

  void _clearAll() {
    setState(_selectedGroups.clear);
  }

  void _onGroupToggled({
    required RandomizeGroup group,
    required bool selected,
  }) {
    setState(() {
      if (selected) {
        _selectedGroups.add(group);
      } else {
        _selectedGroups.remove(group);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Randomize preset'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select which parameter groups to randomize.',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RandomizeGroupSection(
                          title: 'Synth',
                          groups: const [RandomizeGroup.synth],
                          selected: _selectedGroups,
                          onChanged: _onGroupToggled,
                        ),
                        const SizedBox(height: 16),
                        _RandomizeGroupSection(
                          title: 'Envelope',
                          groups: const [
                            RandomizeGroup.envelope1,
                            RandomizeGroup.envelope2,
                          ],
                          selected: _selectedGroups,
                          onChanged: _onGroupToggled,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RandomizeGroupSection(
                          title: 'Effects',
                          groups: const [RandomizeGroup.effects],
                          selected: _selectedGroups,
                          onChanged: _onGroupToggled,
                        ),
                        const SizedBox(height: 16),
                        _RandomizeGroupSection(
                          title: 'Arp / Seq',
                          groups: const [
                            RandomizeGroup.arpeggiator,
                            RandomizeGroup.sequencer,
                          ],
                          selected: _selectedGroups,
                          onChanged: _onGroupToggled,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RandomizeGroupSection(
                          title: 'Sampler',
                          groups: const [RandomizeGroup.sampler],
                          selected: _selectedGroups,
                          onChanged: _onGroupToggled,
                        ),
                        const SizedBox(height: 16),
                        _RandomizeGroupSection(
                          title: 'Modulation',
                          groups: const [
                            RandomizeGroup.modA,
                            RandomizeGroup.modB,
                            RandomizeGroup.modX,
                            RandomizeGroup.modY,
                          ],
                          selected: _selectedGroups,
                          onChanged: _onGroupToggled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value:
                          _selectedGroups.length == RandomizeGroup.values.length
                          ? true
                          : _selectedGroups.isEmpty
                          ? false
                          : null,
                      tristate: true,
                      onChanged: (value) {
                        if (value == true) {
                          _selectAll();
                        } else {
                          _clearAll();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Select all'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
        PlinkyButton(
          onPressed: _selectedGroups.isEmpty
              ? null
              : () {
                  ref
                      .read(plinkyProvider.notifier)
                      .randomizePreset(_selectedGroups.toList());
                  Navigator.of(context).pop();
                },
          icon: Icons.shuffle,
          label: 'Randomize',
        ),
      ],
    );
  }
}

class _RandomizeGroupSection extends StatelessWidget {
  const _RandomizeGroupSection({
    required this.title,
    required this.groups,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<RandomizeGroup> groups;
  final Set<RandomizeGroup> selected;
  final void Function({
    required RandomizeGroup group,
    required bool selected,
  })
  onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...groups.map((group) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: selected.contains(group),
                    onChanged: (value) => onChanged(
                      group: group,
                      selected: value ?? false,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(group.displayName),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SampleSelector extends StatelessWidget {
  const _SampleSelector({
    required this.samples,
    required this.selectedSampleId,
    required this.currentUserId,
    required this.onChanged,
  });

  final List<SavedSample> samples;
  final String? selectedSampleId;
  final String? currentUserId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedName = selectedSampleId != null
        ? samples
                  .where((s) => s.id == selectedSampleId)
                  .map((s) => s.name.isEmpty ? '(unnamed)' : s.name)
                  .firstOrNull ??
              'Unknown sample'
        : 'No sample';

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Sample (optional)',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(child: Text(selectedName)),
          if (selectedSampleId != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => onChanged(null),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () async {
              final result = await showDialog<SavedSample>(
                context: context,
                builder: (context) => SamplePickerDialog(
                  samples: samples,
                  currentUserId: currentUserId,
                ),
              );
              if (result != null) {
                onChanged(result.id);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
