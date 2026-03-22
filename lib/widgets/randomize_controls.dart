import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class RandomizeControls extends ConsumerStatefulWidget {
  const RandomizeControls({super.key});

  @override
  ConsumerState<RandomizeControls> createState() =>
      _RandomizeControlsState();
}

class _RandomizeControlsState
    extends ConsumerState<RandomizeControls> {
  final Set<RandomizeGroup> _selectedGroups =
      Set.of(RandomizeGroup.values);

  void _selectAll() {
    setState(() {
      _selectedGroups.addAll(RandomizeGroup.values);
    });
  }

  void _clearAll() {
    setState(_selectedGroups.clear);
  }

  void _randomize() {
    ref
        .read(plinkyProvider.notifier)
        .randomizePatch(_selectedGroups.toList());
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Randomize patch',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        const Text(
          'This will randomize the patch in the browser '
          'memory - if you want to transfer it over to '
          'Plinky, press "Save patch".',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            PlinkyButton(
              onPressed: _selectAll,
              icon: Icons.select_all,
              label: 'Select all',
            ),
            const SizedBox(width: 8),
            PlinkyButton(
              onPressed: _clearAll,
              icon: Icons.deselect,
              label: 'Clear all',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _RandomizeGroupSection(
              title: 'Synth',
              groups: const [RandomizeGroup.synth],
              selected: _selectedGroups,
              onChanged: _onGroupToggled,
            ),
            _RandomizeGroupSection(
              title: 'Envelope',
              groups: const [
                RandomizeGroup.envelope1,
                RandomizeGroup.envelope2,
              ],
              selected: _selectedGroups,
              onChanged: _onGroupToggled,
            ),
            _RandomizeGroupSection(
              title: 'Effects',
              groups: const [RandomizeGroup.effects],
              selected: _selectedGroups,
              onChanged: _onGroupToggled,
            ),
            _RandomizeGroupSection(
              title: 'Arp / Seq',
              groups: const [
                RandomizeGroup.arpeggiator,
                RandomizeGroup.sequencer,
              ],
              selected: _selectedGroups,
              onChanged: _onGroupToggled,
            ),
            _RandomizeGroupSection(
              title: 'Sampler',
              groups: const [RandomizeGroup.sampler],
              selected: _selectedGroups,
              onChanged: _onGroupToggled,
            ),
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
        const SizedBox(height: 16),
        PlinkyButton(
          onPressed: _randomize,
          icon: Icons.shuffle,
          label: 'Randomize these parameters',
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
  }) onChanged;

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
