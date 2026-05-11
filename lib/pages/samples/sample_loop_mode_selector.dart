import 'package:flutter/material.dart';
import 'package:plinkyhub/models/sample_loop_mode.dart';

class SampleLoopModeSelector extends StatelessWidget {
  const SampleLoopModeSelector({
    required this.loopMode,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final SampleLoopMode loopMode;
  final bool enabled;
  final ValueChanged<SampleLoopMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loop',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SampleLoopMode>(
          segments: const [
            ButtonSegment(
              value: SampleLoopMode.oneShotSlice,
              label: Text('One-shot\nslice', textAlign: TextAlign.center),
            ),
            ButtonSegment(
              value: SampleLoopMode.loopSlice,
              label: Text('Loop\nslice', textAlign: TextAlign.center),
            ),
            ButtonSegment(
              value: SampleLoopMode.oneShotAll,
              label: Text('One-shot\nall', textAlign: TextAlign.center),
            ),
            ButtonSegment(
              value: SampleLoopMode.loopAll,
              label: Text('Loop\nall', textAlign: TextAlign.center),
            ),
          ],
          selected: {loopMode},
          onSelectionChanged: enabled
              ? (selection) => onChanged(selection.first)
              : null,
        ),
      ],
    );
  }
}
