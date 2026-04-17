import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_state.freezed.dart';

@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    @Default(false) bool isLoading,
    User? user,
    String? username,
    String? errorMessage,
    String? infoMessage,
    String? prefillEmail,
    @Default(false) bool isPasswordRecovery,
  }) = _AuthenticationState;
}
