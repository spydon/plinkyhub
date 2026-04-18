import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/patterns/create_pattern_tab.dart';
import 'package:plinkyhub/pages/patterns/pattern_card.dart';
import 'package:plinkyhub/pages/patterns/providers/saved_patterns_notifier.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

enum PatternTab {
  my,
  community,
  create,
}

class SavedPatternsPage extends ConsumerStatefulWidget {
  const SavedPatternsPage({this.initialTab, super.key});

  final String? initialTab;

  @override
  ConsumerState<SavedPatternsPage> createState() => _SavedPatternsPageState();
}

class _SavedPatternsPageState extends ConsumerState<SavedPatternsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab != null
        ? PatternTab.values
              .firstWhere(
                (t) => t.name == widget.initialTab,
                orElse: () => PatternTab.my,
              )
              .index
        : 0;

    _tabController = TabController(
      length: PatternTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPatternsProvider.notifier).fetchPublicItems();
      if (initialIndex == 0) {
        ref.read(savedPatternsProvider.notifier).fetchUserItems();
      }
    });
  }

  @override
  void didUpdateWidget(SavedPatternsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = PatternTab.values.firstWhere(
        (t) => t.name == widget.initialTab,
        orElse: () => PatternTab.my,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = PatternTab.values[_tabController.index].name;
      context.go(AppRoute.patterns.tab(tabName));
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
    final authenticationState = ref.watch(authenticationProvider);
    final savedPatternsState = ref.watch(savedPatternsProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Patterns'),
            Tab(text: 'Community Patterns'),
            Tab(text: 'Create Pattern'),
          ],
        ),
        if (savedPatternsState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedPatternsState.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              if (isSignedIn)
                SearchableItemList(
                  items: savedPatternsState.userItems,
                  starredItems: savedPatternsState.starredItems,
                  isLoading: !savedPatternsState.hasLoadedUserItems,
                  isOwned: true,
                  onRefresh: () =>
                      ref.read(savedPatternsProvider.notifier).fetchUserItems(),
                  itemBuilder: (pattern) => PatternCard(
                    pattern: pattern,
                    isOwned: pattern.userId == authenticationState.user?.id,
                  ),
                  itemLabel: 'pattern',
                )
              else
                const SignInPrompt(
                  message: 'Sign in to upload and manage your patterns',
                ),
              SearchableItemList(
                items: savedPatternsState.publicItems,
                isLoading: !savedPatternsState.hasLoadedPublicItems,
                isOwned: false,
                onRefresh: () =>
                    ref.read(savedPatternsProvider.notifier).fetchPublicItems(),
                itemBuilder: (pattern) => PatternCard(
                  pattern: pattern,
                  isOwned: false,
                ),
                itemLabel: 'pattern',
              ),
              if (isSignedIn)
                CreatePatternTab(
                  onCreated: () => _tabController.animateTo(0),
                )
              else
                const SignInPrompt(
                  message: 'Sign in to create and share patterns',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
