import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/forgot_password_dialog.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/settings_dialog.dart';

const reservedUsernames = {
  'my-plinky',
  'editor',
  'presets',
  'packs',
  'samples',
  'wavetables',
  'patterns',
  'users',
  'profile',
  'firmware',
  'about',
};

enum _AccountMenuAction { viewProfile, settings, signOut }

class AuthenticationButton extends ConsumerWidget {
  const AuthenticationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticationState = ref.watch(authenticationProvider);
    final user = authenticationState.user;

    if (authenticationState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (user == null) {
      return TextButton(
        onPressed: () => _showSignInDialog(context, ref),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login, size: 24),
            Text('Sign in'),
          ],
        ),
      );
    }

    final username = authenticationState.username;
    final displayName = username ?? user.email ?? 'Account';

    return PopupMenuButton<_AccountMenuAction>(
      tooltip: displayName,
      onSelected: (action) {
        switch (action) {
          case _AccountMenuAction.viewProfile:
            if (username != null) {
              context.go(AppRoute.userPage(username));
            }
          case _AccountMenuAction.settings:
            showDialog<void>(
              context: context,
              builder: (context) => const SettingsDialog(),
            );
          case _AccountMenuAction.signOut:
            ref.read(authenticationProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_AccountMenuAction>(
          enabled: false,
          child: Text(
            displayName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const PopupMenuDivider(),
        if (username != null)
          const PopupMenuItem<_AccountMenuAction>(
            value: _AccountMenuAction.viewProfile,
            child: Text('View profile'),
          ),
        const PopupMenuItem<_AccountMenuAction>(
          value: _AccountMenuAction.settings,
          child: Text('Settings'),
        ),
        const PopupMenuItem<_AccountMenuAction>(
          value: _AccountMenuAction.signOut,
          child: Text('Sign out'),
        ),
      ],
      child: CircleAvatar(
        radius: 16,
        child: Text(
          displayName[0].toUpperCase(),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context, WidgetRef ref) {
    showSignInDialog(context);
  }
}

void showSignInDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => const SignInDialog(),
  );
}

class SignInDialog extends ConsumerStatefulWidget {
  const SignInDialog({super.key});

  @override
  ConsumerState<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends ConsumerState<SignInDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    final prefillEmail = ref.read(authenticationProvider).prefillEmail;
    if (prefillEmail != null) {
      _emailController.text = prefillEmail;
      ref.read(authenticationProvider.notifier).clearPrefillEmail();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationProvider);

    // Close dialog on successful sign-in.
    ref.listen(authenticationProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        Navigator.of(context).pop();
      }
    });

    return AlertDialog(
      title: Text(_isSignUp ? 'Create account' : 'Sign in'),
      content: SizedBox(
        width: 320,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSignUp) ...[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  autofillHints: const [AutofillHints.newUsername],
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                textInputAction: TextInputAction.next,
                autofocus: !_isSignUp,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                autofillHints: [
                  if (_isSignUp)
                    AutofillHints.newPassword
                  else
                    AutofillHints.password,
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (!_isSignUp) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authenticationState.isLoading
                        ? null
                        : () => _showForgotPassword(context, ref),
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
              if (authenticationState.errorMessage != null) ...[
                const SizedBox(height: 12),
                CopyableErrorMessage(
                  message: authenticationState.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                if (_isConfirmationError(
                  authenticationState.errorMessage!,
                )) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PlinkyButton(
                      onPressed: authenticationState.isLoading
                          ? null
                          : () => _resendConfirmation(ref),
                      icon: Icons.email,
                      label: 'Resend confirmation email',
                    ),
                  ),
                ],
              ],
              if (authenticationState.infoMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  authenticationState.infoMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () {
            ref.read(authenticationProvider.notifier).clearMessages();
            setState(() => _isSignUp = !_isSignUp);
          },
          icon: Icons.swap_horiz,
          label: _isSignUp
              ? 'Already have an account? Sign in'
              : "Don't have an account? Sign up",
        ),
        PlinkyButton(
          onPressed: () {
            ref.read(authenticationProvider.notifier).clearMessages();
            Navigator.of(context).pop();
          },
          icon: Icons.close,
          label: 'Cancel',
        ),
        PlinkyButton(
          onPressed: authenticationState.isLoading ? null : _submit,
          icon: Icons.login,
          label: _isSignUp ? 'Sign up' : 'Sign in',
        ),
      ],
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();
    final notifier = ref.read(authenticationProvider.notifier);

    final validationError = _validate(email, password, username);
    if (validationError != null) {
      notifier.setError(validationError);
      return;
    }

    TextInput.finishAutofillContext();
    if (_isSignUp) {
      notifier.signUp(email, password, username);
    } else {
      notifier.signIn(email, password);
    }
  }

  bool _isConfirmationError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('confirm') ||
        lower.contains('confirmation') ||
        lower.contains('expired');
  }

  void _showForgotPassword(BuildContext context, WidgetRef ref) {
    final email = _emailController.text.trim();
    ref.read(authenticationProvider.notifier).clearMessages();
    showForgotPasswordDialog(
      context,
      prefillEmail: email.isEmpty ? null : email,
    );
  }

  void _resendConfirmation(WidgetRef ref) {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ref
          .read(authenticationProvider.notifier)
          .setError(
            'Please enter your email address to resend the confirmation.',
          );
      return;
    }
    ref.read(authenticationProvider.notifier).resendConfirmationEmail(email);
  }

  String? _validate(String email, String password, String username) {
    if (email.isEmpty) {
      return 'Please enter your email address.';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address.';
    }
    if (password.isEmpty) {
      return 'Please enter your password.';
    }
    if (_isSignUp) {
      if (username.isEmpty) {
        return 'Please choose a username.';
      }
      if (username.length < 3) {
        return 'Username must be at least 3 characters.';
      }
      if (reservedUsernames.contains(username.toLowerCase())) {
        return 'That username is reserved. Please choose another.';
      }
      if (password.length < 6) {
        return 'Password must be at least 6 characters.';
      }
    }
    return null;
  }
}
