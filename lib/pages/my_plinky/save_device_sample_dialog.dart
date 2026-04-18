import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/pages/samples/models/sample_write.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/samples/sample_metadata_form.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveDeviceSampleDialog extends ConsumerStatefulWidget {
  const SaveDeviceSampleDialog({
    required this.pcmBytes,
    required this.sampleInfo,
    super.key,
  });

  final Uint8List pcmBytes;
  final ParsedSampleInfo? sampleInfo;

  @override
  ConsumerState<SaveDeviceSampleDialog> createState() =>
      _SaveDeviceSampleDialogState();
}

class _SaveDeviceSampleDialogState
    extends ConsumerState<SaveDeviceSampleDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late List<double> _slicePoints;
  late List<int> _sliceNotes;
  late bool _pitched;
  int _baseNote = 60;
  int _fineTune = 0;
  bool _isPublic = true;
  bool _isSaving = false;
  Uint8List? _wavBytes;

  @override
  void initState() {
    super.initState();
    final info = widget.sampleInfo;
    _slicePoints = info != null
        ? List.of(info.slicePoints)
        : List.of(defaultSlicePoints);
    _sliceNotes = info != null
        ? List.of(info.sliceNotes)
        : List.of(defaultSliceNotes);
    _pitched = info?.pitched ?? false;
    _wavBytes = plinkyPcmToWav(widget.pcmBytes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = ref.read(authenticationProvider).user?.id;
      if (userId == null) {
        return;
      }

      final pcmBytes = widget.pcmBytes;
      final wavBytes = _wavBytes!;
      final contentHash = computeContentHash(pcmBytes);
      final filePath = '$userId/$name.wav';
      final pcmFilePath = '$userId/$name.pcm';

      final supabase = Supabase.instance.client;

      await supabase.storage
          .from('samples')
          .uploadBinary(
            filePath,
            wavBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      await supabase.storage
          .from('samples')
          .uploadBinary(
            pcmFilePath,
            pcmBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final write = SampleWrite(
        userId: userId,
        name: name,
        filePath: filePath,
        pcmFilePath: pcmFilePath,
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
        slicePoints: _slicePoints,
        sliceNotes: _sliceNotes,
        pitched: _pitched,
        baseNote: _baseNote,
        fineTune: _fineTune,
        contentHash: contentHash,
      );
      final result = await supabase
          .from('samples')
          .insert(write.toJson())
          .select('id')
          .single();

      await ref.read(savedSamplesProvider.notifier).refreshAll();

      if (mounted) {
        Navigator.of(context).pop(result['id'] as String);
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $error')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pcmFrameCount = widget.pcmBytes.length ~/ 2;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save sample to cloud',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SampleMetadataForm(
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
                onSliceNotesChanged: (notes) =>
                    setState(() => _sliceNotes = notes),
                wavBytes: _wavBytes,
                pcmFrameCount: pcmFrameCount,
                sampleName: _nameController.text.isNotEmpty
                    ? _nameController.text
                    : 'device-sample',
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PlinkyButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Cancel',
                  ),
                  const SizedBox(width: 8),
                  PlinkyButton(
                    onPressed: _isSaving ? null : _save,
                    icon: Icons.save,
                    label: _isSaving ? 'Saving...' : 'Save',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
