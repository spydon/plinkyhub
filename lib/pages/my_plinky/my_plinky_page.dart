import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/my_plinky/models/my_plinky_state.dart';
import 'package:plinkyhub/pages/my_plinky/my_plinky_connect_view.dart';
import 'package:plinkyhub/pages/my_plinky/my_plinky_device_view.dart';
import 'package:plinkyhub/pages/my_plinky/my_plinky_error_view.dart';
import 'package:plinkyhub/pages/my_plinky/providers/my_plinky_notifier.dart';
import 'package:plinkyhub/widgets/loading_indicator.dart';

class MyPlinkyPage extends ConsumerWidget {
  const MyPlinkyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPlinkyProvider);
    return switch (state.pageState) {
      MyPlinkyPageState.connect => const MyPlinkyConnectView(),
      MyPlinkyPageState.loading => LoadingIndicator(
        message: state.statusMessage,
        progress: state.progress,
      ),
      MyPlinkyPageState.loaded => const MyPlinkyDeviceView(),
      MyPlinkyPageState.error => MyPlinkyErrorView(
        errorMessage: state.errorMessage,
      ),
    };
  }
}
