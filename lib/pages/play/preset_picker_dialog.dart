import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/play_notifier.dart';
import 'package:plinkyhub/state/saved_presets_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/widgets/searchable_picker_dialog.dart';

class PresetPickerDialog extends ConsumerStatefulWidget {
  const PresetPickerDialog({super.key});

  @override
  ConsumerState<PresetPickerDialog> createState() => _PresetPickerDialogState();
}

class _PresetPickerDialogState extends ConsumerState<PresetPickerDialog> {
  bool _loading = false;

  Future<void> _loadPreset(SavedPreset preset) async {
    setState(() => _loading = true);

    // Load the preset into the editor state so the player can
    // read scale, stride, octave and other parameters from it.
    ref.read(savedPresetsProvider.notifier).loadPresetIntoEditor(preset);

    // If the preset has an associated sample, load it into the
    // player automatically.
    if (preset.sampleId != null) {
      try {
        final samples =
            ref.read(savedSamplesProvider).userSamples +
            ref.read(savedSamplesProvider).publicSamples;
        final sample = samples
            .where((sample) => sample.id == preset.sampleId)
            .firstOrNull;

        if (sample != null) {
          final wavBytes = await ref
              .read(savedSamplesProvider.notifier)
              .downloadWav(sample.filePath);
          await ref
              .read(playProvider.notifier)
              .loadSample(
                sample.name,
                wavBytes,
                baseMidi: sample.baseNote,
                slicePoints: sample.slicePoints,
                sliceNotes: sample.sliceNotes,
                pitched: sample.pitched,
              );
        }
      } on Exception catch (error) {
        debugPrint('Failed to load associated sample: $error');
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final presetsState = ref.watch(savedPresetsProvider);
    final presets = presetsState.userPresets;
    final currentUserId = ref.watch(authenticationProvider).user?.id;

    if (_loading) {
      return const AlertDialog(
        title: Text('Load Preset'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        ),
        actions: [],
      );
    }

    return SearchablePickerDialog<SavedPreset>(
      title: 'Load Preset',
      items: presets,
      currentUserId: currentUserId,
      emptyMessage: 'No saved presets',
      itemSubtitle: (preset) => preset.category,
      itemLeading: (_) => const Icon(Icons.piano),
      itemTrailing: (preset) => preset.sampleId != null
          ? const Icon(Icons.audio_file, size: 16)
          : const SizedBox.shrink(),
      onSelected: _loadPreset,
    );
  }
}
