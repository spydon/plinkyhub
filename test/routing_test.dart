import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/routes.dart';

void main() {
  group('AppRoute URL helpers', () {
    test('userPage returns /<username>', () {
      expect(AppRoute.userPage('alice'), '/alice');
    });

    test('userPageTab puts the tab in a query parameter', () {
      expect(
        AppRoute.userPageTab('alice', 'packs'),
        '/alice?tab=packs',
      );
    });

    test('profileTab targets the signed-in-user profile route', () {
      expect(AppRoute.profileTab('samples'), '/profile?tab=samples');
    });

    test('itemPage encodes names that contain URL-unsafe characters', () {
      expect(
        AppRoute.presets.itemPage('alice', 'My Preset?/1'),
        '/alice/preset/My%20Preset%3F%2F1',
      );
      expect(
        AppRoute.packs.itemPage('bob', 'pack #2'),
        '/bob/pack/pack%20%232',
      );
      expect(
        AppRoute.samples.itemPage('carol', 'drum&bass'),
        '/carol/sample/drum%26bass',
      );
    });

    test('sampleEditPage / wavetableEditPage append /edit', () {
      expect(
        AppRoute.sampleEditPage('alice', 'kick'),
        '/alice/sample/kick/edit',
      );
      expect(
        AppRoute.wavetableEditPage('alice', 'saw'),
        '/alice/wavetable/saw/edit',
      );
    });

    test('tab() nests under a top-level tab path', () {
      expect(AppRoute.users.tab('highscore'), '/users/highscore');
      expect(AppRoute.presets.tab('community'), '/presets/community');
    });
  });

  group('Router location updates', () {
    // Regression guard for the bug where clicking a user from
    // Users > Highscore navigated to the correct page but left the URL
    // at /users/highscore. The fix was to pin top-level detail routes
    // to the root navigator with parentNavigatorKey.

    String currentLocation(GoRouter router) =>
        router.routeInformationProvider.value.uri.toString();

    testWidgets(
      'pushing a root-navigator route from inside a shell branch '
      'updates the URL to the pushed route',
      (tester) async {
        final rootNavigatorKey = GlobalKey<NavigatorState>();
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/users/highscore',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => Scaffold(body: shell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/users',
                      builder: (context, state) => const Text('users'),
                      routes: [
                        GoRoute(
                          path: ':tab',
                          builder: (context, state) => Builder(
                            builder: (context) => ElevatedButton(
                              onPressed: () => context.go('/alice'),
                              child: const Text('open-alice'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/:username',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) =>
                  Text('profile:${state.pathParameters['username']}'),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(currentLocation(router), '/users/highscore');

        await tester.tap(find.text('open-alice'));
        await tester.pumpAndSettle();

        expect(currentLocation(router), '/alice');
        expect(find.text('profile:alice'), findsOneWidget);
      },
    );

    testWidgets(
      'context.push from inside a shell branch leaves the URL stuck '
      '(regression guard: AGENTS.md requires context.go instead)',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/users/highscore',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => Scaffold(body: shell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/users',
                      builder: (context, state) => const Text('users'),
                      routes: [
                        GoRoute(
                          path: ':tab',
                          builder: (context, state) => Builder(
                            builder: (context) => ElevatedButton(
                              onPressed: () => context.push('/alice'),
                              child: const Text('open-alice'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/:username',
              builder: (context, state) =>
                  Text('profile:${state.pathParameters['username']}'),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(routerConfig: router),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('open-alice'));
        await tester.pumpAndSettle();

        // The page renders, but the URL is stuck on the branch path.
        expect(find.text('profile:alice'), findsOneWidget);
        expect(currentLocation(router), '/users/highscore');
      },
    );

    testWidgets(
      'context.go to a tab sub-path updates the URL',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/users',
          routes: [
            GoRoute(
              path: '/users',
              builder: (context, state) => Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.go(
                    AppRoute.users.tab('highscore'),
                  ),
                  child: const Text('go-highscore'),
                ),
              ),
              routes: [
                GoRoute(
                  path: ':tab',
                  builder: (context, state) =>
                      Text('tab:${state.pathParameters['tab']}'),
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(routerConfig: router),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('go-highscore'));
        await tester.pumpAndSettle();

        expect(currentLocation(router), '/users/highscore');
      },
    );
  });
}
