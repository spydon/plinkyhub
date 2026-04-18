import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/firmware/edit_firmware_dialog.dart';
import 'package:plinkyhub/pages/firmware/flash_firmware_dialog.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/pages/firmware/providers/firmwares_notifier.dart';
import 'package:plinkyhub/pages/firmware/widgets/firmware_share_link_button.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class FirmwareCard extends ConsumerWidget {
  const FirmwareCard({
    required this.firmware,
    required this.isAdmin,
    this.onDeleted,
    super.key,
  });

  final SavedFirmware firmware;
  final bool isAdmin;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(
          '/firmware/${Uri.encodeComponent(firmware.name)}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (firmware.isPinned) ...[
                    const Icon(Icons.push_pin, size: 16),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    firmware.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(firmware.version),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (firmware.isBeta) ...[
                    const SizedBox(width: 4),
                    Chip(
                      label: const Text('Beta'),
                      backgroundColor: theme.colorScheme.tertiary.withValues(
                        alpha: 0.2,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  const Spacer(),
                  FirmwareShareLinkButton(
                    firmwareName: firmware.name,
                  ),
                ],
              ),
              if (firmware.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  firmware.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  PlinkyButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) =>
                          FlashFirmwareDialog(firmware: firmware),
                    ),
                    icon: Icons.flash_on,
                    label: 'Flash to Plinky',
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    PlinkyButton(
                      onPressed: () => ref
                          .read(firmwaresProvider.notifier)
                          .togglePinned(firmware),
                      icon: firmware.isPinned
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                      label: firmware.isPinned ? 'Unpin' : 'Pin',
                    ),
                    const SizedBox(width: 8),
                    PlinkyButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) =>
                            EditFirmwareDialog(firmware: firmware),
                      ),
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    const SizedBox(width: 8),
                    PlinkyButton(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: Icons.delete_outline,
                      label: 'Delete',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete firmware'),
        content: Text('Delete "${firmware.name} ${firmware.version}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(firmwaresProvider.notifier)
                  .deleteFirmware(firmware.id, firmware.filePath);
              onDeleted?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
