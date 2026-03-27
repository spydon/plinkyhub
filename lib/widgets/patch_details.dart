import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/patch.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/state/saved_patches_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class PatchDetailsHeader extends ConsumerWidget {
  const PatchDetailsHeader({required this.patch, super.key});

  final Patch patch;

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
              width: 120,
              child: TextField(
                controller: TextEditingController(
                  text: patch.name,
                ),
                maxLength: 8,
                decoration: const InputDecoration(
                  isDense: true,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(plinkyProvider.notifier).patchName = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<PatchCategory>(
                initialValue: patch.category,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                items: PatchCategory.values.map((category) {
                  return DropdownMenuItem<PatchCategory>(
                    value: category,
                    child: Text(
                      category.label.isEmpty ? '(none)' : category.label,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(plinkyProvider.notifier).patchCategory = value;
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            _SaveToCloudButton(patch: patch),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: () {
                ref.read(selectedPageProvider.notifier).selected = 0;
              },
              icon: Icons.play_arrow,
              label: 'Open in player',
            ),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const _RandomizeDialog(),
              ),
              icon: Icons.shuffle,
              label: 'Randomize patch',
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
                  value: patch.arp,
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
                      ref.read(plinkyProvider.notifier).patchArp = value;
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
                  value: patch.latch,
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
                      ref.read(plinkyProvider.notifier).patchLatch = value;
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
                  'Loop start: ${patch.loopStart}',
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
                  'Loop length: ${patch.loopLength}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            if (patch.usesSample)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.audio_file, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Sample #${patch.sampleSlot}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _SaveToCloudButton extends ConsumerWidget {
  const _SaveToCloudButton({required this.patch});

  final Patch patch;

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
    final descriptionController = TextEditingController();
    var isPublic = false;
    String? selectedSampleId;
    final sourcePatchId = plinkyState.sourcePatchId;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final samples =
              ref.read(savedSamplesProvider).userSamples;
          return AlertDialog(
            title: Text(
              'Save "${patch.name.isEmpty ? '(unnamed)' : patch.name}"'
              ' to cloud',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: selectedSampleId,
                  decoration: const InputDecoration(
                    labelText: 'Sample (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      child: Text('No sample'),
                    ),
                    ...samples.map((sample) {
                      return DropdownMenuItem<String?>(
                        value: sample.id,
                        child: Text(
                          sample.name.isEmpty
                              ? '(unnamed)'
                              : sample.name,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setDialogState(
                      () => selectedSampleId = value,
                    );
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Share publicly'),
                  subtitle: const Text(
                    'Allow others to find and load this patch',
                  ),
                  value: isPublic,
                  onChanged: (value) {
                    setDialogState(() => isPublic = value);
                  },
                ),
              ],
            ),
            actions: [
              PlinkyButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icons.close,
                label: 'Cancel',
              ),
              if (sourcePatchId != null)
                PlinkyButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref
                        .read(savedPatchesProvider.notifier)
                        .overwritePatch(
                          sourcePatchId,
                          patch,
                          description:
                              descriptionController.text.isEmpty
                                  ? null
                                  : descriptionController.text,
                          sampleId: selectedSampleId,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Patch overwritten'),
                      ),
                    );
                  },
                  icon: Icons.save,
                  label: 'Overwrite',
                ),
              PlinkyButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(savedPatchesProvider.notifier)
                      .savePatch(
                        patch,
                        description: descriptionController.text,
                        isPublic: isPublic,
                        sampleId: selectedSampleId,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patch saved to cloud'),
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
      title: const Text('Randomize patch'),
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
                      .randomizePatch(_selectedGroups.toList());
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
