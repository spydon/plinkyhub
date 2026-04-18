import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/pack_upload_request.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_packs_notifier.dart';
import 'package:plinkyhub/state/sound_service.dart';
import 'package:plinkyhub/utils/constants.dart';
import 'package:plinkyhub/utils/content_hash.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/plinky_device_parser.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/wav.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/widgets/chromium_required_banner.dart';
import 'package:plinkyhub/widgets/linked_item_icon.dart';
import 'package:plinkyhub/widgets/loading_indicator.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LoadStep { select, review, uploading, done, error }

/// Info about a public entry that matches content loaded from Plinky.
class MatchedEntry {
  const MatchedEntry({required this.id, required this.name});

  final String id;
  final String name;
}

class LoadPackTab extends ConsumerStatefulWidget {
  const LoadPackTab({this.onLoaded, super.key});

  final VoidCallback? onLoaded;

  @override
  ConsumerState<LoadPackTab> createState() => _LoadPackTabState();
}

class _LoadPackTabState extends ConsumerState<LoadPackTab> {
  _LoadStep _step = _LoadStep.select;
  String _statusMessage = '';
  double? _progress;
  String? _errorMessage;

  // Parsed data from Plinky.
  List<Uint8List?> _presetDataList = [];
  List<ParsedSampleInfo?> _sampleInfos = [];
  List<Uint8List?> _patternQuarters = [];
  Map<int, Uint8List> _samplePcmData = {};
  Set<int> _emptySampleSlots = {};
  Uint8List? _wavetableUf2Bytes;

  // User-editable names and sharing toggles.
  final _packNameController = TextEditingController(
    text: '',
  );
  final _packDescriptionController = TextEditingController();
  final _packYoutubeUrlController = TextEditingController();
  bool _packIsPublic = true;
  final _presetNames = <int, TextEditingController>{};
  final _presetDescriptions = <int, TextEditingController>{};
  final _presetCategories = <int, PresetCategory>{};
  // Tracks which presets have a name from the device (not derived).
  final _presetsWithDeviceName = <int>{};
  final _sampleNames = <int, TextEditingController>{};
  final _sampleDescriptions = <int, TextEditingController>{};
  final _wavetableNameController = TextEditingController();
  final _wavetableDescriptionController = TextEditingController();
  final _patternNames = <int, TextEditingController>{};
  final _patternDescriptions = <int, TextEditingController>{};
  bool _includeWavetableInPack = true;
  bool _includePatternsInPack = true;

  // Tracks which sample is currently playing so others can stop.
  final _activeSampleNotifier = ValueNotifier<String?>(null);

  // Content hashes computed from Plinky data.
  final _presetHashes = <int, String>{};
  final _sampleHashes = <int, String>{};
  String? _wavetableHash;
  final _patternHashes = <int, String>{};

  // Matched existing public entries (slot/pattern index -> entry).
  final _matchedPresets = <int, MatchedEntry>{};
  final _matchedSamples = <int, MatchedEntry>{};
  MatchedEntry? _matchedWavetable;
  final _matchedPatterns = <int, MatchedEntry>{};

  // Existing pack that matches the loaded content (null if none).
  SavedPack? _matchedPack;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _packNameController.addListener(_updateDerivedNames);
  }

  /// Updates names of items that don't have a device name or matched entry
  /// to match the pack name with an appended number.
  void _updateDerivedNames() {
    final packName = _packNameController.text.trim();
    for (final entry in _presetNames.entries) {
      if (!_presetsWithDeviceName.contains(entry.key) &&
          !_matchedPresets.containsKey(entry.key)) {
        entry.value.text = packName.isEmpty
            ? ''
            : '$packName - ${entry.key + 1}';
      }
    }
    for (final entry in _sampleNames.entries) {
      if (!_matchedSamples.containsKey(entry.key)) {
        entry.value.text = packName.isEmpty
            ? ''
            : '$packName - ${entry.key + 1}';
      }
    }
    for (final entry in _patternNames.entries) {
      if (!_matchedPatterns.containsKey(entry.key)) {
        entry.value.text = packName.isEmpty
            ? ''
            : '$packName - ${entry.key + 1}';
      }
    }
    if (_matchedWavetable == null) {
      _wavetableNameController.text = packName;
    }
  }

  @override
  void dispose() {
    _packNameController.removeListener(_updateDerivedNames);
    _packNameController.dispose();
    _packDescriptionController.dispose();
    _packYoutubeUrlController.dispose();
    _activeSampleNotifier.dispose();
    _wavetableNameController.dispose();
    _wavetableDescriptionController.dispose();
    for (final controller in _patternNames.values) {
      controller.dispose();
    }
    for (final controller in _patternDescriptions.values) {
      controller.dispose();
    }
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
    // Collect controllers to dispose after clearing the maps,
    // so _updateDerivedNames doesn't touch disposed controllers.
    final controllersToDispose = [
      ..._presetNames.values,
      ..._presetDescriptions.values,
      ..._sampleNames.values,
      ..._sampleDescriptions.values,
      ..._patternNames.values,
      ..._patternDescriptions.values,
    ];

    setState(() {
      _step = _LoadStep.select;
      _statusMessage = '';
      _errorMessage = null;
      _presetDataList = [];
      _sampleInfos = [];
      _patternQuarters = [];
      _samplePcmData = {};
      _emptySampleSlots = {};
      _wavetableUf2Bytes = null;
      _presetNames.clear();
      _presetDescriptions.clear();
      _presetCategories.clear();
      _presetsWithDeviceName.clear();
      _sampleNames.clear();
      _sampleDescriptions.clear();
      _patternNames.clear();
      _patternDescriptions.clear();
      _matchedPresets.clear();
      _matchedSamples.clear();
      _matchedWavetable = null;
      _matchedPatterns.clear();
      _matchedPack = null;
      // Set pack name after clearing maps so the listener
      // iterates empty maps instead of disposed controllers.
      _packNameController.text = '';
      _packDescriptionController.clear();
      _packYoutubeUrlController.clear();
      _packIsPublic = true;
      _wavetableNameController.clear();
      _wavetableDescriptionController.clear();
      _includeWavetableInPack = true;
      _includePatternsInPack = true;
      _presetHashes.clear();
      _sampleHashes.clear();
      _wavetableHash = null;
      _patternHashes.clear();
    });

    for (final controller in controllersToDispose) {
      controller.dispose();
    }
  }

  Future<void> _readFromPlinky() async {
    final directory = await showDirectoryPicker();
    if (directory == null) {
      return;
    }

    // Total steps: 1 (presets) + sampleCount (samples) + 1 (wavetable)
    // + 1 (parse presets) + 1 (parse samples) + 1 (check wavetable)
    // = sampleCount + 5.
    const totalSteps = sampleCount + 5;
    var completedSteps = 0;

    void updateProgress(String message) {
      completedSteps++;
      setState(() {
        _statusMessage = message;
        _progress = completedSteps / totalSteps;
      });
    }

    setState(() {
      _step = _LoadStep.uploading;
      _statusMessage = 'Reading files from Plinky...';
      _progress = 0;
      _errorMessage = null;
    });

    try {
      // Read all files on the main thread (File System Access API
      // requires it).
      final presetsUf2Bytes = await readFileFromDirectory(
        directory,
        'PRESETS.UF2',
      );
      if (presetsUf2Bytes == null) {
        throw Exception(
          'PRESETS.UF2 not found on the selected drive.',
        );
      }

      final sampleUf2s = <Uint8List?>[];
      for (var i = 0; i < sampleCount; i++) {
        updateProgress('Reading SAMPLE$i.UF2...');
        sampleUf2s.add(
          await readFileFromDirectory(directory, 'SAMPLE$i.UF2'),
        );
      }

      updateProgress('Reading CURRENT.UF2...');
      final currentUf2Bytes = await readFileFromDirectory(
        directory,
        'CURRENT.UF2',
      );
      final wavetablePayload = currentUf2Bytes != null
          ? extractWavetablePayloadFromCurrentUf2(currentUf2Bytes)
          : null;
      _wavetableUf2Bytes = wavetablePayload != null
          ? packWavetableUf2(wavetablePayload)
          : null;

      // Parse device data on the main thread, yielding to the UI
      // between phases (Isolate.run is not supported in WASM).

      // Phase 1: Parse presets and patterns.
      updateProgress('Parsing presets...');
      await Future<void>.delayed(Duration.zero);
      final presetsResult = parsePresetsPhase(presetsUf2Bytes);

      // Phase 2: Parse samples.
      final samplesResult = await parseSamplesPhase(
        SamplesPhaseInput(
          sampleUf2s: sampleUf2s,
          sampleInfos: presetsResult.sampleInfos,
        ),
        onSampleParsing: (index) {
          setState(() => _statusMessage = 'Parsing sample $index...');
        },
      );

      // Phase 3: Check wavetable.
      updateProgress('Checking wavetable...');
      await Future<void>.delayed(Duration.zero);
      final wavetableResult = parseWavetablePhase(_wavetableUf2Bytes);

      final result = ParsedPlinkyDevice(
        presets: presetsResult.presets,
        sampleInfos: presetsResult.sampleInfos,
        rawSampleInfos: presetsResult.rawSampleInfos,
        patternQuarters: presetsResult.patternQuarters,
        nonEmptyPatternIndices: presetsResult.nonEmptyPatternIndices,
        samplePcmData: samplesResult.samplePcmData,
        emptySampleSlots: samplesResult.emptySampleSlots,
        presetHashes: presetsResult.presetHashes,
        sampleHashes: samplesResult.sampleHashes,
        wavetableHash: wavetableResult.wavetableHash,
        patternHashes: presetsResult.patternHashes,
        deviceHasWavetable: wavetableResult.deviceHasWavetable,
      );

      // Store parsed results.
      _presetDataList = result.presets;
      _sampleInfos = result.sampleInfos;
      _patternQuarters = result.patternQuarters;
      _samplePcmData = result.samplePcmData;
      _emptySampleSlots = result.emptySampleSlots;

      // Use hashes from parsed result.
      _presetHashes
        ..clear()
        ..addAll(result.presetHashes);
      _sampleHashes
        ..clear()
        ..addAll(result.sampleHashes);
      _wavetableHash = result.wavetableHash;
      _patternHashes
        ..clear()
        ..addAll(result.patternHashes);

      // Normalize wavetable bytes based on parsed result.
      if (!result.deviceHasWavetable) {
        _wavetableUf2Bytes = null;
      }

      // Build editable names from parsed data.
      _presetNames.clear();
      _presetDescriptions.clear();
      _presetCategories.clear();
      _presetsWithDeviceName.clear();
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
        if (preset.name.isNotEmpty) {
          _presetsWithDeviceName.add(i);
        }
        _presetNames[i] = TextEditingController(
          text: preset.name.isNotEmpty ? preset.name : '',
        );
        _presetDescriptions[i] = TextEditingController();
        _presetCategories[i] = preset.category;
      }

      _sampleNames.clear();
      _sampleDescriptions.clear();
      for (final slotIndex in _samplePcmData.keys) {
        _sampleNames[slotIndex] = TextEditingController(text: '');
        _sampleDescriptions[slotIndex] = TextEditingController();
      }

      final hasWavetable =
          _wavetableUf2Bytes != null && _wavetableUf2Bytes!.isNotEmpty;
      _includeWavetableInPack = hasWavetable;
      if (hasWavetable) {
        _wavetableNameController.clear();
        _wavetableDescriptionController.clear();
      }

      _patternNames.clear();
      _patternDescriptions.clear();
      for (final patternIndex in result.nonEmptyPatternIndices) {
        _patternNames[patternIndex] = TextEditingController(text: '');
        _patternDescriptions[patternIndex] = TextEditingController();
      }
      _includePatternsInPack = _patternNames.isNotEmpty;

      // Find existing public matches using precomputed hashes.
      setState(() {
        _statusMessage = 'Checking for existing content...';
      });
      _matchedPresets.clear();
      _matchedSamples.clear();
      _matchedWavetable = null;
      _matchedPatterns.clear();

      await Future.wait([
        _findMatches('presets', _presetHashes, _matchedPresets),
        _findMatches('samples', _sampleHashes, _matchedSamples),
        _findMatches(
          'patterns',
          _patternHashes,
          _matchedPatterns,
        ),
        _findWavetableMatch(),
      ]);

      // Set names from matched entries.
      for (final entry in _matchedPresets.entries) {
        _presetNames[entry.key]?.text = entry.value.name;
        _presetsWithDeviceName.add(entry.key);
      }
      for (final entry in _matchedSamples.entries) {
        _sampleNames[entry.key]?.text = entry.value.name;
      }
      if (_matchedWavetable != null) {
        _wavetableNameController.text = _matchedWavetable!.name;
      }
      for (final entry in _matchedPatterns.entries) {
        _patternNames[entry.key]?.text = entry.value.name;
      }

      _matchedPack = await _findDuplicatePack();

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

  Future<void> _findMatches(
    String table,
    Map<int, String> hashes,
    Map<int, MatchedEntry> matches,
  ) async {
    if (hashes.isEmpty) {
      return;
    }

    final uniqueHashes = hashes.values.toSet().toList();
    final results = await _supabase
        .from(table)
        .select('id, name, content_hash')
        .eq('is_public', true)
        .inFilter('content_hash', uniqueHashes);

    final hashToEntry = <String, MatchedEntry>{};
    for (final row in results) {
      final hash = row['content_hash'] as String?;
      if (hash != null) {
        hashToEntry[hash] = MatchedEntry(
          id: row['id'] as String,
          name: row['name'] as String,
        );
      }
    }

    for (final entry in hashes.entries) {
      final matched = hashToEntry[entry.value];
      if (matched != null) {
        matches[entry.key] = matched;
      }
    }
  }

  Future<void> _findWavetableMatch() async {
    if (_wavetableHash == null) {
      return;
    }

    final results = await _supabase
        .from('wavetables')
        .select('id, name, content_hash')
        .eq('is_public', true)
        .eq('content_hash', _wavetableHash!)
        .limit(1);

    if (results.isNotEmpty) {
      _matchedWavetable = MatchedEntry(
        id: results.first['id'] as String,
        name: results.first['name'] as String,
      );
    }
  }

  /// Computes the content hash for the current device data.
  String _computePackHash() {
    return computePackContentHash(
      presetHashes: _presetHashes,
      sampleHashes: _sampleHashes,
      patternHashes: _patternHashes,
    );
  }

  /// Checks if an existing pack already contains all the same content
  /// by comparing the pack content hash.
  Future<SavedPack?> _findDuplicatePack() async {
    final packHash = _computePackHash();

    // Check locally loaded packs first.
    final packsState = ref.read(savedPacksProvider);
    final allLocalPacks = [
      ...packsState.userItems,
      ...packsState.publicItems,
    ];
    for (final pack in allLocalPacks) {
      if (pack.contentHash == packHash) {
        return pack;
      }
    }

    // Query the database for any pack with the same hash.
    final results = await _supabase
        .from('packs')
        .select(
          '*, pack_slots(*), profiles(username), '
          'pack_stars(count)',
        )
        .eq('content_hash', packHash)
        .limit(1);

    if (results.isNotEmpty) {
      return SavedPack.fromJson(
        results.first,
      );
    }

    return null;
  }

  void _showDuplicatePackDialog(SavedPack pack) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pack already exists'),
        content: Text(
          'A pack with the same content already exists: '
          '"${pack.name}".',
        ),
        actions: [
          PlinkyButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            icon: Icons.close,
            label: 'Cancel',
          ),
          if (pack.username.isNotEmpty)
            PlinkyButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(
                  AppRoute.packs.itemPage(
                    pack.username,
                    pack.name,
                  ),
                );
              },
              icon: Icons.open_in_new,
              label: 'View pack',
            ),
        ],
      ),
    );
  }

  Future<void> _uploadAll() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    // Check for duplicate pack before uploading.
    final duplicatePack = await _findDuplicatePack();
    if (duplicatePack != null && mounted) {
      _showDuplicatePackDialog(duplicatePack);
      return;
    }

    setState(() {
      _step = _LoadStep.uploading;
      _statusMessage = 'Uploading...';
    });

    // Track uploaded storage paths for cleanup on failure.
    final uploadedSamplePaths = <String>[];
    final uploadedWavetablePaths = <String>[];
    final uploadedPatternPaths = <String>[];

    try {
      // Phase 1: Upload all files to storage.

      // Upload sample files (skip matched entries).
      final sampleUploads = <PackUploadSample>[];
      for (final entry in _samplePcmData.entries) {
        final slotIndex = entry.key;
        final matched = _matchedSamples[slotIndex];

        if (matched != null) {
          sampleUploads.add(
            PackUploadSample(
              slotIndex: slotIndex,
              userId: userId,
              name: matched.name,
              filePath: '',
              pcmFilePath: '',
              existingId: matched.id,
            ),
          );
          continue;
        }

        final pcmBytes = entry.value;
        final name =
            _sampleNames[slotIndex]?.text.trim() ?? 'Sample $slotIndex';

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
        uploadedSamplePaths.add(wavPath);

        await _supabase.storage
            .from('samples')
            .uploadBinary(
              pcmPath,
              pcmBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        uploadedSamplePaths.add(pcmPath);

        final info = slotIndex < _sampleInfos.length
            ? _sampleInfos[slotIndex]
            : null;

        sampleUploads.add(
          PackUploadSample(
            slotIndex: slotIndex,
            userId: userId,
            name: name,
            filePath: wavPath,
            pcmFilePath: pcmPath,
            description: _sampleDescriptions[slotIndex]?.text.trim() ?? '',
            isPublic: _packIsPublic,
            slicePoints:
                info?.slicePoints ?? List<double>.of(defaultSlicePoints),
            sliceNotes: info?.sliceNotes ?? List<int>.of(defaultSliceNotes),
            pitched: info?.pitched ?? false,
            contentHash: _sampleHashes[slotIndex],
          ),
        );
      }

      // Upload wavetable file (skip if matched).
      // Every pack must have a wavetable, fall back to the default.
      PackUploadWavetable wavetableUpload;
      if (_includeWavetableInPack &&
          _wavetableUf2Bytes != null &&
          _wavetableUf2Bytes!.isNotEmpty) {
        if (_matchedWavetable != null) {
          wavetableUpload = PackUploadWavetable(
            userId: userId,
            name: _matchedWavetable!.name,
            filePath: '',
            existingId: _matchedWavetable!.id,
          );
        } else {
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
          uploadedWavetablePaths.add(wavetablePath);

          wavetableUpload = PackUploadWavetable(
            userId: userId,
            name: _wavetableNameController.text.trim(),
            filePath: wavetablePath,
            description: _wavetableDescriptionController.text.trim(),
            isPublic: _packIsPublic,
            contentHash: _wavetableHash,
          );
        }
      } else {
        wavetableUpload = const PackUploadWavetable(
          userId: '',
          name: 'Wavetable',
          filePath: '',
          existingId: defaultWavetableId,
        );
      }

      // Upload pattern files (skip matched entries).
      final patternUploads = <PackUploadPattern>[];
      if (_includePatternsInPack) {
        for (final entry in _patternNames.entries) {
          final patternIndex = entry.key;
          final matched = _matchedPatterns[patternIndex];

          if (matched != null) {
            patternUploads.add(
              PackUploadPattern(
                patternIndex: patternIndex,
                userId: userId,
                name: matched.name,
                filePath: '',
                existingId: matched.id,
              ),
            );
            continue;
          }

          final name = entry.value.text.trim();

          setState(() {
            _statusMessage = 'Uploading pattern "$name"...';
          });

          final quarterStart = patternIndex * 4;
          final quarters = List<Uint8List?>.filled(
            _patternQuarters.length,
            null,
          );
          for (var q = 0; q < 4; q++) {
            final index = quarterStart + q;
            if (index < _patternQuarters.length) {
              quarters[index] = _patternQuarters[index];
            }
          }

          final patternBlob = serializePatternQuarters(quarters);
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final patternPath = '$userId/pattern${patternIndex}_$timestamp.bin';

          await _supabase.storage
              .from('patterns')
              .uploadBinary(
                patternPath,
                patternBlob,
                fileOptions: const FileOptions(upsert: true),
              );
          uploadedPatternPaths.add(patternPath);

          patternUploads.add(
            PackUploadPattern(
              patternIndex: patternIndex,
              userId: userId,
              name: name,
              filePath: patternPath,
              description:
                  _patternDescriptions[patternIndex]?.text.trim() ?? '',
              isPublic: _packIsPublic,
              contentHash: _patternHashes[patternIndex],
            ),
          );
        }
      }

      // Phase 2: Insert all DB rows in a single transaction via RPC.
      setState(() {
        _statusMessage = 'Creating pack...';
      });

      // Build preset data (skip matched entries).
      // Pre-compute raw P_SAMPLE values for each sample slot.
      final sampleSlotRawValues = <int, int>{
        for (final slotIndex in _samplePcmData.keys)
          slotIndex: sampleSlotToRaw(slotIndex),
      };

      final presetUploads = <PackUploadPreset>[];
      for (final entry in _presetNames.entries) {
        final slotIndex = entry.key;
        final matched = _matchedPresets[slotIndex];

        if (matched != null) {
          presetUploads.add(
            PackUploadPreset(
              slotIndex: slotIndex,
              userId: userId,
              name: matched.name,
              category: '',
              presetData: '',
              existingId: matched.id,
            ),
          );
          continue;
        }

        final presetBytes = _presetDataList[slotIndex];
        if (presetBytes == null) {
          continue;
        }

        final name = entry.value.text.trim();
        final preset = Preset(presetBytes.buffer);
        final category = _presetCategories[slotIndex] ?? preset.category;

        // Detect which sample slot this preset uses.
        int? presetSampleSlotIndex;
        if (preset.usesSample) {
          final presetRaw = preset.parameterById('P_SAMPLE')?.value;
          if (presetRaw != null) {
            for (final rawEntry in sampleSlotRawValues.entries) {
              if ((presetRaw - rawEntry.value).abs() < 2) {
                presetSampleSlotIndex = rawEntry.key;
                break;
              }
            }
          }
        }

        presetUploads.add(
          PackUploadPreset(
            slotIndex: slotIndex,
            userId: userId,
            name: name.isNotEmpty ? name : preset.name,
            category: category.name,
            presetData: base64Encode(presetBytes),
            description: _presetDescriptions[slotIndex]?.text.trim() ?? '',
            isPublic: _packIsPublic,
            contentHash: _presetHashes[slotIndex],
            sampleSlotIndex: presetSampleSlotIndex,
          ),
        );
      }

      // Build pack slots (using slot_index references that the RPC
      // resolves to actual IDs).
      final slotUploads = <PackUploadSlot>[
        for (final preset in presetUploads)
          PackUploadSlot(
            slotNumber: presetSlotStart + preset.slotIndex,
            presetSlotIndex: preset.slotIndex,
          ),
        for (final pattern in patternUploads)
          PackUploadSlot(
            slotNumber: patternSlotStart + pattern.patternIndex,
            patternIndex: pattern.patternIndex,
          ),
        for (final sample in sampleUploads)
          PackUploadSlot(
            slotNumber: sampleSlotStart + sample.slotIndex,
            sampleSlotIndex: sample.slotIndex,
          ),
        for (final emptySlot in _emptySampleSlots)
          PackUploadSlot(
            slotNumber: sampleSlotStart + emptySlot,
          ),
      ];

      final request = PackUploadRequest(
        packData: PackUploadPack(
          userId: userId,
          name: _packNameController.text.trim(),
          description: _packDescriptionController.text.trim(),
          youtubeUrl: _packYoutubeUrlController.text.trim(),
          isPublic: _packIsPublic,
          contentHash: _computePackHash(),
        ),
        samplesData: sampleUploads,
        presetsData: presetUploads,
        wavetableData: wavetableUpload,
        patternsData: patternUploads,
        packSlotsData: slotUploads,
      );

      await _supabase.rpc(
        'create_pack_from_plinky',
        params: request.toJson(),
      );

      await ref.read(savedPacksProvider.notifier).fetchUserItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pack saved successfully!'),
          ),
        );
        _reset();
        widget.onLoaded?.call();
      }
    } on Exception catch (error) {
      debugPrint('Failed to upload pack: $error');

      // Clean up any uploaded storage files.
      await _cleanupStorageFiles('samples', uploadedSamplePaths);
      await _cleanupStorageFiles('wavetables', uploadedWavetablePaths);
      await _cleanupStorageFiles('patterns', uploadedPatternPaths);

      if (mounted) {
        setState(() {
          _step = _LoadStep.error;
          _errorMessage = error.toString();
        });
      }
    }
  }

  Future<void> _cleanupStorageFiles(
    String bucket,
    List<String> paths,
  ) async {
    if (paths.isEmpty) {
      return;
    }
    try {
      await _supabase.storage.from(bucket).remove(paths);
    } on Exception catch (error) {
      debugPrint('Failed to clean up $bucket files: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _LoadStep.uploading) {
      return LoadingIndicator(message: _statusMessage, progress: _progress);
    }

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
              emptySampleSlots: _emptySampleSlots,
              packNameController: _packNameController,
              packDescriptionController: _packDescriptionController,
              packYoutubeUrlController: _packYoutubeUrlController,
              packIsPublic: _packIsPublic,
              onPackIsPublicChanged: (value) =>
                  setState(() => _packIsPublic = value),
              wavetableNameController: _wavetableNameController,
              wavetableDescriptionController: _wavetableDescriptionController,
              hasWavetable:
                  _wavetableUf2Bytes != null && _wavetableUf2Bytes!.isNotEmpty,
              includeWavetable: _includeWavetableInPack,
              onIncludeWavetableChanged: (value) =>
                  setState(() => _includeWavetableInPack = value),
              patternNames: _patternNames,
              patternDescriptions: _patternDescriptions,
              includePatterns: _includePatternsInPack,
              onIncludePatternsChanged: (value) =>
                  setState(() => _includePatternsInPack = value),
              matchedPresets: _matchedPresets,
              matchedSamples: _matchedSamples,
              matchedWavetable: _matchedWavetable,
              matchedPatterns: _matchedPatterns,
              matchedPack: _matchedPack,
              activeSampleNotifier: _activeSampleNotifier,
              onBack: _reset,
              onSave: _uploadAll,
              onChanged: () => setState(() {}),
            ),
            _LoadStep.uploading || _LoadStep.done => const SizedBox.shrink(),
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
        if (!isFileSystemAccessSupported) ...[
          const SizedBox(height: 12),
          const ChromiumRequiredBanner(requireFileSystemAccess: true),
        ],
        const SizedBox(height: 16),
        PlinkyButton(
          onPressed: isFileSystemAccessSupported ? onSelectDrive : null,
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
    required this.emptySampleSlots,
    required this.packNameController,
    required this.packDescriptionController,
    required this.packYoutubeUrlController,
    required this.packIsPublic,
    required this.onPackIsPublicChanged,
    required this.wavetableNameController,
    required this.wavetableDescriptionController,
    required this.hasWavetable,
    required this.includeWavetable,
    required this.onIncludeWavetableChanged,
    required this.patternNames,
    required this.patternDescriptions,
    required this.includePatterns,
    required this.onIncludePatternsChanged,
    required this.matchedPresets,
    required this.matchedSamples,
    required this.matchedWavetable,
    required this.matchedPatterns,
    required this.activeSampleNotifier,
    required this.onBack,
    required this.onSave,
    required this.onChanged,
    this.matchedPack,
  });

  final Map<int, TextEditingController> presetNames;
  final Map<int, TextEditingController> presetDescriptions;
  final Map<int, PresetCategory> presetCategories;
  final Map<int, TextEditingController> sampleNames;
  final Map<int, TextEditingController> sampleDescriptions;
  final Map<int, Uint8List> samplePcmData;
  final Set<int> emptySampleSlots;
  final TextEditingController packNameController;
  final TextEditingController packDescriptionController;
  final TextEditingController packYoutubeUrlController;
  final bool packIsPublic;
  final ValueChanged<bool> onPackIsPublicChanged;
  final TextEditingController wavetableNameController;
  final TextEditingController wavetableDescriptionController;
  final bool hasWavetable;
  final bool includeWavetable;
  final ValueChanged<bool> onIncludeWavetableChanged;
  final Map<int, TextEditingController> patternNames;
  final Map<int, TextEditingController> patternDescriptions;
  final bool includePatterns;
  final ValueChanged<bool> onIncludePatternsChanged;
  final Map<int, MatchedEntry> matchedPresets;
  final Map<int, MatchedEntry> matchedSamples;
  final MatchedEntry? matchedWavetable;
  final Map<int, MatchedEntry> matchedPatterns;
  final SavedPack? matchedPack;
  final ValueNotifier<String?> activeSampleNotifier;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (matchedPack != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is the '
                        '${matchedPack!.name} pack.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (matchedPack!.username.isNotEmpty)
                      LinkedItemIcon(
                        onTap: () => context.go(
                          AppRoute.packs.itemPage(
                            matchedPack!.username,
                            matchedPack!.name,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        Text(
          'Found ${presetNames.length} presets, '
          '${sampleNames.length} samples'
          '${patternNames.isNotEmpty ? ', '
                    '${patternNames.length} patterns' : ''} '
          '${hasWavetable ? 'and a wavetable ' : ''}'
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
          minLines: 3,
          maxLines: null,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: packYoutubeUrlController,
          decoration: const InputDecoration(
            labelText: 'YouTube URL (optional)',
            hintText: 'https://www.youtube.com/watch?v=...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.play_circle_outline),
          ),
        ),
        SwitchListTile(
          title: const Text('Share with community'),
          value: packIsPublic,
          onChanged: onPackIsPublicChanged,
        ),
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
              isMatched: matchedPresets.containsKey(slotIndex),
              onEdit: matchedPresets.containsKey(slotIndex)
                  ? null
                  : () => _showPresetEditDialog(
                      context,
                      slotIndex,
                    ),
            ),
        ],
        if (sampleNames.isNotEmpty || emptySampleSlots.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Samples',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final slotIndex in [
            ...sampleNames.keys,
            ...emptySampleSlots,
          ]..sort())
            if (sampleNames.containsKey(slotIndex))
              _SamplePreviewRow(
                controller: sampleNames[slotIndex]!,
                label: 'Sample $slotIndex',
                activeSampleNotifier: activeSampleNotifier,
                pcmData: samplePcmData[slotIndex],
                isMatched: matchedSamples.containsKey(slotIndex),
                onEdit: matchedSamples.containsKey(slotIndex)
                    ? null
                    : () => _showSampleEditDialog(
                        context,
                        slotIndex,
                      ),
              )
            else
              _EmptySlotRow(
                label: 'Sample $slotIndex',
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
              isMatched: matchedWavetable != null,
              onEdit: matchedWavetable != null
                  ? null
                  : () => _showWavetableEditDialog(context),
            ),
        ],
        if (patternNames.isNotEmpty) ...[
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
            for (final patternIndex in patternNames.keys.toList()..sort())
              _NamedItemRow(
                controller: patternNames[patternIndex]!,
                label: 'Pattern ${patternIndex + 1}',
                isMatched: matchedPatterns.containsKey(patternIndex),
                onEdit: matchedPatterns.containsKey(patternIndex)
                    ? null
                    : () => _showPatternEditDialog(
                        context,
                        patternIndex,
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

  void _showPatternEditDialog(BuildContext context, int patternIndex) {
    showDialog<void>(
      context: context,
      builder: (context) => _NameDescriptionEditDialog(
        title: 'Edit Pattern',
        nameController: patternNames[patternIndex]!,
        descriptionController: patternDescriptions[patternIndex]!,
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

class _SamplePreviewRow extends ConsumerStatefulWidget {
  const _SamplePreviewRow({
    required this.controller,
    required this.label,
    required this.activeSampleNotifier,
    this.pcmData,
    this.isMatched = false,
    this.onEdit,
  });

  final TextEditingController controller;
  final String label;
  final ValueNotifier<String?> activeSampleNotifier;
  final Uint8List? pcmData;
  final bool isMatched;
  final VoidCallback? onEdit;

  @override
  ConsumerState<_SamplePreviewRow> createState() => _SamplePreviewRowState();
}

class _SamplePreviewRowState extends ConsumerState<_SamplePreviewRow> {
  AudioSource? _audioSource;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.activeSampleNotifier.addListener(_onActiveSampleChanged);
  }

  @override
  void dispose() {
    widget.activeSampleNotifier.removeListener(_onActiveSampleChanged);
    super.dispose();
  }

  void _onActiveSampleChanged() {
    if (_isPlaying && widget.activeSampleNotifier.value != widget.label) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _togglePlayback() async {
    final soundService = ref.read(soundServiceProvider);

    if (_isPlaying) {
      await soundService.stopPreview();
      widget.activeSampleNotifier.value = null;
      setState(() => _isPlaying = false);
      return;
    }

    final pcmData = widget.pcmData;
    if (pcmData == null) {
      return;
    }

    if (_audioSource == null) {
      final wavBytes = plinkyPcmToWav(pcmData);
      _audioSource = await soundService.loadSource(
        '${widget.label}.wav',
        wavBytes,
      );
    }

    widget.activeSampleNotifier.value = widget.label;
    await soundService.play(_audioSource!);
    setState(() => _isPlaying = true);

    final duration = soundService.getLength(_audioSource!);
    await Future<void>.delayed(duration);
    if (mounted && _isPlaying) {
      widget.activeSampleNotifier.value = null;
      setState(() => _isPlaying = false);
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
              readOnly: widget.isMatched,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: widget.isMatched
                    ? const Tooltip(
                        message: 'Existing public content will be reused',
                        child: Icon(Icons.link, size: 18),
                      )
                    : null,
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

class _EmptySlotRow extends StatelessWidget {
  const _EmptySlotRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(
          'EMPTY',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _NamedItemRow extends StatelessWidget {
  const _NamedItemRow({
    required this.controller,
    required this.label,
    this.isMatched = false,
    this.onEdit,
  });

  final TextEditingController controller;
  final String label;
  final bool isMatched;
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
              readOnly: isMatched,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: isMatched
                    ? const Tooltip(
                        message: 'Existing public content will be reused',
                        child: Icon(Icons.link, size: 18),
                      )
                    : null,
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
              minLines: 3,
              maxLines: null,
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
                  minLines: 3,
                  maxLines: null,
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
