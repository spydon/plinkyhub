import 'dart:typed_data';

import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/parameter.dart';
import 'package:plinkyhub/models/plinky_params.dart';

/// Represents a single Plinky synthesizer patch stored as
/// a 1552-byte binary buffer.
class Patch {
  Patch(ByteBuffer buffer) : _buffer = buffer {
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
  bool get latch => (_bitFieldUint8[0] & 2) > 0;
  int get loopStart => _bitFieldInt8[1];
  int get loopLength => _bitFieldInt8[2];

  PatchCategory get category {
    final array = Uint8List.view(_buffer, 1543, 1);
    final index = array[0];
    if (index >= PatchCategory.values.length) {
      return PatchCategory.none;
    }
    return PatchCategory.values[index];
  }

  set category(PatchCategory value) {
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
      array[index] =
          index < value.length ? value.codeUnitAt(index) : 0;
    }
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
