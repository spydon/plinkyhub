import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/wavetables/models/saved_wavetable.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_transfer_dialog.dart';

class SaveWavetableToPlinkyDialog extends ConsumerWidget {
  const SaveWavetableToPlinkyDialog({
    required this.wavetable,
    super.key,
  });

  final SavedWavetable wavetable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlinkyTransferDialog(
      configuration: PlinkyTransferDialogConfiguration(
        itemType: 'wavetable',
        title: 'Save to Plinky',
        onWebUsbSave: (ref, controller) async {
          controller.updateStatus('Downloading wavetable...');
          final uf2Bytes = await ref
              .read(savedWavetablesProvider.notifier)
              .downloadUf2(wavetable.filePath);

          controller.updateStatus('Extracting wavetable data...');
          final wavetableData = uf2ToData(uf2Bytes);

          controller.updateStatus('Sending wavetable to Plinky...');
          await ref
              .read(plinkyProvider.notifier)
              .sendWavetable(
                wavetableData: wavetableData,
                onProgress: (value) {
                  if (controller.isMounted) {
                    controller.updateProgress(value);
                  }
                },
              );

          controller.updateStatus('Verifying wavetable...');
          controller.updateProgress(null);
          final verified = await ref
              .read(plinkyProvider.notifier)
              .verifyWavetable(wavetableData);

          if (!verified) {
            throw Exception(
              'Wavetable verification failed. The data on the device '
              'does not match what was sent. Check the browser console '
              'for details.',
            );
          }
        },
        onTunnelOfLightsSave: (directory, ref, controller) async {
          controller.updateStatus('Downloading wavetable...');
          final uf2Bytes = await ref
              .read(savedWavetablesProvider.notifier)
              .downloadUf2(wavetable.filePath);

          controller.updateStatus('Writing WAVETAB.UF2...');
          await writeFileToDirectory(directory, 'WAVETAB.UF2', uf2Bytes);
        },
      ),
    );
  }
}
