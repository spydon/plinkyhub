import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/midi_state.dart';
import 'package:plinkyhub/services/webmidi_service.dart';

final midiProvider = NotifierProvider<MidiNotifier, MidiState>(
  MidiNotifier.new,
);

class MidiNotifier extends Notifier<MidiState> {
  final WebMidiService _service = WebMidiService();

  @override
  MidiState build() => const MidiState();

  Future<void> connect() async {
    _service.onMessage = _onMessage;
    _service.onOutputsChanged = _onOutputsChanged;
    await _service.connect();
    final outputs = _service.outputs;
    state = state.copyWith(
      isConnected: _service.isConnected,
      outputs: outputs,
      selectedOutputId: state.selectedOutputId ?? _defaultOutputId(outputs),
    );
  }

  void selectOutput(String? outputId) {
    state = state.copyWith(selectedOutputId: outputId);
  }

  void _onOutputsChanged() {
    final outputs = _service.outputs;
    final selected = state.selectedOutputId;
    final stillPresent = outputs.any((output) => output.id == selected);

    // Always switch to a Plinky when one appears, even if another
    // output is already selected.
    final plinkyId = outputs
        .where((output) => output.name.toLowerCase().contains('plinky'))
        .firstOrNull
        ?.id;
    final newSelection =
        plinkyId ?? (stillPresent ? selected : _defaultOutputId(outputs));

    state = state.copyWith(
      outputs: outputs,
      selectedOutputId: newSelection,
    );
  }

  /// Picks the best output to default to. Prefers a port whose name
  /// contains "plinky" so the user doesn't have to manually pick it
  /// when their Plinky is plugged in.
  String? _defaultOutputId(List<MidiOutputPort> outputs) {
    if (outputs.isEmpty) {
      return null;
    }
    final plinky = outputs
        .where((output) => output.name.toLowerCase().contains('plinky'))
        .firstOrNull;
    return (plinky ?? outputs.first).id;
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

  /// Send a MIDI note-on message to the currently selected output.
  void sendNoteOn(int note, {int channel = 0, int velocity = 100}) {
    final outputId = state.selectedOutputId;
    if (outputId == null) {
      return;
    }
    _service.sendToOutput(
      outputId,
      Uint8List.fromList([
        0x90 | (channel & 0x0F),
        note & 0x7F,
        velocity & 0x7F,
      ]),
    );
  }

  /// Send a MIDI note-off message to the currently selected output.
  void sendNoteOff(int note, {int channel = 0}) {
    final outputId = state.selectedOutputId;
    if (outputId == null) {
      return;
    }
    _service.sendToOutput(
      outputId,
      Uint8List.fromList([
        0x80 | (channel & 0x0F),
        note & 0x7F,
        0,
      ]),
    );
  }

  /// Send polyphonic aftertouch (0xA_) for [note]. The Plinky firmware
  /// uses this to update the per-string pressure of an already-pressed
  /// MIDI note (see `processmidimsg` case 0xa).
  void sendPolyphonicAftertouch(
    int note,
    int pressure, {
    int channel = 0,
  }) {
    final outputId = state.selectedOutputId;
    if (outputId == null) {
      return;
    }
    _service.sendToOutput(
      outputId,
      Uint8List.fromList([
        0xA0 | (channel & 0x0F),
        note & 0x7F,
        pressure & 0x7F,
      ]),
    );
  }

  /// Send a MIDI program-change message to switch the Plinky preset slot.
  void sendProgramChange(int programNumber, {int channel = 0}) {
    final outputId = state.selectedOutputId;
    if (outputId == null) {
      return;
    }
    _service.sendToOutput(
      outputId,
      Uint8List.fromList([
        0xC0 | (channel & 0x0F),
        programNumber & 0x7F,
      ]),
    );
  }

  /// Send an "all notes off" control-change to the selected output.
  void sendAllNotesOff({int channel = 0}) {
    final outputId = state.selectedOutputId;
    if (outputId == null) {
      return;
    }
    _service.sendToOutput(
      outputId,
      Uint8List.fromList([
        0xB0 | (channel & 0x0F),
        123,
        0,
      ]),
    );
  }

  void disconnect() {
    _service.disconnect();
    state = const MidiState();
  }
}
