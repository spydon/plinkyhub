import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_wavetable.dart';
import 'package:plinkyhub/state/saved_wavetables_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

enum _DialogStep {
  instructions,
  progress,
  done,
  error,
}

class SaveWavetableToPlinkyDialog extends ConsumerStatefulWidget {
  const SaveWavetableToPlinkyDialog({
    required this.wavetable,
    super.key,
  });

  final SavedWavetable wavetable;

  @override
  ConsumerState<SaveWavetableToPlinkyDialog> createState() =>
      _SaveWavetableToPlinkyDialogState();
}

class _SaveWavetableToPlinkyDialogState
    extends ConsumerState<SaveWavetableToPlinkyDialog> {
  _DialogStep _step = _DialogStep.instructions;
  String _statusMessage = '';
  String? _errorMessage;

  Future<void> _startSave() async {
    FileSystemDirectoryHandle directory;
    try {
      directory = await html.window.showDirectoryPicker(
        mode: PermissionMode.readwrite,
      );
    } on AbortError {
      return;
    } on Exception {
      return;
    }

    setState(() {
      _step = _DialogStep.progress;
      _statusMessage = 'Downloading wavetable...';
    });

    try {
      final uf2Bytes = await ref
          .read(savedWavetablesProvider.notifier)
          .downloadUf2(widget.wavetable.filePath);

      setState(() {
        _statusMessage = 'Writing WAVETABLE.UF2...';
      });
      await _writeFile(directory, 'WAVETABLE.UF2', uf2Bytes);

      setState(() => _step = _DialogStep.done);
    } on Exception catch (error) {
      setState(() {
        _step = _DialogStep.error;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _writeFile(
    FileSystemDirectoryHandle directory,
    String fileName,
    Uint8List data,
  ) async {
    final fileHandle = await directory.getFileHandle(
      fileName,
      create: true,
    );
    final writable = await fileHandle.createWritable();
    await writable.writeAsArrayBuffer(data);
    await writable.close();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        switch (_step) {
          _DialogStep.instructions => 'Save to Plinky',
          _DialogStep.progress => 'Saving...',
          _DialogStep.done => 'Done',
          _DialogStep.error => 'Error',
        },
      ),
      content: SizedBox(
        width: 400,
        child: switch (_step) {
          _DialogStep.instructions => _buildInstructions(),
          _DialogStep.progress => _buildProgress(),
          _DialogStep.done => _buildDone(),
          _DialogStep.error => _buildError(),
        },
      ),
      actions: switch (_step) {
        _DialogStep.instructions => [
            PlinkyButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Cancel',
            ),
            PlinkyButton(
              onPressed: _startSave,
              icon: Icons.folder_open,
              label: 'Select Plinky drive',
            ),
          ],
        _DialogStep.progress => [],
        _DialogStep.done || _DialogStep.error => [
            PlinkyButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Close',
            ),
          ],
      },
    );
  }

  Widget _buildInstructions() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To save this wavetable to your Plinky, put it '
          'into Tunnel of Lights mode:',
        ),
        SizedBox(height: 12),
        Text('1. Turn off your Plinky'),
        SizedBox(height: 4),
        Text(
          '2. Hold the rotary encoder while turning '
          'the Plinky on',
        ),
        SizedBox(height: 4),
        Text(
          '3. The Plinky will appear as a USB drive '
          'on your computer',
        ),
        SizedBox(height: 12),
        Text(
          'Then click the button below to select the '
          'Plinky drive.',
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(_statusMessage),
      ],
    );
  }

  Widget _buildDone() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, size: 48, color: Colors.green),
        SizedBox(height: 16),
        Text(
          'Wavetable saved to Plinky successfully! '
          'Eject the drive and restart your Plinky.',
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(_errorMessage ?? 'An unknown error occurred.'),
      ],
    );
  }
}
