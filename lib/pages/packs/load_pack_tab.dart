import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/pack_slot_write.dart';
import 'package:plinkyhub/models/pack_write.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/preset_write.dart';
import 'package:plinkyhub/models/sample_write.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/models/wavetable_write.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LoadStep { select, review, uploading, done, error }

class LoadPackTab extends ConsumerStatefulWidget {
  const LoadPackTab({this.onLoaded, super.key});

  final VoidCallback? onLoaded;

  @override
  ConsumerState<LoadPackTab> createState() =>
      _LoadPackTabState();
}

class _LoadPackTabState extends ConsumerState<LoadPackTab> {
  _LoadStep _step = _LoadStep.select;
  String _statusMessage = '';
  String? _errorMessage;

  // Parsed data from Plinky.
  List<Uint8List?> _presetDataList = [];
  List<ParsedSampleInfo?> _sampleInfos = [];
  Map<int, Uint8List> _samplePcmData = {};
  Uint8List? _wavetableUf2Bytes;

  // User-editable names and sharing toggles.
  final _packNameController = TextEditingController(
    text: '',
  );
  final _packDescriptionController =
      TextEditingController();
  bool _packIsPublic = true;
  final _presetNames = <int, TextEditingController>{};
  final _presetDescriptions = <int, TextEditingController>{};
  final _presetCategories = <int, PresetCategory>{};
  final _presetIsPublic = <int, bool>{};
  final _sampleNames = <int, TextEditingController>{};
  final _sampleDescriptions = <int, TextEditingController>{};
  final _sampleIsPublic = <int, bool>{};
  final _wavetableNameController = TextEditingController(
    text: 'Wavetable',
  );
  bool _wavetableIsPublic = true;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void dispose() {
    _packNameController.dispose();
    _packDescriptionController.dispose();
    _wavetableNameController.dispose();
    for (final controller in _presetNames.values) {
      controller.dispose();
    }
    for (final controller in _presetDescriptions.values) {
      controller.dispose();
    }
    for (final controller in _sampleNames.values) {
      controller.dispose();
    }
    for (final controller in _sampleDescriptions.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _reset() {
    for (final controller in _presetNames.values) {
      controller.dispose();
    }
    for (final controller in _presetDescriptions.values) {
      controller.dispose();
    }
    for (final controller in _sampleNames.values) {
      controller.dispose();
    }
    for (final controller in _sampleDescriptions.values) {
      controller.dispose();
    }
    setState(() {
      _step = _LoadStep.select;
      _statusMessage = '';
      _errorMessage = null;
      _presetDataList = [];
      _sampleInfos = [];
      _samplePcmData = {};
      _wavetableUf2Bytes = null;
      _packNameController.text = '';
      _packDescriptionController.clear();
      _packIsPublic = true;
      _presetNames.clear();
      _presetDescriptions.clear();
      _presetCategories.clear();
      _presetIsPublic.clear();
      _sampleNames.clear();
      _sampleDescriptions.clear();
      _sampleIsPublic.clear();
      _wavetableNameController.text = 'Wavetable';
      _wavetableIsPublic = true;
    });
  }

  Future<void> _readFromPlinky() async {
    final directory = await showDirectoryPicker();
    if (directory == null) {
      return;
    }

    setState(() {
      _step = _LoadStep.uploading;
      _statusMessage = 'Reading PRESETS.UF2...';
      _errorMessage = null;
    });

    try {
      final presetsUf2Bytes =
          await readFileFromDirectory(directory, 'PRESETS.UF2');
      if (presetsUf2Bytes == null) {
        throw Exception(
          'PRESETS.UF2 not found on the selected drive.',
        );
      }

      final flashImage = uf2ToData(presetsUf2Bytes);

      setState(() {
        _statusMessage = 'Parsing presets...';
      });
      _presetDataList =
          parsePresetsFromFlashImage(flashImage);
      _sampleInfos =
          parseSampleInfosFromFlashImage(flashImage);

      _samplePcmData = {};
      for (var i = 0; i < sampleCount; i++) {
        setState(() {
          _statusMessage = 'Reading SAMPLE$i.UF2...';
        });
        final sampleBytes =
            await readFileFromDirectory(directory, 'SAMPLE$i.UF2');
        if (sampleBytes != null &&
            sampleBytes.isNotEmpty) {
          try {
            final pcmData = uf2ToData(sampleBytes);
            if (pcmData.isNotEmpty &&
                !pcmData.every((byte) => byte == 0)) {
              _samplePcmData[i] = pcmData;
            }
          } on FormatException {
            // Skip invalid sample files.
          }
        }
      }

      setState(() {
        _statusMessage = 'Reading WAVETABLE.UF2...';
      });
      _wavetableUf2Bytes =
          await readFileFromDirectory(directory, 'WAVETABLE.UF2');

      // Build editable names from parsed data.
      _presetNames.clear();
      _presetDescriptions.clear();
      _presetCategories.clear();
      _presetIsPublic.clear();
      for (var i = 0; i < presetCount; i++) {
        final presetBytes = _presetDataList[i];
        if (presetBytes == null) {
          continue;
        }
        final preset = Preset(presetBytes.buffer);
        final name = preset.name.isNotEmpty
            ? preset.name
            : 'Preset ${i + 1}';
        _presetNames[i] =
            TextEditingController(text: name);
        _presetDescriptions[i] =
            TextEditingController();
        _presetCategories[i] = preset.category;
        _presetIsPublic[i] = true;
      }

      _sampleNames.clear();
      _sampleDescriptions.clear();
      _sampleIsPublic.clear();
      for (final slotIndex in _samplePcmData.keys) {
        _sampleNames[slotIndex] = TextEditingController(
          text: 'Sample $slotIndex',
        );
        _sampleDescriptions[slotIndex] =
            TextEditingController();
        _sampleIsPublic[slotIndex] = true;
      }

      if (_wavetableUf2Bytes != null &&
          _wavetableUf2Bytes!.isNotEmpty) {
        _wavetableNameController.text = 'Wavetable';
        _wavetableIsPublic = true;
      }

      setState(() {
        _step = _LoadStep.review;
      });
    } on Exception catch (error) {
      debugPrint('Failed to read from Plinky: $error');
      if (mounted) {
        setState(() {
          _step = _LoadStep.error;
          _errorMessage = error.toString();
        });
      }
    }
  }

  Future<void> _uploadAll() async {
    final userId =
        ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setState(() {
      _step = _LoadStep.uploading;
      _statusMessage = 'Uploading...';
    });

    try {
      // Upload samples.
      final sampleIdBySlot = <int, String>{};
      for (final entry in _samplePcmData.entries) {
        final slotIndex = entry.key;
        final pcmBytes = entry.value;
        final name = _sampleNames[slotIndex]?.text ??
            'Sample $slotIndex';
        final isPublic =
            _sampleIsPublic[slotIndex] ?? false;

        setState(() {
          _statusMessage =
              'Uploading sample "$name"...';
        });

        final wavBytes = plinkyPcmToWav(pcmBytes);
        final timestamp =
            DateTime.now().millisecondsSinceEpoch;
        final baseName = 'sample$slotIndex';
        final wavPath =
            '$userId/${baseName}_$timestamp.wav';
        final pcmPath =
            '$userId/${baseName}_$timestamp.pcm';

        await _supabase.storage
            .from('samples')
            .uploadBinary(
              wavPath,
              wavBytes,
              fileOptions:
                  const FileOptions(upsert: true),
            );
        await _supabase.storage
            .from('samples')
            .uploadBinary(
              pcmPath,
              pcmBytes,
              fileOptions:
                  const FileOptions(upsert: true),
            );

        final info = slotIndex < _sampleInfos.length
            ? _sampleInfos[slotIndex]
            : null;

        final description =
            _sampleDescriptions[slotIndex]?.text.trim() ??
                '';

        final sampleWrite = SampleWrite(
          userId: userId,
          name: name,
          filePath: wavPath,
          pcmFilePath: pcmPath,
          description: description,
          isPublic: isPublic,
          slicePoints: info?.slicePoints ??
              List.of(defaultSlicePoints),
          sliceNotes: info?.sliceNotes ??
              List.of(defaultSliceNotes),
          pitched: info?.pitched ?? false,
        );

        final sampleResponse = await _supabase
            .from('samples')
            .insert(sampleWrite.toJson())
            .select('id')
            .single();
        sampleIdBySlot[slotIndex] =
            sampleResponse['id'] as String;
      }

      // Upload wavetable.
      String? wavetableId;
      if (_wavetableUf2Bytes != null &&
          _wavetableUf2Bytes!.isNotEmpty) {
        setState(() {
          _statusMessage = 'Uploading wavetable...';
        });

        final timestamp =
            DateTime.now().millisecondsSinceEpoch;
        final wavetablePath =
            '$userId/wavetable_$timestamp.uf2';

        await _supabase.storage
            .from('wavetables')
            .uploadBinary(
              wavetablePath,
              _wavetableUf2Bytes!,
              fileOptions:
                  const FileOptions(upsert: true),
            );

        final wavetableWrite = WavetableWrite(
          userId: userId,
          name:
              _wavetableNameController.text.trim(),
          filePath: wavetablePath,
          isPublic: _wavetableIsPublic,
        );

        final wavetableResponse = await _supabase
            .from('wavetables')
            .insert(wavetableWrite.toJson())
            .select('id')
            .single();
        wavetableId =
            wavetableResponse['id'] as String;
      }

      // Upload presets.
      final presetIdBySlot = <int, String>{};
      for (final entry in _presetNames.entries) {
        final slotIndex = entry.key;
        final presetBytes =
            _presetDataList[slotIndex];
        if (presetBytes == null) {
          continue;
        }

        final name = entry.value.text.trim();
        final isPublic =
            _presetIsPublic[slotIndex] ?? false;

        setState(() {
          _statusMessage =
              'Uploading preset "$name"...';
        });

        final preset = Preset(presetBytes.buffer);
        final description =
            _presetDescriptions[slotIndex]?.text.trim() ??
                '';
        final category =
            _presetCategories[slotIndex] ??
                preset.category;

        final presetWrite = PresetWrite(
          userId: userId,
          name: name.isNotEmpty ? name : preset.name,
          category: category.name,
          presetData: base64Encode(presetBytes),
          description: description,
          isPublic: isPublic,
        );

        final presetResponse = await _supabase
            .from('presets')
            .insert(presetWrite.toJson())
            .select('id')
            .single();
        presetIdBySlot[slotIndex] =
            presetResponse['id'] as String;
      }

      // Create pack.
      setState(() {
        _statusMessage = 'Creating pack...';
      });

      final packWrite = PackWrite(
        userId: userId,
        name: _packNameController.text.trim(),
        description:
            _packDescriptionController.text.trim(),
        isPublic: _packIsPublic,
        wavetableId: wavetableId,
      );
      final packResponse = await _supabase
          .from('packs')
          .insert(packWrite.toJson())
          .select('id')
          .single();
      final packId = packResponse['id'] as String;

      // Insert pack slots.
      final slotRows = <Map<String, dynamic>>[];
      for (var i = 0; i < presetCount; i++) {
        final presetId = presetIdBySlot[i];
        String? sampleId;
        if (presetId != null) {
          final presetBytes = _presetDataList[i];
          if (presetBytes != null) {
            final preset =
                Preset(presetBytes.buffer);
            if (preset.usesSample) {
              for (final entry
                  in sampleIdBySlot.entries) {
                final raw =
                    sampleSlotToRaw(entry.key);
                final presetRaw = preset
                    .parameterById('P_SAMPLE')
                    ?.value;
                if (presetRaw != null &&
                    (presetRaw - raw).abs() < 2) {
                  sampleId = entry.value;
                  break;
                }
              }
            }
          }
        }

        if (presetId != null || sampleId != null) {
          slotRows.add(
            PackSlotWrite(
              packId: packId,
              slotNumber: i,
              presetId: presetId,
              sampleId: sampleId,
            ).toJson(),
          );
        }
      }

      if (slotRows.isNotEmpty) {
        await _supabase
            .from('pack_slots')
            .insert(slotRows);
      }

      await ref
          .read(savedPacksProvider.notifier)
          .fetchUserPacks();

      if (mounted) {
        setState(() {
          _step = _LoadStep.done;
          _statusMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pack loaded from Plinky'),
          ),
        );
        widget.onLoaded?.call();
      }
    } on Exception catch (error) {
      debugPrint('Failed to upload pack: $error');
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: switch (_step) {
            _LoadStep.select => _LoadSelectStep(
                onSelectDrive: _readFromPlinky,
              ),
            _LoadStep.review => _LoadReviewStep(
                presetNames: _presetNames,
                presetDescriptions: _presetDescriptions,
                presetCategories: _presetCategories,
                presetIsPublic: _presetIsPublic,
                sampleNames: _sampleNames,
                sampleDescriptions: _sampleDescriptions,
                sampleIsPublic: _sampleIsPublic,
                packNameController: _packNameController,
                packDescriptionController:
                    _packDescriptionController,
                packIsPublic: _packIsPublic,
                onPackIsPublicChanged: (value) =>
                    setState(() => _packIsPublic = value),
                wavetableNameController:
                    _wavetableNameController,
                wavetableIsPublic: _wavetableIsPublic,
                onWavetableIsPublicChanged: (value) =>
                    setState(
                  () => _wavetableIsPublic = value,
                ),
                hasWavetable:
                    _wavetableUf2Bytes != null &&
                        _wavetableUf2Bytes!.isNotEmpty,
                onBack: _reset,
                onSave: _uploadAll,
                onChanged: () => setState(() {}),
              ),
            _LoadStep.uploading => _LoadUploadingStep(
                statusMessage: _statusMessage,
              ),
            _LoadStep.done => _LoadDoneStep(
                onLoadAnother: _reset,
              ),
            _LoadStep.error => _LoadErrorStep(
                errorMessage: _errorMessage,
                onTryAgain: _reset,
              ),
          },
        ),
      ),
    );
  }
}

class _LoadSelectStep extends StatelessWidget {
  const _LoadSelectStep({required this.onSelectDrive});

  final VoidCallback onSelectDrive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Load all presets, samples, and wavetable '
          'from a Plinky in Tunnel of Lights mode. '
          'This will create a new pack with all the '
          'data from the device.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        const Text('1. Turn off your Plinky'),
        const SizedBox(height: 4),
        const Text(
          '2. Hold the rotary encoder while '
          'turning the Plinky on',
        ),
        const SizedBox(height: 4),
        const Text(
          '3. The Plinky will appear as a USB '
          'drive on your computer',
        ),
        const SizedBox(height: 16),
        PlinkyButton(
          onPressed: onSelectDrive,
          icon: Icons.folder_open,
          label: 'Select Plinky drive',
        ),
      ],
    );
  }
}

class _LoadReviewStep extends StatelessWidget {
  const _LoadReviewStep({
    required this.presetNames,
    required this.presetDescriptions,
    required this.presetCategories,
    required this.presetIsPublic,
    required this.sampleNames,
    required this.sampleDescriptions,
    required this.sampleIsPublic,
    required this.packNameController,
    required this.packDescriptionController,
    required this.packIsPublic,
    required this.onPackIsPublicChanged,
    required this.wavetableNameController,
    required this.wavetableIsPublic,
    required this.onWavetableIsPublicChanged,
    required this.hasWavetable,
    required this.onBack,
    required this.onSave,
    required this.onChanged,
  });

  final Map<int, TextEditingController> presetNames;
  final Map<int, TextEditingController> presetDescriptions;
  final Map<int, PresetCategory> presetCategories;
  final Map<int, bool> presetIsPublic;
  final Map<int, TextEditingController> sampleNames;
  final Map<int, TextEditingController> sampleDescriptions;
  final Map<int, bool> sampleIsPublic;
  final TextEditingController packNameController;
  final TextEditingController packDescriptionController;
  final bool packIsPublic;
  final ValueChanged<bool> onPackIsPublicChanged;
  final TextEditingController wavetableNameController;
  final bool wavetableIsPublic;
  final ValueChanged<bool> onWavetableIsPublicChanged;
  final bool hasWavetable;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Found ${presetNames.length} presets, '
          '${sampleNames.length} samples'
          '${hasWavetable ? ', and a wavetable' : ''} '
          'on the Plinky.\n\n'
          'Review the names and sharing '
          'settings below, then save.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pack',
          style:
              Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: packNameController,
          decoration: const InputDecoration(
            labelText: 'Pack name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: packDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        SwitchListTile(
          title: const Text('Share with community'),
          value: packIsPublic,
          onChanged: onPackIsPublicChanged,
        ),
        if (sampleNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Samples',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(height: 8),
          for (final slotIndex
              in sampleNames.keys.toList()..sort())
            _NamedItemRow(
              controller: sampleNames[slotIndex]!,
              label: 'Sample $slotIndex',
              isPublic:
                  sampleIsPublic[slotIndex] ?? false,
              onPublicToggled: () {
                sampleIsPublic[slotIndex] =
                    !(sampleIsPublic[slotIndex] ??
                        false);
                onChanged();
              },
              onEdit: () => _showSampleEditDialog(
                context,
                slotIndex,
              ),
            ),
        ],
        if (hasWavetable) ...[
          const SizedBox(height: 16),
          Text(
            'Wavetable',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(height: 8),
          _NamedItemRow(
            controller: wavetableNameController,
            label: 'Wavetable name',
            isPublic: wavetableIsPublic,
            onPublicToggled: () =>
                onWavetableIsPublicChanged(
              !wavetableIsPublic,
            ),
          ),
        ],
        if (presetNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Presets',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(height: 8),
          for (final slotIndex
              in presetNames.keys.toList()..sort())
            _NamedItemRow(
              controller:
                  presetNames[slotIndex]!,
              label:
                  'Preset ${slotIndex + 1}',
              isPublic:
                  presetIsPublic[slotIndex] ??
                      false,
              onPublicToggled: () {
                presetIsPublic[slotIndex] =
                    !(presetIsPublic[slotIndex] ??
                        false);
                onChanged();
              },
              onEdit: () => _showPresetEditDialog(
                context,
                slotIndex,
              ),
            ),
        ],
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              PlinkyButton(
                onPressed: onBack,
                icon: Icons.arrow_back,
                label: 'Back',
              ),
              PlinkyButton(
                onPressed: onSave,
                icon: Icons.cloud_upload,
                label: 'Save',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSampleEditDialog(
    BuildContext context,
    int slotIndex,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _SampleEditDialog(
        nameController: sampleNames[slotIndex]!,
        descriptionController:
            sampleDescriptions[slotIndex]!,
        isPublic: sampleIsPublic[slotIndex] ?? true,
        onIsPublicChanged: (value) {
          sampleIsPublic[slotIndex] = value;
          onChanged();
        },
      ),
    );
  }

  void _showPresetEditDialog(
    BuildContext context,
    int slotIndex,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _PresetEditDialog(
        nameController: presetNames[slotIndex]!,
        descriptionController:
            presetDescriptions[slotIndex]!,
        category: presetCategories[slotIndex] ??
            PresetCategory.none,
        onCategoryChanged: (value) {
          presetCategories[slotIndex] = value;
          onChanged();
        },
        isPublic: presetIsPublic[slotIndex] ?? true,
        onIsPublicChanged: (value) {
          presetIsPublic[slotIndex] = value;
          onChanged();
        },
      ),
    );
  }
}

class _NamedItemRow extends StatelessWidget {
  const _NamedItemRow({
    required this.controller,
    required this.label,
    required this.isPublic,
    required this.onPublicToggled,
    this.onEdit,
  });

  final TextEditingController controller;
  final String label;
  final bool isPublic;
  final VoidCallback onPublicToggled;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Share with community',
            child: IconButton(
              icon: Icon(
                isPublic
                    ? Icons.public
                    : Icons.public_off,
              ),
              onPressed: onPublicToggled,
            ),
          ),
          if (onEdit != null)
            Tooltip(
              message: 'Edit details',
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ),
        ],
      ),
    );
  }
}

class _SampleEditDialog extends StatelessWidget {
  const _SampleEditDialog({
    required this.nameController,
    required this.descriptionController,
    required this.isPublic,
    required this.onIsPublicChanged,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isPublic;
  final ValueChanged<bool> onIsPublicChanged;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Sample'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return SwitchListTile(
                  title: const Text(
                    'Share with community',
                  ),
                  value: isPublic,
                  onChanged: (value) {
                    onIsPublicChanged(value);
                    setDialogState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () =>
              Navigator.of(context).pop(),
          icon: Icons.check,
          label: 'Done',
        ),
      ],
    );
  }
}

class _PresetEditDialog extends StatelessWidget {
  const _PresetEditDialog({
    required this.nameController,
    required this.descriptionController,
    required this.category,
    required this.onCategoryChanged,
    required this.isPublic,
    required this.onIsPublicChanged,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final PresetCategory category;
  final ValueChanged<PresetCategory> onCategoryChanged;
  final bool isPublic;
  final ValueChanged<bool> onIsPublicChanged;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Preset'),
      content: SizedBox(
        width: 400,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            var currentCategory = category;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<
                    PresetCategory>(
                  initialValue: currentCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: PresetCategory.values
                      .map(
                        (category) =>
                            DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.label.isEmpty
                                ? 'None'
                                : category.label,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      currentCategory = value;
                      onCategoryChanged(value);
                      setDialogState(() {});
                    }
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text(
                    'Share with community',
                  ),
                  value: isPublic,
                  onChanged: (value) {
                    onIsPublicChanged(value);
                    setDialogState(() {});
                  },
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () =>
              Navigator.of(context).pop(),
          icon: Icons.check,
          label: 'Done',
        ),
      ],
    );
  }
}

class _LoadUploadingStep extends StatelessWidget {
  const _LoadUploadingStep({
    required this.statusMessage,
  });

  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(statusMessage),
      ],
    );
  }
}

class _LoadDoneStep extends StatelessWidget {
  const _LoadDoneStep({required this.onLoadAnother});

  final VoidCallback onLoadAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.check_circle,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        const Text('Pack loaded successfully!'),
        const SizedBox(height: 16),
        PlinkyButton(
          onPressed: onLoadAnother,
          icon: Icons.refresh,
          label: 'Load another',
        ),
      ],
    );
  }
}

class _LoadErrorStep extends StatelessWidget {
  const _LoadErrorStep({
    required this.errorMessage,
    required this.onTryAgain,
  });

  final String? errorMessage;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.error,
          size: 48,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          errorMessage ?? 'An unknown error occurred.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        PlinkyButton(
          onPressed: onTryAgain,
          icon: Icons.arrow_back,
          label: 'Try again',
        ),
      ],
    );
  }
}
