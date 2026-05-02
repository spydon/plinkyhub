/// Navigation tab routes in sidebar order.
enum AppRoute {
  myPlinky('/my-plinky'),
  editor('/editor'),
  presets('/presets', itemSegment: 'preset'),
  packs('/packs', itemSegment: 'pack'),
  samples('/samples', itemSegment: 'sample'),
  wavetables('/wavetables', itemSegment: 'wavetable'),
  patterns('/patterns', itemSegment: 'pattern'),
  play('/play'),
  users('/users'),
  profile('/profile'),
  firmware('/firmware'),
  about('/about'),
  ;

  const AppRoute(this.path, {this.itemSegment});

  /// The URL path for this tab route.
  final String path;

  /// The singular path segment used in detail routes (e.g. 'preset'
  /// for `/:username/preset/:slug`). Null for tabs without item pages.
  final String? itemSegment;

  /// All tab paths in sidebar order, for indexed navigation.
  static final tabPaths = AppRoute.values.map((r) => r.path).toList();

  /// The route shown when the app starts.
  static const initial = AppRoute.myPlinky;

  /// Path to a tab's sub-tab (e.g. `/presets/community`).
  String tab(String tabName) => '$path/$tabName';

  /// Path to a user's item detail page for this route type.
  String itemPage(String username, String slug) =>
      '/$username/$itemSegment/${Uri.encodeComponent(slug)}';

  /// Path to a user's sample edit page.
  static String sampleEditPage(String username, String slug) =>
      '/$username/${AppRoute.samples.itemSegment}/'
      '${Uri.encodeComponent(slug)}/edit';

  /// Path to a user's wavetable edit page.
  static String wavetableEditPage(String username, String slug) =>
      '/$username/${AppRoute.wavetables.itemSegment}/'
      '${Uri.encodeComponent(slug)}/edit';

  /// Path to a user's profile page.
  static String userPage(String username) => '/$username';

  /// Path to a user's profile page on a specific tab (e.g. packs).
  /// Uses a query parameter so it can't collide with other routes that
  /// share the `/<username>/<segment>` shape.
  static String userPageTab(String username, String tabName) =>
      '/$username?tab=$tabName';

  /// Path to the signed-in user's own profile page on a specific tab.
  static String profileTab(String tabName) => '/profile?tab=$tabName';
}
