import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/models/saved_pattern.dart';

part 'saved_patterns_state.freezed.dart';

@freezed
abstract class SavedPatternsState with _$SavedPatternsState {
  const factory SavedPatternsState({
    @Default([]) List<SavedPattern> userPatterns,
    @Default([]) List<SavedPattern> starredPatterns,
    @Default([]) List<SavedPattern> publicPatterns,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SavedPatternsState;
}
