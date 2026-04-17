import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/authentication_state.dart';
import 'package:plinkyhub/widgets/update_password_dialog.dart';

class _FakeAuthenticationNotifier extends AuthenticationNotifier {
  int updateCount = 0;
  String? lastPassword;
  bool shouldFail = false;

  @override
  AuthenticationState build() =>
      const AuthenticationState(isPasswordRecovery: true);

  @override
  Future<void> updatePassword(String newPassword) async {
    updateCount++;
    lastPassword = newPassword;
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(Duration.zero);
    if (shouldFail) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong.',
      );
      return;
    }
    state = state.copyWith(
      isLoading: false,
      isPasswordRecovery: false,
      infoMessage: 'Your password has been updated.',
    );
  }
}

Widget _harness(_FakeAuthenticationNotifier notifier) {
  return ProviderScope(
    overrides: [
      authenticationProvider.overrideWith(() => notifier),
    ],
    child: const MaterialApp(
      home: Scaffold(body: UpdatePasswordDialog()),
    ),
  );
}

void main() {
  testWidgets('requires password and confirmation to match', (tester) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'supersecret');
    await tester.enterText(fields.at(1), 'typo-secret');
    await tester.tap(find.text('Update password'));
    await tester.pump();

    expect(notifier.updateCount, 0);
    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('rejects passwords below the minimum length', (tester) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'abc');
    await tester.enterText(fields.at(1), 'abc');
    await tester.tap(find.text('Update password'));
    await tester.pump();

    expect(notifier.updateCount, 0);
    expect(
      find.text('Password must be at least $minimumPasswordLength characters.'),
      findsOneWidget,
    );
  });

  testWidgets('submits a valid new password and shows confirmation', (
    tester,
  ) async {
    final notifier = _FakeAuthenticationNotifier();
    await tester.pumpWidget(_harness(notifier));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'supersecret');
    await tester.enterText(fields.at(1), 'supersecret');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(notifier.updateCount, 1);
    expect(notifier.lastPassword, 'supersecret');
    expect(find.text('Password updated'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('surfaces notifier errors from updatePassword', (tester) async {
    final notifier = _FakeAuthenticationNotifier()..shouldFail = true;
    await tester.pumpWidget(_harness(notifier));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'supersecret');
    await tester.enterText(fields.at(1), 'supersecret');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Password updated'), findsNothing);
  });
}
