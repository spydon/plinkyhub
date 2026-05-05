import 'dart:typed_data';

/// Base addresses for each Plinky sample slot (0-7).
const sampleSlotAddresses = [
  0x40000000, // SAMPLE0
  0x40400000, // SAMPLE1
  0x40800000, // SAMPLE2
  0x40C00000, // SAMPLE3
  0x41000000, // SAMPLE4
  0x41400000, // SAMPLE5
  0x41800000, // SAMPLE6
  0x41C00000, // SAMPLE7
];

/// Size of one Plinky sample slot in bytes (4 MB).
const sampleSlotSize = 0x400000;

/// Maximum tolerated input size for [sampleToUf2] (8 MB). Inputs larger than
/// this almost certainly indicate a decoding bug rather than a long sample.
const maxSampleSize = 8 * 1024 * 1024;

/// UF2 magic numbers.
const magic1 = 0x0A324655;
const magic2 = 0x9E5D5157;
const magicEnd = 0x0AB16F30;

/// Bytes of payload data per UF2 block.
const dataPerBlock = 256;

/// Total size of one UF2 block.
const uf2BlockSize = 512;

/// Converts raw [data] into a UF2 file targeting [baseAddress].
///
/// Each UF2 block carries [dataPerBlock] bytes of payload at incrementing
/// addresses starting from [baseAddress].
Uint8List dataToUf2(Uint8List data, int baseAddress) {
  final totalBlocks = (data.length + dataPerBlock - 1) ~/ dataPerBlock;
  final output = ByteData(totalBlocks * uf2BlockSize);

  for (var blockNum = 0; blockNum < totalBlocks; blockNum++) {
    final offset = blockNum * uf2BlockSize;
    final dataOffset = blockNum * dataPerBlock;
    final dataLength = (dataOffset + dataPerBlock <= data.length)
        ? dataPerBlock
        : data.length - dataOffset;

    // Header
    output.setUint32(offset + 0, magic1, Endian.little);
    output.setUint32(offset + 4, magic2, Endian.little);
    output.setUint32(offset + 8, 0x00000000, Endian.little); // flags
    output.setUint32(
      offset + 12,
      baseAddress + dataOffset,
      Endian.little,
    ); // target address
    output.setUint32(offset + 16, dataLength, Endian.little);
    output.setUint32(offset + 20, blockNum, Endian.little);
    output.setUint32(offset + 24, totalBlocks, Endian.little);
    output.setUint32(offset + 28, 0, Endian.little); // reserved / family ID

    // Data payload (remaining bytes in the 476-byte region are already zero)
    for (var i = 0; i < dataLength; i++) {
      output.setUint8(offset + 32 + i, data[dataOffset + i]);
    }

    // Final magic
    output.setUint32(offset + uf2BlockSize - 4, magicEnd, Endian.little);
  }

  return output.buffer.asUint8List();
}

/// Like [dataToUf2] but only emits UF2 blocks for the specified
/// [includedPages] of [flashImage] (each page is [pageSize] bytes). Pages
/// not in [includedPages] are skipped, so flashing the resulting file leaves
/// the corresponding flash regions on the device untouched.
Uint8List flashImageToUf2(
  Uint8List flashImage,
  int baseAddress, {
  required Set<int> includedPages,
  required int pageSize,
}) {
  assert(pageSize % dataPerBlock == 0, 'pageSize must be a multiple of block');
  final blocksPerPage = pageSize ~/ dataPerBlock;
  final sortedPages = includedPages.toList()..sort();
  final totalBlocks = sortedPages.length * blocksPerPage;
  final output = ByteData(totalBlocks * uf2BlockSize);

  var globalBlockNum = 0;
  for (final pageIndex in sortedPages) {
    for (var blockInPage = 0; blockInPage < blocksPerPage; blockInPage++) {
      final offset = globalBlockNum * uf2BlockSize;
      final dataOffset = pageIndex * pageSize + blockInPage * dataPerBlock;
      final targetAddress = baseAddress + dataOffset;

      output.setUint32(offset + 0, magic1, Endian.little);
      output.setUint32(offset + 4, magic2, Endian.little);
      output.setUint32(offset + 8, 0x00000000, Endian.little);
      output.setUint32(offset + 12, targetAddress, Endian.little);
      output.setUint32(offset + 16, dataPerBlock, Endian.little);
      output.setUint32(offset + 20, globalBlockNum, Endian.little);
      output.setUint32(offset + 24, totalBlocks, Endian.little);
      output.setUint32(offset + 28, 0, Endian.little);

      for (var i = 0; i < dataPerBlock; i++) {
        output.setUint8(offset + 32 + i, flashImage[dataOffset + i]);
      }

      output.setUint32(offset + uf2BlockSize - 4, magicEnd, Endian.little);

      globalBlockNum++;
    }
  }

  return output.buffer.asUint8List();
}

/// Converts raw sample [data] into a UF2 file targeting the given [slotIndex]
/// (0-7) in Plinky's sample memory.
Uint8List sampleToUf2(Uint8List data, {int slotIndex = 0}) {
  assert(slotIndex >= 0 && slotIndex < 8, 'slotIndex must be 0-7');
  if (data.length > maxSampleSize) {
    throw ArgumentError(
      'Sample is ${data.length} bytes; refusing to encode more than '
      '$maxSampleSize bytes (sample slot is $sampleSlotSize bytes).',
    );
  }

  final trimmedData = data.length > sampleSlotSize
      ? data.sublist(0, sampleSlotSize)
      : data;
  return dataToUf2(trimmedData, sampleSlotAddresses[slotIndex]);
}

/// Parses a UF2 file and extracts the raw data payload.
///
/// Returns the concatenated data from all UF2 blocks, ordered by target
/// address. Throws [FormatException] if the file is not a valid UF2.
Uint8List uf2ToData(Uint8List uf2Bytes) {
  if (uf2Bytes.length < uf2BlockSize) {
    throw const FormatException('Invalid UF2: file too small');
  }

  final fileBlockCount = uf2Bytes.length ~/ uf2BlockSize;
  final view = ByteData.sublistView(uf2Bytes);

  // Validate the first block and read the declared block count from its
  // header (offset 24). The file may be larger due to firmware padding.
  final firstM1 = view.getUint32(0, Endian.little);
  final firstM2 = view.getUint32(4, Endian.little);
  if (firstM1 != magic1 || firstM2 != magic2) {
    throw const FormatException('Invalid UF2: bad magic in first block');
  }
  final declaredBlockCount = view.getUint32(24, Endian.little);
  final blockCount =
      declaredBlockCount > 0 && declaredBlockCount <= fileBlockCount
      ? declaredBlockCount
      : fileBlockCount;

  // First pass: find the lowest target address and total data size.
  var minAddress = 0xFFFFFFFF;
  var maxEnd = 0;
  for (var i = 0; i < blockCount; i++) {
    final offset = i * uf2BlockSize;
    final m1 = view.getUint32(offset + 0, Endian.little);
    final m2 = view.getUint32(offset + 4, Endian.little);
    if (m1 != magic1 || m2 != magic2) {
      throw FormatException('Invalid UF2: bad magic in block $i');
    }
    final targetAddress = view.getUint32(offset + 12, Endian.little);
    final dataSize = view.getUint32(offset + 16, Endian.little);
    if (targetAddress < minAddress) {
      minAddress = targetAddress;
    }
    final end = targetAddress + dataSize;
    if (end > maxEnd) {
      maxEnd = end;
    }
  }

  // Allocate output buffer and copy each block's payload.
  final totalSize = maxEnd - minAddress;
  final output = Uint8List(totalSize);
  for (var i = 0; i < blockCount; i++) {
    final offset = i * uf2BlockSize;
    final targetAddress = view.getUint32(offset + 12, Endian.little);
    final dataSize = view.getUint32(offset + 16, Endian.little);
    final outputOffset = targetAddress - minAddress;
    for (var j = 0; j < dataSize; j++) {
      output[outputOffset + j] = uf2Bytes[offset + 32 + j];
    }
  }

  return output;
}
