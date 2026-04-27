import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

final soundServiceProvider = Provider<SoundService>((_) => SoundService());

class SoundService {
  final _loadedSources = <String, AudioSource>{};
  SoundHandle? _activeHandle;

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

  /// Play a slice of an audio source defined by fractional start/end points.
  Future<SoundHandle> playSlice(
    AudioSource source, {
    required double startFraction,
    required double endFraction,
  }) async {
    await stopPreview();

    final totalDuration = _soloud.getLength(source);
    final startTime = totalDuration * startFraction;
    final sliceDuration = totalDuration * (endFraction - startFraction);

    // Start at volume 0 so that any audio rendered before the seek and
    // unpause take effect (e.g. a frame at position 0) is silent.
    final handle = await _soloud.play(source, paused: true, volume: 0);
    _soloud.seek(handle, startTime);
    _soloud.setPause(handle, false);
    _soloud.setVolume(handle, 1);

    if (sliceDuration > Duration.zero) {
      _soloud.scheduleStop(handle, sliceDuration);
    }

    _activeHandle = handle;
    return handle;
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
}
