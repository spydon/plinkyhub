import 'dart:typed_data';

import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/parameter.dart';
import 'package:plinkyhub/models/plinky_params.dart';

/// Represents a single Plinky synthesizer preset stored as
/// a 1552-byte binary buffer.
class Preset {
  Preset(ByteBuffer buffer) : _buffer = buffer {
    for (var index = 0; index < eParams.length; index++) {
      final parameterIdentifier = eParams[index];
      final byteOffset = index * 16;
      final array = Int16List.view(_buffer, byteOffset, 8);
      final definition = getParamDef(parameterIdentifier);
      parameters.add(
        Parameter(
          id: parameterIdentifier,
          array: array,
          name: definition?.name,
          description: definition?.description ?? '',
          minimum: definition?.min ?? 0,
          maximum: definition?.max ?? 127,
          controlChange: definition?.cc ?? -1,
          enumNames: definition?.enumName,
        ),
      );
    }

    _bitFieldUint8 = Uint8List.view(
      _buffer,
      _buffer.lengthInBytes - 16,
      16,
    );
    _bitFieldInt8 = Int8List.view(
      _buffer,
      _buffer.lengthInBytes - 16,
      16,
    );
  }

  final ByteBuffer _buffer;
  final List<Parameter> parameters = [];
  late final Uint8List _bitFieldUint8;
  late final Int8List _bitFieldInt8;

  ByteBuffer get buffer => _buffer;

  bool get arp => (_bitFieldUint8[0] & 1) > 0;
  set arp(bool value) {
    if (value) {
      _bitFieldUint8[0] |= 1;
    } else {
      _bitFieldUint8[0] &= ~1;
    }
  }

  bool get latch => (_bitFieldUint8[0] & 2) > 0;
  set latch(bool value) {
    if (value) {
      _bitFieldUint8[0] |= 2;
    } else {
      _bitFieldUint8[0] &= ~2;
    }
  }

  int get loopStart => _bitFieldInt8[1];
  int get loopLength => _bitFieldInt8[2];

  PresetCategory get category {
    final array = Uint8List.view(_buffer, 1543, 1);
    final index = array[0];
    if (index >= PresetCategory.values.length) {
      return PresetCategory.none;
    }
    return PresetCategory.values[index];
  }

  set category(PresetCategory value) {
    final array = Uint8List.view(_buffer, 1543, 1);
    array[0] = value.index;
  }

  String get name {
    final array = Uint8List.view(_buffer, 1544, 8);
    final result = StringBuffer();
    for (final charCode in array) {
      if (charCode == 0) {
        continue;
      }
      result.writeCharCode(charCode);
    }
    return result.toString();
  }

  set name(String value) {
    final array = Uint8List.view(_buffer, 1544, 8);
    for (var index = 0; index < 8; index++) {
      array[index] = index < value.length ? value.codeUnitAt(index) : 0;
    }
  }

  /// Returns the parameter with the given [id], or null if not found.
  Parameter? parameterById(String id) {
    for (final parameter in parameters) {
      if (parameter.id == id) {
        return parameter;
      }
    }
    return null;
  }

  /// Scale index (0-25) for the selected musical scale.
  int get scaleIndex {
    final scaleParameter = parameterById('P_SCALE');
    if (scaleParameter == null) {
      return 25; // chromatic
    }
    final options = scaleParameter.getSelectOptions();
    if (options == null) {
      return 25;
    }
    final width = 1024 / options.length;
    return (scaleParameter.value / width)
        .floor()
        .clamp(0, options.length - 1);
  }

  /// Stride in semitones between columns (default 7 = perfect fifth).
  int get stride {
    final strideParameter = parameterById('P_STRIDE');
    if (strideParameter == null) {
      return 7;
    }
    // Raw value 0-1024 maps to 0-127 semitones.
    return (strideParameter.value / 1024 * 127).round().clamp(0, 127);
  }

  /// Octave offset (-4 to +4).
  int get octaveOffset {
    final octaveParameter = parameterById('P_OCT');
    if (octaveParameter == null) {
      return 0;
    }
    // Raw value -1024..1024 maps to -4..+4 octaves.
    return (octaveParameter.value / 256).round().clamp(-4, 4);
  }

  /// Sample slot number (0-127) used by this preset.
  int get sampleSlot {
    final sampleParameter = parameterById('P_SAMPLE');
    if (sampleParameter == null) {
      return 0;
    }
    return (sampleParameter.value / 1024 * 127).round().clamp(0, 127);
  }

  /// Whether this preset uses a sample (sample slot > 0).
  bool get usesSample => sampleSlot > 0;

  /// Fine pitch offset in semitones (fractional, ±12).
  double get pitchOffset {
    final pitchParameter = parameterById('P_PITCH');
    if (pitchParameter == null) {
      return 0;
    }
    // Raw value -1024..1024 maps to ±12 semitones (1 octave).
    return pitchParameter.value / 1024 * 12;
  }

  void randomize(List<RandomizeGroup> groups) {
    final parameterIdsToRandomize = <String>{};
    for (final group in groups) {
      parameterIdsToRandomize.addAll(group.parameterIds);
    }

    for (final parameter in parameters) {
      if (parameterIdsToRandomize.contains(parameter.id)) {
        parameter.randomize();
      }
    }
  }
}
