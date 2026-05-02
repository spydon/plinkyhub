import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

const minimumPasswordLength = 6;

/// Returns a user-facing validation error for the new-password form, or
/// null if the input is acceptable.
String? validateNewPassword(String password, String confirm) {
  if (password.isEmpty) {
    return 'Please enter a new password.';
  }
  if (password.length < minimumPasswordLength) {
    return 'Password must be at least '
        '$minimumPasswordLength characters.';
  }
  if (password != confirm) {
    return 'Passwords do not match.';
  }
  return null;
}

void showUpdatePasswordDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const UpdatePasswordDialog(),
  );
}

class UpdatePasswordDialog extends ConsumerStatefulWidget {
  const UpdatePasswordDialog({super.key});

  @override
  ConsumerState<UpdatePasswordDialog> createState() =>
      _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends ConsumerState<UpdatePasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _passwordUpdated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authenticationProvider.notifier).clearMessages();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationState = ref.watch(authenticationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // When updatePassword succeeds, isPasswordRecovery drops to false and
    // infoMessage is set. Swap the UI into confirmation mode.
    ref.listen(authenticationProvider, (previous, next) {
      final wasUpdating = previous?.isLoading == true;
      final succeeded =
          wasUpdating &&
          !next.isLoading &&
          next.errorMessage == null &&
          next.infoMessage != null;
      if (succeeded && mounted) {
        setState(() => _passwordUpdated = true);
      }
    });

    return AlertDialog(
      title: Text(
        _passwordUpdated ? 'Password updated' : 'Choose a new password',
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_passwordUpdated) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your password has been updated. You can now use it '
                      'to sign in.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Enter a new password for your account. It must be at '
                'least $minimumPasswordLength characters long.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (authenticationState.errorMessage != null) ...[
              const SizedBox(height: 12),
              CopyableErrorMessage(
                message: authenticationState.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_passwordUpdated)
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
              ref.read(authenticationProvider.notifier)
                ..clearMessages()
                ..clearPasswordRecovery();
              Navigator.of(context).pop();
            },
            icon: Icons.close,
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed: authenticationState.isLoading ? null : _submit,
            icon: Icons.save,
            label: 'Update password',
          ),
        ],
      ],
    );
  }

  void _submit() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final notifier = ref.read(authenticationProvider.notifier);

    final validationError = validateNewPassword(password, confirm);
    if (validationError != null) {
      notifier.setError(validationError);
      return;
    }
    notifier.updatePassword(password);
  }
}
