import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/utils/wt.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class UploadWavetableTab extends ConsumerStatefulWidget {
  const UploadWavetableTab({this.onUploaded, super.key});

  final VoidCallback? onUploaded;

  @override
  ConsumerState<UploadWavetableTab> createState() => _UploadWavetableTabState();
}

class _UploadWavetableTabState extends ConsumerState<UploadWavetableTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  bool _isPublic = true;
  bool _isUploading = false;
  String? _errorMessage;

  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _youtubeUrlController.clear();
      _isPublic = true;
      _isUploading = false;
      _errorMessage = null;
      _selectedFileName = null;
      _selectedFileBytes = null;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['uf2', 'wt'],
      withData: true,
    );

    final file = result?.files.single;
    final fileBytes = file?.bytes;
    if (file == null || fileBytes == null) {
      return;
    }

    try {
      final uf2Bytes = _convertToWavetableUf2(fileBytes);
      setState(() {
        _errorMessage = null;
        _selectedFileName = file.name;
        _selectedFileBytes = uf2Bytes;
        if (_nameController.text.trim().isEmpty) {
          // Pre-fill name from filename without extension.
          final baseName = file.name.replaceAll(
            RegExp(r'\.(uf2|wt)$', caseSensitive: false),
            '',
          );
          _nameController.text = baseName;
        }
      });
    } on FormatException catch (error) {
      setState(() {
        _errorMessage = error.message;
        _selectedFileName = null;
        _selectedFileBytes = null;
      });
    }
  }

  /// Converts a picked file into the internal wavetable UF2 format.
  ///
  /// `.wt` files are parsed and rendered into a wavetable UF2; `.uf2` files are
  /// validated as Plinky wavetables and used as-is. Throws [FormatException]
  /// if the file is neither.
  Uint8List _convertToWavetableUf2(Uint8List fileBytes) {
    if (isWtFile(fileBytes)) {
      final slots = wtToWavetableSamples(fileBytes);
      return generateWavetableUf2FromSamples(slots);
    }
    if (isWavetableUf2(fileBytes)) {
      return fileBytes;
    }
    throw const FormatException(
      'Unsupported file. Pick a Plinky wavetable UF2 or a .wt wavetable file.',
    );
  }

  Future<void> _upload() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null || _selectedFileBytes == null) {
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
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
        youtubeUrl: _youtubeUrlController.text.trim(),
      );

      await ref
          .read(savedWavetablesProvider.notifier)
          .saveWavetable(wavetable, uf2Bytes: _selectedFileBytes!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wavetable imported')),
        );
        _resetForm();
        widget.onUploaded?.call();
      }
    } on Exception catch (error) {
      debugPrint('Failed to upload wavetable: $error');
      setState(() {
        _isUploading = false;
        _errorMessage = error.toString();
      });
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Import a pre-built wavetable. Supported formats are a '
                'Plinky wavetable UF2 (.uf2) and a .wt wavetable file from '
                'editors such as WaveEdit or Serum. A .wt file is converted '
                'to the Plinky wavetable format automatically.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              PlinkyButton(
                onPressed: _isUploading ? null : _pickFile,
                icon: Icons.file_open,
                label: 'Pick wavetable file',
              ),
              const SizedBox(height: 12),
              if (_selectedFileName != null)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFileName!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Remove',
                      onPressed: _isUploading
                          ? null
                          : () => setState(() {
                              _selectedFileName = null;
                              _selectedFileBytes = null;
                            }),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                )
              else
                Text(
                  'No file selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
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
                minLines: 3,
                maxLines: null,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _youtubeUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL (optional)',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Share with community'),
                value: _isPublic,
                onChanged: _isUploading
                    ? null
                    : (value) => setState(() => _isPublic = value),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                CopyableErrorMessage(
                  message: _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'By uploading, you confirm that you own this '
                'wavetable or have the right to use and '
                'distribute it (e.g. under a Creative Commons '
                'licence or similar terms).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              PlinkyButton(
                onPressed: _isUploading || _selectedFileBytes == null
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
