import 'package:freezed_annotation/freezed_annotation.dart';

part 'midi_state.freezed.dart';

/// Represents an active MIDI note with its velocity.
class ActiveNote {
  const ActiveNote({required this.note, required this.velocity});

  final int note;
  final int velocity;
}

@freezed
abstract class MidiState with _$MidiState {
  const factory MidiState({
    @Default(false) bool isConnected,
    @Default({}) Map<int, ActiveNote> activeNotes,
  }) = _MidiState;
}
