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
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class UploadSampleTab extends ConsumerStatefulWidget {
  const UploadSampleTab({this.onUploaded, super.key});

  final VoidCallback? onUploaded;

  @override
  ConsumerState<UploadSampleTab> createState() => _UploadSampleTabState();
}

class _UploadSampleTabState extends ConsumerState<UploadSampleTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  Uint8List? _wavBytes;
  String? _fileName;
  Uint8List? _sampleUf2Bytes;
  String? _sampleUf2FileName;
  Uint8List? _presetsUf2Bytes;
  bool _isUploading = false;
  bool _isConverting = false;
  int _baseNote = 60;
  int _fineTune = 0;
  bool _pitched = false;
  List<double> _slicePoints = List.of(defaultSlicePoints);
  List<int> _sliceNotes = List.of(defaultSliceNotes);
  int? _pcmFrameCount;
  String? _sampleTooLongWarning;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _isPublic = true;
      _wavBytes = null;
      _fileName = null;
      _sampleUf2Bytes = null;
      _sampleUf2FileName = null;
      _presetsUf2Bytes = null;
      _isUploading = false;
      _isConverting = false;
      _baseNote = 60;
      _fineTune = 0;
      _pitched = false;
      _slicePoints = List.of(defaultSlicePoints);
      _sliceNotes = List.of(defaultSliceNotes);
      _pcmFrameCount = null;
      _sampleTooLongWarning = null;
    });
  }

  Future<void> _pickWavFile() async {
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

      await Future<void>.delayed(Duration.zero);

      String? warning;
      int? frameCount;
      try {
        final pcm = wavToPlinkyPcm(bytes);
        frameCount = pcm.length ~/ 2;
        if (pcm.length > maxPcmBytes) {
          final durationSeconds = pcm.length ~/ 2 / plinkySampleRate;
          const maxSeconds = maxPcmBytes ~/ 2 / plinkySampleRate;
          warning =
              'Sample is too long (~${durationSeconds}s). '
              'Plinky supports up to ~${maxSeconds}s per slot '
              'at 31,250 Hz.';
        }
      } on FormatException catch (e) {
        warning = e.message;
      }

      if (mounted) {
        setState(() {
          _wavBytes = bytes;
          _pcmFrameCount = frameCount;
          _isConverting = false;
          _sampleTooLongWarning = warning;
        });
      }
    }
  }

  Future<void> _pickSampleUf2() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['uf2', 'UF2'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) {
      return;
    }

    final file = result.files.single;
    final upperName = file.name.toUpperCase();
    if (!upperName.startsWith('SAMPLE') || !upperName.endsWith('.UF2')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a SAMPLEx.UF2 file '
              '(e.g. SAMPLE0.UF2)',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _sampleUf2Bytes = file.bytes;
      _sampleUf2FileName = file.name;
    });

    await _processUf2Files();
  }

  Future<void> _pickPresetsUf2() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['uf2', 'UF2'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) {
      return;
    }

    final upperName = result.files.single.name.toUpperCase();
    if (upperName != 'PRESETS.UF2') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a PRESETS.UF2 file',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _presetsUf2Bytes = result.files.single.bytes;
    });

    // Re-process if we already have a sample UF2 loaded.
    if (_sampleUf2Bytes != null) {
      await _processUf2Files();
    }
  }

  Future<void> _processUf2Files() async {
    if (_sampleUf2Bytes == null) {
      return;
    }

    setState(() {
      _isConverting = true;
      _sampleTooLongWarning = null;
    });

    await Future<void>.delayed(Duration.zero);

    try {
      final pcmBytes = uf2ToData(_sampleUf2Bytes!);
      if (pcmBytes.isEmpty) {
        throw const FormatException(
          'The sample UF2 file contains no data.',
        );
      }

      final slotIndex = _parseSlotIndexFromFilename(_sampleUf2FileName!);

      final wavBytes = plinkyPcmToWav(pcmBytes);
      final frameCount = pcmBytes.length ~/ 2;

      String? warning;
      if (pcmBytes.length > maxPcmBytes) {
        final durationSeconds = pcmBytes.length ~/ 2 / plinkySampleRate;
        const maxSeconds = maxPcmBytes ~/ 2 / plinkySampleRate;
        warning =
            'Sample is too long (~${durationSeconds}s). '
            'Plinky supports up to ~${maxSeconds}s per slot '
            'at 31,250 Hz.';
      }

      ParsedSampleInfo? sampleInfo;
      if (_presetsUf2Bytes != null) {
        try {
          final flashImage = uf2ToData(_presetsUf2Bytes!);
          final sampleInfos = parseFlashImage(flashImage).sampleInfos;
          if (slotIndex >= 0 && slotIndex < sampleInfos.length) {
            sampleInfo = sampleInfos[slotIndex];
          }
        } on FormatException {
          // Ignore PRESETS.UF2 parse errors.
        }
      }

      if (mounted) {
        setState(() {
          _fileName = _sampleUf2FileName;
          _wavBytes = wavBytes;
          _pcmFrameCount = frameCount;
          _isConverting = false;
          _sampleTooLongWarning = warning;
          if (_nameController.text.isEmpty) {
            _nameController.text = _sampleUf2FileName!;
          }
          if (sampleInfo != null) {
            _slicePoints = sampleInfo.slicePoints;
            _sliceNotes = sampleInfo.sliceNotes;
            _pitched = sampleInfo.pitched;
          }
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _isConverting = false;
          _sampleTooLongWarning = e.message;
        });
      }
    }
  }

  int _parseSlotIndexFromFilename(String filename) {
    final upperName = filename.toUpperCase();
    final match = RegExp(r'SAMPLE(\d)').firstMatch(upperName);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  Future<void> _upload() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (_wavBytes == null || _fileName == null || userId == null) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final pcmBytes = wavToPlinkyPcm(_wavBytes!);
      final baseName = _fileName!.substring(0, _fileName!.lastIndexOf('.'));
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wavStorageName = '${baseName}_$timestamp.wav';
      final pcmStorageName = '${baseName}_$timestamp.pcm';

      final sample = SavedSample(
        id: '',
        userId: userId,
        name: _nameController.text.trim(),
        filePath: '$userId/$wavStorageName',
        pcmFilePath: '$userId/$pcmStorageName',
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
            wavBytes: _wavBytes!,
            pcmBytes: pcmBytes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample uploaded')),
        );
        _resetForm();
        widget.onUploaded?.call();
      }
    } on Exception catch (e) {
      debugPrint('Failed to upload sample: $e');
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload a WAV file, or a SAMPLEx.UF2 file '
                'from your Plinky. If you also provide the '
                'PRESETS.UF2 file, slice points and other '
                'metadata will be imported automatically.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              PlinkyButton(
                onPressed: _isUploading || _isConverting ? null : _pickWavFile,
                icon: Icons.audio_file,
                label: _fileName != null && _sampleUf2Bytes == null
                    ? _fileName!
                    : 'Choose WAV file',
              ),
              const SizedBox(height: 12),
              Text(
                'Or upload from Plinky UF2 files:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: PlinkyButton(
                      onPressed: _isUploading || _isConverting
                          ? null
                          : _pickSampleUf2,
                      icon: Icons.memory,
                      label: _sampleUf2FileName ?? 'SAMPLEx.UF2',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PlinkyButton(
                      onPressed: _isUploading || _isConverting
                          ? null
                          : _pickPresetsUf2,
                      icon: Icons.settings,
                      label: 'PRESETS.UF2',
                    ),
                  ),
                ],
              ),
              if (_presetsUf2Bytes != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Metadata loaded from PRESETS.UF2',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                onChanged: (value) => setState(() => _pitched = value),
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
                wavBytes: _wavBytes,
                pcmFrameCount: _pcmFrameCount,
                enabled: !_isUploading,
                onChanged: (points) => setState(() => _slicePoints = points),
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
                    : (value) => setState(() => _isPublic = value),
              ),
              const SizedBox(height: 8),
              Text(
                'By uploading, you confirm that you own this '
                'sample or have the right to use and distribute '
                'it (e.g. under a Creative Commons licence or '
                'similar terms).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              PlinkyButton(
                onPressed:
                    _isUploading ||
                        _wavBytes == null ||
                        _sampleTooLongWarning != null
                    ? null
                    : _upload,
                icon: _isUploading ? Icons.hourglass_empty : Icons.upload,
                label: _isUploading ? 'Uploading...' : 'Upload',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
