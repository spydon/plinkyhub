import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/preset.dart';

part 'plinky_state.freezed.dart';

enum PlinkyConnectionState {
  disconnected,
  connecting,
  connected,
  loadingPreset,
  savingPreset,
  error,
}

@freezed
abstract class PlinkyState with _$PlinkyState {
  const factory PlinkyState({
    @Default(PlinkyConnectionState.disconnected)
    PlinkyConnectionState connectionState,
    Preset? preset,
    @Default(0) int presetNumber,
    String? errorMessage,
    /// ID of the saved cloud preset that was loaded into the editor,
    /// used to enable overwriting instead of always saving new.
    String? sourcePresetId,
  }) = _PlinkyState;
}
