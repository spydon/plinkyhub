import 'dart:convert';
import 'dart:typed_data';

/// Decompress a short URI-safe Base64 string back to a
/// 1552-byte preset.
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
  for (var index = 0; index < 1552 && index < uncompressed.length; index++) {
    result[(index % 97) * 16 + (index ~/ 97)] = uncompressed[index];
  }
  return result;
}
