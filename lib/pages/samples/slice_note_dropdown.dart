import 'package:flutter/material.dart';
import 'package:plinkyhub/utils/note_names.dart';

/// Compact note selector for a single slice in pitched mode.
///
/// Plinky uses note values 0-96 where value + 12 gives the MIDI
/// note number.
class SliceNoteDropdown extends StatelessWidget {
  const SliceNoteDropdown({
    required this.note,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  /// Plinky note value (0-96).
  final int note;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final noteName = noteNames[note % 12];
    final octave = (note + 12) ~/ 12 - 1;

    return SizedBox(
      width: 72,
      child: DropdownButton<int>(
        value: note,
        isExpanded: true,
        isDense: true,
        onChanged: enabled
            ? (value) {
                if (value != null) {
                  onChanged(value);
                }
              }
            : null,
        items: List.generate(97, (index) {
          final itemNoteName = noteNames[index % 12];
          final itemOctave = (index + 12) ~/ 12 - 1;
          return DropdownMenuItem(
            value: index,
            child: Text('$itemNoteName$itemOctave'),
          );
        }),
        selectedItemBuilder: (context) {
          return List.generate(97, (_) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$noteName$octave',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          });
        },
      ),
    );
  }
}
