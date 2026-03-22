import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/category.dart';
import 'package:plinkyhub/models/patch.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/utils/compress.dart';

const _usbBufferSize = 64;
const _magicHeader = [0xF3, 0x0F, 0xAB, 0xCA];

final plinkyProvider =
    NotifierProvider<PlinkyNotifier, PlinkyState>(PlinkyNotifier.new);

class PlinkyNotifier extends Notifier<PlinkyState> {
  final WebUsbService _webUsbService = WebUsbService();
  Completer<ByteData>? _dataCompleter;

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
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
    }
  }

  void _onDataReceived(ByteData data) {
    _dataCompleter?.complete(data);
    _dataCompleter = null;
  }

  void _onError(Object error) {
    state = state.copyWith(
      connectionState: PlinkyConnectionState.error,
      errorMessage: error.toString(),
    );
  }

  Future<ByteData> _waitForData() {
    _dataCompleter = Completer<ByteData>();
    return _dataCompleter!.future;
  }

  Future<void> loadPatch() async {
    final patchNumber = state.patchNumber.clamp(0, 31);
    state = state.copyWith(
      connectionState: PlinkyConnectionState.loadingPatch,
      patchNumber: patchNumber,
    );

    try {
      final requestBuffer = Uint8List.fromList([
        ..._magicHeader,
        0, // get
        patchNumber,
        0,
        0,
        0,
        0,
      ]);
      await _webUsbService.send(requestBuffer);

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

      final totalLength =
          chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
      final patchData = Uint8List(totalLength);
      var offset = 0;
      for (final chunk in chunks) {
        patchData.setAll(offset, chunk);
        offset += chunk.length;
      }

      final patch = Patch(patchData.buffer);

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
        patch: patch,
      );
    } on Exception catch (error) {
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

  Future<void> savePatch() async {
    final patch = state.patch;
    if (patch == null) {
      return;
    }

    final patchNumber = state.patchNumber.clamp(0, 31);
    state = state.copyWith(
      connectionState: PlinkyConnectionState.savingPatch,
      patchNumber: patchNumber,
    );

    try {
      final data = Uint8List.view(patch.buffer);
      final byteCount = data.length;
      final lowByte = byteCount & 0xFF;
      final highByte = (byteCount >> 8) & 0xFF;

      final headerBuffer = Uint8List.fromList([
        ..._magicHeader,
        1, // set
        patchNumber,
        0,
        0,
        lowByte,
        highByte,
      ]);
      await _webUsbService.send(headerBuffer);

      var offset = 0;
      while (offset < data.length) {
        final end = (offset + _usbBufferSize).clamp(0, data.length);
        final chunk = data.sublist(offset, end);
        await _webUsbService.send(chunk);
        offset += _usbBufferSize;
      }

      state = state.copyWith(
        connectionState: PlinkyConnectionState.connected,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        connectionState: PlinkyConnectionState.error,
        errorMessage: error.toString(),
      );
    }
  }

  set patchNumber(int number) {
    state = state.copyWith(patchNumber: number.clamp(0, 31));
  }

  void parsePatchFromUrl(String encodedPatch) {
    try {
      final decodedPatch = bytedecompress(
        Uri.decodeComponent(encodedPatch),
      );
      final patch = Patch(decodedPatch.buffer);
      state = state.copyWith(patch: patch);
    } on Exception {
      state = state.copyWith(
        errorMessage: 'Failed to parse patch from URL',
      );
    }
  }

  void loadPatchFromBytes(Uint8List data) {
    final patch = Patch(data.buffer);
    state = state.copyWith(patch: patch);
  }

  void clearPatch() {
    state = state.copyWith(patch: null);
  }

  void randomizePatch(List<RandomizeGroup> groups) {
    final patch = state.patch;
    if (patch == null) {
      return;
    }
    patch.randomize(groups);
    state = state.copyWith(patch: patch);
  }

  set patchName(String name) {
    state.patch?.name = name;
  }

  set patchCategory(PatchCategory category) {
    state.patch?.category = category;
  }
}
