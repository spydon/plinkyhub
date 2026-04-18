import 'package:freezed_annotation/freezed_annotation.dart';

part 'pattern_playback_state.freezed.dart';

@freezed
abstract class PatternPlaybackState with _$PatternPlaybackState {
  const factory PatternPlaybackState({
    @Default(false) bool isPlaying,
    String? currentPatternId,
    @Default(0) int currentStep,
    int? presetSlot,
    @Default(80) double beatsPerMinute,
  }) = _PatternPlaybackState;
}
