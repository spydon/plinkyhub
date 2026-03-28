import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinkyhub/router.dart';
import 'package:plinkyhub/widgets/navigation_sidebar.dart';
import 'package:plinkyhub/widgets/terms_of_service_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
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

class PlinkyHubApp extends ConsumerWidget {
  const PlinkyHubApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
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
        colorSchemeSeed: const Color(0xFF00897B),
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: textTheme,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF00897B),
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: textTheme,
      ),
      routerConfig: router,
    );
  }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
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
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
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
