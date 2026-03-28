import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/pages/about_page.dart';
import 'package:plinkyhub/pages/editor/editor_page.dart';
import 'package:plinkyhub/pages/packs/pack_page.dart';
import 'package:plinkyhub/pages/packs/saved_packs_page.dart';
import 'package:plinkyhub/pages/patterns/pattern_page.dart';
import 'package:plinkyhub/pages/patterns/saved_patterns_page.dart';
import 'package:plinkyhub/pages/presets/preset_page.dart';
import 'package:plinkyhub/pages/presets/saved_presets_page.dart';
import 'package:plinkyhub/pages/samples/sample_page.dart';
import 'package:plinkyhub/pages/samples/saved_samples_page.dart';
import 'package:plinkyhub/pages/user_profile_page.dart';
import 'package:plinkyhub/pages/wavetables/saved_wavetables_page.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_page.dart';
import 'package:plinkyhub/widgets/navigation_sidebar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(ProviderContainer container) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/editor',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PlinkyHubShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Editor
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/editor',
                builder: (context, state) => EditorPage(
                  presetData: state.uri.queryParameters['p'],
                ),
              ),
            ],
          ),
          // Branch 1: Presets
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/presets',
                builder: (context, state) => const SavedPresetsPage(),
              ),
            ],
          ),
          // Branch 2: Packs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/packs',
                builder: (context, state) => const SavedPacksPage(),
              ),
            ],
          ),
          // Branch 3: Samples
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/samples',
                builder: (context, state) => const SavedSamplesPage(),
              ),
            ],
          ),
          // Branch 4: Wavetables
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wavetables',
                builder: (context, state) => const SavedWavetablesPage(),
              ),
            ],
          ),
          // Branch 5: Patterns
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patterns',
                builder: (context, state) => const SavedPatternsPage(),
              ),
            ],
          ),
          // Branch 6: User Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const UserProfilePage(),
              ),
            ],
          ),
          // Branch 7: About
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),

      // Item detail pages — displayed within the shell via
      // parentNavigatorKey so they show the sidebar.
      GoRoute(
        path: '/:username/preset/:name',
        builder: (context, state) => _ItemPageShell(
          child: PresetPage(
            username: state.pathParameters['username']!,
            presetName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:username/pack/:name',
        builder: (context, state) => _ItemPageShell(
          child: PackPage(
            username: state.pathParameters['username']!,
            packName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:username/sample/:name',
        builder: (context, state) => _ItemPageShell(
          child: SamplePage(
            username: state.pathParameters['username']!,
            sampleName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:username/wavetable/:name',
        builder: (context, state) => _ItemPageShell(
          child: WavetablePage(
            username: state.pathParameters['username']!,
            wavetableName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:username/pattern/:name',
        builder: (context, state) => _ItemPageShell(
          child: PatternPage(
            username: state.pathParameters['username']!,
            patternName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),

      // User profile deep link — catch-all for /<username>.
      GoRoute(
        path: '/:username',
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return _ItemPageShell(
            child: UserProfilePage(username: username),
          );
        },
      ),
    ],
  );
}

class _ItemPageShell extends ConsumerWidget {
  const _ItemPageShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationSidebar(
                selectedIndex: -1,
                onDestinationSelected: (index) {
                  final paths = [
                    '/editor',
                    '/presets',
                    '/packs',
                    '/samples',
                    '/wavetables',
                    '/patterns',
                    '/profile',
                    '/about',
                  ];
                  if (index >= 0 && index < paths.length) {
                    context.go(paths[index]);
                  }
                },
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggle();
              },
            ),
          ),
        ],
      ),
    );
  }
}
