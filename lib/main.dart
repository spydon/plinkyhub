import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/about_page.dart';
import 'package:plinkyhub/pages/editor_page.dart';

void main() {
  runApp(const ProviderScope(child: PlinkyHubApp()));
}

class PlinkyHubApp extends StatelessWidget {
  const PlinkyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlinkyHub',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF28222E),
        useMaterial3: true,
      ),
      home: const PlinkyHubShell(),
    );
  }
}

class PlinkyHubShell extends StatefulWidget {
  const PlinkyHubShell({super.key});

  @override
  State<PlinkyHubShell> createState() => _PlinkyHubShellState();
}

class _PlinkyHubShellState extends State<PlinkyHubShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    EditorPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'PlinkyHub',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.piano_outlined),
                selectedIcon: Icon(Icons.piano),
                label: Text('Editor'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
