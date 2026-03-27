import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/services/webmidi_service.dart';
import 'package:plinkyhub/state/midi_state.dart';

final midiProvider = NotifierProvider<MidiNotifier, MidiState>(
  MidiNotifier.new,
);

class MidiNotifier extends Notifier<MidiState> {
  final WebMidiService _service = WebMidiService();

  @override
  MidiState build() => const MidiState();

  Future<void> connect() async {
    _service.onMessage = _onMessage;
    await _service.connect();
    state = state.copyWith(isConnected: _service.isConnected);
  }

  void _onMessage(MidiMessage message) {
    if (message.isNoteOn) {
      final note = ActiveNote(
        note: message.note,
        velocity: message.velocity,
      );
      state = state.copyWith(
        activeNotes: {...state.activeNotes, message.note: note},
      );
    } else if (message.isNoteOff) {
      state = state.copyWith(
        activeNotes: {...state.activeNotes}..remove(message.note),
      );
    }
  }

  void disconnect() {
    _service.disconnect();
    state = const MidiState();
  }
}
