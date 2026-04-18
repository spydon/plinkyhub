import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/samples/sample_metadata_form.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';

enum _LoadStep { instructions, reading, review, uploading, done, error }

class LoadSampleTab extends ConsumerStatefulWidget {
  const LoadSampleTab({this.onLoaded, super.key});

  final VoidCallback? onLoaded;

  @override
  ConsumerState<LoadSampleTab> createState() => _LoadSampleTabState();
}

class _LoadSampleTabState extends ConsumerState<LoadSampleTab> {
  _LoadStep _step = _LoadStep.instructions;
  int _selectedSlot = 0;
  String _statusMessage = '';
  String? _errorMessage;

  Uint8List? _pcmBytes;
  Uint8List? _wavBytes;
  int? _pcmFrameCount;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  int _baseNote = 60;
  int _fineTune = 0;
  bool _pitched = false;
  List<double> _slicePoints = List.of(defaultSlicePoints);
  List<int> _sliceNotes = List.of(defaultSliceNotes);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _step = _LoadStep.instructions;
      _selectedSlot = 0;
      _statusMessage = '';
      _errorMessage = null;
      _pcmBytes = null;
      _wavBytes = null;
      _pcmFrameCount = null;
      _nameController.clear();
      _descriptionController.clear();
      _isPublic = true;
      _baseNote = 60;
      _fineTune = 0;
      _pitched = false;
      _slicePoints = List.of(defaultSlicePoints);
      _sliceNotes = List.of(defaultSliceNotes);
    });
  }

  Future<void> _readFromPlinky() async {
    final directory = await showDirectoryPicker();
    if (directory == null) {
      return;
    }

    setState(() {
      _step = _LoadStep.reading;
      _statusMessage = 'Reading SAMPLE$_selectedSlot.UF2...';
      _errorMessage = null;
    });

    try {
      final sampleBytes = await readFileFromDirectory(
        directory,
        'SAMPLE$_selectedSlot.UF2',
      );
      if (sampleBytes == null || sampleBytes.isEmpty) {
        throw Exception(
          'SAMPLE$_selectedSlot.UF2 not found on the selected drive.',
        );
      }

      final pcmData = uf2ToData(sampleBytes);
      if (pcmData.isEmpty) {
        throw Exception(
          'SAMPLE$_selectedSlot.UF2 contains no data.',
        );
      }

      setState(() {
        _statusMessage = 'Reading PRESETS.UF2...';
      });

      final presetsUf2Bytes = await readFileFromDirectory(
        directory,
        'PRESETS.UF2',
      );

      ParsedSampleInfo? sampleInfo;
      if (presetsUf2Bytes != null) {
        try {
          final flashImage = uf2ToData(presetsUf2Bytes);
          final sampleInfos = parseFlashImage(flashImage).sampleInfos;
          if (_selectedSlot < sampleInfos.length) {
            sampleInfo = sampleInfos[_selectedSlot];
          }
        } on FormatException {
          // Ignore PRESETS.UF2 parse errors: metadata is optional.
        }
      }

      // The firmware exports the full sample slot (up to 4 MB), but the
      // actual sample may be shorter. Trim to sampleLength so that the
      // fractional slice points align with the displayed waveform.
      final trimmedPcm =
          sampleInfo != null && sampleInfo.sampleLength * 2 < pcmData.length
          ? Uint8List.sublistView(pcmData, 0, sampleInfo.sampleLength * 2)
          : pcmData;

      final wavBytes = plinkyPcmToWav(trimmedPcm);
      final frameCount = trimmedPcm.length ~/ 2;

      if (mounted) {
        setState(() {
          _pcmBytes = trimmedPcm;
          _wavBytes = wavBytes;
          _pcmFrameCount = frameCount;
          _nameController.text = 'Sample $_selectedSlot';
          if (sampleInfo != null) {
            _slicePoints = sampleInfo.slicePoints;
            _sliceNotes = sampleInfo.sliceNotes;
            _pitched = sampleInfo.pitched;
          }
          _step = _LoadStep.review;
        });
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _step = _LoadStep.error;
          _errorMessage = error.toString();
        });
      }
    }
  }

  Future<void> _upload() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (_wavBytes == null || _pcmBytes == null || userId == null) {
      return;
    }

    setState(() {
      _step = _LoadStep.uploading;
      _statusMessage = 'Uploading sample...';
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseName = 'sample$_selectedSlot';
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
            pcmBytes: _pcmBytes!,
          );

      if (mounted) {
        setState(() {
          _step = _LoadStep.done;
        });
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _step = _LoadStep.error;
          _errorMessage = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _LoadStep.instructions || _step == _LoadStep.review) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SampleMetadataForm(
          header: _step == _LoadStep.instructions
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TunnelOfLightsInstructions(
                      itemType: 'sample',
                      isLoading: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSlot,
                      decoration: const InputDecoration(
                        labelText: 'Sample slot',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        sampleCount,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text('Sample $index'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSlot = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    PlinkyButton(
                      onPressed: isFileSystemAccessSupported
                          ? _readFromPlinky
                          : null,
                      icon: Icons.usb,
                      label: 'Select Plinky drive',
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sample $_selectedSlot loaded',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PlinkyButton(
                      onPressed: _reset,
                      icon: Icons.clear,
                      label: 'Clear',
                    ),
                  ],
                ),
          nameController: _nameController,
          descriptionController: _descriptionController,
          isPublic: _isPublic,
          onIsPublicChanged: (value) =>
              setState(() => _isPublic = value ?? true),
          pitched: _pitched,
          onPitchedChanged: (value) => setState(() => _pitched = value),
          baseNote: _baseNote,
          onBaseNoteChanged: (value) => setState(() => _baseNote = value),
          fineTune: _fineTune,
          onFineTuneChanged: (value) => setState(() => _fineTune = value),
          slicePoints: _slicePoints,
          onSlicePointsChanged: (points) =>
              setState(() => _slicePoints = points),
          sliceNotes: _sliceNotes,
          onSliceNotesChanged: (notes) => setState(() => _sliceNotes = notes),
          wavBytes: _wavBytes,
          pcmFrameCount: _pcmFrameCount,
          sampleName:
              '${ref.read(authenticationProvider).username ?? 'local'}'
              '_${_nameController.text}',
          enabled: _step == _LoadStep.review,
          footer: _step == _LoadStep.review
              ? Row(
                  children: [
                    Expanded(
                      child: PlinkyButton(
                        onPressed: _reset,
                        icon: Icons.arrow_back,
                        label: 'Back',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PlinkyButton(
                        onPressed: _upload,
                        icon: Icons.upload,
                        label: 'Upload',
                      ),
                    ),
                  ],
                )
              : null,
        ),
      );
    }

    return switch (_step) {
      _LoadStep.reading => Center(
        child: SaveProgressView(statusMessage: _statusMessage),
      ),
      _LoadStep.uploading => Center(
        child: SaveProgressView(statusMessage: _statusMessage),
      ),
      _LoadStep.done => _LoadDoneView(
        onDone: () {
          _reset();
          widget.onLoaded?.call();
        },
      ),
      _LoadStep.error => _LoadErrorView(
        errorMessage: _errorMessage,
        onRetry: _reset,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _LoadDoneView extends StatelessWidget {
  const _LoadDoneView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SaveDoneView(itemType: 'sample'),
          const SizedBox(height: 16),
          PlinkyButton(
            onPressed: onDone,
            icon: Icons.check,
            label: 'Done',
          ),
        ],
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SaveErrorView(errorMessage: errorMessage),
          const SizedBox(height: 16),
          PlinkyButton(
            onPressed: onRetry,
            icon: Icons.refresh,
            label: 'Try again',
          ),
        ],
      ),
    );
  }
}
