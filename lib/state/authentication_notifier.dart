import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/authentication_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      state = state.copyWith(
        user: user,
        username: username,
        isLoading: false,
        errorMessage: null,
      );
    });
    ref.onDispose(() => _authSubscription?.cancel());
    if (currentUser != null) {
      _fetchUsername(currentUser.id).then((username) {
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
        errorMessage: _friendlyAuthError(error.message),
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
      state = state.copyWith(
        user: response.user,
        username: username,
        isLoading: false,
      );
    } on AuthException catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyAuthError(error.message),
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyAuthError(error.toString()),
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
        errorMessage: _friendlyAuthError(error.message),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  static String _friendlyAuthError(String message) {
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
