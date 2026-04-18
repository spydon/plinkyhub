import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/plinky_state.dart';
import 'package:plinkyhub/providers/plinky_notifier.dart';
import 'package:plinkyhub/services/webusb_service.dart';
import 'package:plinkyhub/utils/file_system_access.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:plinkyhub/widgets/plinky_save_dialog_views.dart';

/// Callback interface passed to save functions so they can update the
/// dialog's progress UI without direct access to `setState`.
class PlinkyTransferController {
  PlinkyTransferController._({
    required void Function(String message) updateStatus,
    required void Function(double? value) updateProgress,
    required bool Function() checkMounted,
  }) : _updateStatus = updateStatus,
       _updateProgress = updateProgress,
       _checkMounted = checkMounted;

  final void Function(String message) _updateStatus;
  final void Function(double? value) _updateProgress;
  final bool Function() _checkMounted;

  /// Update the status message shown below the progress bar.
  void updateStatus(String message) => _updateStatus(message);

  /// Update the progress bar value. Pass `null` for indeterminate.
  void updateProgress(double? value) => _updateProgress(value);

  /// Whether the dialog is still mounted.
  bool get isMounted => _checkMounted();
}

/// A custom setup step in the transfer dialog flow (e.g. slot selection).
///
/// These steps appear after method selection and before the save begins.
class PlinkyTransferStep {
  const PlinkyTransferStep({
    required this.content,
    this.forwardLabel,
  });

  /// Widget builder for this step's content area. Receives the currently
  /// selected [TransferMethod] so it can adapt if needed.
  final Widget Function(TransferMethod method) content;

  /// Optional override for the forward button label. When null, defaults
  /// to `'Send'` for WebUSB on the last step and `'Next'` otherwise.
  final String Function(TransferMethod method)? forwardLabel;
}

/// Complete configuration for a [PlinkyTransferDialog].
class PlinkyTransferDialogConfiguration {
  const PlinkyTransferDialogConfiguration({
    required this.itemType,
    required this.onTunnelOfLightsSave,
    this.title,
    this.webUsbNote,
    this.setupSteps = const [],
    this.onWebUsbSave,
  });

  /// Label like `'sample'`, `'preset'`, `'wavetable'`, or `'pack'`.
  final String itemType;

  /// Custom title for setup steps. When null, uses
  /// `'Save $itemType to Plinky'`.
  final String? title;

  /// Optional warning shown in the [TransferMethodSelection] view
  /// (e.g. pattern caveat for packs).
  final String? webUsbNote;

  /// Custom setup steps between method selection and the save.
  final List<PlinkyTransferStep> setupSteps;

  /// Called when the user confirms a WebUSB save. When null, the
  /// WebUSB option is hidden and the dialog behaves as Tunnel-only
  /// (e.g. patterns).
  final Future<void> Function(
    WidgetRef ref,
    PlinkyTransferController controller,
  )?
  onWebUsbSave;

  /// Called when the user confirms a Tunnel of Lights save.
  final Future<void> Function(
    FileSystemDirectoryHandle directory,
    WidgetRef ref,
    PlinkyTransferController controller,
  )
  onTunnelOfLightsSave;
}

/// A generic transfer-to-Plinky dialog that handles the step machine,
/// title/content/actions switching, WebUSB connection boilerplate, and
/// Tunnel of Lights directory picker.
///
/// Each caller provides a [PlinkyTransferDialogConfiguration] with
/// its item type, optional custom steps, and save callbacks.
class PlinkyTransferDialog extends ConsumerStatefulWidget {
  const PlinkyTransferDialog({
    required this.configuration,
    super.key,
  });

  final PlinkyTransferDialogConfiguration configuration;

  @override
  ConsumerState<PlinkyTransferDialog> createState() =>
      _PlinkyTransferDialogState();
}

enum _Step {
  methodSelection,
  customStep,
  instructions,
  progress,
  done,
  error,
}

class _PlinkyTransferDialogState extends ConsumerState<PlinkyTransferDialog> {
  _Step _step = _Step.methodSelection;
  TransferMethod _method = TransferMethod.webUsb;
  int _customStepIndex = 0;
  String _statusMessage = '';
  String? _errorMessage;
  double? _progress;

  PlinkyTransferDialogConfiguration get _configuration => widget.configuration;

  bool get _hasWebUsb => _configuration.onWebUsbSave != null;

  bool get _hasCustomSteps => _configuration.setupSteps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Tunnel-only dialogs skip method selection.
    if (!_hasWebUsb) {
      _method = TransferMethod.tunnelOfLights;
      if (_hasCustomSteps) {
        _step = _Step.customStep;
        _customStepIndex = 0;
      } else {
        _step = _Step.instructions;
      }
    }
  }

  // -- Navigation helpers --------------------------------------------------

  void _selectMethodAndAdvance(TransferMethod method) {
    _method = method;
    if (_hasCustomSteps) {
      setState(() {
        _customStepIndex = 0;
        _step = _Step.customStep;
      });
    } else if (method == TransferMethod.webUsb) {
      _startWebUsbSave();
    } else {
      setState(() => _step = _Step.instructions);
    }
  }

  void _advanceFromCustomStep() {
    if (_customStepIndex < _configuration.setupSteps.length - 1) {
      setState(() => _customStepIndex++);
    } else if (_method == TransferMethod.webUsb) {
      _startWebUsbSave();
    } else {
      setState(() => _step = _Step.instructions);
    }
  }

  void _backFromCustomStep() {
    if (_customStepIndex > 0) {
      setState(() => _customStepIndex--);
    } else if (_hasWebUsb) {
      setState(() => _step = _Step.methodSelection);
    }
    // Tunnel-only with first custom step: no further back.
  }

  void _backFromInstructions() {
    if (_hasCustomSteps) {
      setState(() {
        _customStepIndex = _configuration.setupSteps.length - 1;
        _step = _Step.customStep;
      });
    } else if (_hasWebUsb) {
      setState(() => _step = _Step.methodSelection);
    }
  }

  // -- Save helpers --------------------------------------------------------

  PlinkyTransferController _buildController() {
    return PlinkyTransferController._(
      updateStatus: (message) {
        if (mounted) {
          setState(() => _statusMessage = message);
        }
      },
      updateProgress: (value) {
        if (mounted) {
          setState(() => _progress = value);
        }
      },
      checkMounted: () => mounted,
    );
  }

  Future<void> _startWebUsbSave() async {
    setState(() {
      _step = _Step.progress;
      _statusMessage = 'Connecting to Plinky...';
      _progress = null;
    });

    final controller = _buildController();

    try {
      final notifier = ref.read(plinkyProvider.notifier);
      final currentState = ref.read(plinkyProvider);

      if (currentState.connectionState == PlinkyConnectionState.disconnected ||
          currentState.connectionState == PlinkyConnectionState.error) {
        await notifier.connect();
      }
      final afterConnect = ref.read(plinkyProvider);
      if (afterConnect.connectionState != PlinkyConnectionState.connected) {
        throw Exception(
          afterConnect.errorMessage ?? 'Failed to connect to Plinky.',
        );
      }

      await _configuration.onWebUsbSave!(ref, controller);

      if (mounted && _step == _Step.progress) {
        setState(() => _step = _Step.done);
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _step = _Step.error;
          _errorMessage = error.toString();
        });
      }
    }
  }

  Future<void> _startTunnelOfLightsSave() async {
    final directory = await showDirectoryPicker(readwrite: true);
    if (directory == null) {
      return;
    }

    setState(() {
      _step = _Step.progress;
      _statusMessage = 'Preparing...';
      _progress = null;
    });

    final controller = _buildController();

    try {
      await _configuration.onTunnelOfLightsSave(directory, ref, controller);

      if (mounted && _step == _Step.progress) {
        setState(() => _step = _Step.done);
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() {
          _step = _Step.error;
          _errorMessage = error.toString();
        });
      }
    }
  }

  // -- Build ---------------------------------------------------------------

  String get _setupTitle =>
      _configuration.title ?? 'Save ${_configuration.itemType} to Plinky';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: switch (_step) {
        _Step.methodSelection ||
        _Step.customStep ||
        _Step.instructions => Text(_setupTitle),
        _Step.progress => const Text('Uploading to Plinky...'),
        _Step.done => Row(
          children: [
            const Text('Done'),
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        _Step.error => const Text('Error'),
      },
      content: SizedBox(
        width: 400,
        child: switch (_step) {
          _Step.methodSelection => TransferMethodSelection(
            itemType: _configuration.itemType,
            webUsbNote: _configuration.webUsbNote,
          ),
          _Step.customStep =>
            _configuration.setupSteps[_customStepIndex].content(_method),
          _Step.instructions => TunnelOfLightsInstructions(
            itemType: _configuration.itemType,
          ),
          _Step.progress => SaveProgressView(
            statusMessage: _statusMessage,
            progress: _progress,
          ),
          _Step.done => SaveDoneView(
            itemType: _configuration.itemType,
            usedWebUsb: _method == TransferMethod.webUsb,
          ),
          _Step.error => SaveErrorView(errorMessage: _errorMessage),
        },
      ),
      actions: switch (_step) {
        _Step.methodSelection => _methodSelectionActions(context),
        _Step.customStep => _customStepActions(context),
        _Step.instructions => _instructionsActions(context),
        _Step.progress => const [],
        _Step.done || _Step.error => [
          PlinkyButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Close',
          ),
        ],
      },
    );
  }

  List<Widget> _methodSelectionActions(BuildContext context) {
    return [
      PlinkyButton(
        onPressed: () => Navigator.of(context).pop(),
        label: 'Cancel',
      ),
      if (WebUsbService.isSupported && _hasWebUsb)
        PlinkyButton(
          onPressed: () => _selectMethodAndAdvance(TransferMethod.webUsb),
          icon: Icons.usb,
          label: 'Send via USB',
        ),
      PlinkyButton(
        onPressed: () => _selectMethodAndAdvance(TransferMethod.tunnelOfLights),
        icon: Icons.folder_open,
        label: 'Tunnel of Lights (faster)',
      ),
    ];
  }

  List<Widget> _customStepActions(BuildContext context) {
    final step = _configuration.setupSteps[_customStepIndex];
    final isLastCustomStep =
        _customStepIndex == _configuration.setupSteps.length - 1;

    String forwardLabel;
    if (step.forwardLabel != null) {
      forwardLabel = step.forwardLabel!(_method);
    } else if (isLastCustomStep && _method == TransferMethod.webUsb) {
      forwardLabel = 'Send';
    } else {
      forwardLabel = 'Next';
    }

    return [
      PlinkyButton(
        onPressed: _backFromCustomStep,
        label: 'Back',
      ),
      PlinkyButton(
        onPressed: _advanceFromCustomStep,
        label: forwardLabel,
      ),
    ];
  }

  List<Widget> _instructionsActions(BuildContext context) {
    return [
      PlinkyButton(
        onPressed: _backFromInstructions,
        label: 'Back',
      ),
      PlinkyButton(
        onPressed: _startTunnelOfLightsSave,
        icon: Icons.folder_open,
        label: 'Select Plinky drive',
      ),
    ];
  }
}
