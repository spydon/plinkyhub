import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/pack_slot_write.dart';
import 'package:plinkyhub/models/pack_write.dart';
import 'package:plinkyhub/models/pattern_write.dart';
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
  ConsumerState<LoadPackTab> createState() => _LoadPackTabState();
}

class _LoadPackTabState extends ConsumerState<LoadPackTab> {
  _LoadStep _step = _LoadStep.select;
  String _statusMessage = '';
  String? _errorMessage;

  // Parsed data from Plinky.
  List<Uint8List?> _presetDataList = [];
  List<ParsedSampleInfo?> _sampleInfos = [];
  List<Uint8List?> _patternQuarters = [];
  Map<int, Uint8List> _samplePcmData = {};
  Uint8List? _wavetableUf2Bytes;

  // User-editable names and sharing toggles.
  final _packNameController = TextEditingController(
    text: '',
  );
  final _packDescriptionController = TextEditingController();
  bool _packIsPublic = true;
  final _presetNames = <int, TextEditingController>{};
  final _presetDescriptions = <int, TextEditingController>{};
  final _presetCategories = <int, PresetCategory>{};
  final _sampleNames = <int, TextEditingController>{};
  final _sampleDescriptions = <int, TextEditingController>{};
  final _wavetableNameController = TextEditingController(
    text: 'Wavetable',
  );
  final _wavetableDescriptionController = TextEditingController();
  final _patternNameController = TextEditingController(
    text: 'Patterns',
  );
  final _patternDescriptionController = TextEditingController();
  bool _includeWavetableInPack = true;
  bool _includePatternsInPack = true;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void dispose() {
    _packNameController.dispose();
    _packDescriptionController.dispose();
    _wavetableNameController.dispose();
    _wavetableDescriptionController.dispose();
    _patternNameController.dispose();
    _patternDescriptionController.dispose();
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
      _patternQuarters = [];
      _samplePcmData = {};
      _wavetableUf2Bytes = null;
      _packNameController.text = '';
      _packDescriptionController.clear();
      _packIsPublic = true;
      _presetNames.clear();
      _presetDescriptions.clear();
      _presetCategories.clear();
      _sampleNames.clear();
      _sampleDescriptions.clear();
      _wavetableNameController.text = 'Wavetable';
      _wavetableDescriptionController.clear();
      _patternNameController.text = 'Patterns';
      _patternDescriptionController.clear();
      _includeWavetableInPack = true;
      _includePatternsInPack = true;
    });
  }

  /// Returns true if the UF2 data is empty (all zeros or all 0xFF).
  bool _isEmptyUf2(Uint8List data) {
    return data.every((b) => b == 0) || data.every((b) => b == 0xFF);
  }

  /// Returns true if the PCM data is silent (all zeros, all 0xFF,
  /// or every 16-bit sample is the same value).
  bool _isSilentPcm(Uint8List pcmData) {
    if (pcmData.every((byte) => byte == 0) ||
        pcmData.every((byte) => byte == 0xFF)) {
      return true;
    }
    // Check as 16-bit samples — silent if every frame is identical.
    if (pcmData.length >= 2) {
      final view = Int16List.view(pcmData.buffer);
      final firstSample = view[0];
      if (view.every((sample) => sample == firstSample)) {
        return true;
      }
    }
    return false;
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
      final presetsUf2Bytes = await readFileFromDirectory(
        directory,
        'PRESETS.UF2',
      );
      if (presetsUf2Bytes == null) {
        throw Exception(
          'PRESETS.UF2 not found on the selected drive.',
        );
      }

      final flashImage = uf2ToData(presetsUf2Bytes);

      setState(() {
        _statusMessage = 'Parsing presets...';
      });
      final parsed = parseFlashImage(flashImage);
      _presetDataList = parsed.presets;
      _sampleInfos = parsed.sampleInfos;
      _patternQuarters = parsed.patternQuarters;

      _samplePcmData = {};
      for (var i = 0; i < sampleCount; i++) {
        // Skip samples where the sample info indicates no data.
        final sampleInfo = i < _sampleInfos.length ? _sampleInfos[i] : null;
        if (sampleInfo == null) {
          continue;
        }

        setState(() {
          _statusMessage = 'Reading SAMPLE$i.UF2...';
        });
        final sampleBytes = await readFileFromDirectory(
          directory,
          'SAMPLE$i.UF2',
        );
        if (sampleBytes != null && sampleBytes.isNotEmpty) {
          try {
            final pcmData = uf2ToData(sampleBytes);
            if (pcmData.isNotEmpty && !_isSilentPcm(pcmData)) {
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
      _wavetableUf2Bytes = await readFileFromDirectory(
        directory,
        'WAVETABLE.UF2',
      );
      if (_wavetableUf2Bytes != null && _isEmptyUf2(_wavetableUf2Bytes!)) {
        _wavetableUf2Bytes = null;
      }

      // Build editable names from parsed data.
      _presetNames.clear();
      _presetDescriptions.clear();
      _presetCategories.clear();
      for (var i = 0; i < presetCount; i++) {
        final presetBytes = _presetDataList[i];
        if (presetBytes == null) {
          continue;
        }
        final preset = Preset(presetBytes.buffer);
        if (preset.isEmpty) {
          _presetDataList[i] = null;
          continue;
        }
        final name = preset.name.isNotEmpty ? preset.name : 'Preset ${i + 1}';
        _presetNames[i] = TextEditingController(text: name);
        _presetDescriptions[i] = TextEditingController();
        _presetCategories[i] = preset.category;
      }

      _sampleNames.clear();
      _sampleDescriptions.clear();
      for (final slotIndex in _samplePcmData.keys) {
        _sampleNames[slotIndex] = TextEditingController(
          text: 'Sample $slotIndex',
        );
        _sampleDescriptions[slotIndex] = TextEditingController();
      }

      final hasWavetable =
          _wavetableUf2Bytes != null && _wavetableUf2Bytes!.isNotEmpty;
      _includeWavetableInPack = hasWavetable;
      if (hasWavetable) {
        _wavetableNameController.text = 'Wavetable';
        _wavetableDescriptionController.clear();
      }

      final hasPatterns = parsed.nonEmptyPatternCount > 0;
      _includePatternsInPack = hasPatterns;
      if (hasPatterns) {
        _patternNameController.text = 'Patterns';
        _patternDescriptionController.clear();
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
    final userId = ref.read(authenticationProvider).user?.id;
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
        final name = _sampleNames[slotIndex]?.text ?? 'Sample $slotIndex';

        setState(() {
          _statusMessage = 'Uploading sample "$name"...';
        });

        final wavBytes = plinkyPcmToWav(pcmBytes);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final baseName = 'sample$slotIndex';
        final wavPath = '$userId/${baseName}_$timestamp.wav';
        final pcmPath = '$userId/${baseName}_$timestamp.pcm';

        await _supabase.storage
            .from('samples')
            .uploadBinary(
              wavPath,
              wavBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        await _supabase.storage
            .from('samples')
            .uploadBinary(
              pcmPath,
              pcmBytes,
              fileOptions: const FileOptions(upsert: true),
            );

        final info = slotIndex < _sampleInfos.length
            ? _sampleInfos[slotIndex]
            : null;

        final description = _sampleDescriptions[slotIndex]?.text.trim() ?? '';

        final sampleWrite = SampleWrite(
          userId: userId,
          name: name,
          filePath: wavPath,
          pcmFilePath: pcmPath,
          description: description,
          isPublic: _packIsPublic,
          slicePoints: info?.slicePoints ?? List.of(defaultSlicePoints),
          sliceNotes: info?.sliceNotes ?? List.of(defaultSliceNotes),
          pitched: info?.pitched ?? false,
        );

        final sampleResponse = await _supabase
            .from('samples')
            .insert(sampleWrite.toJson())
            .select('id')
            .single();
        sampleIdBySlot[slotIndex] = sampleResponse['id'] as String;
      }

      // Upload wavetable.
      String? wavetableId;
      if (_includeWavetableInPack &&
          _wavetableUf2Bytes != null &&
          _wavetableUf2Bytes!.isNotEmpty) {
        setState(() {
          _statusMessage = 'Uploading wavetable...';
        });

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final wavetablePath = '$userId/wavetable_$timestamp.uf2';

        await _supabase.storage
            .from('wavetables')
            .uploadBinary(
              wavetablePath,
              _wavetableUf2Bytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        final wavetableWrite = WavetableWrite(
          userId: userId,
          name: _wavetableNameController.text.trim(),
          filePath: wavetablePath,
          description: _wavetableDescriptionController.text.trim(),
          isPublic: _packIsPublic,
        );

        final wavetableResponse = await _supabase
            .from('wavetables')
            .insert(wavetableWrite.toJson())
            .select('id')
            .single();
        wavetableId = wavetableResponse['id'] as String;
      }

      // Upload patterns (serialized pattern quarters from PRESETS.UF2).
      String? patternId;
      if (_includePatternsInPack &&
          _patternQuarters.any((q) => q != null)) {
        setState(() {
          _statusMessage = 'Uploading patterns...';
        });

        final patternBlob = serializePatternQuarters(_patternQuarters);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final patternPath = '$userId/patterns_$timestamp.bin';

        await _supabase.storage
            .from('patterns')
            .uploadBinary(
              patternPath,
              patternBlob,
              fileOptions: const FileOptions(upsert: true),
            );

        final patternWrite = PatternWrite(
          userId: userId,
          name: _patternNameController.text.trim(),
          filePath: patternPath,
          description: _patternDescriptionController.text.trim(),
          isPublic: _packIsPublic,
        );

        final patternResponse = await _supabase
            .from('patterns')
            .insert(patternWrite.toJson())
            .select('id')
            .single();
        patternId = patternResponse['id'] as String;
      }

      // Upload presets.
      final presetIdBySlot = <int, String>{};
      for (final entry in _presetNames.entries) {
        final slotIndex = entry.key;
        final presetBytes = _presetDataList[slotIndex];
        if (presetBytes == null) {
          continue;
        }

        final name = entry.value.text.trim();

        setState(() {
          _statusMessage = 'Uploading preset "$name"...';
        });

        final preset = Preset(presetBytes.buffer);
        final description = _presetDescriptions[slotIndex]?.text.trim() ?? '';
        final category = _presetCategories[slotIndex] ?? preset.category;

        final presetWrite = PresetWrite(
          userId: userId,
          name: name.isNotEmpty ? name : preset.name,
          category: category.name,
          presetData: base64Encode(presetBytes),
          description: description,
          isPublic: _packIsPublic,
        );

        final presetResponse = await _supabase
            .from('presets')
            .insert(presetWrite.toJson())
            .select('id')
            .single();
        presetIdBySlot[slotIndex] = presetResponse['id'] as String;
      }

      // Create pack.
      setState(() {
        _statusMessage = 'Creating pack...';
      });

      final packWrite = PackWrite(
        userId: userId,
        name: _packNameController.text.trim(),
        description: _packDescriptionController.text.trim(),
        isPublic: _packIsPublic,
        wavetableId: _includeWavetableInPack ? wavetableId : null,
        patternId: _includePatternsInPack ? patternId : null,
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
            final preset = Preset(presetBytes.buffer);
            if (preset.usesSample) {
              for (final entry in sampleIdBySlot.entries) {
                final raw = sampleSlotToRaw(entry.key);
                final presetRaw = preset.parameterById('P_SAMPLE')?.value;
                if (presetRaw != null && (presetRaw - raw).abs() < 2) {
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
        await _supabase.from('pack_slots').insert(slotRows);
      }

      await ref.read(savedPacksProvider.notifier).fetchUserPacks();

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
              sampleNames: _sampleNames,
              sampleDescriptions: _sampleDescriptions,
              samplePcmData: _samplePcmData,
              packNameController: _packNameController,
              packDescriptionController: _packDescriptionController,
              packIsPublic: _packIsPublic,
              onPackIsPublicChanged: (value) =>
                  setState(() => _packIsPublic = value),
              wavetableNameController: _wavetableNameController,
              wavetableDescriptionController:
                  _wavetableDescriptionController,
              hasWavetable:
                  _wavetableUf2Bytes != null && _wavetableUf2Bytes!.isNotEmpty,
              includeWavetable: _includeWavetableInPack,
              onIncludeWavetableChanged: (value) =>
                  setState(() => _includeWavetableInPack = value),
              patternNameController: _patternNameController,
              patternDescriptionController:
                  _patternDescriptionController,
              hasPatterns: _patternQuarters.any((q) => q != null),
              includePatterns: _includePatternsInPack,
              onIncludePatternsChanged: (value) =>
                  setState(() => _includePatternsInPack = value),
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
  const _LoadSelectStep({
    required this.onSelectDrive,
  });

  final VoidCallback onSelectDrive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Load all presets, samples, wavetable, and '
          'patterns from a Plinky in Tunnel of Lights '
          'mode. This will create a new pack with all '
          'the data from the device.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    required this.sampleNames,
    required this.sampleDescriptions,
    required this.samplePcmData,
    required this.packNameController,
    required this.packDescriptionController,
    required this.packIsPublic,
    required this.onPackIsPublicChanged,
    required this.wavetableNameController,
    required this.wavetableDescriptionController,
    required this.hasWavetable,
    required this.includeWavetable,
    required this.onIncludeWavetableChanged,
    required this.patternNameController,
    required this.patternDescriptionController,
    required this.hasPatterns,
    required this.includePatterns,
    required this.onIncludePatternsChanged,
    required this.onBack,
    required this.onSave,
    required this.onChanged,
  });

  final Map<int, TextEditingController> presetNames;
  final Map<int, TextEditingController> presetDescriptions;
  final Map<int, PresetCategory> presetCategories;
  final Map<int, TextEditingController> sampleNames;
  final Map<int, TextEditingController> sampleDescriptions;
  final Map<int, Uint8List> samplePcmData;
  final TextEditingController packNameController;
  final TextEditingController packDescriptionController;
  final bool packIsPublic;
  final ValueChanged<bool> onPackIsPublicChanged;
  final TextEditingController wavetableNameController;
  final TextEditingController wavetableDescriptionController;
  final bool hasWavetable;
  final bool includeWavetable;
  final ValueChanged<bool> onIncludeWavetableChanged;
  final TextEditingController patternNameController;
  final TextEditingController patternDescriptionController;
  final bool hasPatterns;
  final bool includePatterns;
  final ValueChanged<bool> onIncludePatternsChanged;
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
          '${hasWavetable ? ', a wavetable' : ''}'
          '${hasPatterns ? '${hasWavetable ? ',' : ''} and patterns' : ''} '
          'on the Plinky.\n\n'
          'Review the names and sharing '
          'settings below, then save.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pack',
          style: Theme.of(context).textTheme.titleMedium,
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final slotIndex in sampleNames.keys.toList()..sort())
            _SamplePreviewRow(
              controller: sampleNames[slotIndex]!,
              label: 'Sample $slotIndex',
              pcmData: samplePcmData[slotIndex],
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile(
            title: const Text('Include in pack'),
            value: includeWavetable,
            onChanged: onIncludeWavetableChanged,
          ),
          if (includeWavetable)
            _NamedItemRow(
              controller: wavetableNameController,
              label: 'Wavetable name',
              onEdit: () => _showWavetableEditDialog(context),
            ),
        ],
        if (hasPatterns) ...[
          const SizedBox(height: 16),
          Text(
            'Patterns',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile(
            title: const Text('Include in pack'),
            value: includePatterns,
            onChanged: onIncludePatternsChanged,
          ),
          if (includePatterns)
            _NamedItemRow(
              controller: patternNameController,
              label: 'Patterns name',
              onEdit: () => _showPatternEditDialog(context),
            ),
        ],
        if (presetNames.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Presets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final slotIndex in presetNames.keys.toList()..sort())
            _NamedItemRow(
              controller: presetNames[slotIndex]!,
              label: 'Preset ${slotIndex + 1}',
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
      builder: (context) => _NameDescriptionEditDialog(
        title: 'Edit Sample',
        nameController: sampleNames[slotIndex]!,
        descriptionController: sampleDescriptions[slotIndex]!,
      ),
    );
  }

  void _showWavetableEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _NameDescriptionEditDialog(
        title: 'Edit Wavetable',
        nameController: wavetableNameController,
        descriptionController: wavetableDescriptionController,
      ),
    );
  }

  void _showPatternEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _NameDescriptionEditDialog(
        title: 'Edit Patterns',
        nameController: patternNameController,
        descriptionController: patternDescriptionController,
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
        descriptionController: presetDescriptions[slotIndex]!,
        category: presetCategories[slotIndex] ?? PresetCategory.none,
        onCategoryChanged: (value) {
          presetCategories[slotIndex] = value;
          onChanged();
        },
      ),
    );
  }
}

class _SamplePreviewRow extends StatefulWidget {
  const _SamplePreviewRow({
    required this.controller,
    required this.label,
    this.pcmData,
    this.onEdit,
  });

  final TextEditingController controller;
  final String label;
  final Uint8List? pcmData;
  final VoidCallback? onEdit;

  @override
  State<_SamplePreviewRow> createState() => _SamplePreviewRowState();
}

class _SamplePreviewRowState extends State<_SamplePreviewRow> {
  AudioSource? _audioSource;
  SoundHandle? _activeHandle;
  bool _isPlaying = false;

  @override
  void dispose() {
    _stopAndDispose();
    super.dispose();
  }

  void _stopAndDispose() {
    final handle = _activeHandle;
    if (handle != null) {
      SoLoud.instance.stop(handle);
      _activeHandle = null;
    }
    final source = _audioSource;
    if (source != null) {
      SoLoud.instance.disposeSource(source);
      _audioSource = null;
    }
  }

  Future<void> _togglePlayback() async {
    final soloud = SoLoud.instance;

    if (_isPlaying && _activeHandle != null) {
      await soloud.stop(_activeHandle!);
      setState(() {
        _activeHandle = null;
        _isPlaying = false;
      });
      return;
    }

    final pcmData = widget.pcmData;
    if (pcmData == null) {
      return;
    }

    if (!soloud.isInitialized) {
      await soloud.init();
    }

    if (_audioSource == null) {
      final wavBytes = plinkyPcmToWav(pcmData);
      _audioSource = await soloud.loadMem('preview.wav', wavBytes);
    }

    final handle = await soloud.play(_audioSource!);
    setState(() {
      _activeHandle = handle;
      _isPlaying = true;
    });

    final duration = soloud.getLength(_audioSource!);
    await Future<void>.delayed(duration);
    if (mounted && _isPlaying) {
      setState(() {
        _activeHandle = null;
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (widget.pcmData != null)
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.stop : Icons.play_arrow,
                size: 20,
              ),
              tooltip: _isPlaying ? 'Stop' : 'Play',
              onPressed: _togglePlayback,
            ),
          if (widget.onEdit != null)
            Tooltip(
              message: 'Edit details',
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: widget.onEdit,
              ),
            ),
        ],
      ),
    );
  }
}

class _NamedItemRow extends StatelessWidget {
  const _NamedItemRow({
    required this.controller,
    required this.label,
    this.onEdit,
  });

  final TextEditingController controller;
  final String label;
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

class _NameDescriptionEditDialog extends StatelessWidget {
  const _NameDescriptionEditDialog({
    required this.title,
    required this.nameController,
    required this.descriptionController,
  });

  final String title;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
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
          ],
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
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
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final PresetCategory category;
  final ValueChanged<PresetCategory> onCategoryChanged;

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
                DropdownButtonFormField<PresetCategory>(
                  initialValue: currentCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: PresetCategory.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.label.isEmpty ? 'None' : category.label,
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
              ],
            );
          },
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () => Navigator.of(context).pop(),
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
