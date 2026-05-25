import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/sample_loop_mode.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/samples/sample_metadata_form.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class UploadSampleTab extends ConsumerStatefulWidget {
  const UploadSampleTab({
    this.onUploaded,
    this.sampleToEdit,
    this.onClear,
    super.key,
  });

  final VoidCallback? onUploaded;
  final SavedSample? sampleToEdit;
  final VoidCallback? onClear;

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
  SampleLoopMode _loopMode = SampleLoopMode.oneShotSlice;
  List<double> _slicePoints = List.of(defaultSlicePoints);
  List<int> _sliceNotes = List.of(defaultSliceNotes);
  int? _pcmFrameCount;
  String? _sampleTooLongWarning;

  @override
  void initState() {
    super.initState();
    if (widget.sampleToEdit != null) {
      final sample = widget.sampleToEdit!;
      _nameController.text = sample.name;
      _descriptionController.text = sample.description;
      _isPublic = sample.isPublic;
      _baseNote = sample.baseNote;
      _fineTune = sample.fineTune;
      _pitched = sample.pitched;
      _loopMode = SampleLoopMode.fromValue(sample.loopMode);
      _slicePoints = List.of(sample.slicePoints);
      _sliceNotes = List.of(sample.sliceNotes);
      _fileName = sample.filePath.split('/').last;
      _loadExistingWav();
    }
  }

  Future<void> _loadExistingWav() async {
    if (widget.sampleToEdit == null) {
      return;
    }
    setState(() => _isConverting = true);
    try {
      final bytes = await ref
          .read(savedSamplesProvider.notifier)
          .downloadWav(widget.sampleToEdit!.filePath);
      if (mounted) {
        setState(() {
          _wavBytes = bytes;
          _isConverting = false;
        });
      }
    } on Exception catch (e) {
      debugPrint('Failed to load existing WAV: $e');
      if (mounted) {
        setState(() {
          _isConverting = false;
          _sampleTooLongWarning = 'Failed to load existing WAV file.';
        });
      }
    }
  }

  @override
  void didUpdateWidget(UploadSampleTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sampleToEdit != oldWidget.sampleToEdit) {
      if (widget.sampleToEdit != null) {
        final sample = widget.sampleToEdit!;
        _nameController.text = sample.name;
        _descriptionController.text = sample.description;
        _isPublic = sample.isPublic;
        _baseNote = sample.baseNote;
        _fineTune = sample.fineTune;
        _pitched = sample.pitched;
        _loopMode = SampleLoopMode.fromValue(sample.loopMode);
        _slicePoints = List.of(sample.slicePoints);
        _sliceNotes = List.of(sample.sliceNotes);
        _fileName = sample.filePath.split('/').last;
        _loadExistingWav();
      } else if (oldWidget.sampleToEdit != null) {
        _resetForm();
      }
    }
  }

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
      _loopMode = SampleLoopMode.oneShotSlice;
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
          final dotIndex = name.lastIndexOf('.');
          _nameController.text = dotIndex > 0
              ? name.substring(0, dotIndex)
              : name;
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
          _wavBytes = frameCount != null ? bytes : null;
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

      // The firmware exports the full sample slot (up to 4 MB), but the
      // actual sample may be shorter. Trim to sampleLength so that the
      // fractional slice points align with the displayed waveform.
      final trimmedPcm =
          sampleInfo != null && sampleInfo.sampleLength * 2 < pcmBytes.length
          ? Uint8List.sublistView(pcmBytes, 0, sampleInfo.sampleLength * 2)
          : pcmBytes;

      final wavBytes = plinkyPcmToWav(trimmedPcm);
      final frameCount = trimmedPcm.length ~/ 2;

      String? warning;
      if (trimmedPcm.length > maxPcmBytes) {
        final durationSeconds = trimmedPcm.length ~/ 2 / plinkySampleRate;
        const maxSeconds = maxPcmBytes ~/ 2 / plinkySampleRate;
        warning =
            'Sample is too long (~${durationSeconds}s). '
            'Plinky supports up to ~${maxSeconds}s per slot '
            'at 31,250 Hz.';
      }

      if (mounted) {
        setState(() {
          _fileName = _sampleUf2FileName;
          _wavBytes = wavBytes;
          _pcmFrameCount = frameCount;
          _isConverting = false;
          _sampleTooLongWarning = warning;
          if (_nameController.text.isEmpty) {
            final name = _sampleUf2FileName!;
            final dotIndex = name.lastIndexOf('.');
            _nameController.text = dotIndex > 0
                ? name.substring(0, dotIndex)
                : name;
          }
          if (sampleInfo != null) {
            _slicePoints = sampleInfo.slicePoints;
            _sliceNotes = sampleInfo.sliceNotes;
            _pitched = sampleInfo.pitched;
            _loopMode = SampleLoopMode.fromValue(sampleInfo.loopMode);
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

  void _clearSample() {
    _resetForm();
    widget.onClear?.call();
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

      final sample =
          widget.sampleToEdit?.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            isPublic: _isPublic,
            slicePoints: _slicePoints,
            baseNote: _baseNote,
            fineTune: _fineTune,
            pitched: _pitched,
            sliceNotes: _sliceNotes,
            loopMode: _loopMode.value,
            updatedAt: DateTime.now(),
          ) ??
          SavedSample(
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
            loopMode: _loopMode.value,
          );

      if (widget.sampleToEdit != null) {
        await ref.read(savedSamplesProvider.notifier).updateSample(sample);
        // If WAV/PCM bytes changed (new file picked), we might need to
        // re-upload them, but current updateSample doesn't support
        // that. For now, assume metadata update only or re-upload if
        // file changed.
        // Actually, let's keep it simple for now as per requirements.
      } else {
        await ref
            .read(savedSamplesProvider.notifier)
            .saveSample(
              sample,
              wavBytes: _wavBytes!,
              pcmBytes: pcmBytes,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.sampleToEdit != null
                  ? 'Sample updated'
                  : 'Sample uploaded',
            ),
          ),
        );
        _resetForm();
        widget.onUploaded?.call();
      }
    } on Exception catch (e) {
      debugPrint('Failed to save sample: $e');
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
      child: SampleMetadataForm(
        header: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _wavBytes == null
              ? Column(
                  key: const ValueKey('file-picker'),
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
                      onPressed: _isUploading || _isConverting
                          ? null
                          : _pickWavFile,
                      icon: Icons.audio_file,
                      label: 'Choose WAV file',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Or upload from Plinky UF2 files:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    PlinkyButton(
                      onPressed: _isUploading || _isConverting
                          ? null
                          : _pickSampleUf2,
                      icon: Icons.memory,
                      label: _sampleUf2FileName ?? 'SAMPLEx.UF2',
                    ),
                    const SizedBox(height: 8),
                    PlinkyButton(
                      onPressed: _isUploading || _isConverting
                          ? null
                          : _pickPresetsUf2,
                      icon: Icons.settings,
                      label: 'PRESETS.UF2',
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
                  ],
                )
              : Column(
                  key: const ValueKey('clear-sample'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _fileName ?? 'Sample loaded',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PlinkyButton(
                          onPressed: _isUploading ? null : _clearSample,
                          icon: Icons.clear,
                          label: 'Clear sample',
                        ),
                      ],
                    ),
                    if (_sampleTooLongWarning != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _sampleTooLongWarning!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        nameController: _nameController,
        descriptionController: _descriptionController,
        isPublic: _isPublic,
        onIsPublicChanged: (value) => setState(() => _isPublic = value ?? true),
        pitched: _pitched,
        onPitchedChanged: (value) => setState(() => _pitched = value),
        loopMode: _loopMode,
        onLoopModeChanged: (value) => setState(() => _loopMode = value),
        baseNote: _baseNote,
        onBaseNoteChanged: (value) => setState(() => _baseNote = value),
        fineTune: _fineTune,
        onFineTuneChanged: (value) => setState(() => _fineTune = value),
        slicePoints: _slicePoints,
        onSlicePointsChanged: (points) => setState(() => _slicePoints = points),
        sliceNotes: _sliceNotes,
        onSliceNotesChanged: (notes) => setState(() => _sliceNotes = notes),
        wavBytes: _wavBytes,
        pcmFrameCount: _pcmFrameCount,
        sampleName:
            '${ref.read(authenticationProvider).username ?? 'local'}'
            '_${_nameController.text}',
        enabled: !_isUploading,
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              icon: _isUploading
                  ? Icons.hourglass_empty
                  : (widget.sampleToEdit != null ? Icons.save : Icons.upload),
              label: _isUploading
                  ? (widget.sampleToEdit != null
                        ? 'Updating...'
                        : 'Uploading...')
                  : (widget.sampleToEdit != null
                        ? 'Update Sample'
                        : 'Upload Sample'),
            ),
          ],
        ),
      ),
    );
  }
}
