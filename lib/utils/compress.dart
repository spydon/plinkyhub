import 'dart:convert';
import 'dart:typed_data';

/// Compress a 1552-byte patch into a short URI-safe
/// Base64 string.
String bytecompress(Uint8List input) {
  final swizzled = Uint8List(1552);
  for (var index = 0; index < 1552; index++) {
    swizzled[index] =
        input[(index % 97) * 16 + (index ~/ 97)];
  }
  final compressed = <int>[];
  var position = 0;
  while (position < 1552) {
    final nonZeroStart = position;
    while (position < 1552 &&
        position < nonZeroStart + 255 &&
        (swizzled[position] != 0 ||
            (position + 1 < 1552 &&
                swizzled[position + 1] != 0))) {
      position++;
    }
    compressed.add(position - nonZeroStart);
    for (var offset = nonZeroStart;
        offset < position;
        offset++) {
      compressed.add(swizzled[offset]);
    }
    final zeroStart = position;
    while (position < 1552 &&
        position < zeroStart + 255 &&
        swizzled[position] == 0) {
      position++;
    }
    compressed.add(position - zeroStart);
  }
  final encoded = base64Encode(Uint8List.fromList(compressed));
  return encoded
      .replaceAll('/', '-')
      .replaceAll('=', '_')
      .replaceAll('+', '.');
}

/// Decompress a short URI-safe Base64 string back to a
/// 1552-byte patch.
Uint8List bytedecompress(String encoded) {
  final normalized = encoded
      .replaceAll('-', '/')
      .replaceAll('_', '=')
      .replaceAll('.', '+');
  final decoded = base64Decode(normalized);
  final uncompressed = <int>[];
  var position = 0;
  while (position < decoded.length) {
    final nonZeroLength = decoded[position++];
    for (var offset = 0; offset < nonZeroLength; offset++) {
      uncompressed.add(decoded[position++]);
    }
    if (position >= decoded.length) {
      break;
    }
    final zeroLength = decoded[position++];
    for (var offset = 0; offset < zeroLength; offset++) {
      uncompressed.add(0);
    }
  }
  final result = Uint8List(1552);
  for (var index = 0;
      index < 1552 && index < uncompressed.length;
      index++) {
    result[(index % 97) * 16 + (index ~/ 97)] =
        uncompressed[index];
  }
  return result;
}
