import 'package:flutter/material.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/widgets/chromium_required_banner.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';

/// How data is transferred to the Plinky device.
enum TransferMethod {
  /// Send directly over WebUSB while the Plinky is running normally.
  webUsb,

  /// Write UF2 files to the Plinky drive in Tunnel of Lights mode.
  tunnelOfLights,
}

class TunnelOfLightsInstructions extends StatelessWidget {
  const TunnelOfLightsInstructions({
    required this.itemType,
    this.isLoading = false,
    super.key,
  });

  final String itemType;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final action = isLoading
        ? 'To load a $itemType from your Plinky, put it'
        : 'To save this $itemType to your Plinky, put it';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$action into Tunnel of Lights mode:'),
        const SizedBox(height: 12),
        const Text('1. Turn off your Plinky'),
        const SizedBox(height: 4),
        const Text(
          '2. Hold the rotary encoder while turning '
          'the Plinky on',
        ),
        const SizedBox(height: 4),
        const Text(
          '3. The Plinky will appear as a USB drive '
          'on your computer',
        ),
        const SizedBox(height: 12),
        const Text(
          'Then click the button below to select the '
          'Plinky drive.',
        ),
        if (!isFileSystemAccessSupported) ...[
          const SizedBox(height: 12),
          const ChromiumRequiredBanner(requireFileSystemAccess: true),
        ],
      ],
    );
  }
}

class SaveProgressView extends StatelessWidget {
  const SaveProgressView({
    required this.statusMessage,
    this.progress,
    super.key,
  });

  final String statusMessage;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PlinkyLoadingAnimation(),
        const SizedBox(height: 16),
        Text(statusMessage),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 12),
        Text(
          '(this may take a while)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class SaveDoneView extends StatelessWidget {
  const SaveDoneView({
    required this.itemType,
    this.usedWebUsb = false,
    super.key,
  });

  final String itemType;
  final bool usedWebUsb;

  @override
  Widget build(BuildContext context) {
    final label = '${itemType[0].toUpperCase()}${itemType.substring(1)}';
    if (usedWebUsb) {
      return Text('$label sent to Plinky successfully!');
    }
    return Text(
      '$label saved to Plinky successfully!\n'
      'Eject the drive and restart your Plinky.',
    );
  }
}

/// Reusable method selection view for choosing between WebUSB and
/// Tunnel of Lights when saving to a Plinky device.
class TransferMethodSelection extends StatelessWidget {
  const TransferMethodSelection({
    required this.itemType,
    this.webUsbNote,
    super.key,
  });

  /// Label like 'preset', 'sample', 'wavetable', or 'pack'.
  final String itemType;

  /// Optional warning shown below the WebUSB option (e.g. pattern caveat).
  final String? webUsbNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose how to save the $itemType to your Plinky:'),
        const SizedBox(height: 16),
        if (WebUsbService.isSupported) ...[
          const _TransferMethodOption(
            icon: Icons.usb,
            title: 'Send via USB',
            description:
                'Send directly over WebUSB while Plinky is running '
                'normally. No need for Tunnel of Lights mode.',
          ),
          if (webUsbNote != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(
                webUsbNote!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
        const _TransferMethodOption(
          icon: Icons.folder_open,
          title: 'Tunnel of Lights (faster)',
          description:
              'Write UF2 files to the Plinky drive. Requires putting '
              'Plinky into Tunnel of Lights mode first.',
        ),
        if (!WebUsbService.isSupported || !isFileSystemAccessSupported) ...[
          const SizedBox(height: 16),
          const ChromiumRequiredBanner(
            requireWebUsb: true,
            requireFileSystemAccess: true,
          ),
        ],
      ],
    );
  }
}

class _TransferMethodOption extends StatelessWidget {
  const _TransferMethodOption({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SlotSelectionGrid extends StatelessWidget {
  const SlotSelectionGrid({
    required this.itemType,
    required this.slotCount,
    required this.selectedSlot,
    required this.onSlotChanged,
    this.columns = 4,
    this.rows = 8,
    this.displayOffset = 1,
    super.key,
  });

  final String itemType;
  final int slotCount;
  final int selectedSlot;
  final ValueChanged<int> onSlotChanged;
  final int columns;
  final int rows;
  final int displayOffset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select the $itemType slot on your Plinky:'),
        const SizedBox(height: 12),
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var column = 0; column < columns; column++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: column < columns - 1 ? 8 : 0,
                      bottom: row < rows - 1 ? 8 : 0,
                    ),
                    child: row * columns + column < slotCount
                        ? ChoiceChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(
                                '${row * columns + column + displayOffset}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            selected: selectedSlot == row * columns + column,
                            showCheckmark: false,
                            onSelected: (_) =>
                                onSlotChanged(row * columns + column),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        Text(
          'Note: This will overwrite the existing $itemType in slot '
          '${selectedSlot + displayOffset} on your Plinky.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class SaveErrorView extends StatelessWidget {
  const SaveErrorView({
    this.errorMessage,
    super.key,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        CopyableErrorMessage(
          message: errorMessage ?? 'An unknown error occurred.',
        ),
      ],
    );
  }
}
