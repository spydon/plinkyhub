import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/pages/about_page.dart';
import 'package:plinkyhub/pages/editor/editor_page.dart';
import 'package:plinkyhub/pages/packs/saved_packs_page.dart';
import 'package:plinkyhub/pages/patterns/saved_patterns_page.dart';
import 'package:plinkyhub/pages/presets/saved_presets_page.dart';
import 'package:plinkyhub/pages/samples/saved_samples_page.dart';
import 'package:plinkyhub/pages/user_profile_page.dart';
import 'package:plinkyhub/pages/wavetables/saved_wavetables_page.dart';
import 'package:plinkyhub/state/deep_link_notifier.dart';
import 'package:plinkyhub/state/user_profile_notifier.dart';

const _reservedPaths = {
  'editor',
  'presets',
  'packs',
  'samples',
  'wavetables',
  'patterns',
  'about',
};

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
          // Branch 6: User Profile + Item Deep Links
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/:username',
                builder: (context, state) {
                  final username = state.pathParameters['username']!;
                  if (_reservedPaths.contains(username)) {
                    return const SizedBox.shrink();
                  }
                  container
                      .read(userProfileProvider.notifier)
                      .loadUserProfileByUsername(username);
                  return const UserProfilePage();
                },
                routes: [
                  GoRoute(
                    path: 'preset/:name',
                    redirect: (context, state) {
                      _setDeepLinkTarget(container, state, 'preset');
                      return '/presets';
                    },
                  ),
                  GoRoute(
                    path: 'pack/:name',
                    redirect: (context, state) {
                      _setDeepLinkTarget(container, state, 'pack');
                      return '/packs';
                    },
                  ),
                  GoRoute(
                    path: 'sample/:name',
                    redirect: (context, state) {
                      _setDeepLinkTarget(container, state, 'sample');
                      return '/samples';
                    },
                  ),
                  GoRoute(
                    path: 'wavetable/:name',
                    redirect: (context, state) {
                      _setDeepLinkTarget(
                        container,
                        state,
                        'wavetable',
                      );
                      return '/wavetables';
                    },
                  ),
                  GoRoute(
                    path: 'pattern/:name',
                    redirect: (context, state) {
                      _setDeepLinkTarget(
                        container,
                        state,
                        'pattern',
                      );
                      return '/patterns';
                    },
                  ),
                ],
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
    ],
  );
}

void _setDeepLinkTarget(
  ProviderContainer container,
  GoRouterState state,
  String type,
) {
  final username = state.pathParameters['username']!;
  final name = state.pathParameters['name']!;
  container.read(deepLinkTargetProvider.notifier).target = DeepLinkTarget(
    username: username,
    type: type,
    name: Uri.decodeComponent(name),
  );
}
