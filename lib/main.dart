import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinkyhub/pages/about_page.dart';
import 'package:plinkyhub/pages/editor_page.dart';
import 'package:plinkyhub/pages/saved_packs_page.dart';
import 'package:plinkyhub/pages/saved_patches_page.dart';
import 'package:plinkyhub/pages/saved_samples_page.dart';
import 'package:plinkyhub/widgets/navigation_sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const ProviderScope(child: PlinkyHubApp()));
}

final selectedPageProvider =
    NotifierProvider<SelectedPageNotifier, int>(SelectedPageNotifier.new);

class SelectedPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
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
  const PlinkyHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textTheme = TextTheme(
      headlineLarge: GoogleFonts.fingerPaint(),
      headlineMedium: GoogleFonts.fingerPaint(),
      headlineSmall: GoogleFonts.fingerPaint(),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlinkyHub',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF28222E),
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: textTheme,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF28222E),
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: textTheme,
      ),
      home: const PlinkyHubShell(),
    );
  }
}

class PlinkyHubShell extends ConsumerStatefulWidget {
  const PlinkyHubShell({super.key});

  @override
  ConsumerState<PlinkyHubShell> createState() => _PlinkyHubShellState();
}

class _PlinkyHubShellState extends ConsumerState<PlinkyHubShell> {
  static const _pages = <Widget>[
    EditorPage(),
    SavedPatchesPage(),
    SavedPacksPage(),
    SavedSamplesPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedPageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationSidebar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  ref.read(selectedPageProvider.notifier).select(index);
                },
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _pages[selectedIndex]),
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
