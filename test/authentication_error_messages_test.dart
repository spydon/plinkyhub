import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:test/test.dart';

void main() {
  group('AuthenticationNotifier.friendlyAuthError', () {
    test('maps invalid login credentials to a friendly message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'Invalid login credentials',
      );
      expect(result, contains('Incorrect email or password'));
    });

    test('maps email-not-confirmed to a confirmation prompt', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'Email not confirmed',
      );
      expect(result, contains('confirm your email'));
    });

    test('maps duplicate-user to an existing-account message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'User already registered',
      );
      expect(result, contains('already exists'));
    });

    test('maps rate-limit to a throttling message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'Email rate limit exceeded',
      );
      expect(result, contains('Too many attempts'));
    });

    test('maps short-password to a length message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'Password should be at least 6 characters',
      );
      expect(result, contains('at least 6 characters'));
    });

    test('maps same-password reuse to a reuse message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'New password should be different from the old password',
      );
      expect(result, contains('different from your old password'));
    });

    test('maps missing-session errors to an expired-link message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'Auth session missing!',
      );
      expect(result, contains('recovery link has expired'));
    });

    test('maps invalid refresh token to an expired-link message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'Invalid Refresh Token: Not Found',
      );
      expect(result, contains('recovery link has expired'));
    });

    test('maps network errors to a connection message', () {
      final result = AuthenticationNotifier.friendlyAuthError(
        'SocketException: Failed to connect',
      );
      expect(result, contains('check your internet connection'));
    });

    test('falls through to the raw message for unknown errors', () {
      const raw = 'something weird happened that we do not handle';
      expect(AuthenticationNotifier.friendlyAuthError(raw), equals(raw));
    });
  });
}
