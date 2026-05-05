import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/services/webmidi_service.dart';

part 'midi_state.freezed.dart';

@freezed
abstract class MidiState with _$MidiState {
  const factory MidiState({
    @Default(false) bool isConnected,
    @Default({}) Set<int> activeNotes,
    @Default([]) List<MidiOutputPort> outputs,
    String? selectedOutputId,
  }) = _MidiState;
}
