import 'package:flutter/material.dart';
import 'package:plinkyhub/utils/note_names.dart';

class BaseNoteSelector extends StatelessWidget {
  const BaseNoteSelector({
    required this.baseNote,
    required this.fineTune,
    required this.enabled,
    required this.onBaseNoteChanged,
    required this.onFineTuneChanged,
    super.key,
  });

  final int baseNote;
  final int fineTune;
  final bool enabled;
  final ValueChanged<int> onBaseNoteChanged;
  final ValueChanged<int> onFineTuneChanged;

  @override
  Widget build(BuildContext context) {
    final noteName = noteNames[baseNote % 12];
    final octave = (baseNote ~/ 12) - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base note',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<int>(
              value: baseNote % 12,
              onChanged: enabled
                  ? (value) {
                      if (value != null) {
                        onBaseNoteChanged(
                          (baseNote ~/ 12) * 12 + value,
                        );
                      }
                    }
                  : null,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text(noteNames[index]),
                );
              }),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: baseNote ~/ 12,
              onChanged: enabled
                  ? (value) {
                      if (value != null) {
                        onBaseNoteChanged(
                          value * 12 + baseNote % 12,
                        );
                      }
                    }
                  : null,
              items: List.generate(10, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text('${index - 1}'),
                );
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Fine tune: $fineTune cents',
                    style:
                        Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: fineTune.toDouble(),
                    min: -50,
                    max: 50,
                    divisions: 100,
                    label: '$fineTune c',
                    onChanged: enabled
                        ? (value) =>
                            onFineTuneChanged(value.round())
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          '$noteName$octave'
          '${fineTune != 0 ? ' (${fineTune > 0 ? '+' : ''}${fineTune}c)' : ''}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
