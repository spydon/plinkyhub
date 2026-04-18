import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';

part 'user_profile_state.freezed.dart';

@freezed
abstract class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    @Default('') String userId,
    @Default('') String username,
    @Default([]) List<SavedPreset> presets,
    @Default([]) List<SavedPack> packs,
    @Default([]) List<SavedSample> samples,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _UserProfileState;
}
