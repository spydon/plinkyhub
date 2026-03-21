import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/patch.dart';

part 'plinky_state.freezed.dart';

enum PlinkyConnectionState {
  disconnected,
  connecting,
  connected,
  loadingPatch,
  savingPatch,
  error,
}

@freezed
abstract class PlinkyState with _$PlinkyState {
  const factory PlinkyState({
    @Default(PlinkyConnectionState.disconnected)
    PlinkyConnectionState connectionState,
    Patch? patch,
    @Default(0) int patchNumber,
    String? errorMessage,
  }) = _PlinkyState;
}
