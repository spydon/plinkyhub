import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About PlinkyHub',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'PlinkyHub is a site for sharing, creating and '
            'organizing your Plinky patches.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Plinky is an 8-voice polyphonic touch synthesizer '
            'that you play by touching.',
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: null,
            child: Text(
              'plinkysynth.com',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
