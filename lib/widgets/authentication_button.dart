import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';

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

    return PopupMenuButton<String>(
      tooltip: user.email ?? 'Account',
      onSelected: (value) {
        if (value == 'sign_out') {
          ref.read(authenticationProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            user.email ?? 'Signed in',
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
          (user.email ?? '?')[0].toUpperCase(),
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
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
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
        TextButton(
          onPressed: () {
            ref.read(authenticationProvider.notifier).clearError();
            setState(() => _isSignUp = !_isSignUp);
          },
          child: Text(
            _isSignUp
                ? 'Already have an account? Sign in'
                : "Don't have an account? Sign up",
          ),
        ),
        TextButton(
          onPressed: () {
            ref.read(authenticationProvider.notifier).clearError();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              authenticationState.isLoading ? null : _submit,
          child: authenticationState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(_isSignUp ? 'Sign up' : 'Sign in'),
        ),
      ],
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    final notifier = ref.read(authenticationProvider.notifier);
    if (_isSignUp) {
      notifier.signUp(email, password);
    } else {
      notifier.signIn(email, password);
    }
  }
}
