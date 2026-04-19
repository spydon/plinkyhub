import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/firmware/firmware_list_tab.dart';

class FirmwarePage extends ConsumerWidget {
  const FirmwarePage({this.initialTab, super.key});

  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FirmwareListTab();
  }
}
