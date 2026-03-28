import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/state/play_state.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/utils/pitch.dart';

final playProvider = NotifierProvider<PlayNotifier, PlayState>(
  PlayNotifier.new,
);

class PlayNotifier extends Notifier<PlayState> {
  AudioSource? _audioSource;
  AudioSource? _waveformSource;

  /// One voice per column (8 columns max), matching Plinky polyphony.
  final _activeHandles = <int, SoundHandle>{};

  @override
  PlayState build() => const PlayState();

  Future<void> _ensureSoLoud() async {
    final soloud = SoLoud.instance;
    if (!soloud.isInitialized) {
      debugPrint('Initializing SoLoud...');
      await soloud.init();
      debugPrint('SoLoud initialized');
    }
  }

  /// Ensure a waveform source exists for synth playback.
  Future<AudioSource> _ensureWaveform() async {
    if (_waveformSource != null) {
      return _waveformSource!;
    }
    await _ensureSoLoud();
    // Default to a superWave saw — close to Plinky's default
    // "4 sawtooths per voice" at PWM=0.
    _waveformSource = await SoLoud.instance.loadWaveform(
      WaveForm.fSaw,
      true, // superWave
      0.5, // scale
      0.2, // detune
    );
    return _waveformSource!;
  }

  /// Load a WAV sample for playback with its slice configuration.
  Future<void> loadSample(
    String name,
    Uint8List wavBytes, {
    int baseMidi = 60,
    List<double> slicePoints = defaultSlicePoints,
    List<int> sliceNotes = defaultSliceNotes,
    bool pitched = false,
  }) async {
    state = state.copyWith(isLoadingSample: true);
    try {
      await _ensureSoLoud();

      // Dispose previous source if any.
      final oldSource = _audioSource;
      if (oldSource != null) {
        _stopAll();
        SoLoud.instance.disposeSource(oldSource);
      }

      debugPrint('Loading sample (${wavBytes.length} bytes)...');
      _audioSource = await SoLoud.instance.loadMem('sample.wav', wavBytes);
      debugPrint('Sample loaded');
      state = state.copyWith(
        sampleWavBytes: wavBytes,
        sampleName: name,
        sampleBaseMidi: baseMidi,
        slicePoints: slicePoints,
        sliceNotes: sliceNotes,
        pitched: pitched,
        isLoadingSample: false,
      );
    } on Exception catch (error) {
      debugPrint('Failed to load sample: $error');
      state = state.copyWith(isLoadingSample: false);
    }
  }

  /// Read the current preset from the plinky state.
  Preset? get _preset => ref.read(plinkyProvider).preset;

  /// Start playing the pad at [row], [col].
  ///
  /// Uses preset parameters (scale, stride, octave) to determine the
  /// MIDI note, just like the Plinky hardware. If a sample is loaded
  /// it is played pitched to match the note; otherwise a waveform
  /// synth is used.
  Future<void> playPad(int row, int col) async {
    final hasSample = _audioSource != null;
    final preset = _preset;

    // Need at least a preset to determine notes.
    if (preset == null && !hasSample) {
      return;
    }

    final soloud = SoLoud.instance;
    final padIndex = row * 8 + col;

    // Stop existing voice in this column.
    final existing = _activeHandles.remove(col);
    if (existing != null) {
      try {
        soloud.stop(existing);
      } on Exception catch (_) {}
    }

    // Calculate the MIDI note for this pad position using preset params.
    final scaleIndex = preset?.scaleIndex ?? 25; // chromatic
    final stride = preset?.stride ?? 7;
    final octaveOffset = preset?.octaveOffset ?? 0;
    final pitchOffset = preset?.pitchOffset ?? 0.0;

    final midiNote = midiNoteForPad(
      row: row,
      col: col,
      scaleIndex: scaleIndex,
      stride: stride,
      octaveOffset: octaveOffset,
      pitchOffset: pitchOffset,
    );

    try {
      SoundHandle handle;

      if (hasSample) {
        handle = await _playSampleNote(
          midiNote: midiNote,
          row: row,
        );
      } else {
        handle = await _playWaveformNote(midiNote: midiNote);
      }

      _activeHandles[col] = handle;
      state = state.copyWith(
        activePads: {...state.activePads, padIndex},
      );
    } on Exception catch (error) {
      debugPrint('Failed to play pad: $error');
    }
  }

  /// Play a sample slice pitched to [midiNote].
  Future<SoundHandle> _playSampleNote({
    required int midiNote,
    required int row,
  }) async {
    final source = _audioSource!;
    final soloud = SoLoud.instance;

    // Determine slice boundaries.
    final sliceIndex = row.clamp(0, 7);
    final slicePoints = state.slicePoints;
    final startFraction = slicePoints[sliceIndex];
    final endFraction =
        sliceIndex < 7 ? slicePoints[sliceIndex + 1] : 1.0;

    final totalDuration = soloud.getLength(source);
    final startTime = totalDuration * startFraction;
    final sliceDuration =
        totalDuration * (endFraction - startFraction);

    // The slice note is the intended pitch for this slice.
    // On Plinky, slice notes are in Plinky note format (48 = C4).
    // Convert to MIDI: plinkyNote + 12 = midiNote.
    final sliceNote = state.sliceNotes.length > sliceIndex
        ? state.sliceNotes[sliceIndex]
        : 48;
    final sliceMidi = sliceNote + 12;

    // Playback speed shifts the sample pitch from sliceMidi to our
    // target midiNote.
    final speed = playbackSpeedForMidi(midiNote, sliceMidi);

    final handle = await soloud.play(source, paused: true);
    soloud.seek(handle, startTime);
    soloud.setRelativePlaySpeed(handle, speed);
    soloud.setPause(handle, false);

    // Schedule stop at the end of the slice (adjusted for speed).
    if (sliceDuration > Duration.zero) {
      final adjustedDuration = sliceDuration * (1.0 / speed);
      soloud.scheduleStop(handle, adjustedDuration);
    }

    return handle;
  }

  /// Play a waveform tone at [midiNote].
  Future<SoundHandle> _playWaveformNote({required int midiNote}) async {
    final source = await _ensureWaveform();
    final soloud = SoLoud.instance;

    // Convert MIDI note to frequency: f = 440 * 2^((note - 69) / 12).
    final frequency = 440.0 * pow(2, (midiNote - 69) / 12);
    soloud.setWaveformFreq(source, frequency);

    return soloud.play(source);
  }

  /// Stop the note for the pad at [row], [col].
  void stopPad(int row, int col) {
    final padIndex = row * 8 + col;
    final handle = _activeHandles.remove(col);
    if (handle != null) {
      try {
        SoLoud.instance.stop(handle);
      } on Exception catch (_) {}
    }
    state = state.copyWith(
      activePads: {...state.activePads}..remove(padIndex),
    );
  }

  void _stopAll() {
    final soloud = SoLoud.instance;
    for (final handle in _activeHandles.values) {
      try {
        soloud.stop(handle);
      } on Exception catch (_) {}
    }
    _activeHandles.clear();
    state = state.copyWith(activePads: {});
  }
}
