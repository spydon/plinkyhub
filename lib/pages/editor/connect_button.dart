import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/state/plinky_state.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class ConnectButton extends ConsumerWidget {
  const ConnectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plinkyProvider);
    return PlinkyButton(
      onPressed: state.connectionState == PlinkyConnectionState.connecting
          ? null
          : () => ref.read(plinkyProvider.notifier).connect(),
      icon: Icons.usb,
      label: 'Connect',
    );
  }
}
