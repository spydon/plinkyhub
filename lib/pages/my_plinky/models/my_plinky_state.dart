import 'dart:typed_data';

import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';

/// View state for the My Plinky page.
enum MyPlinkyPageState { connect, loading, loaded, error }

/// A linked-entry triple stored per preset slot.
typedef LinkedSlot = ({String? presetId, String? sampleId, String? patternId});

class MyPlinkyState {
  const MyPlinkyState({
    this.pageState = MyPlinkyPageState.connect,
    this.statusMessage = '',
    this.progress,
    this.errorMessage,
    this.includeSamples = true,
    this.samplesLoaded = false,
    this.directory,
    this.parsedFlashImage,
    this.devicePresets = const {},
    this.deviceSampleSlots = const {},
    this.deviceSamplePcmData = const {},
    this.slots = const [],
    this.wavetableId,
    this.patternIds = const {},
    this.deviceHasWavetable = false,
    this.devicePatternIndices = const [],
    this.matchedPack,
    this.dirtySlots = const {},
    this.dirtyWavetable = false,
    this.dirtyPatterns = const {},
    this.editingSlotIndex,
  });

  final MyPlinkyPageState pageState;
  final String statusMessage;
  final double? progress;
  final String? errorMessage;
  final bool includeSamples;
  final bool samplesLoaded;

  final FileSystemDirectoryHandle? directory;
  final ParsedFlashImage? parsedFlashImage;

  final Map<int, Preset> devicePresets;
  final Set<int> deviceSampleSlots;

  /// Raw PCM data per device sample slot (slot index -> PCM bytes).
  final Map<int, Uint8List> deviceSamplePcmData;
  final List<LinkedSlot> slots;
  final String? wavetableId;
  final Map<int, String?> patternIds;
  final bool deviceHasWavetable;
  final List<int> devicePatternIndices;
  final SavedPack? matchedPack;

  /// Slot indices with changes not yet written to the device.
  final Set<int> dirtySlots;

  /// Whether the wavetable has been changed but not written to the device.
  final bool dirtyWavetable;

  /// Pattern indices with changes not yet written to the device.
  final Set<int> dirtyPatterns;

  /// The preset slot currently being edited in the editor, or null.
  final int? editingSlotIndex;

  /// Whether there are any unsaved changes.
  bool get hasUnsavedChanges =>
      dirtySlots.isNotEmpty || dirtyWavetable || dirtyPatterns.isNotEmpty;

  MyPlinkyState copyWith({
    MyPlinkyPageState? pageState,
    String? statusMessage,
    double? Function()? progress,
    String? Function()? errorMessage,
    bool? includeSamples,
    bool? samplesLoaded,
    FileSystemDirectoryHandle? Function()? directory,
    ParsedFlashImage? Function()? parsedFlashImage,
    Map<int, Preset>? devicePresets,
    Set<int>? deviceSampleSlots,
    Map<int, Uint8List>? deviceSamplePcmData,
    List<LinkedSlot>? slots,
    String? Function()? wavetableId,
    Map<int, String?>? patternIds,
    bool? deviceHasWavetable,
    List<int>? devicePatternIndices,
    SavedPack? Function()? matchedPack,
    Set<int>? dirtySlots,
    bool? dirtyWavetable,
    Set<int>? dirtyPatterns,
    int? Function()? editingSlotIndex,
  }) {
    return MyPlinkyState(
      pageState: pageState ?? this.pageState,
      statusMessage: statusMessage ?? this.statusMessage,
      progress: progress != null ? progress() : this.progress,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      includeSamples: includeSamples ?? this.includeSamples,
      samplesLoaded: samplesLoaded ?? this.samplesLoaded,
      directory: directory != null ? directory() : this.directory,
      parsedFlashImage: parsedFlashImage != null
          ? parsedFlashImage()
          : this.parsedFlashImage,
      devicePresets: devicePresets ?? this.devicePresets,
      deviceSampleSlots: deviceSampleSlots ?? this.deviceSampleSlots,
      deviceSamplePcmData: deviceSamplePcmData ?? this.deviceSamplePcmData,
      slots: slots ?? this.slots,
      wavetableId: wavetableId != null ? wavetableId() : this.wavetableId,
      patternIds: patternIds ?? this.patternIds,
      deviceHasWavetable: deviceHasWavetable ?? this.deviceHasWavetable,
      devicePatternIndices: devicePatternIndices ?? this.devicePatternIndices,
      matchedPack: matchedPack != null ? matchedPack() : this.matchedPack,
      dirtySlots: dirtySlots ?? this.dirtySlots,
      dirtyWavetable: dirtyWavetable ?? this.dirtyWavetable,
      dirtyPatterns: dirtyPatterns ?? this.dirtyPatterns,
      editingSlotIndex: editingSlotIndex != null
          ? editingSlotIndex()
          : this.editingSlotIndex,
    );
  }
}
