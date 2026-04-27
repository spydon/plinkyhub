import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/models/saved_firmware.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/utils/uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _DialogStep { instructions, progress, done, error }

class FlashFirmwareDialog extends ConsumerStatefulWidget {
  const FlashFirmwareDialog({required this.firmware, super.key});

  final SavedFirmware firmware;

  @override
  ConsumerState<FlashFirmwareDialog> createState() =>
      _FlashFirmwareDialogState();
}

class _FlashFirmwareDialogState extends ConsumerState<FlashFirmwareDialog> {
  _DialogStep _step = _DialogStep.instructions;
  String _statusMessage = '';
  String? _errorMessage;
  bool _clearSettings = false;

  Future<void> _startFlash() async {
    final directory = await showDirectoryPicker(readwrite: true);
    if (directory == null) {
      return;
    }

    setState(() {
      _step = _DialogStep.progress;
      _statusMessage = _clearSettings
          ? 'Reading PRESETS.UF2...'
          : 'Downloading firmware...';
    });

    try {
      if (_clearSettings) {
        final existingUf2 = await readFileFromDirectory(
          directory,
          'PRESETS.UF2',
        );
        if (existingUf2 != null) {
          setState(
            () => _statusMessage = 'Clearing settings in PRESETS.UF2...',
          );
          final flashImage = uf2ToData(existingUf2);
          clearSysParamsVersionInFlashImage(flashImage);
          final updatedUf2 = dataToUf2(flashImage, presetsBaseAddress);

          setState(() => _statusMessage = 'Writing PRESETS.UF2...');
          await writeFileToDirectory(directory, 'PRESETS.UF2', updatedUf2);
        }
        setState(() => _statusMessage = 'Downloading firmware...');
      }

      final bytes = await Supabase.instance.client.storage
          .from('firmwares')
          .download(widget.firmware.filePath);

      setState(() => _statusMessage = 'Writing CURRENT.UF2...');
      await writeFileToDirectory(directory, 'CURRENT.UF2', bytes);

      setState(() => _step = _DialogStep.done);
    } on Exception catch (error) {
      setState(() {
        _step = _DialogStep.error;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: switch (_step) {
        _DialogStep.instructions => const Text('Flash firmware'),
        _DialogStep.progress => const Text('Flashing firmware...'),
        _DialogStep.done => Row(
          children: [
            const Text('Done'),
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        _DialogStep.error => const Text('Error'),
      },
      content: SizedBox(
        width: 400,
        child: switch (_step) {
          _DialogStep.instructions => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TunnelOfLightsInstructions(itemType: 'firmware'),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reset Settings Version'),
                subtitle: const Text(
                  'This forces Lucky Phoenix firmware to reinitialize all '
                  'new system settings and is only needed the first time '
                  'you load a Lucky Phoenix firmware',
                ),
                value: _clearSettings,
                onChanged: (value) => setState(() => _clearSettings = value),
              ),
            ],
          ),
          _DialogStep.progress => SaveProgressView(
            statusMessage: _statusMessage,
          ),
          _DialogStep.done => const Text(
            'Firmware written successfully!\n'
            'Eject the drive and restart your Plinky.',
          ),
          _DialogStep.error => SaveErrorView(errorMessage: _errorMessage),
        },
      ),
      actions: switch (_step) {
        _DialogStep.instructions => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancel',
          ),
          PlinkyButton(
            onPressed: _startFlash,
            icon: Icons.folder_open,
            label: 'Select Plinky drive',
          ),
        ],
        _DialogStep.progress => [],
        _DialogStep.done || _DialogStep.error => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Close',
          ),
        ],
      },
    );
  }
}
