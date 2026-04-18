import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plinkyhub/widgets/terms_of_service_dialog.dart';
import 'package:web/web.dart' as web;

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );

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
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'PlinkyHub is made by '),
                _link(
                  'Lukas Klingsbo (spydon)',
                  'https://www.linkedin.com/in/spydon',
                  linkStyle,
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Special thanks to:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '\u2022 '),
                _link(
                  'mmalex',
                  'https://x.com/mmalex',
                  linkStyle,
                ),
                const TextSpan(text: ' and '),
                _link(
                  'Making Sound Machines',
                  'https://makingsoundmachines.com',
                  linkStyle,
                ),
                const TextSpan(
                  text: ' for creating the amazing Plinky and Plinky+',
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '\u2022 '),
                _link(
                  'RJ',
                  'https://github.com/RJ-Eckie',
                  linkStyle,
                ),
                const TextSpan(
                  text:
                      ' for creating the new firmware and his '
                      'in-depth knowledge of how everything works',
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '\u2022 '),
                _link(
                  'Orangetronic',
                  'https://github.com/Orangetronic',
                  linkStyle,
                ),
                const TextSpan(text: ', '),
                _link(
                  'miunau',
                  'https://github.com/miunau',
                  linkStyle,
                ),
                const TextSpan(text: ' and '),
                _link(
                  'wraybowling',
                  'https://github.com/wraybowling',
                  linkStyle,
                ),
                const TextSpan(
                  text: ' for the original Plinky WebUSB editor',
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '\u2022 '),
                _link(
                  'mmalex',
                  'https://x.com/mmalex',
                  linkStyle,
                ),
                const TextSpan(text: ' for the parameter icons'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '\u2022 '),
                _link(
                  'Nathan Plante (Kilgore)',
                  'https://linktr.ee/nathanplante',
                  linkStyle,
                ),
                const TextSpan(
                  text: ' for alpha testing and inspiration',
                ),
              ],
            ),
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
            'Plinky, plinkysynth.com, or any of its creators.\n'
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
            'Bugs & Feature Requests',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Found a bug or have a feature request? '
            'Open an issue on GitHub or ping spydon on '
            'the Plinky Discord.',
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => web.window.open(
              'https://github.com/spydon/plinkyhub/issues',
              '_blank',
            ),
            icon: const Icon(Icons.bug_report),
            label: const Text('GitHub Issues'),
          ),
          TextButton.icon(
            onPressed: () => web.window.open(
              'https://discord.gg/pHzcVnBt3A',
              '_blank',
            ),
            icon: const Icon(Icons.forum),
            label: const Text('Plinky Discord'),
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
          TextButton.icon(
            onPressed: () => showTermsOfServiceDialog(
              context,
              requireAcceptance: false,
            ),
            icon: const Icon(Icons.description),
            label: const Text('Terms of Service'),
          ),
        ],
      ),
    );
  }

  TextSpan _link(String text, String url, TextStyle style) {
    return TextSpan(
      text: text,
      style: style,
      recognizer: TapGestureRecognizer()
        ..onTap = () => web.window.open(url, '_blank'),
    );
  }
}
