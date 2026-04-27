import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

final soundServiceProvider = Provider<SoundService>((_) => SoundService());

class SoundService {
  final _loadedSources = <String, AudioSource>{};
  SoundHandle? _activeHandle;
  AudioSource? _silenceSource;

  static const _silenceKey = '_silence_50ms';
  static const _silenceDuration = Duration(milliseconds: 50);

  SoLoud get _soloud => SoLoud.instance;

  Future<void> _ensureInitialized() async {
    if (!_soloud.isInitialized) {
      await _soloud.init();
    }
  }

  /// Load an audio source by [key], returning a cached version if available.
  Future<AudioSource> loadSource(String key, Uint8List wavBytes) async {
    await _ensureInitialized();

    final cached = _loadedSources[key];
    if (cached != null && _soloud.activeSounds.contains(cached)) {
      return cached;
    }

    debugPrint('Loading source: $key (${wavBytes.length} bytes)');
    final source = await _soloud.loadMem(key, wavBytes);
    _loadedSources[key] = source;
    return source;
  }

  /// Play an audio source from the beginning, stopping any current preview.
  Future<SoundHandle> play(AudioSource source) async {
    await stopPreview();
    final handle = await _soloud.play(source);
    _activeHandle = handle;
    return handle;
  }

  /// Play a slice of [wavBytes] defined by fractional start/end points.
  Future<({SoundHandle handle, Duration sliceDuration})> playSlice({
    required String key,
    required Uint8List wavBytes,
    required double startFraction,
    required double endFraction,
  }) async {
    await stopPreview();
    await _flushOutputBufferWithSilence();

    final source = await loadSource(key, wavBytes);
    final totalDuration = _soloud.getLength(source);
    final startTime = totalDuration * startFraction;
    final sliceDuration = totalDuration * (endFraction - startFraction);

    final handle = await _soloud.play(source, paused: true);
    _soloud.seek(handle, startTime);
    _soloud.setPause(handle, false);

    if (sliceDuration > Duration.zero) {
      _soloud.scheduleStop(handle, sliceDuration);
    }

    _activeHandle = handle;
    return (handle: handle, sliceDuration: sliceDuration);
  }

  /// Stop the currently playing preview.
  ///
  /// Mutes the handle before stopping so that any residual audio in SoLoud's
  /// internal output buffer is silent.
  Future<void> stopPreview() async {
    final handle = _activeHandle;
    if (handle != null) {
      try {
        _soloud.setVolume(handle, 0);
        _soloud.stop(handle);
      } on Exception catch (_) {}
      _activeHandle = null;
    }
  }

  /// Dispose a previously loaded source and remove it from the cache.
  void disposeSource(String key) {
    final source = _loadedSources.remove(key);
    if (source != null) {
      _soloud.disposeSource(source);
    }
  }

  /// The duration of a loaded source.
  Duration getLength(AudioSource source) => _soloud.getLength(source);

  /// Plays [_silenceDuration] of zeros and waits for it to drain so that any
  /// residual audio in SoLoud's output buffer is displaced before the next
  /// slice starts.
  Future<void> _flushOutputBufferWithSilence() async {
    await _ensureInitialized();
    final source = _silenceSource ??= await _soloud.loadMem(
      _silenceKey,
      _buildSilenceWav(_silenceDuration),
    );
    await _soloud.play(source);
    await Future<void>.delayed(_silenceDuration);
  }
}

/// Builds a mono 16-bit PCM WAV containing [duration] of zeros.
Uint8List _buildSilenceWav(Duration duration) {
  const sampleRate = 8000;
  final frameCount = (sampleRate * duration.inMicroseconds) ~/ 1000000;
  final dataSize = frameCount * 2;
  final wav = ByteData(44 + dataSize);
  wav
    ..setUint32(0, 0x52494646) // 'RIFF'
    ..setUint32(4, 36 + dataSize, Endian.little)
    ..setUint32(8, 0x57415645) // 'WAVE'
    ..setUint32(12, 0x666d7420) // 'fmt '
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // 'data'
    ..setUint32(40, dataSize, Endian.little);
  return wav.buffer.asUint8List();
}
