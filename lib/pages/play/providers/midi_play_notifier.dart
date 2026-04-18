import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/midi_notifier.dart';
import 'package:plinkyhub/utils/pitch.dart';

/// Per-pad state for the WebMIDI play page. Tracks each held pad's
/// MIDI note (so we know what to release on note-off, even if the
/// scale or octave shifts mid-press) and its current pressure (0..1)
/// so the UI can render brightness that reflects the touch position.
class MidiPlayState {
  const MidiPlayState({
    this.activeNotesByPad = const {},
    this.pressureByPad = const {},
  });

  /// padIndex (row * 8 + column) -> MIDI note that was sent on press.
  final Map<int, int> activeNotesByPad;

  /// padIndex -> latest pressure value in [0, 1].
  final Map<int, double> pressureByPad;

  Set<int> get activePadIndices => activeNotesByPad.keys.toSet();

  MidiPlayState copyWith({
    Map<int, int>? activeNotesByPad,
    Map<int, double>? pressureByPad,
  }) {
    return MidiPlayState(
      activeNotesByPad: activeNotesByPad ?? this.activeNotesByPad,
      pressureByPad: pressureByPad ?? this.pressureByPad,
    );
  }
}

final midiPlayProvider = NotifierProvider<MidiPlayNotifier, MidiPlayState>(
  MidiPlayNotifier.new,
);

class MidiPlayNotifier extends Notifier<MidiPlayState> {
  @override
  MidiPlayState build() {
    ref.onDispose(_releaseAll);
    return const MidiPlayState();
  }

  /// Sends a MIDI note-on for the pad at [row], [column] using the given
  /// scale mapping. [pressure] (0..1) drives both the note-on velocity
  /// and the initial polyphonic-aftertouch value, and is stored so
  /// the UI can light the cell to match.
  void pressPad({
    required int row,
    required int column,
    required PlinkyScale scale,
    int stride = 7,
    int octaveOffset = 0,
    int channel = 0,
    double pressure = 1,
  }) {
    final padIndex = row * 8 + column;
    if (state.activeNotesByPad.containsKey(padIndex)) {
      return;
    }
    final note = midiNoteForPad(
      row: row,
      column: column,
      scale: scale,
      stride: stride,
      octaveOffset: octaveOffset,
    );
    final clamped = pressure.clamp(0.0, 1.0);
    final velocity = (clamped * 127).round().clamp(1, 127);
    final midi = ref.read(midiProvider.notifier)
      ..sendNoteOn(note, channel: channel, velocity: velocity);
    midi.sendPolyphonicAftertouch(note, velocity, channel: channel);
    state = state.copyWith(
      activeNotesByPad: {...state.activeNotesByPad, padIndex: note},
      pressureByPad: {...state.pressureByPad, padIndex: clamped},
    );
  }

  /// Updates the live pressure for an already-pressed pad. Sends
  /// polyphonic aftertouch so the Plinky tracks the new value.
  void updatePadPressure({
    required int row,
    required int column,
    required double pressure,
    int channel = 0,
  }) {
    final padIndex = row * 8 + column;
    final note = state.activeNotesByPad[padIndex];
    if (note == null) {
      return;
    }
    final clamped = pressure.clamp(0.0, 1.0);
    final value = (clamped * 127).round().clamp(0, 127);
    ref
        .read(midiProvider.notifier)
        .sendPolyphonicAftertouch(note, value, channel: channel);
    state = state.copyWith(
      pressureByPad: {...state.pressureByPad, padIndex: clamped},
    );
  }

  /// Sends a MIDI note-off for the previously-pressed pad and clears
  /// it from the active set.
  void releasePad(int row, int column, {int channel = 0}) {
    final padIndex = row * 8 + column;
    final note = state.activeNotesByPad[padIndex];
    if (note == null) {
      return;
    }
    ref.read(midiProvider.notifier).sendNoteOff(note, channel: channel);
    final notes = {...state.activeNotesByPad}..remove(padIndex);
    final pressures = {...state.pressureByPad}..remove(padIndex);
    state = state.copyWith(
      activeNotesByPad: notes,
      pressureByPad: pressures,
    );
  }

  /// Release every currently-held pad. Called automatically on
  /// dispose, and also from the play page when the latch toggle is
  /// switched off so stranded notes don't keep sounding.
  void releaseAll({int channel = 0}) {
    if (state.activeNotesByPad.isEmpty) {
      return;
    }
    final midiNotifier = ref.read(midiProvider.notifier);
    for (final note in state.activeNotesByPad.values) {
      midiNotifier.sendNoteOff(note, channel: channel);
    }
    state = const MidiPlayState();
  }

  void _releaseAll() => releaseAll();
}
