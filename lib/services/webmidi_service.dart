import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('navigator')
external _Navigator get _navigator;

extension type _Navigator._(JSObject _) implements JSObject {
  external JSPromise<MIDIAccess> requestMIDIAccess(
    MIDIOptions? options,
  );
}

extension type MIDIOptions._(JSObject _) implements JSObject {
  external factory MIDIOptions({bool sysex, bool software});
}

extension type MIDIAccess._(JSObject _) implements JSObject {
  external MIDIInputMap get inputs;
  external MIDIOutputMap get outputs;
  external set onstatechange(JSFunction? callback);
}

extension type MIDIInputMap._(JSObject _) implements JSObject {
  external JSFunction get forEach;
}

extension type MIDIOutputMap._(JSObject _) implements JSObject {
  external JSFunction get forEach;
}

extension type MIDIInput._(JSObject _) implements JSObject {
  external JSString get name;
  external JSString get id;
  external JSString get state;
  external set onmidimessage(JSFunction? callback);
}

extension type MIDIOutput._(JSObject _) implements JSObject {
  external JSString get name;
  external JSString get id;
  external JSString get state;
  external void send(JSUint8Array data);
}

extension type MIDIMessageEvent._(JSObject _) implements JSObject {
  external JSUint8Array get data;
}

/// A MIDI message received from a device.
class MidiMessage {
  const MidiMessage({
    required this.command,
    required this.note,
    required this.velocity,
  });

  /// MIDI command (0x90 = note on, 0x80 = note off, 0xB0 = CC, etc.)
  final int command;

  /// MIDI note number (0-127) or CC number.
  final int note;

  /// Velocity (0-127) or CC value.
  final int velocity;

  bool get isNoteOn => (command & 0xF0) == 0x90 && velocity > 0;
  bool get isNoteOff =>
      (command & 0xF0) == 0x80 || ((command & 0xF0) == 0x90 && velocity == 0);
}

typedef MidiMessageCallback = void Function(MidiMessage message);
typedef MidiOutputsChangedCallback = void Function();

/// A MIDI output port the user can send messages to.
class MidiOutputPort {
  const MidiOutputPort({required this.id, required this.name});

  final String id;
  final String name;
}

class WebMidiService {
  MIDIAccess? _access;
  final _inputs = <String, MIDIInput>{};
  final _outputs = <String, MIDIOutput>{};
  MidiMessageCallback? onMessage;
  MidiOutputsChangedCallback? onOutputsChanged;
  bool _connected = false;

  bool get isConnected => _connected;

  List<MidiOutputPort> get outputs {
    return _outputs.entries
        .map(
          (entry) => MidiOutputPort(
            id: entry.key,
            name: entry.value.name.toDart,
          ),
        )
        .toList();
  }

  Future<void> connect() async {
    try {
      final options = MIDIOptions(sysex: false, software: true);
      _access = await _navigator.requestMIDIAccess(options).toDart;
      _connected = true;
      _bindInputs();
      _bindOutputs();
      _access!.onstatechange = _onStateChange.toJS;
    } on Object catch (error) {
      debugPrint('Web MIDI access denied: $error');
      _connected = false;
    }
  }

  void _bindInputs() {
    final access = _access;
    if (access == null) {
      return;
    }

    // Clear old listeners.
    for (final input in _inputs.values) {
      input.onmidimessage = null;
    }
    _inputs.clear();

    // Iterate over the MIDIInputMap using JS forEach.
    access.inputs.forEach.callAsFunction(
      access.inputs,
      ((MIDIInput input, JSString key) {
        final inputName = input.name.toDart;
        final inputId = input.id.toDart;
        debugPrint('MIDI input found: $inputName ($inputId)');
        _inputs[inputId] = input;
        input.onmidimessage = _onMidiMessage.toJS;
      }).toJS,
    );
  }

  void _bindOutputs() {
    final access = _access;
    if (access == null) {
      return;
    }

    _outputs.clear();

    access.outputs.forEach.callAsFunction(
      access.outputs,
      ((MIDIOutput output, JSString key) {
        final outputName = output.name.toDart;
        final outputId = output.id.toDart;
        debugPrint('MIDI output found: $outputName ($outputId)');
        _outputs[outputId] = output;
      }).toJS,
    );

    onOutputsChanged?.call();
  }

  void _onStateChange(JSObject event) {
    debugPrint('MIDI state change');
    _bindInputs();
    _bindOutputs();
  }

  void _onMidiMessage(MIDIMessageEvent event) {
    final data = event.data.toDart;
    if (data.length < 3) {
      return;
    }

    final message = MidiMessage(
      command: data[0],
      note: data[1],
      velocity: data[2],
    );
    onMessage?.call(message);
  }

  /// Send raw MIDI bytes to the output port identified by [outputId].
  void sendToOutput(String outputId, Uint8List data) {
    final output = _outputs[outputId];
    if (output == null) {
      debugPrint('MIDI output $outputId not found');
      return;
    }
    try {
      output.send(data.toJS);
    } on Object catch (error) {
      debugPrint('Failed to send MIDI: $error');
    }
  }
}
