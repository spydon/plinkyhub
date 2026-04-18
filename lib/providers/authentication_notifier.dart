import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/authentication_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Which email-link flow the user most recently started. Persisted to
/// local storage so the router can tailor the "link expired" message
/// when the user eventually clicks the link.
enum AuthEmailFlow { signup, recovery }

const _lastAuthEmailFlowKey = 'last_auth_email_flow';
const _lastAuthEmailFlowTimestampKey = 'last_auth_email_flow_timestamp';

/// Maximum age of a persisted flow marker we still trust. Longer than
/// any Supabase email-link lifetime, but short enough to avoid stale
/// carry-over from weeks-old activity.
const _lastAuthEmailFlowMaxAge = Duration(days: 2);

final authenticationProvider =
    NotifierProvider<AuthenticationNotifier, AuthenticationState>(
      AuthenticationNotifier.new,
    );

class AuthenticationNotifier extends Notifier<AuthenticationState> {
  StreamSubscription<AuthState>? _authSubscription;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  AuthenticationState build() {
    final currentUser = _supabase.auth.currentUser;
    _authSubscription?.cancel();
    _authSubscription = _supabase.auth.onAuthStateChange.listen((
      authState,
    ) async {
      final user = authState.session?.user;
      String? username;
      if (user != null) {
        username = await _fetchUsername(user.id);
      }
      final isRecoveryEvent =
          authState.event == AuthChangeEvent.passwordRecovery;
      state = state.copyWith(
        user: user,
        username: username,
        isLoading: false,
        errorMessage: null,
        infoMessage: null,
        isPasswordRecovery: isRecoveryEvent || state.isPasswordRecovery,
      );
    });
    ref.onDispose(() => _authSubscription?.cancel());
    if (currentUser != null) {
      Future.microtask(() async {
        final username = await _fetchUsername(currentUser.id);
        state = state.copyWith(username: username);
      });
    }
    return AuthenticationState(user: currentUser);
  }

  Future<String?> _fetchUsername(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .maybeSingle();
      return response?['username'] as String?;
    } on PostgrestException catch (error) {
      debugPrint('$error');
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: response.user,
        isLoading: false,
      );
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.message),
      );
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      await _recordLastAuthEmailFlow(AuthEmailFlow.signup);
      state = state.copyWith(
        user: response.user,
        username: username,
        isLoading: false,
      );
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.message),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.toString()),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabase.auth.signOut();
      state = const AuthenticationState();
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.message),
      );
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      infoMessage: null,
    );
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email);
      await _recordLastAuthEmailFlow(AuthEmailFlow.signup);
      state = state.copyWith(
        isLoading: false,
        infoMessage: 'Confirmation email sent! Please check your inbox.',
      );
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.message),
      );
    }
  }

  /// Send a password-reset email to [email]. Supabase emails a link that,
  /// when clicked, returns to the app with a recovery session that fires
  /// [AuthChangeEvent.passwordRecovery]. The app then prompts the user for
  /// a new password via [updatePassword].
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      infoMessage: null,
    );
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: _passwordResetRedirectUrl(),
      );
      await _recordLastAuthEmailFlow(AuthEmailFlow.recovery);
      state = state.copyWith(
        isLoading: false,
        infoMessage:
            'Password reset email sent! Check your inbox and click the '
            'link to choose a new password.',
      );
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.message),
      );
    }
  }

  /// Set a new password for the currently signed-in user. Used both for
  /// the password-recovery flow (after the user clicks the email link)
  /// and for in-app password changes.
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      infoMessage: null,
    );
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      state = state.copyWith(
        isLoading: false,
        isPasswordRecovery: false,
        infoMessage: 'Your password has been updated.',
      );
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: friendlyAuthError(error.message),
      );
    }
  }

  static Future<void> _recordLastAuthEmailFlow(AuthEmailFlow flow) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_lastAuthEmailFlowKey, flow.name);
      await preferences.setInt(
        _lastAuthEmailFlowTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } on Object catch (error) {
      debugPrint('Failed to record auth email flow: $error');
    }
  }

  /// Returns the most recent [AuthEmailFlow] the user initiated, or
  /// null if none is recorded (or the record is too old to trust).
  static Future<AuthEmailFlow?> readLastAuthEmailFlow() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final name = preferences.getString(_lastAuthEmailFlowKey);
      final timestamp = preferences.getInt(_lastAuthEmailFlowTimestampKey);
      if (name == null || timestamp == null) {
        return null;
      }
      final recordedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(recordedAt) > _lastAuthEmailFlowMaxAge) {
        return null;
      }
      return AuthEmailFlow.values.firstWhere(
        (flow) => flow.name == name,
        orElse: () => AuthEmailFlow.signup,
      );
    } on Object catch (error) {
      debugPrint('Failed to read auth email flow: $error');
      return null;
    }
  }

  static String? _passwordResetRedirectUrl() {
    if (!kIsWeb) {
      return null;
    }
    // On Flutter Web, Uri.base reflects the current document URL;
    // `origin` gives the scheme + host (+ port) without path/query.
    return Uri.base.origin;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearInfo() {
    state = state.copyWith(infoMessage: null);
  }

  void setInfo(String message) {
    state = state.copyWith(infoMessage: message);
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, infoMessage: null);
  }

  /// Exit password-recovery mode. The user remains signed in with the
  /// recovery session, but subsequent flows stop treating the session as
  /// a recovery in progress.
  void clearPasswordRecovery() {
    state = state.copyWith(isPasswordRecovery: false);
  }

  void setPrefillEmail(String email) {
    state = state.copyWith(prefillEmail: email);
  }

  void clearPrefillEmail() {
    state = state.copyWith(prefillEmail: null);
  }

  static String friendlyAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please check your inbox and confirm your email '
          'before signing in.';
    }
    if (lower.contains('user already registered')) {
      return 'An account with this email already exists. '
          'Try signing in instead.';
    }
    if (lower.contains('signup is disabled')) {
      return 'Sign-up is currently disabled. '
          'Please contact the administrator.';
    }
    if (lower.contains('email rate limit exceeded') ||
        lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('password') && lower.contains('at least')) {
      return 'Password is too short. '
          'Please use at least 6 characters.';
    }
    if (lower.contains('new password should be different') ||
        lower.contains('password should be different') ||
        lower.contains('same password')) {
      return 'Your new password must be different from your old password.';
    }
    if (lower.contains('auth session missing') ||
        lower.contains('session_not_found') ||
        lower.contains('invalid refresh token')) {
      return 'Your recovery link has expired. '
          'Please request a new password reset email.';
    }
    if (lower.contains('unique') || lower.contains('duplicate')) {
      return 'That username is already taken. '
          'Please choose a different one.';
    }
    if (lower.contains('row-level security') ||
        lower.contains('row level security')) {
      return 'Unable to create your profile. '
          'Please try again.';
    }
    if (lower.contains('network') ||
        lower.contains('socket') ||
        lower.contains('connection')) {
      return 'Unable to connect. '
          'Please check your internet connection.';
    }
    return message;
  }
}
