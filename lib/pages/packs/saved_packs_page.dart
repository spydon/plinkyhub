import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/packs/create_pack_tab.dart';
import 'package:plinkyhub/pages/packs/load_pack_tab.dart';
import 'package:plinkyhub/pages/packs/pack_card.dart';
import 'package:plinkyhub/pages/packs/providers/saved_packs_notifier.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

enum PackTab {
  my,
  community,
  create,
  load,
}

class SavedPacksPage extends ConsumerStatefulWidget {
  const SavedPacksPage({this.initialTab, super.key});

  final String? initialTab;

  @override
  ConsumerState<SavedPacksPage> createState() => _SavedPacksPageState();
}

class _SavedPacksPageState extends ConsumerState<SavedPacksPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab != null
        ? PackTab.values
              .firstWhere(
                (t) => t.name == widget.initialTab,
                orElse: () => PackTab.my,
              )
              .index
        : 0;

    _tabController = TabController(
      length: PackTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPacksProvider.notifier).fetchPublicItems();
      if (initialIndex == 0) {
        ref.read(savedPacksProvider.notifier).fetchUserItems();
      }
    });
  }

  @override
  void didUpdateWidget(SavedPacksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = PackTab.values.firstWhere(
        (t) => t.name == widget.initialTab,
        orElse: () => PackTab.my,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = PackTab.values[_tabController.index].name;
      context.go(AppRoute.packs.tab(tabName));
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
    final savedPacksState = ref.watch(savedPacksProvider);
    final isSignedIn = authenticationState.user != null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Packs'),
            Tab(text: 'Community Packs'),
            Tab(text: 'Create Pack'),
            Tab(text: 'Load from Plinky'),
          ],
        ),
        if (savedPacksState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              savedPacksState.errorMessage!,
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
                  items: savedPacksState.userItems,
                  starredItems: savedPacksState.starredItems,
                  isLoading: !savedPacksState.hasLoadedUserItems,
                  isOwned: true,
                  onRefresh: () =>
                      ref.read(savedPacksProvider.notifier).fetchUserItems(),
                  itemBuilder: (pack) => PackCard(
                    pack: pack,
                    isOwned: pack.userId == authenticationState.user?.id,
                    onEdit: pack.userId == authenticationState.user?.id
                        ? () => context.go(
                            AppRoute.packs.tab(PackTab.create.name),
                          )
                        : null,
                  ),
                  itemLabel: 'pack',
                )
              else
                const SignInPrompt(
                  message: 'Sign in to save and manage your packs',
                ),
              SearchableItemList(
                items: savedPacksState.publicItems,
                isLoading: !savedPacksState.hasLoadedPublicItems,
                isOwned: false,
                onRefresh: () =>
                    ref.read(savedPacksProvider.notifier).fetchPublicItems(),
                itemBuilder: (pack) => PackCard(
                  pack: pack,
                  isOwned: false,
                ),
                itemLabel: 'pack',
              ),
              if (isSignedIn)
                const CreatePackTab()
              else
                const SignInPrompt(
                  message: 'Sign in to create packs',
                ),
              if (isSignedIn)
                LoadPackTab(
                  onLoaded: () => _tabController.animateTo(0),
                )
              else
                const SignInPrompt(
                  message: 'Sign in to load packs',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
