import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/my_plinky/providers/my_plinky_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/widgets/chromium_required_banner.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class MyPlinkyConnectView extends ConsumerWidget {
  const MyPlinkyConnectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final includeSamples = ref.watch(
      myPlinkyProvider.select((state) => state.includeSamples),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'My Plinky',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect your Plinky in Tunnel of Lights mode '
                "to see what's on it.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              const Text('1. Turn off your Plinky'),
              const SizedBox(height: 4),
              const Text(
                '2. Hold the rotary encoder while '
                'turning the Plinky on',
              ),
              const SizedBox(height: 4),
              const Text(
                '3. The Plinky will appear as a USB '
                'drive on your computer',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Load samples'),
                subtitle: const Text(
                  'Reading samples takes longer but lets you '
                  'view and manage them',
                ),
                value: includeSamples,
                onChanged: (value) => ref
                    .read(myPlinkyProvider.notifier)
                    .setIncludeSamples(value: value),
              ),
              const SizedBox(height: 16),
              const ChromiumRequiredBanner(
                requireFileSystemAccess: true,
              ),
              const SizedBox(height: 16),
              PlinkyButton(
                onPressed: isFileSystemAccessSupported
                    ? () =>
                          ref.read(myPlinkyProvider.notifier).connectToPlinky()
                    : null,
                icon: Icons.usb,
                label: 'Select Plinky drive',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
