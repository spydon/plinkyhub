import 'package:flutter/material.dart';

class SampleModeSelector extends StatelessWidget {
  const SampleModeSelector({
    required this.pitched,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool pitched;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Mode',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Tape')),
            ButtonSegment(value: true, label: Text('Pitched')),
          ],
          selected: {pitched},
          onSelectionChanged: enabled
              ? (selection) => onChanged(selection.first)
              : null,
        ),
      ],
    );
  }
}
