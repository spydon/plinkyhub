import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/providers/firmwares_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class UploadFirmwareDialog extends ConsumerStatefulWidget {
  const UploadFirmwareDialog({super.key});

  @override
  ConsumerState<UploadFirmwareDialog> createState() =>
      _UploadFirmwareDialogState();
}

class _UploadFirmwareDialogState extends ConsumerState<UploadFirmwareDialog> {
  final _nameController = TextEditingController();
  final _versionController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _isBeta = false;
  PlatformFile? _selectedFile;
  var _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['uf2'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    final name = _nameController.text.trim();
    final version = _versionController.text.trim();
    final file = _selectedFile;
    if (name.isEmpty || version.isEmpty || file?.bytes == null) {
      return;
    }

    setState(() => _isUploading = true);
    try {
      await ref
          .read(firmwaresProvider.notifier)
          .uploadFirmware(
            name: name,
            version: version,
            description: _descriptionController.text.trim(),
            isBeta: _isBeta,
            fileBytes: file!.bytes!,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpload =
        _nameController.text.trim().isNotEmpty &&
        _versionController.text.trim().isNotEmpty &&
        _selectedFile?.bytes != null &&
        !_isUploading;

    return AlertDialog(
      title: const Text('Upload firmware'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _versionController,
              decoration: const InputDecoration(
                labelText: 'Version',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: null,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Beta'),
              value: _isBeta,
              onChanged: (value) => setState(() => _isBeta = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                PlinkyButton(
                  onPressed: _pickFile,
                  icon: Icons.attach_file,
                  label: 'Select .uf2 file',
                ),
                const SizedBox(width: 8),
                if (_selectedFile != null)
                  Expanded(
                    child: Text(
                      _selectedFile!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancel',
        ),
        PlinkyButton(
          onPressed: canUpload ? _upload : null,
          icon: Icons.upload,
          label: _isUploading ? 'Uploading...' : 'Upload',
        ),
      ],
    );
  }
}
