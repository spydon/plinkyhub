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

  static const _labels = {
    SampleLoopMode.oneShotSlice: 'One-shot, slice',
    SampleLoopMode.loopSlice: 'Loop, slice',
    SampleLoopMode.oneShotAll: 'One-shot, all',
    SampleLoopMode.loopAll: 'Loop, all',
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SampleLoopMode>(
      initialValue: loopMode,
      decoration: const InputDecoration(
        labelText: 'Loop mode',
        border: OutlineInputBorder(),
      ),
      items: SampleLoopMode.values
          .map(
            (mode) => DropdownMenuItem(
              value: mode,
              child: Text(_labels[mode]!),
            ),
          )
          .toList(),
      onChanged: enabled ? (value) => onChanged(value!) : null,
    );
  }
}
