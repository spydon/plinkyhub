import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/main.dart';
import 'package:plinkyhub/pages/about_page.dart';
import 'package:plinkyhub/pages/editor/editor_page.dart';
import 'package:plinkyhub/pages/firmware/firmware_detail_page.dart';
import 'package:plinkyhub/pages/firmware/firmware_page.dart';
import 'package:plinkyhub/pages/my_plinky/my_plinky_page.dart';
import 'package:plinkyhub/pages/packs/pack_page.dart';
import 'package:plinkyhub/pages/packs/saved_packs_page.dart';
import 'package:plinkyhub/pages/patterns/pattern_page.dart';
import 'package:plinkyhub/pages/patterns/saved_patterns_page.dart';
import 'package:plinkyhub/pages/play/play_page.dart';
import 'package:plinkyhub/pages/presets/preset_page.dart';
import 'package:plinkyhub/pages/presets/saved_presets_page.dart';
import 'package:plinkyhub/pages/samples/sample_page.dart';
import 'package:plinkyhub/pages/samples/saved_samples_page.dart';
import 'package:plinkyhub/pages/user_profile_page.dart';
import 'package:plinkyhub/pages/users/users_page.dart';
import 'package:plinkyhub/pages/wavetables/saved_wavetables_page.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_page.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/navigation_sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(ProviderContainer container) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.initial.path,
    redirect: (context, state) async {
      final notifier = container.read(authenticationProvider.notifier);

      // Supabase's PKCE email-confirmation and password-recovery links
      // redirect back to the site root with a `?code=<uuid>` query
      // parameter that must be exchanged for a session before the user
      // is signed in.
      final code = state.uri.queryParameters['code'];
      if (code != null) {
        try {
          await Supabase.instance.client.auth.exchangeCodeForSession(code);
        } on AuthException catch (error) {
          debugPrint('Code exchange failed: $error');
          notifier.setError(
            AuthenticationNotifier.friendlyAuthError(error.message),
          );
        } on Object catch (error) {
          // exchangeCodeForSession can throw StorageException or generic
          // errors when the PKCE verifier is missing (e.g. different
          // browser). Always fall through to the initial route so the
          // user sees a usable screen.
          debugPrint('Code exchange failed: $error');
          notifier.setError(
            'Unable to complete that link. '
            'Please try requesting a new one.',
          );
        }
        return AppRoute.initial.path;
      }

      final errorCode = state.uri.queryParameters['error_code'];
      if (errorCode != null) {
        final description = state.uri.queryParameters['error_description'];
        final email = state.uri.queryParameters['email'];
        if (email != null) {
          notifier.setPrefillEmail(Uri.decodeComponent(email));
        }
        if (errorCode == 'otp_expired') {
          // Supabase uses otp_expired for both signup-confirmation and
          // password-recovery expiries. The URL itself carries no hint,
          // so consult the persisted flow marker to word the message
          // for whichever flow the user most recently started.
          final flow = await AuthenticationNotifier.readLastAuthEmailFlow();
          if (flow == AuthEmailFlow.recovery) {
            notifier.setError(
              'Your password reset link has expired. '
              'Please request a new one using "Forgot password?".',
            );
          } else {
            notifier.setError(
              'Your confirmation link has expired. '
              'Please sign in with your email and password to '
              'receive a new confirmation email.',
            );
          }
        } else if (description != null) {
          notifier.setError(Uri.decodeComponent(description));
        }
        return AppRoute.initial.path;
      }

      // Bare "/" (no query params, no matching route) falls through to
      // the initial tab instead of go_router's not-found screen.
      if (state.uri.path == '/') {
        return AppRoute.initial.path;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PlinkyHubShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: My Plinky
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.myPlinky.path,
                builder: (context, state) => const MyPlinkyPage(),
              ),
            ],
          ),
          // Branch 1: Editor
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.editor.path,
                builder: (context, state) => EditorPage(
                  presetData: state.uri.queryParameters['p'],
                ),
              ),
            ],
          ),
          // Branch 2: Presets
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.presets.path,
                builder: (context, state) => const SavedPresetsPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => SavedPresetsPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Packs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.packs.path,
                builder: (context, state) => const SavedPacksPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => SavedPacksPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: Samples
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.samples.path,
                builder: (context, state) => const SavedSamplesPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => SavedSamplesPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 5: Wavetables
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.wavetables.path,
                builder: (context, state) => const SavedWavetablesPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => SavedWavetablesPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 6: Patterns
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.patterns.path,
                builder: (context, state) => const SavedPatternsPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => SavedPatternsPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 7: Play
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.play.path,
                builder: (context, state) => const PlayPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => PlayPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 8: Users
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.users.path,
                builder: (context, state) => const UsersPage(),
                routes: [
                  GoRoute(
                    path: ':tab',
                    builder: (context, state) => UsersPage(
                      initialTab: state.pathParameters['tab'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 9: User Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                builder: (context, state) => UserProfilePage(
                  initialTab: state.uri.queryParameters['tab'],
                ),
              ),
            ],
          ),
          // Branch 10: Firmware
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.firmware.path,
                builder: (context, state) => FirmwarePage(
                  initialTab: state.uri.queryParameters['tab'],
                ),
              ),
            ],
          ),
          // Branch 11: About
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.about.path,
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),

      // Firmware detail page, not tied to a username.
      GoRoute(
        path: '/firmware/:name',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _ItemPageShell(
          child: FirmwareDetailPage(
            firmwareName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),

      // Item detail pages. parentNavigatorKey pins them to the root
      // navigator so pushing them from inside a shell branch updates
      // the browser URL instead of staying on the branch's URL.
      GoRoute(
        path: '/:username/preset/:name',
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
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
        path: '/:username/sample/:name/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _ItemPageShell(
          child: SavedSamplesPage(
            editSampleName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:username/wavetable/:name',
        parentNavigatorKey: _rootNavigatorKey,
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
        path: '/:username/wavetable/:name/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _ItemPageShell(
          child: SavedWavetablesPage(
            editWavetableName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:username/pattern/:name',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _ItemPageShell(
          child: PatternPage(
            username: state.pathParameters['username']!,
            patternName: Uri.decodeComponent(
              state.pathParameters['name']!,
            ),
          ),
        ),
      ),

      // User profile deep link, catch-all for /<username>.
      GoRoute(
        path: '/:username',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return _ItemPageShell(
            child: UserProfilePage(
              username: username,
              initialTab: state.uri.queryParameters['tab'],
            ),
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
    return Scaffold(
      body: Row(
        children: [
          NavigationSidebar(
            selectedIndex: -1,
            onDestinationSelected: (index) {
              final paths = AppRoute.tabPaths;
              if (index >= 0 && index < paths.length) {
                context.go(paths[index]);
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(
                    onPressed: () => _onBackPressed(context),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    // In-app navigation uses `context.push(...)`, so popping the
    // navigator gets us back to whatever page the user came from.
    // For direct deep-links there's no history to pop, so derive a
    // sensible parent route from the current URL instead of falling
    // back to the home tab.
    if (context.canPop()) {
      context.pop();
      return;
    }
    final location = GoRouterState.of(context).uri.path;
    context.go(_parentRouteFor(location));
  }
}

/// Returns the URL the back button should navigate to from [location].
/// Edit pages step back to their view page; item detail pages step
/// back to their parent listing tab; user profile pages step back to
/// the users tab.
String _parentRouteFor(String location) {
  final segments = location
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();

  if (segments.isEmpty) {
    return AppRoute.initial.path;
  }

  // /firmware/<name> -> /firmware
  if (segments.first == 'firmware') {
    return AppRoute.firmware.path;
  }

  // /<username>/<itemSegment>/<name>/edit -> /<username>/<itemSegment>/<name>
  if (segments.length >= 4 && segments.last == 'edit') {
    return '/${segments[0]}/${segments[1]}/${segments[2]}';
  }

  // /<username>/<itemSegment>/<name> -> /<itemSegment-list>
  if (segments.length >= 3) {
    final itemSegment = segments[1];
    for (final route in AppRoute.values) {
      if (route.itemSegment == itemSegment) {
        return route.path;
      }
    }
  }

  // /<username> -> /users
  if (segments.length == 1) {
    return AppRoute.users.path;
  }

  return AppRoute.initial.path;
}
