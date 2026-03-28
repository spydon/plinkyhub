import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class UploadWavetableTab extends ConsumerStatefulWidget {
  const UploadWavetableTab({this.onUploaded, super.key});

  final VoidCallback? onUploaded;

  @override
  ConsumerState<UploadWavetableTab> createState() =>
      _UploadWavetableTabState();
}

class _UploadWavetableTabState
    extends ConsumerState<UploadWavetableTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isUploading = false;
  bool _isGenerating = false;
  String? _errorMessage;

  /// The 15 WAV file slots (c0–c14). Null means the slot is empty.
  final List<_WavSlot?> _slots =
      List<_WavSlot?>.filled(wavetableUserShapeCount, null);

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
      _isUploading = false;
      _isGenerating = false;
      _errorMessage = null;
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = null;
      }
    });
  }

  int get _filledSlotCount =>
      _slots.where((slot) => slot != null).length;

  bool get _allSlotsFilled => _filledSlotCount == wavetableUserShapeCount;

  Future<void> _pickAllFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final files = result.files
        .where((file) => file.bytes != null)
        .toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    setState(() {
      _errorMessage = null;
      // Try to match filenames to c0–c14 pattern first.
      final unmatched = <PlatformFile>[];
      for (final file in files) {
        final slotIndex = _parseSlotIndex(file.name);
        if (slotIndex != null && _slots[slotIndex] == null) {
          _slots[slotIndex] = _WavSlot(
            fileName: file.name,
            bytes: file.bytes!,
          );
        } else {
          unmatched.add(file);
        }
      }

      // Assign remaining files to empty slots in order.
      var nextEmpty = 0;
      for (final file in unmatched) {
        while (nextEmpty < wavetableUserShapeCount &&
            _slots[nextEmpty] != null) {
          nextEmpty++;
        }
        if (nextEmpty >= wavetableUserShapeCount) {
          break;
        }
        _slots[nextEmpty] = _WavSlot(
          fileName: file.name,
          bytes: file.bytes!,
        );
        nextEmpty++;
      }
    });
  }

  Future<void> _pickSlotFile(int slotIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      setState(() {
        _errorMessage = null;
        _slots[slotIndex] = _WavSlot(
          fileName: file.name,
          bytes: file.bytes!,
        );
      });
    }
  }

  /// Tries to extract a slot index (0–14) from a filename like "c0.wav",
  /// "c14.wav", "C3.wav", etc.
  int? _parseSlotIndex(String fileName) {
    final match =
        RegExp(r'^[cC](\d{1,2})\b').firstMatch(fileName);
    if (match == null) {
      return null;
    }
    final index = int.tryParse(match.group(1)!);
    if (index == null ||
        index < 0 ||
        index >= wavetableUserShapeCount) {
      return null;
    }
    return index;
  }

  Future<void> _createAndUpload() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null || !_allSlotsFilled) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      // Allow the UI to update before heavy computation.
      await Future<void>.delayed(Duration.zero);

      final wavFiles = _slots.map((slot) => slot!.bytes).toList();
      final uf2Bytes = generateWavetableUf2(wavFiles);

      setState(() {
        _isGenerating = false;
        _isUploading = true;
      });

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'wavetable';
      final storageName = '${name}_$timestamp.uf2';

      final wavetable = SavedWavetable(
        id: '',
        userId: userId,
        name: name,
        filePath: '$userId/$storageName',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
      );

      await ref
          .read(savedWavetablesProvider.notifier)
          .saveWavetable(wavetable, uf2Bytes: uf2Bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wavetable created')),
        );
        _resetForm();
        widget.onUploaded?.call();
      }
    } on FormatException catch (e) {
      setState(() {
        _isGenerating = false;
        _isUploading = false;
        _errorMessage = e.message;
      });
    } on Exception catch (e) {
      debugPrint('Failed to create wavetable: $e');
      setState(() {
        _isGenerating = false;
        _isUploading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = _isUploading || _isGenerating;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a wavetable from 15 single-cycle WAV '
                'files (c0 through c14). Each file should '
                'contain one cycle of a waveform. A built-in '
                'saw and sine wave are added automatically as '
                'the first and last shapes.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              PlinkyButton(
                onPressed: isBusy ? null : _pickAllFiles,
                icon: Icons.folder_open,
                label: 'Pick WAV files',
              ),
              const SizedBox(height: 12),
              Text(
                '$_filledSlotCount / $wavetableUserShapeCount '
                'slots filled',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ...List.generate(wavetableUserShapeCount, (index) {
                final slot = _slots[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          'c$index',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        slot != null
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: slot != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          slot?.fileName ?? '(empty)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: slot != null
                                ? null
                                : theme.colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.audio_file, size: 18),
                        tooltip: 'Pick file for c$index',
                        onPressed: isBusy
                            ? null
                            : () => _pickSlotFile(index),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (slot != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Remove',
                          onPressed: isBusy
                              ? null
                              : () => setState(
                                  () => _slots[index] = null,
                                ),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                );
              }),
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
              SwitchListTile(
                title: const Text('Share with community'),
                value: _isPublic,
                onChanged: isBusy
                    ? null
                    : (value) =>
                        setState(() => _isPublic = value),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'By uploading, you confirm that you own these '
                'waveforms or have the right to use and '
                'distribute them (e.g. under a Creative Commons '
                'licence or similar terms).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (_isGenerating)
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
                    Text('Generating wavetable...'),
                  ],
                )
              else
                PlinkyButton(
                  onPressed:
                      isBusy || !_allSlotsFilled
                          ? null
                          : _createAndUpload,
                  icon: _isUploading
                      ? Icons.hourglass_empty
                      : Icons.upload,
                  label: _isUploading
                      ? 'Uploading...'
                      : 'Create & Upload',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavSlot {
  const _WavSlot({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final Uint8List bytes;
}
