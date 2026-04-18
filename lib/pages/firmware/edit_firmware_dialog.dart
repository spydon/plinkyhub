import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/pages/firmware/providers/firmwares_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class EditFirmwareDialog extends ConsumerStatefulWidget {
  const EditFirmwareDialog({required this.firmware, super.key});

  final SavedFirmware firmware;

  @override
  ConsumerState<EditFirmwareDialog> createState() => _EditFirmwareDialogState();
}

class _EditFirmwareDialogState extends ConsumerState<EditFirmwareDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _versionController;
  late final TextEditingController _descriptionController;
  late bool _isBeta;
  late bool _isPinned;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.firmware.name);
    _versionController = TextEditingController(text: widget.firmware.version);
    _descriptionController = TextEditingController(
      text: widget.firmware.description,
    );
    _isBeta = widget.firmware.isBeta;
    _isPinned = widget.firmware.isPinned;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final version = _versionController.text.trim();
    if (name.isEmpty || version.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(firmwaresProvider.notifier)
          .updateFirmware(
            id: widget.firmware.id,
            name: name,
            version: version,
            description: _descriptionController.text.trim(),
            isBeta: _isBeta,
            isPinned: _isPinned,
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        _nameController.text.trim().isNotEmpty &&
        _versionController.text.trim().isNotEmpty &&
        !_isSaving;

    return AlertDialog(
      title: const Text('Edit firmware'),
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
            SwitchListTile(
              title: const Text('Pinned'),
              value: _isPinned,
              onChanged: (value) => setState(() => _isPinned = value),
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
          onPressed: canSave ? _save : null,
          icon: Icons.save,
          label: _isSaving ? 'Saving...' : 'Save',
        ),
      ],
    );
  }
}
