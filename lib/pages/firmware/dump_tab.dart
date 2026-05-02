import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/create_dump_dialog.dart';
import 'package:plinkyhub/pages/firmware/dump_card.dart';
import 'package:plinkyhub/pages/firmware/firmware_admins.dart';
import 'package:plinkyhub/pages/firmware/lpe_firmware_required_notice.dart';
import 'package:plinkyhub/pages/firmware/providers/dumps_notifier.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/widgets/chromium_required_banner.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class DumpTab extends ConsumerWidget {
  const DumpTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticationState = ref.watch(authenticationProvider);
    final dumpsState = ref.watch(dumpsProvider);
    final theme = Theme.of(context);

    if (authenticationState.user == null) {
      return const SignInPrompt(
        message: 'Sign in to create and manage your flash dumps',
      );
    }

    final canCreateDump = WebUsbService.isSupported;
    final isAdmin = firmwareAdminIds.contains(authenticationState.user?.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flash dumps',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Create a binary snapshot of your Plinky's internal (1 MB) "
            'and external (32 MB) flash memory.\n'
            'Dumps are stored privately in your account and can be '
            'downloaded later.'
            '${isAdmin ? '\n'
                      'As a firmware admin you can download dumps from '
                      'every user.' : ''}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          PlinkyButton(
            onPressed: canCreateDump
                ? () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const CreateDumpDialog(),
                  )
                : null,
            icon: Icons.save_alt,
            label: 'Create dump',
          ),
          const SizedBox(height: 16),
          const LpeFirmwareRequiredNotice(),
          const SizedBox(height: 16),
          const ChromiumRequiredBanner(requireWebUsb: true),
          const SizedBox(height: 16),
          if (dumpsState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CopyableErrorMessage(
                message: dumpsState.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (dumpsState.isLoading)
            const Center(child: PlinkyLoadingAnimation())
          else if (dumpsState.dumps.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No dumps yet. Create your first dump to back up '
                "your Plinky's flash memory.",
              ),
            )
          else
            ...dumpsState.dumps.map((dump) => DumpCard(dump: dump)),
        ],
      ),
    );
  }
}
