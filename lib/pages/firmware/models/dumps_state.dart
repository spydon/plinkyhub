import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/pages/firmware/models/saved_dump.dart';

part 'dumps_state.freezed.dart';

@freezed
abstract class DumpsState with _$DumpsState {
  const factory DumpsState({
    @Default([]) List<SavedDump> dumps,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _DumpsState;
}
