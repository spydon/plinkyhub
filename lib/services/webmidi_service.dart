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
  external set onstatechange(JSFunction? callback);
}

extension type MIDIInputMap._(JSObject _) implements JSObject {
  external JSFunction get forEach;
}

extension type MIDIInput._(JSObject _) implements JSObject {
  external JSString get name;
  external JSString get id;
  external JSString get state;
  external set onmidimessage(JSFunction? callback);
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
      (command & 0xF0) == 0x80 ||
      ((command & 0xF0) == 0x90 && velocity == 0);
}

typedef MidiMessageCallback = void Function(MidiMessage message);

class WebMidiService {
  MIDIAccess? _access;
  final _inputs = <String, MIDIInput>{};
  MidiMessageCallback? onMessage;
  bool _connected = false;

  bool get isConnected => _connected;

  static bool get isSupported {
    try {
      // Accessing _navigator will throw if not available.
      _navigator;
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> connect() async {
    try {
      final options = MIDIOptions(sysex: false, software: true);
      _access = await _navigator.requestMIDIAccess(options).toDart;
      _connected = true;
      _bindInputs();
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

  void _onStateChange(JSObject event) {
    debugPrint('MIDI state change');
    _bindInputs();
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

  void disconnect() {
    for (final input in _inputs.values) {
      input.onmidimessage = null;
    }
    _inputs.clear();
    if (_access != null) {
      _access!.onstatechange = null;
    }
    _connected = false;
  }
}
