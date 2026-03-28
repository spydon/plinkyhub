import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
            'organizing your Plinky presets.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Plinky is an 8-voice polyphonic touch synthesizer '
            'that you play by touching.',
          ),
          const SizedBox(height: 16),
          const Text('PlinkyHub is made by Lukas Klingsbo (spydon).'),
          const SizedBox(height: 16),
          Text(
            'Special thanks to:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            '\u2022 mmalex and Making Sound Machines for creating '
            'the amazing Plinky and Plinky+',
          ),
          const SizedBox(height: 4),
          const Text(
            '\u2022 RJ for creating the new firmware',
          ),
          const SizedBox(height: 4),
          const Text(
            '\u2022 Orangetronic, miunau and wraybowling for the '
            'original Plinky WebUSB editor',
          ),
          const SizedBox(height: 4),
          const Text(
            '\u2022 mmalex for the parameter icons',
          ),
          const SizedBox(height: 24),
          Text(
            'Disclaimer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'PlinkyHub is an independent community project and is not '
            'affiliated with, endorsed by, or officially connected to '
            'Plinky, plinkysynth.com, or any of its creators. '
            'All product names, trademarks, and registered trademarks '
            'are the property of their respective owners.',
          ),
          const SizedBox(height: 8),
          const Text(
            'PlinkyHub is open source and provided as-is, without any '
            'warranty. Use at your own risk.',
          ),
          const SizedBox(height: 24),
          Text(
            'Links',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => web.window.open(
              'https://github.com/spydon/plinkyhub',
              '_blank',
            ),
            icon: const Icon(Icons.code),
            label: const Text('PlinkyHub GitHub'),
          ),
          TextButton.icon(
            onPressed: () => web.window.open(
              'https://plinkysynth.com',
              '_blank',
            ),
            icon: const Icon(Icons.language),
            label: const Text('plinkysynth.com'),
          ),
          TextButton.icon(
            onPressed: () => web.window.open(
              'https://plinkysynth.github.io/editor/',
              '_blank',
            ),
            icon: const Icon(Icons.piano),
            label: const Text('Original Plinky WebUSB Editor'),
          ),
        ],
      ),
    );
  }
}
