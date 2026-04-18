import 'package:flutter/material.dart';

/// Notice explaining that the flash dump feature only works with LPE
/// firmware v0.5.0+, which exposes the WebUSB flash dump commands
/// (`IDX_DUMP_INT_FLASH` / `IDX_DUMP_EXT_FLASH`). Stock Plinky
/// firmware does not implement those commands.
class LpeFirmwareRequiredNotice extends StatelessWidget {
  const LpeFirmwareRequiredNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.memory,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Text(
              'Flash dumps require LPE firmware v0.5.0 or later '
              '(ember-labs-io/Plinky_LPE).\n'
              'Stock Plinky firmware does not expose the WebUSB flash '
              'dump commands needed for this feature.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
