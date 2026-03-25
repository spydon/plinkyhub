import 'package:flutter/material.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          PlinkyButton(
            onPressed: () => showSignInDialog(context),
            icon: Icons.login,
            label: 'Sign in',
          ),
        ],
      ),
    );
  }
}
