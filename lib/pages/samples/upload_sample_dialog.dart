import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/base_note_selector.dart';
import 'package:plinkyhub/pages/samples/sample_mode_selector.dart';
import 'package:plinkyhub/pages/samples/slice_points_editor.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_samples_notifier.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class UploadSampleDialog extends ConsumerStatefulWidget {
  const UploadSampleDialog({super.key});

  @override
  ConsumerState<UploadSampleDialog> createState() =>
      _UploadSampleDialogState();
}

class _UploadSampleDialogState
    extends ConsumerState<UploadSampleDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isUploading = false;
  bool _isConverting = false;
  int _baseNote = 60;
  int _fineTune = 0;
  bool _pitched = false;
  List<double> _slicePoints = List.of(defaultSlicePoints);
  List<int> _sliceNotes = List.of(defaultSliceNotes);
  String? _sampleTooLongWarning;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final name = result.files.single.name;

      setState(() {
        _fileName = name;
        _isConverting = true;
        _sampleTooLongWarning = null;
        if (_nameController.text.isEmpty) {
          _nameController.text = name;
        }
      });

      // Run conversion off the main isolate tick to let the UI
      // update.
      await Future<void>.delayed(Duration.zero);

      String? warning;
      try {
        final pcm = wavToPlinkyPcm(bytes);
        if (pcm.length > maxPcmBytes) {
          final durationSeconds =
              pcm.length ~/ 2 / plinkySampleRate;
          const maxSeconds =
              maxPcmBytes ~/ 2 / plinkySampleRate;
          warning = 'Sample is too long (~${durationSeconds}s). '
              'Plinky supports up to ~${maxSeconds}s per slot '
              'at 31,250 Hz.';
        }
      } on FormatException catch (e) {
        warning = e.message;
      }

      if (mounted) {
        setState(() {
          _fileBytes = bytes;
          _isConverting = false;
          _sampleTooLongWarning = warning;
        });
      }
    }
  }

  Future<void> _upload() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (_fileBytes == null ||
        _fileName == null ||
        userId == null) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final pcmBytes = wavToPlinkyPcm(_fileBytes!);
      final pcmFileName =
          '${_fileName!.substring(0, _fileName!.lastIndexOf('.'))}.pcm';

      final sample = SavedSample(
        id: '',
        userId: userId,
        name: _nameController.text.trim(),
        filePath: '$userId/$_fileName',
        pcmFilePath: '$userId/$pcmFileName',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
        slicePoints: _slicePoints,
        baseNote: _baseNote,
        fineTune: _fineTune,
        pitched: _pitched,
        sliceNotes: _sliceNotes,
      );

      await ref
          .read(savedSamplesProvider.notifier)
          .saveSample(
            sample,
            wavBytes: _fileBytes!,
            pcmBytes: pcmBytes,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample uploaded')),
        );
      }
    } on FormatException catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Sample'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlinkyButton(
                onPressed: _isUploading || _isConverting
                    ? null
                    : _pickFile,
                icon: Icons.audio_file,
                label: _fileName ?? 'Choose file',
              ),
              if (_isConverting) ...[
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Validating sample...'),
                  ],
                ),
              ],
              if (_sampleTooLongWarning != null) ...[
                const SizedBox(height: 8),
                Text(
                  _sampleTooLongWarning!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SampleModeSelector(
                pitched: _pitched,
                enabled: !_isUploading,
                onChanged: (value) =>
                    setState(() => _pitched = value),
              ),
              const SizedBox(height: 16),
              if (!_pitched)
                BaseNoteSelector(
                  baseNote: _baseNote,
                  fineTune: _fineTune,
                  enabled: !_isUploading,
                  onBaseNoteChanged: (value) =>
                      setState(() => _baseNote = value),
                  onFineTuneChanged: (value) =>
                      setState(() => _fineTune = value),
                ),
              if (!_pitched) const SizedBox(height: 16),
              SlicePointsEditor(
                slicePoints: _slicePoints,
                wavBytes: _fileBytes,
                enabled: !_isUploading,
                onChanged: (points) =>
                    setState(() => _slicePoints = points),
                pitched: _pitched,
                sliceNotes: _sliceNotes,
                onSliceNotesChanged: (notes) =>
                    setState(() => _sliceNotes = notes),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Share with community'),
                value: _isPublic,
                onChanged: _isUploading
                    ? null
                    : (value) =>
                        setState(() => _isPublic = value),
              ),
              const SizedBox(height: 8),
              Text(
                'By uploading, you confirm that you own this '
                'sample or have the right to use and distribute '
                'it (e.g. under a Creative Commons licence or '
                'similar terms).',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: _isUploading
              ? null
              : () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
        PlinkyButton(
          onPressed: _isUploading ||
                  _fileBytes == null ||
                  _sampleTooLongWarning != null
              ? null
              : _upload,
          icon: _isUploading
              ? Icons.hourglass_empty
              : Icons.upload,
          label: _isUploading ? 'Uploading...' : 'Upload',
        ),
      ],
    );
  }
}
