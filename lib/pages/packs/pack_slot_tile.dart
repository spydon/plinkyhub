import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/packs/preset_picker_dialog.dart';
import 'package:plinkyhub/pages/packs/sample_picker_dialog.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';

class PackSlotTile extends ConsumerWidget {
  const PackSlotTile({
    required this.slotNumber,
    required this.presetId,
    required this.sampleId,
    required this.onPresetChanged,
    required this.onSampleChanged,
    super.key,
  });

  final int slotNumber;
  final String? presetId;
  final String? sampleId;
  final ValueChanged<String?> onPresetChanged;
  final ValueChanged<String?> onSampleChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presets = ref.watch(
      savedPresetsProvider.select((state) => state.userPresets),
    );
    final samples = ref.watch(
      savedSamplesProvider.select((state) => state.userSamples),
    );

    final presetName = presetId != null
        ? presets
                  .where((preset) => preset.id == presetId)
                  .firstOrNull
                  ?.name ??
              '(unknown)'
        : 'Empty';
    final sampleName = sampleId != null
        ? samples
                  .where((sample) => sample.id == sampleId)
                  .firstOrNull
                  ?.name ??
              '(unknown)'
        : 'None';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPresetPicker(context, presets),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${slotNumber + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presetName,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sampleName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'preset',
                    child: Text('Pick preset'),
                  ),
                  const PopupMenuItem(
                    value: 'sample',
                    child: Text('Pick sample'),
                  ),
                  if (presetId != null || sampleId != null)
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear slot'),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'preset':
                      _showPresetPicker(context, presets);
                    case 'sample':
                      _showSamplePicker(context, samples);
                    case 'clear':
                      onPresetChanged(null);
                      onSampleChanged(null);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetPicker(
    BuildContext context,
    List<SavedPreset> presets,
  ) {
    showDialog<String>(
      context: context,
      builder: (context) => PresetPickerDialog(presets: presets),
    ).then((selectedId) {
      if (selectedId != null) {
        onPresetChanged(selectedId);
      }
    });
  }

  void _showSamplePicker(
    BuildContext context,
    List<SavedSample> samples,
  ) {
    showDialog<String>(
      context: context,
      builder: (context) =>
          SamplePickerDialog(samples: samples),
    ).then((selectedId) {
      if (selectedId != null) {
        onSampleChanged(selectedId);
      }
    });
  }
}
