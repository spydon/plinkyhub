import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/firmware_admins.dart';
import 'package:plinkyhub/pages/firmware/firmware_card.dart';
import 'package:plinkyhub/pages/firmware/providers/firmwares_notifier.dart';
import 'package:plinkyhub/pages/firmware/upload_firmware_dialog.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';

class FirmwareListTab extends ConsumerWidget {
  const FirmwareListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firmwaresState = ref.watch(firmwaresProvider);
    final currentUserId = ref.watch(authenticationProvider).user?.id;
    final isAdmin =
        currentUserId != null && firmwareAdminIds.contains(currentUserId);

    if (firmwaresState.isLoading) {
      return const Center(child: PlinkyLoadingAnimation());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Firmware',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (isAdmin)
                PlinkyButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => const UploadFirmwareDialog(),
                  ),
                  icon: Icons.upload,
                  label: 'Upload firmware',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (firmwaresState.errorMessage != null)
            Text(
              firmwaresState.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else if (firmwaresState.firmwares.isEmpty)
            const Text('No firmware versions available yet.')
          else
            ...firmwaresState.firmwares.map(
              (firmware) => FirmwareCard(
                firmware: firmware,
                isAdmin: isAdmin,
              ),
            ),
        ],
      ),
    );
  }
}
