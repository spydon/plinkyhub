import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/firmware/dump_tab.dart';
import 'package:plinkyhub/pages/firmware/firmware_list_tab.dart';
import 'package:plinkyhub/routing/routes.dart';

enum FirmwareTab {
  firmware,
  dump,
}

class FirmwarePage extends ConsumerStatefulWidget {
  const FirmwarePage({this.initialTab, super.key});

  final String? initialTab;

  @override
  ConsumerState<FirmwarePage> createState() => _FirmwarePageState();
}

class _FirmwarePageState extends ConsumerState<FirmwarePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab != null
        ? FirmwareTab.values
              .firstWhere(
                (tab) => tab.name == widget.initialTab,
                orElse: () => FirmwareTab.firmware,
              )
              .index
        : 0;

    _tabController = TabController(
      length: FirmwareTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void didUpdateWidget(FirmwarePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = FirmwareTab.values.firstWhere(
        (entry) => entry.name == widget.initialTab,
        orElse: () => FirmwareTab.firmware,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = FirmwareTab.values[_tabController.index].name;
      // Use a query parameter instead of a path segment to avoid
      // colliding with the firmware detail route (/firmware/:name).
      context.go('${AppRoute.firmware.path}?tab=$tabName');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Firmware'),
            Tab(text: 'Dump'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              FirmwareListTab(),
              DumpTab(),
            ],
          ),
        ),
      ],
    );
  }
}
