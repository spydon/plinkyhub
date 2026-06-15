import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:plinkyhub/utils/wavetable.dart';
import 'package:plinkyhub/utils/wavetable_cache.dart';

class WavetablePlayer extends StatefulWidget {
  final WavetableCache cache;

  const WavetablePlayer({required this.cache, super.key});

  @override
  State<WavetablePlayer> createState() => _WavetablePlayerState();
}

class _WavetablePlayerState extends State<WavetablePlayer> {
  late final _soloud = SoLoud.instance;

  AudioSource? _soloudBufferStream;
  SoundHandle? _currentSound;

  late double _currentSlot;
  double _frequency = 220.0;
  double _currentVolume = 0.7;
  int get slotA => _currentSlot.floor();
  double get slotAMix => 1 - (_currentSlot - slotA);
  int get slotB => _currentSlot.ceil() % wavetableUserShapeCount;
  double get slotBMix => 1 - slotAMix;
  List<double> get currentSamples => List.generate(
    widget.cache.sampleCount,
    (i) =>
        widget.cache[slotA].samples[i] * slotAMix +
        widget.cache[slotB].samples[i] * slotBMix,
  );

  static const int _copies = 16;
  static const int _sampleRate = 44100;
  static const double _minFrequency = 50.0;
  static const double _maxFrequency = 4000.0;

  Int16List get currentPCM => widget.cache[slotA]
      .mixWith(widget.cache[slotB], slotBMix)
      .toPCM16(frequency: _frequency, copies: _copies);

  bool _soloudReady = false;

  @override
  void initState() {
    super.initState();
    _currentSlot = 0;
    _soloud.init().then((_) async {
      widget.cache.addListener(_onSlotUpdated);
      await updateBuffer();
      setState(() => _soloudReady = true);
    });
  }

  double _frequencyToSlider(double frequency) =>
      (log(frequency) - log(_minFrequency)) /
      (log(_maxFrequency) - log(_minFrequency));
  double _sliderToFrequency(double t) =>
      exp(log(_minFrequency) + t * (log(_maxFrequency) - log(_minFrequency)));

  static int get _maxBufferBytes =>
      (_sampleRate / _minFrequency).ceil() * 4 * _copies;

  AudioSource get newBufferStream => _soloud.setBufferStream(
    maxBufferSizeBytes: _maxBufferBytes,
    bufferingTimeNeeds: 0.1,
    sampleRate: _sampleRate,
  );

  Future<void> updateBuffer() async {
    _soloudBufferStream ??= newBufferStream;
    _soloud.resetBufferStream(_soloudBufferStream!);
    _soloud.addAudioDataStream(
      _soloudBufferStream!,
      currentPCM.buffer.asUint8List(),
    );
  }

  void _onSlotUpdated() {
    // only the changed slot needs updating
    if (widget.cache.lastUpdatedSlot != slotA &&
        widget.cache.lastUpdatedSlot != slotB) {
      return;
    }
    if (_soloudReady) {
      updateBuffer();
    }
  }

  @override
  void didUpdateWidget(WavetablePlayer old) {
    super.didUpdateWidget(old);
    if (widget.cache != old.cache) {
      old.cache.removeListener(_onSlotUpdated);
      widget.cache.addListener(_onSlotUpdated);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_soloudReady) {
      return const Center(child: CircularProgressIndicator());
    }
    final sliderLabelA = '#$slotA';
    final sliderLabelB = slotBMix > 0
        ? ' (${slotAMix.toStringAsFixed(2)}) + '
              '#$slotB (${slotBMix.toStringAsFixed(2)})'
        : '';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Wavetable Player',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Slot: ${_currentSlot.toStringAsFixed(2)}'),
          Slider(
            value: _currentSlot,
            secondaryTrackValue: slotB.toDouble(),
            label: sliderLabelA + sliderLabelB,
            onChanged: (v) => setState(() => _currentSlot = v),
            onChangeEnd: (_) {
              updateBuffer();
            },
            max: wavetableUserShapeCount.toDouble() - 0.01,
          ),
          const SizedBox(height: 8),
          // Volume slider
          const Text('Volume'),
          Slider(
            value: _currentVolume,
            onChanged: (v) {
              if (_currentSound != null) {
                _soloud.setVolume(_currentSound!, v);
              }
              setState(() => _currentVolume = v);
            },
          ),
          const SizedBox(height: 8),
          // Frequency slider (log scale: slider position maps to log frequency)
          Text('Frequency: ${_frequency.toStringAsFixed(1)} Hz'),
          Slider(
            value: _frequencyToSlider(_frequency),
            onChanged: (v) =>
                setState(() => _frequency = _sliderToFrequency(v)),
            onChangeEnd: (_) => updateBuffer(),
          ),
          const SizedBox(height: 16),
          // Play/Pause button
          ElevatedButton(
            onPressed: () async {
              if (_currentSound == null) {
                _currentSound = await _soloud.play(
                  _soloudBufferStream!,
                  looping: true,
                  volume: _currentVolume,
                );
              } else {
                _soloud.stop(_currentSound!);
                _currentSound = null;
              }
              setState(() {});
            },
            child: Text(_currentSound == null ? 'Play' : 'Stop'),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    widget.cache.removeListener(_onSlotUpdated);
    if (_soloudBufferStream != null) {
      await _soloud.disposeSource(_soloudBufferStream!);
      _soloudBufferStream = null;
    }
    super.dispose();
  }
}
