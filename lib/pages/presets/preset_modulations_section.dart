import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plinkyhub/models/parameter.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/utils/format.dart';

class PresetModulationsSection extends StatelessWidget {
  const PresetModulationsSection({required this.savedPreset, super.key});

  final SavedPreset savedPreset;

  @override
  Widget build(BuildContext context) {
    final Preset preset;
    try {
      final bytes = base64Decode(savedPreset.presetData);
      preset = Preset(Uint8List.fromList(bytes).buffer);
    } on FormatException {
      return const SizedBox.shrink();
    }

    final knobAEntries = <_ModulationEntry>[];
    final knobBEntries = <_ModulationEntry>[];
    for (final parameter in preset.parameters) {
      if (parameter.modulations.a != 0) {
        knobAEntries.add(
          _ModulationEntry(
            parameter: parameter,
            amount: parameter.modulations.a,
          ),
        );
      }
      if (parameter.modulations.b != 0) {
        knobBEntries.add(
          _ModulationEntry(
            parameter: parameter,
            amount: parameter.modulations.b,
          ),
        );
      }
    }

    knobAEntries.sort((a, b) => b.absoluteAmount.compareTo(a.absoluteAmount));
    knobBEntries.sort((a, b) => b.absoluteAmount.compareTo(a.absoluteAmount));

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final knobAColumn = _KnobColumn(
              label: 'Knob A',
              entries: knobAEntries,
            );
            final knobBColumn = _KnobColumn(
              label: 'Knob B',
              entries: knobBEntries,
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  knobAColumn,
                  const SizedBox(height: 12),
                  knobBColumn,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: knobAColumn),
                const SizedBox(width: 16),
                Expanded(child: knobBColumn),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModulationEntry {
  const _ModulationEntry({required this.parameter, required this.amount});

  final Parameter parameter;
  final int amount;

  int get absoluteAmount => amount.abs();
}

class _KnobColumn extends StatelessWidget {
  const _KnobColumn({required this.label, required this.entries});

  final String label;
  final List<_ModulationEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        if (entries.isEmpty)
          Text(
            'No modulations',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.parameter.name ?? entry.parameter.id,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatSignedAmount(entry.amount),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _formatSignedAmount(int amount) {
  final formatted = formatValue(amount);
  if (amount > 0 && !formatted.startsWith('+')) {
    return '+$formatted';
  }
  return formatted;
}
