import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/providers/dumps_notifier.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

enum _CreateDumpStep {
  form,
  reading,
  uploading,
  done,
  error,
}

class CreateDumpDialog extends ConsumerStatefulWidget {
  const CreateDumpDialog({super.key});

  @override
  ConsumerState<CreateDumpDialog> createState() => _CreateDumpDialogState();
}

class _CreateDumpDialogState extends ConsumerState<CreateDumpDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chunkSizeController = TextEditingController(text: '4096');
  _CreateDumpStep _step = _CreateDumpStep.form;
  String _statusMessage = '';
  double _progress = 0;
  String? _errorMessage;

  /// Bytes captured from the most recent dump attempt. Kept around so the
  /// user can download partial data for debugging when the firmware times
  /// out mid-transfer.
  Uint8List? _capturedInternalBytes;
  Uint8List? _capturedExternalBytes;
  int? _capturedExternalExpectedSize;

  /// Which flash regions to read. Allowing each to be toggled separately
  /// is useful for isolating firmware bugs, e.g. skipping internal to
  /// see whether external alone behaves differently.
  bool _readInternal = true;
  bool _readExternal = true;

  /// True once the dump has actually been uploaded to the backend; false
  /// for debug paths (non-null chunk size) that skip the upload and just
  /// offer local downloads.
  bool _wasUploaded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _chunkSizeController.dispose();
    super.dispose();
  }

  /// Parses the optional debug "bytes to read" field. Returns null when
  /// the field is empty (read the full region) or when the value does not
  /// parse as a positive integer.
  int? _parseChunkSize() {
    final raw = _chunkSizeController.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  Future<void> _startDump() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }
    if (!_readInternal && !_readExternal) {
      return;
    }

    setState(() {
      _step = _CreateDumpStep.reading;
      _statusMessage = 'Connecting to Plinky...';
      _progress = 0;
      _errorMessage = null;
      _capturedInternalBytes = null;
      _capturedExternalBytes = null;
      _capturedExternalExpectedSize = null;
      _wasUploaded = false;
    });

    final plinkyNotifier = ref.read(plinkyProvider.notifier);
    final plinkyState = ref.read(plinkyProvider);

    try {
      if (plinkyState.connectionState == PlinkyConnectionState.disconnected ||
          plinkyState.connectionState == PlinkyConnectionState.error) {
        await plinkyNotifier.connect();
      }
      final afterConnect = ref.read(plinkyProvider);
      if (afterConnect.connectionState != PlinkyConnectionState.connected) {
        throw Exception(
          afterConnect.errorMessage ?? 'Failed to connect to Plinky',
        );
      }

      // When both regions are selected we weight progress by their size
      // (1 MB + 32 MB). When only one is selected it gets the full bar.
      final internalShare = _readInternal && _readExternal
          ? 1 / 33
          : (_readInternal ? 1.0 : 0.0);
      final externalShare = _readInternal && _readExternal
          ? 32 / 33
          : (_readExternal ? 1.0 : 0.0);

      Uint8List? internalBytes;
      Uint8List? externalBytes;

      final chunkSize = _parseChunkSize();

      if (_readInternal) {
        setState(() {
          _statusMessage = chunkSize == null
              ? 'Reading internal flash (1 MB)...'
              : 'Reading internal flash in $chunkSize-byte chunks...';
          _progress = 0;
        });
        internalBytes = await plinkyNotifier.readFlashDump(
          flashIndex: flashDumpInternalIndex,
          chunkBytes: chunkSize,
          onProgress: (value) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progress = value * internalShare;
            });
          },
        );
        _capturedInternalBytes = internalBytes;
      }

      if (_readExternal) {
        setState(() {
          _statusMessage = chunkSize == null
              ? 'Reading external flash (32 MB)...'
              : 'Reading external flash in $chunkSize-byte chunks...';
          _progress = internalShare;
        });
        externalBytes = await plinkyNotifier.readFlashDump(
          flashIndex: flashDumpExternalIndex,
          chunkBytes: chunkSize,
          onProgress: (value) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progress = internalShare + value * externalShare;
            });
          },
        );
        _capturedExternalBytes = externalBytes;
      }

      final shouldUpload = internalBytes != null || externalBytes != null;
      if (shouldUpload) {
        setState(() {
          _step = _CreateDumpStep.uploading;
          _statusMessage = 'Uploading dump to your account...';
          _progress = 0;
        });

        await ref
            .read(dumpsProvider.notifier)
            .uploadDump(
              title: title,
              description: _descriptionController.text.trim(),
              internalFlashBytes: internalBytes,
              externalFlashBytes: externalBytes,
            );
        _wasUploaded = true;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _step = _CreateDumpStep.done;
      });
    } on Object catch (error) {
      debugPrint('Dump failed: $error');
      if (error is FlashDumpTimeoutException) {
        if (error.flashIndex == flashDumpInternalIndex) {
          _capturedInternalBytes = error.partialBytes;
        } else if (error.flashIndex == flashDumpExternalIndex) {
          _capturedExternalBytes = error.partialBytes;
          _capturedExternalExpectedSize = error.expectedBytes;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _step = _CreateDumpStep.error;
        _errorMessage = error.toString();
      });
    }
  }

  void _downloadCapturedBytes(Uint8List bytes, String suffix) {
    final rawTitle = _titleController.text.trim();
    final baseName = rawTitle.isEmpty ? 'plinky_debug' : rawTitle;
    final safeName = baseName
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-]+'), '_')
        .replaceAll(RegExp('_+'), '_');
    final finalName = safeName.isEmpty ? 'plinky_debug' : safeName;
    downloadBytesToUser(bytes, '${finalName}_$suffix.bin');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(switch (_step) {
        _CreateDumpStep.form => 'Create flash dump',
        _CreateDumpStep.reading => 'Reading flash...',
        _CreateDumpStep.uploading => 'Uploading dump...',
        _CreateDumpStep.done => 'Dump saved',
        _CreateDumpStep.error => 'Error',
      }),
      content: SizedBox(
        width: 460,
        child: switch (_step) {
          _CreateDumpStep.form => _DumpFormView(
            titleController: _titleController,
            descriptionController: _descriptionController,
            chunkSizeController: _chunkSizeController,
            readInternal: _readInternal,
            readExternal: _readExternal,
            onToggleInternal: (value) => setState(() => _readInternal = value),
            onToggleExternal: (value) => setState(() => _readExternal = value),
            onChanged: () => setState(() {}),
          ),
          _CreateDumpStep.reading => _DumpProgressView(
            statusMessage: _statusMessage,
            progress: _progress,
          ),
          _CreateDumpStep.uploading => _DumpProgressView(
            statusMessage: _statusMessage,
            progress: null,
          ),
          _CreateDumpStep.done => _DumpDoneView(
            internalBytes: _capturedInternalBytes,
            externalBytes: _capturedExternalBytes,
            wasUploaded: _wasUploaded,
            onDownload: _downloadCapturedBytes,
          ),
          _CreateDumpStep.error => _DumpErrorView(
            errorMessage: _errorMessage ?? 'An unknown error occurred.',
            internalBytes: _capturedInternalBytes,
            externalBytes: _capturedExternalBytes,
            externalExpectedSize: _capturedExternalExpectedSize,
            onDownload: _downloadCapturedBytes,
          ),
        },
      ),
      actions: switch (_step) {
        _CreateDumpStep.form => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed:
                _titleController.text.trim().isEmpty ||
                    (!_readInternal && !_readExternal)
                ? null
                : _startDump,
            icon: Icons.usb,
            label: 'Connect & dump',
          ),
        ],
        _CreateDumpStep.reading || _CreateDumpStep.uploading => const [],
        _CreateDumpStep.done || _CreateDumpStep.error => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Close',
          ),
        ],
      },
    );
  }
}

class _DumpFormView extends StatelessWidget {
  const _DumpFormView({
    required this.titleController,
    required this.descriptionController,
    required this.chunkSizeController,
    required this.readInternal,
    required this.readExternal,
    required this.onToggleInternal,
    required this.onToggleExternal,
    required this.onChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController chunkSizeController;
  final bool readInternal;
  final bool readExternal;
  final ValueChanged<bool> onToggleInternal;
  final ValueChanged<bool> onToggleExternal;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Give this dump a title so you can find it later. '
          'The external flash is 32 MB and can take a '
          'few minutes to transfer.\n'
          'Deselect one region to skip it; the selected region is still '
          'uploaded to your account.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
          ),
          minLines: 3,
          maxLines: null,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: chunkSizeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Chunk size in bytes (optional)',
            border: OutlineInputBorder(),
            helperText:
                'When set, the region is read through many small requests '
                'of this size (workaround for the LPE firmware 5 s state '
                'timeout). Leave empty to request the whole region at once.',
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: readInternal,
          onChanged: (value) => onToggleInternal(value ?? false),
          title: const Text('Read internal flash (1 MB)'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: readExternal,
          onChanged: (value) => onToggleExternal(value ?? false),
          title: const Text('Read external flash (32 MB)'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}

class _DumpDoneView extends StatelessWidget {
  const _DumpDoneView({
    required this.internalBytes,
    required this.externalBytes,
    required this.wasUploaded,
    required this.onDownload,
  });

  final Uint8List? internalBytes;
  final Uint8List? externalBytes;
  final bool wasUploaded;
  final void Function(Uint8List bytes, String suffix) onDownload;

  @override
  Widget build(BuildContext context) {
    if (wasUploaded) {
      return const Text(
        'Your flash dump has been saved. '
        'You can download the binaries any time from the Dump tab.',
      );
    }
    final theme = Theme.of(context);
    final hasInternal = internalBytes != null;
    final hasExternal = externalBytes != null;
    final String what;
    if (hasInternal && !hasExternal) {
      what = 'Only the internal flash was read';
    } else if (hasExternal && !hasInternal) {
      what = 'Only the external flash was read';
    } else {
      what = 'Partial selection was read';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dump finished. $what, so it was not uploaded. '
          'Download the bytes directly:',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (internalBytes != null)
              PlinkyButton(
                onPressed: () => onDownload(internalBytes!, 'internal'),
                icon: Icons.download,
                label: 'Internal (${_formatBytes(internalBytes!.length)})',
              ),
            if (externalBytes != null)
              PlinkyButton(
                onPressed: () => onDownload(externalBytes!, 'external'),
                icon: Icons.download,
                label: 'External (${_formatBytes(externalBytes!.length)})',
              ),
          ],
        ),
      ],
    );
  }
}

class _DumpProgressView extends StatelessWidget {
  const _DumpProgressView({
    required this.statusMessage,
    required this.progress,
  });

  final String statusMessage;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final percentText = progress == null
        ? ''
        : ' (${(progress! * 100).toStringAsFixed(0)}%)';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$statusMessage$percentText'),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: progress),
      ],
    );
  }
}

class _DumpErrorView extends StatelessWidget {
  const _DumpErrorView({
    required this.errorMessage,
    required this.internalBytes,
    required this.externalBytes,
    required this.externalExpectedSize,
    required this.onDownload,
  });

  final String errorMessage;
  final Uint8List? internalBytes;
  final Uint8List? externalBytes;
  final int? externalExpectedSize;
  final void Function(Uint8List bytes, String suffix) onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCaptures = internalBytes != null || externalBytes != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          errorMessage,
          style: TextStyle(color: theme.colorScheme.error),
        ),
        if (hasCaptures) ...[
          const SizedBox(height: 16),
          Text(
            'Download the bytes captured before the error for debugging:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (internalBytes != null)
                PlinkyButton(
                  onPressed: () => onDownload(internalBytes!, 'internal'),
                  icon: Icons.download,
                  label: 'Internal (${_formatBytes(internalBytes!.length)})',
                ),
              if (externalBytes != null)
                PlinkyButton(
                  onPressed: () => onDownload(externalBytes!, 'external'),
                  icon: Icons.download,
                  label: externalExpectedSize != null
                      ? 'External partial '
                            '(${_formatBytes(externalBytes!.length)} / '
                            '${_formatBytes(externalExpectedSize!)})'
                      : 'External (${_formatBytes(externalBytes!.length)})',
                ),
            ],
          ),
        ],
      ],
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  if (bytes >= 1024 * 1024) {
    final megabytes = bytes / (1024 * 1024);
    return '${megabytes.toStringAsFixed(megabytes >= 10 ? 0 : 1)} MB';
  }
  if (bytes >= 1024) {
    final kilobytes = bytes / 1024;
    return '${kilobytes.toStringAsFixed(kilobytes >= 10 ? 0 : 1)} KB';
  }
  return '$bytes B';
}
