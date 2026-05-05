import 'dart:typed_data';

import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/parameter.dart';
import 'package:plinkyhub/models/plinky_params.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';

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

  /// Sample slot index (0-7) used by this preset, or -1 if none.
  int get sampleSlot => rawToSampleSlot(parameterById('P_SAMPLE')?.value ?? 0);

  /// Whether this preset uses a sample.
  bool get usesSample => sampleSlot >= 0;

  /// Whether this preset is effectively empty (all parameters at zero).
  bool get isEmpty => parameters.every((parameter) => parameter.value == 0);

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
