import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/preset.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/utils/compress.dart';

const _usbBufferSize = 64;
const _magicHeader = [0xF3, 0x0F, 0xAB, 0xCA];

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
        onTimeout: () =>
            throw TimeoutException('No response from Plinky'),
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

  set presetNumber(int number) {
    _presetNumber = number.clamp(0, 31);
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

  void loadPresetFromBytes(Uint8List data, {String? sourceId}) {
    final preset = Preset(data.buffer);
    state = state.copyWith(preset: preset, sourcePresetId: sourceId);
  }

  void clearPreset() {
    state = state.copyWith(preset: null, sourcePresetId: null);
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
