import 'package:flutter/material.dart';

class TunnelOfLightsInstructions extends StatelessWidget {
  const TunnelOfLightsInstructions({
    required this.itemType,
    super.key,
  });

  final String itemType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To save this $itemType to your Plinky, put it '
          'into Tunnel of Lights mode:',
        ),
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
      ],
    );
  }
}

class SaveProgressView extends StatelessWidget {
  const SaveProgressView({
    required this.statusMessage,
    super.key,
  });

  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(statusMessage),
      ],
    );
  }
}

class SaveDoneView extends StatelessWidget {
  const SaveDoneView({
    required this.itemType,
    super.key,
  });

  final String itemType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          '${itemType[0].toUpperCase()}${itemType.substring(1)} '
          'saved to Plinky successfully! '
          'Eject the drive and restart your Plinky.',
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
        Text(errorMessage ?? 'An unknown error occurred.'),
      ],
    );
  }
}
