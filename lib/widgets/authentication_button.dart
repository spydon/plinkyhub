import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

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

    return PopupMenuButton<String>(
      tooltip: displayName,
      onSelected: (value) {
        if (value == 'sign_out') {
          ref.read(authenticationProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            displayName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'sign_out',
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (authenticationState.errorMessage != null) ...[
              Text(
                authenticationState.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_isSignUp) ...[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
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
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: () {
            ref.read(authenticationProvider.notifier).clearError();
            setState(() => _isSignUp = !_isSignUp);
          },
          icon: Icons.swap_horiz,
          label: _isSignUp
              ? 'Already have an account? Sign in'
              : "Don't have an account? Sign up",
        ),
        PlinkyButton(
          onPressed: () {
            ref.read(authenticationProvider.notifier).clearError();
            Navigator.of(context).pop();
          },
          icon: Icons.close,
          label: 'Cancel',
        ),
        PlinkyButton(
          onPressed:
              authenticationState.isLoading ? null : _submit,
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

    if (_isSignUp) {
      notifier.signUp(email, password, username);
    } else {
      notifier.signIn(email, password);
    }
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
      if (password.length < 6) {
        return 'Password must be at least 6 characters.';
      }
    }
    return null;
  }
}
