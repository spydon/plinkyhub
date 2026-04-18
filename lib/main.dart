import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/router.dart';
import 'package:plinkyhub/widgets/authentication_button.dart';
import 'package:plinkyhub/widgets/navigation_sidebar.dart';
import 'package:plinkyhub/widgets/terms_of_service_dialog.dart';
import 'package:plinkyhub/widgets/update_password_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final devEmail = dotenv.env['DEV_EMAIL'];
  final devPassword = dotenv.env['DEV_PASSWORD'];
  if (devEmail != null &&
      devPassword != null &&
      Supabase.instance.client.auth.currentUser == null) {
    await Supabase.instance.client.auth.signInWithPassword(
      email: devEmail,
      password: devPassword,
    );
  }

  final container = ProviderContainer();
  final router = createRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: PlinkyHubApp(router: router),
    ),
  );
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

const defaultPrimaryColor = Color(0xFF00897B);

final primaryColorProvider = NotifierProvider<PrimaryColorNotifier, Color>(
  PrimaryColorNotifier.new,
);

class PrimaryColorNotifier extends Notifier<Color> {
  static const _storageKey = 'primary_color';

  @override
  Color build() {
    _load();
    return defaultPrimaryColor;
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt(_storageKey);
    if (value != null) {
      state = Color(value);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_storageKey, color.toARGB32());
  }
}

class PlinkyHubApp extends ConsumerWidget {
  const PlinkyHubApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final primaryColor = ref.watch(primaryColorProvider);
    final textTheme = TextTheme(
      headlineLarge: GoogleFonts.fingerPaint(),
      headlineMedium: GoogleFonts.fingerPaint(),
      headlineSmall: GoogleFonts.fingerPaint(),
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PlinkyHub',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: textTheme,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: primaryColor,
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: textTheme,
      ),
      routerConfig: router,
    );
  }
}

/// Exposes the current shell branch index so descendant pages can
/// check whether they are the active branch.
class ShellBranchIndex extends InheritedWidget {
  const ShellBranchIndex({
    required this.currentIndex,
    required super.child,
    super.key,
  });

  final int currentIndex;

  static int of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShellBranchIndex>()!
        .currentIndex;
  }

  @override
  bool updateShouldNotify(ShellBranchIndex oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

class PlinkyHubShell extends ConsumerStatefulWidget {
  const PlinkyHubShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<PlinkyHubShell> createState() => _PlinkyHubShellState();
}

class _PlinkyHubShellState extends ConsumerState<PlinkyHubShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasAcceptedTermsOfService()) {
        showTermsOfServiceDialog(context);
      }
      final authState = ref.read(authenticationProvider);
      // If the user arrived via a password-recovery link, Supabase fires
      // AuthChangeEvent.passwordRecovery synchronously during startup and
      // we already have isPasswordRecovery set here.
      if (authState.isPasswordRecovery) {
        showUpdatePasswordDialog(context);
        return;
      }
      // If the router redirect set an auth error (e.g. expired confirmation
      // link), open the sign-in dialog so the user can act on it.
      if (authState.errorMessage != null && authState.user == null) {
        showSignInDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a snackbar when the user's profile is fully loaded (username
    // available), covering both manual sign-in and automatic session restore.
    ref.listen(authenticationProvider, (previous, next) {
      if (previous?.username == null && next.username != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${next.username}!'),
          ),
        );
      }
      // Supabase may fire the password-recovery event after initState,
      // especially if the URL hash is parsed asynchronously.
      if (previous?.isPasswordRecovery != true &&
          next.isPasswordRecovery == true) {
        showUpdatePasswordDialog(context);
      }
    });

    return ShellBranchIndex(
      currentIndex: widget.navigationShell.currentIndex,
      child: Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                NavigationSidebar(
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                          index == widget.navigationShell.currentIndex,
                    );
                  },
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.navigationShell),
              ],
            ),
            const Positioned(
              bottom: 8,
              right: 8,
              child: _BetaLabel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BetaLabel extends StatefulWidget {
  const _BetaLabel();

  @override
  State<_BetaLabel> createState() => _BetaLabelState();
}

class _BetaLabelState extends State<_BetaLabel>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isHoveringLabel = false;
  bool _isHoveringTooltip = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _show() {
    _overlayController.show();
    _animationController.forward(from: 0);
  }

  void _scheduleHide() {
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_isHoveringLabel && !_isHoveringTooltip) {
        _animationController.reverse().then((_) {
          if (mounted && !_isHoveringLabel && !_isHoveringTooltip) {
            _overlayController.hide();
          }
        });
      }
    });
  }

  void _onTooltipEnter() {
    _isHoveringTooltip = true;
  }

  void _onTooltipExit() {
    _isHoveringTooltip = false;
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.bottomRight,
            offset: const Offset(0, -8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: Alignment.bottomRight,
                  child: _BetaTooltipContent(
                    onEnter: _onTooltipEnter,
                    onExit: _onTooltipExit,
                  ),
                ),
              ),
            ),
          );
        },
        child: MouseRegion(
          onEnter: (_) {
            _isHoveringLabel = true;
            _show();
          },
          onExit: (_) {
            _isHoveringLabel = false;
            _scheduleHide();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'BETA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BetaTooltipContent extends StatelessWidget {
  const _BetaTooltipContent({
    required this.onEnter,
    required this.onExit,
  });

  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PlinkyHub is in beta',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Found a bug or have a feature request? '
                  'Open an issue on GitHub or ping spydon '
                  'on the Plinky Discord.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                const _TooltipLink(
                  icon: Icons.bug_report,
                  label: 'GitHub Issues',
                  url: 'https://github.com/spydon/plinkyhub/issues',
                ),
                const _TooltipLink(
                  icon: Icons.forum,
                  label: 'Plinky Discord',
                  url: 'https://discord.gg/pHzcVnBt3A',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipLink extends StatelessWidget {
  const _TooltipLink({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => web.window.open(url, '_blank'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
