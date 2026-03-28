import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/pattern_data.dart';
import 'package:plinkyhub/models/saved_pattern.dart';
import 'package:plinkyhub/pages/patterns/pattern_grid_editor.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_patterns_notifier.dart';
import 'package:plinkyhub/utils/midi_import.dart';
import 'package:plinkyhub/utils/pitch.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

/// Available step counts for pattern length.
const _stepCountOptions = [8, 16, 32, 64];

class CreatePatternTab extends ConsumerStatefulWidget {
  const CreatePatternTab({this.onCreated, super.key});

  final VoidCallback? onCreated;

  @override
  ConsumerState<CreatePatternTab> createState() => _CreatePatternTabState();
}

class _CreatePatternTabState extends ConsumerState<CreatePatternTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isSaving = false;
  int _stepCount = 16;
  PlinkyScale _scale = PlinkyScale.major;
  late List<List<bool>> _grid;

  @override
  void initState() {
    super.initState();
    _grid = _createEmptyGrid(_stepCount);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<List<bool>> _createEmptyGrid(int steps) {
    return [
      for (var s = 0; s < steps; s++) [for (var r = 0; r < 8; r++) false],
    ];
  }

  void _updateStepCount(int newCount) {
    setState(() {
      if (newCount > _stepCount) {
        // Extend grid with empty steps.
        _grid = [
          ..._grid,
          for (var s = _stepCount; s < newCount; s++)
            [for (var r = 0; r < 8; r++) false],
        ];
      } else {
        // Truncate grid.
        _grid = _grid.sublist(0, newCount);
      }
      _stepCount = newCount;
    });
  }

  void _clearGrid() {
    setState(() {
      _grid = _createEmptyGrid(_stepCount);
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _isPublic = true;
      _isSaving = false;
      _stepCount = 16;
      _scale = PlinkyScale.major;
      _grid = _createEmptyGrid(_stepCount);
    });
  }

  bool get _hasActiveSteps => _grid.any((step) => step.any((cell) => cell));

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
    final fileName = result.files.single.name;

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
          _applyMidiImport(trackResult, fileName);
          return;
        }
      }

      _applyMidiImport(importResult, fileName);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import MIDI: $error')),
        );
      }
    }
  }

  void _applyMidiImport(MidiImportResult result, String fileName) {
    setState(() {
      _stepCount = result.stepCount;
      _grid = result.grid;
      if (_nameController.text.isEmpty) {
        final baseName = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;
        _nameController.text = baseName;
      }
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

  Future<void> _save() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the pattern')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final patternData = PatternData(
        stepCount: _stepCount,
        scaleIndex: _scale.index,
        grid: [
          for (final step in _grid) [for (final cell in step) cell ? 1 : 0],
        ],
      );

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
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create a step-sequencer pattern for your Plinky. '
            'Tap cells in the grid to toggle notes on each step, '
            'or import from a MIDI file.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          PlinkyButton(
            onPressed: _isSaving ? null : _importMidi,
            icon: Icons.file_open,
            label: 'Import from MIDI',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          // Scale and step count selectors
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PlinkyScale>(
                  initialValue: _scale,
                  decoration: const InputDecoration(
                    labelText: 'Scale',
                    border: OutlineInputBorder(),
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
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  initialValue: _stepCount,
                  decoration: const InputDecoration(
                    labelText: 'Steps',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    for (final count in _stepCountOptions)
                      DropdownMenuItem(
                        value: count,
                        child: Text('$count'),
                      ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            _updateStepCount(value);
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PatternGridEditor(
            grid: _grid,
            stepCount: _stepCount,
            scale: _scale,
            enabled: !_isSaving,
            onGridChanged: (newGrid) => setState(() => _grid = newGrid),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isSaving || !_hasActiveSteps ? null : _clearGrid,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear grid'),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  title: const Text('Share with community'),
                  value: _isPublic,
                  onChanged: _isSaving
                      ? null
                      : (value) => setState(() => _isPublic = value),
                ),
                const SizedBox(height: 16),
                PlinkyButton(
                  onPressed: _isSaving || !_hasActiveSteps ? null : _save,
                  icon: _isSaving ? Icons.hourglass_empty : Icons.save,
                  label: _isSaving ? 'Saving...' : 'Save Pattern',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
