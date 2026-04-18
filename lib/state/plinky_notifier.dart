import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/utils/compress.dart';
import 'package:plinkyhub/utils/wavetable.dart';

const _usbBufferSize = 64;
const _magicHeader = [0xF3, 0x0F, 0xAB, 0xCA];
const _magicHeaderExtended = [0xF3, 0x0F, 0xAB, 0xCB];

/// Size of each buffer passed to WebUSB `transferOut` when streaming
/// large payloads (samples, wavetables). The browser handles splitting
/// this into max-packet-size USB packets internally, so a larger value
/// means far fewer JS-interop round-trips.
const _transferOutChunkSize = 16 * 1024;

/// Index sent to the Plinky to request an internal flash dump
/// (1 MB starting at 0x08000000). See
/// https://github.com/ember-labs-io/Plinky_LPE commit f2d05a9.
const flashDumpInternalIndex = 254;

/// Index sent to the Plinky to request an external flash dump
/// (32 MB starting at 0x40000000). See
/// https://github.com/ember-labs-io/Plinky_LPE commit f2d05a9.
const flashDumpExternalIndex = 255;

/// Size of the Plinky's internal flash memory in bytes (1 MB).
const flashDumpInternalSize = 0x100000;

/// Size of the Plinky's external flash memory in bytes (32 MB).
const flashDumpExternalSize = 0x2000000;

/// Thrown when a flash dump stalls mid-transfer. Carries the bytes
/// received so far so the caller can save them for debugging the
/// firmware-side timeout / address issues.
class FlashDumpTimeoutException implements Exception {
  FlashDumpTimeoutException({
    required this.flashIndex,
    required this.partialBytes,
    required this.expectedBytes,
  });

  final int flashIndex;
  final Uint8List partialBytes;
  final int expectedBytes;

  @override
  String toString() =>
      'FlashDumpTimeoutException(flashIndex=$flashIndex, '
      'received=${partialBytes.length}, expected=$expectedBytes)';
}

/// Delay after SPI writes before sending SampleInfo, giving the firmware
/// time to clear g_disable_fx and resume its main loop.
const _postSpiDelay = Duration(milliseconds: 500);

final plinkyProvider = NotifierProvider<PlinkyNotifier, PlinkyState>(
  PlinkyNotifier.new,
);

class PlinkyNotifier extends Notifier<PlinkyState> {
  final WebUsbService _webUsbService = WebUsbService();

  /// Incoming data buffer. Data from the read loop is pushed here
  /// so that nothing is lost if it arrives before _waitForData is
  /// called.
  final _receivedData = <ByteData>[];
  Completer<void>? _dataSignal;

  @override
  PlinkyState build() => const PlinkyState();

  Future<void> connect() async {
    state = state.copyWith(
      connectionState: PlinkyConnectionState.connecting,
      errorMessage: null,
    );

    try {
      _webUsbService.onDataReceived = _onDataReceived;
      _webUsbService.onError = _onError;
      await _webUsbService.connect();
      if (!_webUsbService.isConnected) {
        state = state.copyWith(
          connectionState: PlinkyConnectionState.disconnected,
        );
        return;
      }
      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
    }
  }

  void _onDataReceived(ByteData data) {
    _receivedData.add(data);
    if (_dataSignal != null && !_dataSignal!.isCompleted) {
      _dataSignal!.complete();
    }
  }

  void _onError(Object error) {
    state = state.copyWith(
      connectionState: PlinkyConnectionState.error,
      errorMessage: error.toString(),
    );
  }

  Future<ByteData> _waitForData() async {
    if (_receivedData.isEmpty) {
      _dataSignal = Completer<void>();
      await _dataSignal!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('No response from Plinky'),
      );
    }
    return _receivedData.removeAt(0);
  }

  Future<void> loadPreset() async {
    final presetNumber = _presetNumber.clamp(0, 31);
    state = state.copyWith(
      connectionState: PlinkyConnectionState.loadingPreset,
      presetNumber: presetNumber,
    );

    try {
      await _webUsbService.resetInterface();
      _receivedData.clear();

      final requestBuffer = Uint8List.fromList([
        ..._magicHeader,
        0, // get
        presetNumber,
        0,
        0,
        0,
        0,
      ]);
      // Fire-and-forget, matching the original editor behavior.
      _webUsbService.send(requestBuffer);

      ByteData headerData;
      while (true) {
        headerData = await _waitForData();
        if (_isValidLoadHeader(headerData)) {
          break;
        }
      }

      final bytesToProcess =
          headerData.getUint8(8) + headerData.getUint8(9) * 256;

      final chunks = <Uint8List>[];
      var processedBytes = 0;
      while (processedBytes < bytesToProcess) {
        final chunkData = await _waitForData();
        final chunk = Uint8List(chunkData.lengthInBytes);
        for (var index = 0; index < chunkData.lengthInBytes; index++) {
          chunk[index] = chunkData.getUint8(index);
        }
        chunks.add(chunk);
        processedBytes += chunk.length;
      }

      final totalLength = chunks.fold<int>(
        0,
        (sum, chunk) => sum + chunk.length,
      );
      final presetData = Uint8List(totalLength);
      var offset = 0;
      for (final chunk in chunks) {
        presetData.setAll(offset, chunk);
        offset += chunk.length;
      }

      final preset = Preset(presetData.buffer);

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
        preset: preset,
        sourcePresetId: null,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
    }
  }

  bool _isValidLoadHeader(ByteData data) {
    if (data.lengthInBytes != 10) {
      return false;
    }
    if (data.getUint8(0) != 0xF3) {
      return false;
    }
    if (data.getUint8(1) != 0x0F) {
      return false;
    }
    if (data.getUint8(2) != 0xAB) {
      return false;
    }
    if (data.getUint8(3) != 0xCA) {
      return false;
    }
    if (data.getUint8(4) != 1) {
      return false;
    }
    if (data.getUint8(6) != 0) {
      return false;
    }
    if (data.getUint8(7) != 0) {
      return false;
    }
    return true;
  }

  Future<void> savePreset() async {
    final preset = state.preset;
    if (preset == null) {
      return;
    }

    final presetNumber = _presetNumber.clamp(0, 31);
    state = state.copyWith(
      connectionState: PlinkyConnectionState.savingPreset,
      presetNumber: presetNumber,
    );

    try {
      final data = Uint8List.view(preset.buffer);
      final byteCount = data.length;
      final lowByte = byteCount & 0xFF;
      final highByte = (byteCount >> 8) & 0xFF;

      final headerBuffer = Uint8List.fromList([
        ..._magicHeader,
        1, // set
        presetNumber,
        0,
        0,
        lowByte,
        highByte,
      ]);

      // Fire off all sends without awaiting between them, matching
      // the original editor which queues all transferOut calls
      // synchronously. Awaiting each one individually can cause the
      // device to miss data.
      final futures = <Future<void>>[];
      futures.add(_webUsbService.send(headerBuffer));

      var offset = 0;
      while (offset < data.length) {
        final end = (offset + _usbBufferSize).clamp(0, data.length);
        final chunk = data.sublist(offset, end);
        futures.add(_webUsbService.send(chunk));
        offset += _usbBufferSize;
      }

      await Future.wait(futures);

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Sends a sample to Plinky over WebUSB.
  ///
  /// [slotIndex] is the sample slot (0-7).
  /// [pcmData] is the raw PCM audio data (16-bit signed, mono, 31250 Hz).
  /// [sampleInfo] is the 1072-byte SampleInfo struct.
  /// [onProgress] is called with a value between 0.0 and 1.0.
  Future<void> sendSample({
    required int slotIndex,
    required Uint8List pcmData,
    required Uint8List sampleInfo,
    ValueChanged<double>? onProgress,
  }) async {
    state = state.copyWith(
      connectionState: PlinkyConnectionState.sendingSample,
    );

    try {
      await _webUsbService.resetInterface();
      _receivedData.clear();

      // Step 1: Send PCM data first (cmd=3, 32-bit header).
      // This sets g_disable_fx which blocks the firmware's main loop
      // (including PumpFlashWrites). The firmware handles 64KB
      // chunking internally.
      onProgress?.call(0);
      await _sendStreamWithExtendedHeader(
        command: 3,
        index: slotIndex,
        offset: 0,
        data: pcmData,
        onProgress: onProgress,
      );

      // Wait for firmware to clear g_disable_fx and resume its
      // main loop before sending SampleInfo.
      await Future<void>.delayed(_postSpiDelay);

      // Step 2: Send SampleInfo (cmd=1, idx=64+slot, 16-bit header).
      // Sent after PCM data so the firmware's auto-save
      // (PumpFlashWrites) isn't blocked by g_disable_fx during the
      // SPI write. The SampleInfo is marked dirty and saved to
      // internal flash within 5 seconds by the main loop.
      await _sendWithHeader(
        command: 1,
        index: 64 + slotIndex,
        data: sampleInfo,
      );

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  /// Sends a wavetable to Plinky over WebUSB.
  ///
  /// [wavetableData] is the raw wavetable bytes (17×1031 Int16 samples).
  /// [onProgress] is called with a value between 0.0 and 1.0.
  Future<void> sendWavetable({
    required Uint8List wavetableData,
    ValueChanged<double>? onProgress,
  }) async {
    state = state.copyWith(
      connectionState: PlinkyConnectionState.sendingWavetable,
    );

    try {
      await _webUsbService.resetInterface();
      _receivedData.clear();

      // Truncate to exact wavetable size so padded UF2 payloads (e.g. last
      // block rounded to 256 bytes) don't exceed the firmware's size check.
      const expectedSize = wavetableShapeCount * wavetableSamplesPerShape * 2;
      final data = wavetableData.length > expectedSize
          ? wavetableData.sublist(0, expectedSize)
          : wavetableData;

      debugPrint('Sending wavetable: ${data.length} bytes');
      onProgress?.call(0);
      await _sendWithHeader(
        command: 5,
        index: 0,
        data: data,
      );
      onProgress?.call(1);
      debugPrint('Wavetable send complete');

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  /// Reads the entire flash region for [flashIndex] over WebUSB.
  ///
  /// When [chunkBytes] is set the region is fetched through multiple
  /// smaller requests of that size. This is the workaround for the LPE
  /// firmware's 5 s state timeout, which drops large single transfers:
  /// each request goes through the state machine from scratch, so the
  /// timeout never fires against a single long SEND_DATA phase.
  ///
  /// When [chunkBytes] is null a single request is issued for the whole
  /// region (original behavior, works for small regions like presets).
  ///
  /// [onProgress] is called with a value between 0.0 and 1.0 against the
  /// total region size.
  Future<Uint8List> readFlashDump({
    required int flashIndex,
    int? chunkBytes,
    ValueChanged<double>? onProgress,
  }) async {
    assert(
      flashIndex == flashDumpInternalIndex ||
          flashIndex == flashDumpExternalIndex,
      'flashIndex must be a flash dump index',
    );
    assert(chunkBytes == null || chunkBytes > 0, 'chunkBytes must be positive');

    if (chunkBytes == null) {
      return _readFlashDumpRange(
        flashIndex: flashIndex,
        byteOffset: 0,
        byteCount: null,
        onProgress: onProgress,
      );
    }

    final regionSize = flashIndex == flashDumpInternalIndex
        ? flashDumpInternalSize
        : flashDumpExternalSize;
    final combined = Uint8List(regionSize);
    var offset = 0;
    onProgress?.call(0);

    try {
      while (offset < regionSize) {
        final remaining = regionSize - offset;
        final thisChunk = remaining < chunkBytes ? remaining : chunkBytes;
        final chunk = await _readFlashDumpRange(
          flashIndex: flashIndex,
          byteOffset: offset,
          byteCount: thisChunk,
        );
        combined.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
        onProgress?.call(offset / regionSize);
      }
    } on FlashDumpTimeoutException catch (error) {
      // Splice whatever the failing chunk managed to collect into the
      // cumulative buffer, then rethrow with the merged partial bytes.
      if (error.partialBytes.isNotEmpty) {
        final spliceEnd = offset + error.partialBytes.length;
        final clampedEnd = spliceEnd > regionSize ? regionSize : spliceEnd;
        combined.setRange(
          offset,
          clampedEnd,
          error.partialBytes,
        );
        offset = clampedEnd;
      }
      throw FlashDumpTimeoutException(
        flashIndex: error.flashIndex,
        partialBytes: Uint8List.sublistView(combined, 0, offset),
        expectedBytes: regionSize,
      );
    }

    return combined;
  }

  /// Requests a single [byteCount]-sized slice starting at [byteOffset]
  /// (or the rest of the region when [byteCount] is null). Performs one
  /// full request/response exchange with the firmware.
  Future<Uint8List> _readFlashDumpRange({
    required int flashIndex,
    required int byteOffset,
    required int? byteCount,
    ValueChanged<double>? onProgress,
  }) async {
    assert(byteOffset >= 0, 'byteOffset must be non-negative');
    assert(byteCount == null || byteCount > 0, 'byteCount must be positive');

    state = state.copyWith(
      connectionState: PlinkyConnectionState.readingFlashDump,
    );

    try {
      await _webUsbService.resetInterface();
      _receivedData.clear();

      // Request: magic_32 + cmd=0 (send) + idx + offset_32 + len_32.
      // With len=0 the firmware responds with the entire flash region
      // from [byteOffset] onward.
      final requestedLength = byteCount ?? 0;
      final requestBuffer = Uint8List.fromList([
        ..._magicHeaderExtended,
        0, // request to send
        flashIndex,
        byteOffset & 0xFF,
        (byteOffset >> 8) & 0xFF,
        (byteOffset >> 16) & 0xFF,
        (byteOffset >> 24) & 0xFF,
        requestedLength & 0xFF,
        (requestedLength >> 8) & 0xFF,
        (requestedLength >> 16) & 0xFF,
        (requestedLength >> 24) & 0xFF,
      ]);
      _webUsbService.send(requestBuffer);

      // Wait for the 14-byte 32-bit header reply. Keep any non-matching
      // packets around so a timeout can surface whatever the firmware
      // did send (or nothing, if it silently dropped the request).
      final preHeaderBytes = <int>[];
      ByteData headerData;
      try {
        while (true) {
          headerData = await _waitForData();
          if (_isValidFlashDumpHeader(headerData, flashIndex)) {
            break;
          }
          for (var index = 0; index < headerData.lengthInBytes; index++) {
            preHeaderBytes.add(headerData.getUint8(index));
          }
        }
      } on TimeoutException {
        throw FlashDumpTimeoutException(
          flashIndex: flashIndex,
          partialBytes: Uint8List.fromList(preHeaderBytes),
          expectedBytes: 0,
        );
      }

      final bytesToProcess =
          headerData.getUint8(10) +
          headerData.getUint8(11) * 256 +
          headerData.getUint8(12) * 65536 +
          headerData.getUint8(13) * 16777216;

      final dumpBytes = Uint8List(bytesToProcess);
      var processedBytes = 0;
      var lastReportedProgress = 0.0;
      onProgress?.call(0);
      while (processedBytes < bytesToProcess) {
        final ByteData chunkData;
        try {
          chunkData = await _waitForData();
        } on TimeoutException {
          throw FlashDumpTimeoutException(
            flashIndex: flashIndex,
            partialBytes: Uint8List.sublistView(dumpBytes, 0, processedBytes),
            expectedBytes: bytesToProcess,
          );
        }
        final chunkLength = chunkData.lengthInBytes;
        for (var index = 0; index < chunkLength; index++) {
          if (processedBytes + index >= bytesToProcess) {
            break;
          }
          dumpBytes[processedBytes + index] = chunkData.getUint8(index);
        }
        processedBytes += chunkLength;
        final progress = (processedBytes / bytesToProcess).clamp(0.0, 1.0);
        if (progress - lastReportedProgress > 0.005 ||
            processedBytes >= bytesToProcess) {
          lastReportedProgress = progress;
          onProgress?.call(progress);
        }
      }

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
      );
      return dumpBytes;
    } on Exception catch (error) {
      debugPrint('$error');
      // Flash dump failures are handled by the caller's own UI (e.g. the
      // create-dump dialog's partial-bytes recovery). The device itself
      // is still connected, so keep the global connection state intact
      // rather than surfacing this as a top-level Preset Editor error.
      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
        errorMessage: null,
      );
      rethrow;
    }
  }

  bool _isValidFlashDumpHeader(ByteData data, int flashIndex) {
    if (data.lengthInBytes < 14) {
      return false;
    }
    // Extended magic: 0xF3, 0x0F, 0xAB, 0xCB
    if (data.getUint8(0) != 0xF3) {
      return false;
    }
    if (data.getUint8(1) != 0x0F) {
      return false;
    }
    if (data.getUint8(2) != 0xAB) {
      return false;
    }
    if (data.getUint8(3) != 0xCB) {
      return false;
    }
    // Firmware sets cmd=1 in the response.
    if (data.getUint8(4) != 1) {
      return false;
    }
    if (data.getUint8(5) != flashIndex) {
      return false;
    }
    return true;
  }

  /// Reads the current wavetable from Plinky over WebUSB (command 4).
  ///
  /// Returns the raw wavetable bytes as stored in the device's flash.
  Future<Uint8List> readWavetable() async {
    await _webUsbService.resetInterface();
    _receivedData.clear();

    const wavetableByteCount = 17 * 1031 * 2;

    // Send cmd=4 (read wavetable) with the full wavetable size.
    final requestBuffer = Uint8List.fromList([
      ..._magicHeader,
      4, // read wavetable
      0, // idx
      0, 0, // offset (16-bit LE)
      wavetableByteCount & 0xFF,
      (wavetableByteCount >> 8) & 0xFF,
    ]);
    _webUsbService.send(requestBuffer);

    // The firmware responds with a 14-byte extended header (magic 0xCB).
    ByteData headerData;
    while (true) {
      headerData = await _waitForData();
      if (_isValidWavetableReadHeader(headerData)) {
        break;
      }
    }

    final bytesToProcess =
        headerData.getUint8(10) +
        headerData.getUint8(11) * 256 +
        headerData.getUint8(12) * 65536 +
        headerData.getUint8(13) * 16777216;
    debugPrint('Wavetable read: expecting $bytesToProcess bytes');

    final chunks = <Uint8List>[];
    var processedBytes = 0;
    while (processedBytes < bytesToProcess) {
      final chunkData = await _waitForData();
      final chunk = Uint8List(chunkData.lengthInBytes);
      for (var index = 0; index < chunkData.lengthInBytes; index++) {
        chunk[index] = chunkData.getUint8(index);
      }
      chunks.add(chunk);
      processedBytes += chunk.length;
    }

    final totalLength = chunks.fold<int>(
      0,
      (sum, chunk) => sum + chunk.length,
    );
    final wavetableData = Uint8List(totalLength);
    var offset = 0;
    for (final chunk in chunks) {
      wavetableData.setAll(offset, chunk);
      offset += chunk.length;
    }

    debugPrint('Wavetable read complete: ${wavetableData.length} bytes');
    return wavetableData;
  }

  /// Reads back the wavetable from the device and compares it with [sentData].
  ///
  /// Returns `true` if the data matches, `false` otherwise. Logs details
  /// about any mismatch to aid debugging.
  Future<bool> verifyWavetable(Uint8List sentData) async {
    debugPrint('Verifying wavetable...');
    const expectedSize = wavetableShapeCount * wavetableSamplesPerShape * 2;
    final truncatedSentData = sentData.length > expectedSize
        ? sentData.sublist(0, expectedSize)
        : sentData;
    final deviceData = await readWavetable();

    if (deviceData.length != truncatedSentData.length) {
      debugPrint(
        'Wavetable MISMATCH: sent ${truncatedSentData.length} bytes, '
        'read back ${deviceData.length} bytes',
      );
      return false;
    }

    var mismatches = 0;
    int? firstMismatchIndex;
    for (var i = 0; i < truncatedSentData.length; i++) {
      if (deviceData[i] != truncatedSentData[i]) {
        firstMismatchIndex ??= i;
        mismatches++;
      }
    }

    if (mismatches > 0) {
      debugPrint(
        'Wavetable MISMATCH: $mismatches bytes differ, '
        'first at index $firstMismatchIndex '
        '(sent ${truncatedSentData[firstMismatchIndex!]}, '
        'got ${deviceData[firstMismatchIndex]})',
      );
      // Log a few bytes around the first mismatch for context.
      final start = max(0, firstMismatchIndex - 4);
      final end = min(truncatedSentData.length, firstMismatchIndex + 8);
      debugPrint(
        'Sent  [$start..$end]: '
        '${truncatedSentData.sublist(start, end)}',
      );
      debugPrint(
        'Read  [$start..$end]: '
        '${deviceData.sublist(start, end)}',
      );
      return false;
    }

    debugPrint(
      'Wavetable MATCH: all ${truncatedSentData.length} bytes verified',
    );
    return true;
  }

  bool _isValidWavetableReadHeader(ByteData data) {
    if (data.lengthInBytes < 14) {
      return false;
    }
    // Extended magic: 0xF3, 0x0F, 0xAB, 0xCB
    if (data.getUint8(0) != 0xF3) {
      return false;
    }
    if (data.getUint8(1) != 0x0F) {
      return false;
    }
    if (data.getUint8(2) != 0xAB) {
      return false;
    }
    if (data.getUint8(3) != 0xCB) {
      return false;
    }
    // Firmware changes cmd from 4 to 5 in the response.
    if (data.getUint8(4) != 5) {
      return false;
    }
    return true;
  }

  /// Sends data with a standard 10-byte (16-bit) WebUSB header.
  Future<void> _sendWithHeader({
    required int command,
    required int index,
    required Uint8List data,
    int offset = 0,
  }) async {
    final byteCount = data.length;
    final header = Uint8List.fromList([
      ..._magicHeader,
      command,
      index,
      offset & 0xFF,
      (offset >> 8) & 0xFF,
      byteCount & 0xFF,
      (byteCount >> 8) & 0xFF,
    ]);

    // Fire-and-forget the header, then send data in one or more
    // large slices. The browser handles USB packetization internally.
    await _webUsbService.send(header);

    var position = 0;
    while (position < data.length) {
      final end = min(position + _transferOutChunkSize, data.length);
      await _webUsbService.send(data.sublist(position, end));
      position = end;
    }
  }

  /// Sends a large data payload with an extended 14-byte (32-bit) header.
  ///
  /// Data is sent in [_transferOutChunkSize] slices. The browser handles
  /// splitting each slice into 64-byte USB packets, so we avoid
  /// thousands of individual JS-interop round-trips.
  Future<void> _sendStreamWithExtendedHeader({
    required int command,
    required int index,
    required int offset,
    required Uint8List data,
    ValueChanged<double>? onProgress,
  }) async {
    final byteCount = data.length;
    final header = Uint8List(14);
    header[0] = _magicHeaderExtended[0];
    header[1] = _magicHeaderExtended[1];
    header[2] = _magicHeaderExtended[2];
    header[3] = _magicHeaderExtended[3];
    header[4] = command;
    header[5] = index;
    header[6] = offset & 0xFF;
    header[7] = (offset >> 8) & 0xFF;
    header[8] = (offset >> 16) & 0xFF;
    header[9] = (offset >> 24) & 0xFF;
    header[10] = byteCount & 0xFF;
    header[11] = (byteCount >> 8) & 0xFF;
    header[12] = (byteCount >> 16) & 0xFF;
    header[13] = (byteCount >> 24) & 0xFF;

    await _webUsbService.send(header);

    var position = 0;
    while (position < data.length) {
      final end = min(position + _transferOutChunkSize, data.length);
      await _webUsbService.send(data.sublist(position, end));
      position = end;
      onProgress?.call(position / data.length);
    }
  }

  set presetNumber(int number) {
    _presetNumber = number.clamp(0, 31);
  }

  set sourcePresetId(String? id) {
    state = state.copyWith(sourcePresetId: id);
  }

  int _presetNumber = 0;

  void parsePresetFromUrl(String encodedPreset) {
    try {
      final decodedPreset = bytedecompress(
        Uri.decodeComponent(encodedPreset),
      );
      final preset = Preset(decodedPreset.buffer);
      state = state.copyWith(preset: preset);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        errorMessage: 'Failed to parse preset from URL',
      );
    }
  }

  void loadPresetFromBytes(
    Uint8List data, {
    String? sourceId,
    String? sourceSampleId,
  }) {
    final preset = Preset(data.buffer);
    state = state.copyWith(
      preset: preset,
      sourcePresetId: sourceId,
      sourceSampleId: sourceSampleId,
    );
  }

  void clearPreset() {
    state = state.copyWith(
      preset: null,
      sourcePresetId: null,
      sourceSampleId: null,
    );
  }

  void randomizePreset(List<RandomizeGroup> groups) {
    final preset = state.preset;
    if (preset == null) {
      return;
    }
    preset.randomize(groups);
    // Force a state change since Preset is mutated in place.
    state = state.copyWith(preset: null);
    state = state.copyWith(preset: preset);
  }

  set presetName(String name) {
    state.preset?.name = name;
  }

  set presetCategory(PresetCategory category) {
    state.preset?.category = category;
  }

  set presetArp(bool value) {
    state.preset?.arp = value;
    ref.invalidateSelf();
  }

  set presetLatch(bool value) {
    state.preset?.latch = value;
    ref.invalidateSelf();
  }
}
