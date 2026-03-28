import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/play_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/searchable_picker_dialog.dart';

class SamplePickerDialog extends ConsumerStatefulWidget {
  const SamplePickerDialog({super.key});

  @override
  ConsumerState<SamplePickerDialog> createState() => _SamplePickerDialogState();
}

class _SamplePickerDialogState extends ConsumerState<SamplePickerDialog> {
  bool _loading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() => _loading = true);
      await ref
          .read(playProvider.notifier)
          .loadSample(
            result.files.single.name,
            result.files.single.bytes!,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _loadSaved(SavedSample sample) async {
    setState(() => _loading = true);
    try {
      debugPrint('Downloading WAV: ${sample.filePath}');
      final bytes = await ref
          .read(savedSamplesProvider.notifier)
          .downloadWav(sample.filePath);
      debugPrint('Downloaded ${bytes.length} bytes, loading into player...');
      await ref
          .read(playProvider.notifier)
          .loadSample(
            sample.name,
            bytes,
            baseMidi: sample.baseNote,
            slicePoints: sample.slicePoints,
            sliceNotes: sample.sliceNotes,
            pitched: sample.pitched,
          );
      debugPrint('Sample loaded into player');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      debugPrint('Failed to load saved sample: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sample: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final samplesState = ref.watch(savedSamplesProvider);
    final samples = samplesState.userSamples;
    final currentUserId = ref.watch(authenticationProvider).user?.id;

    if (_loading) {
      return const AlertDialog(
        title: Text('Load Sample'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        ),
        actions: [],
      );
    }

    return SearchablePickerDialog<SavedSample>(
      title: 'Load Sample',
      items: samples,
      currentUserId: currentUserId,
      emptyMessage: 'No saved samples',
      itemLeading: (_) => const Icon(Icons.audio_file),
      headerWidget: PlinkyButton(
        onPressed: _pickFile,
        icon: Icons.file_open,
        label: 'Upload WAV file',
      ),
      onSelected: _loadSaved,
    );
  }
}
