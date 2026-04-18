import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinkyhub/models/authentication_state.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/forgot_password_dialog.dart';

class _FakeAuthenticationNotifier extends AuthenticationNotifier {
  int sendCount = 0;
  String? lastEmail;
  bool shouldFail = false;

  @override
  AuthenticationState build() => const AuthenticationState();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    sendCount++;
    lastEmail = email;
    if (shouldFail) {
      state = state.copyWith(
        errorMessage: 'Something went wrong.',
      );
      return;
    }
    state = state.copyWith(
      infoMessage: 'Password reset email sent! Check your inbox.',
    );
  }
}

Widget _harness({
  required _FakeAuthenticationNotifier notifier,
  String? prefillEmail,
}) {
  return ProviderScope(
    overrides: [
      authenticationProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ForgotPasswordDialog(prefillEmail: prefillEmail),
      ),
    ),
  );
}

void main() {
  testWidgets('submits a valid email to the notifier', (tester) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier: notifier));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'user@example.com');
    await tester.tap(find.text('Send reset email'));
    await tester.pump();

    expect(notifier.sendCount, 1);
    expect(notifier.lastEmail, 'user@example.com');
  });

  testWidgets('shows validation error when email is empty', (tester) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier: notifier));
    await tester.pump();

    await tester.tap(find.text('Send reset email'));
    await tester.pump();

    expect(notifier.sendCount, 0);
    expect(find.text('Please enter your email address.'), findsOneWidget);
  });

  testWidgets('rejects malformed email', (tester) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier: notifier));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'not-an-email');
    await tester.tap(find.text('Send reset email'));
    await tester.pump();

    expect(notifier.sendCount, 0);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets('prefills email when provided', (tester) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(
      _harness(notifier: notifier, prefillEmail: 'prefill@example.com'),
    );
    await tester.pump();

    expect(find.text('prefill@example.com'), findsOneWidget);
  });

  testWidgets('switches to confirmation view after email is sent', (
    tester,
  ) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier: notifier));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'user@example.com');
    await tester.tap(find.text('Send reset email'));
    await tester.pump();

    expect(find.textContaining('we sent a link'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Send reset email'), findsNothing);
  });
}
