import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/patterns/models/pattern_data.dart';
import 'package:plinkyhub/pages/patterns/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/pattern_grid_editor.dart';
import 'package:plinkyhub/pages/patterns/pattern_play_controls.dart';
import 'package:plinkyhub/pages/patterns/providers/pattern_playback_notifier.dart';
import 'package:plinkyhub/pages/patterns/providers/saved_patterns_notifier.dart';
import 'package:plinkyhub/pages/patterns/utils/midi_import.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/pitch.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// Plinky patterns start at 16 steps; the editor lets the user extend
/// up to the firmware-supported 64 steps in 16-step increments.
const fixedStepCount = 16;
const _stepIncrement = 16;
const _maxStepCount = 64;

/// Synthetic pattern id used by `patternPlaybackProvider` to identify
/// playback driven from the in-progress pattern editor (so it can show
/// a playhead in the editor's grid without colliding with saved
/// patterns).
const _editorPatternId = '__editor__';

class CreatePatternTab extends ConsumerStatefulWidget {
  const CreatePatternTab({this.onCreated, super.key});

  final VoidCallback? onCreated;

  @override
  ConsumerState<CreatePatternTab> createState() => _CreatePatternTabState();
}

class _CreatePatternTabState extends ConsumerState<CreatePatternTab> {
  bool _isSaving = false;
  PlinkyScale _scale = PlinkyScale.major;
  GridViewMode _viewMode = GridViewMode.coloredByString;
  late List<List<int>> _grid;

  @override
  void initState() {
    super.initState();
    _grid = _createEmptyGrid(fixedStepCount);
  }

  List<List<int>> _createEmptyGrid(int steps) {
    return [
      for (var s = 0; s < steps; s++) [for (var r = 0; r < 8; r++) 0],
    ];
  }

  void _clearGrid() {
    setState(() {
      _grid = _createEmptyGrid(fixedStepCount);
    });
  }

  void _appendSteps() {
    final remaining = _maxStepCount - _grid.length;
    if (remaining <= 0) {
      return;
    }
    final toAdd = remaining < _stepIncrement ? remaining : _stepIncrement;
    setState(() {
      _grid = [
        ..._grid,
        for (var s = 0; s < toAdd; s++) [for (var r = 0; r < 8; r++) 0],
      ];
    });
  }

  void _resetForm() {
    setState(() {
      _isSaving = false;
      _scale = PlinkyScale.major;
      _grid = _createEmptyGrid(fixedStepCount);
    });
  }

  bool get _hasActiveSteps =>
      _grid.any((step) => step.any((cell) => cell != 0));

  /// Snapshot of the current grid state, ready to play or persist.
  PatternData get _patternData => PatternData(
    scaleIndex: _scale.index,
    grid: [
      for (final step in _grid) [...step],
    ],
  );

  Future<void> _importMidi() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mid', 'midi'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) {
      return;
    }

    final bytes = Uint8List.fromList(result.files.single.bytes!);

    try {
      final importResult = importMidiToGrid(
        midiBytes: bytes,
        scale: _scale,
      );

      // If multiple tracks with notes, let the user pick one.
      if (importResult.trackNames.length > 1 && mounted) {
        final selectedTrack = await _showTrackSelectionDialog(
          importResult.trackNames,
        );
        if (selectedTrack != null) {
          final trackResult = importMidiToGrid(
            midiBytes: bytes,
            scale: _scale,
            trackIndex: selectedTrack,
          );
          _applyMidiImport(trackResult);
          return;
        }
      }

      _applyMidiImport(importResult);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import MIDI: $error')),
        );
      }
    }
  }

  void _applyMidiImport(MidiImportResult result) {
    setState(() {
      _grid = result.grid;
    });
  }

  Future<int?> _showTrackSelectionDialog(List<String> trackNames) {
    return showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select track to import'),
        children: [
          for (var i = 0; i < trackNames.length; i++)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(i),
              child: Text(trackNames[i]),
            ),
        ],
      ),
    );
  }

  Future<void> _openSaveDialog() async {
    final result = await showDialog<_SavePatternResult>(
      context: context,
      builder: (context) => const _SavePatternDialog(),
    );
    if (result == null || !mounted) {
      return;
    }
    await _save(
      name: result.name,
      description: result.description,
      isPublic: result.isPublic,
    );
  }

  Future<void> _save({
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Stop any in-progress editor playback before resetting the form.
      ref.read(patternPlaybackProvider.notifier).stop();

      final patternData = _patternData;
      final jsonString = jsonEncode(patternData.toJson());
      final fileBytes = Uint8List.fromList(utf8.encode(jsonString));
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitized = name.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
      final storageName = '${sanitized}_$timestamp.json';

      final pattern = SavedPattern(
        id: '',
        userId: userId,
        name: name,
        filePath: '$userId/$storageName',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: description,
        isPublic: isPublic,
      );

      await ref
          .read(savedPatternsProvider.notifier)
          .savePattern(pattern, fileBytes: fileBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pattern saved')),
        );
        _resetForm();
        widget.onCreated?.call();
      }
    } on Exception catch (error) {
      debugPrint('Failed to save pattern: $error');
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PlinkyButton(
                onPressed: _isSaving ? null : _importMidi,
                icon: Icons.file_open,
                label: 'Import from MIDI',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PlinkyScale>(
                  initialValue: _scale,
                  decoration: const InputDecoration(
                    labelText: 'Scale',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    for (final scale in PlinkyScale.values)
                      DropdownMenuItem(
                        value: scale,
                        child: Text(scale.displayName),
                      ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _scale = value);
                          }
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<GridViewMode>(
                  initialValue: _viewMode,
                  decoration: const InputDecoration(
                    labelText: 'Grid view',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: GridViewMode.blank,
                      child: Text('Blank'),
                    ),
                    DropdownMenuItem(
                      value: GridViewMode.coloredByString,
                      child: Text('Coloured by string'),
                    ),
                    DropdownMenuItem(
                      value: GridViewMode.orderedByString,
                      child: Text('Ordered by string'),
                    ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _viewMode = value);
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PatternPlayControls(
            patternId: _editorPatternId,
            patternData: _patternData,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PatternGridEditor(
              grid: _grid,
              scale: _scale,
              enabled: !_isSaving,
              playbackPatternId: _editorPatternId,
              viewMode: _viewMode,
              onGridChanged: (newGrid) => setState(() => _grid = newGrid),
              onAppendSteps: _isSaving || _grid.length >= _maxStepCount
                  ? null
                  : _appendSteps,
              appendStepsTooltip: _grid.length >= _maxStepCount
                  ? 'Pattern is at the maximum length '
                        '($_maxStepCount steps)'
                  : 'Add $_stepIncrement steps',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _isSaving || !_hasActiveSteps ? null : _clearGrid,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear grid'),
              ),
              const Spacer(),
              PlinkyButton(
                onPressed: _isSaving || !_hasActiveSteps
                    ? null
                    : _openSaveDialog,
                icon: _isSaving ? Icons.hourglass_empty : Icons.save,
                label: _isSaving ? 'Saving...' : 'Save Pattern',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pattern metadata captured by [_SavePatternDialog].
class _SavePatternResult {
  const _SavePatternResult({
    required this.name,
    required this.description,
    required this.isPublic,
  });

  final String name;
  final String description;
  final bool isPublic;
}

class _SavePatternDialog extends StatefulWidget {
  const _SavePatternDialog();

  @override
  State<_SavePatternDialog> createState() => _SavePatternDialogState();
}

class _SavePatternDialogState extends State<_SavePatternDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a name');
      return;
    }
    Navigator.of(context).pop(
      _SavePatternResult(
        name: name,
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Pattern'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: null,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Share with community'),
              contentPadding: EdgeInsets.zero,
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
