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

    final handle = await _soloud.play(source, paused: true);
    _soloud.seek(handle, startTime);
    _soloud.setPause(handle, false);

    if (sliceDuration > Duration.zero) {
      _soloud.scheduleStop(handle, sliceDuration);
    }

    _activeHandle = handle;
    return handle;
  }

  /// Pause or resume the currently playing preview.
  void setPaused({required bool paused}) {
    final handle = _activeHandle;
    if (handle != null) {
      _soloud.setPause(handle, paused);
    }
  }

  /// Stop the currently playing preview.
  Future<void> stopPreview() async {
    final handle = _activeHandle;
    if (handle != null) {
      try {
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
