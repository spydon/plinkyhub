import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/saved_preset.dart';

part 'saved_presets_state.freezed.dart';

@freezed
abstract class SavedPresetsState with _$SavedPresetsState {
  const factory SavedPresetsState({
    @Default([]) List<SavedPreset> userPresets,
    @Default([]) List<SavedPreset> publicPresets,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SavedPresetsState;
}
