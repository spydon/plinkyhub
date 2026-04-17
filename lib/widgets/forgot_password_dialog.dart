import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

void showForgotPasswordDialog(BuildContext context, {String? prefillEmail}) {
  showDialog<void>(
    context: context,
    builder: (context) => ForgotPasswordDialog(prefillEmail: prefillEmail),
  );
}

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({this.prefillEmail, super.key});

  final String? prefillEmail;

  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    final prefillEmail = widget.prefillEmail;
    if (prefillEmail != null && prefillEmail.isNotEmpty) {
      _emailController.text = prefillEmail;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authenticationProvider.notifier).clearMessages();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Track when the info message transitions to the sent state so we
    // can swap the UI into confirmation mode.
    ref.listen(authenticationProvider, (previous, next) {
      final becameSuccess =
          previous?.infoMessage == null && next.infoMessage != null;
      if (becameSuccess && mounted) {
        setState(() => _emailSent = true);
      }
    });

    return AlertDialog(
      title: const Text('Reset password'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_emailSent) ...[
              Text(
                'If an account exists for '
                '${_emailController.text.trim()}, we sent a link to '
                'reset your password. Click the link in the email to '
                'choose a new password.',
                style: theme.textTheme.bodyMedium,
              ),
            ] else ...[
              Text(
                "Enter the email address for your account and we'll send "
                'you a link to choose a new password.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (authenticationState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                authenticationState.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_emailSent)
          PlinkyButton(
            onPressed: () {
              ref.read(authenticationProvider.notifier).clearMessages();
              Navigator.of(context).pop();
            },
            icon: Icons.check,
            label: 'Done',
          )
        else ...[
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
            icon: Icons.email,
            label: 'Send reset email',
          ),
        ],
      ],
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final notifier = ref.read(authenticationProvider.notifier);
    if (email.isEmpty) {
      notifier.setError('Please enter your email address.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      notifier.setError('Please enter a valid email address.');
      return;
    }
    notifier.sendPasswordResetEmail(email);
  }
}
