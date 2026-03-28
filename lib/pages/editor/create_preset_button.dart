import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/state/plinky_notifier.dart';
import 'package:plinkyhub/utils/presets_uf2.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';

class CreatePresetButton extends ConsumerWidget {
  const CreatePresetButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlinkyButton(
      onPressed: () => ref
          .read(plinkyProvider.notifier)
          .loadPresetFromBytes(Uint8List(presetSize)),
      icon: Icons.add,
      label: 'New preset',
    );
  }
}
