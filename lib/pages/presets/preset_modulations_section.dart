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

    final knobAEntries = _collectEntries(preset, (m) => m.a);
    final knobBEntries = _collectEntries(preset, (m) => m.b);
    final accelerometerXEntries = _collectEntries(preset, (m) => m.x);
    final accelerometerYEntries = _collectEntries(preset, (m) => m.y);

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _KnobRow(
                  leftLabel: 'Knob A',
                  leftEntries: knobAEntries,
                  rightLabel: 'Knob B',
                  rightEntries: knobBEntries,
                  isNarrow: isNarrow,
                ),
                if (accelerometerXEntries.isNotEmpty ||
                    accelerometerYEntries.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _KnobRow(
                    leftLabel: 'Accelerometer X',
                    leftEntries: accelerometerXEntries,
                    rightLabel: 'Accelerometer Y',
                    rightEntries: accelerometerYEntries,
                    isNarrow: isNarrow,
                    hideEmptySides: true,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

List<_ModulationEntry> _collectEntries(
  Preset preset,
  int Function(ParameterModulations modulations) selector,
) {
  final entries = <_ModulationEntry>[];
  for (final parameter in preset.parameters) {
    final amount = selector(parameter.modulations);
    if (amount != 0) {
      entries.add(_ModulationEntry(parameter: parameter, amount: amount));
    }
  }
  entries.sort((a, b) => b.absoluteAmount.compareTo(a.absoluteAmount));
  return entries;
}

class _ModulationEntry {
  const _ModulationEntry({required this.parameter, required this.amount});

  final Parameter parameter;
  final int amount;

  int get absoluteAmount => amount.abs();
}

class _KnobRow extends StatelessWidget {
  const _KnobRow({
    required this.leftLabel,
    required this.leftEntries,
    required this.rightLabel,
    required this.rightEntries,
    required this.isNarrow,
    this.hideEmptySides = false,
  });

  final String leftLabel;
  final List<_ModulationEntry> leftEntries;
  final String rightLabel;
  final List<_ModulationEntry> rightEntries;
  final bool isNarrow;
  final bool hideEmptySides;

  @override
  Widget build(BuildContext context) {
    final showLeft = !hideEmptySides || leftEntries.isNotEmpty;
    final showRight = !hideEmptySides || rightEntries.isNotEmpty;

    final leftColumn = showLeft
        ? _KnobColumn(label: leftLabel, entries: leftEntries)
        : null;
    final rightColumn = showRight
        ? _KnobColumn(label: rightLabel, entries: rightEntries)
        : null;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leftColumn != null) leftColumn,
          if (leftColumn != null && rightColumn != null)
            const SizedBox(height: 12),
          if (rightColumn != null) rightColumn,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: leftColumn ?? const SizedBox.shrink()),
        const SizedBox(width: 16),
        Expanded(child: rightColumn ?? const SizedBox.shrink()),
      ],
    );
  }
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
