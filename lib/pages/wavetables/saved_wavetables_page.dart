import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/wavetables/draw_wavetable_tab.dart';
import 'package:plinkyhub/pages/wavetables/providers/saved_wavetables_notifier.dart';
import 'package:plinkyhub/pages/wavetables/upload_wavetable_tab.dart';
import 'package:plinkyhub/pages/wavetables/wavetable_card.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

enum WavetableTab {
  my,
  community,
  create,
  upload,
}

class SavedWavetablesPage extends ConsumerStatefulWidget {
  const SavedWavetablesPage({
    this.initialTab,
    this.editWavetableSlug,
    super.key,
  });

  final String? initialTab;

  /// When non-null, opens the create tab in edit mode for this wavetable.
  final String? editWavetableSlug;

  @override
  ConsumerState<SavedWavetablesPage> createState() =>
      _SavedWavetablesPageState();
}

class _SavedWavetablesPageState extends ConsumerState<SavedWavetablesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    var initialIndex = 0;
    if (widget.editWavetableSlug != null) {
      initialIndex = WavetableTab.create.index;
    } else if (widget.initialTab != null) {
      initialIndex = WavetableTab.values
          .firstWhere(
            (t) => t.name == widget.initialTab,
            orElse: () => WavetableTab.my,
          )
          .index;
    }

    _tabController = TabController(
      length: WavetableTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedWavetablesProvider.notifier).fetchPublicItems();
      if (widget.editWavetableSlug != null || initialIndex == 0) {
        ref.read(savedWavetablesProvider.notifier).fetchUserItems();
      }
    });
  }

  @override
  void didUpdateWidget(SavedWavetablesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = WavetableTab.values.firstWhere(
        (t) => t.name == widget.initialTab,
        orElse: () => WavetableTab.my,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = WavetableTab.values[_tabController.index].name;
      context.go(AppRoute.wavetables.tab(tabName));
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
    final savedWavetablesState = ref.watch(savedWavetablesProvider);
    final isSignedIn = authenticationState.user != null;

    final editWavetable = widget.editWavetableSlug != null
        ? savedWavetablesState.userItems
              .where((w) => w.slug == widget.editWavetableSlug)
              .firstOrNull
        : null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Wavetables'),
            Tab(text: 'Community Wavetables'),
            Tab(text: 'Create Wavetable'),
            Tab(text: 'Upload'),
          ],
        ),
        if (savedWavetablesState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: CopyableErrorMessage(
              message: savedWavetablesState.errorMessage!,
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
                  items: savedWavetablesState.userItems,
                  starredItems: savedWavetablesState.starredItems,
                  isLoading: !savedWavetablesState.hasLoadedUserItems,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedWavetablesProvider.notifier)
                      .fetchUserItems(),
                  itemBuilder: (wavetable) => WavetableCard(
                    wavetable: wavetable,
                    isOwned: wavetable.userId == authenticationState.user?.id,
                  ),
                  itemLabel: 'wavetable',
                )
              else
                const SignInPrompt(
                  message: 'Sign in to upload and manage your wavetables',
                ),
              SearchableItemList(
                items: savedWavetablesState.publicItems,
                isLoading: !savedWavetablesState.hasLoadedPublicItems,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedWavetablesProvider.notifier)
                    .fetchPublicItems(),
                itemBuilder: (wavetable) => WavetableCard(
                  wavetable: wavetable,
                  isOwned: false,
                ),
                itemLabel: 'wavetable',
              ),
              if (isSignedIn)
                if (widget.editWavetableSlug != null &&
                    editWavetable == null &&
                    savedWavetablesState.isLoading)
                  const Center(child: PlinkyLoadingAnimation())
                else
                  DrawWavetableTab(
                    wavetableToEdit: editWavetable,
                    onCreated: () => _tabController.animateTo(0),
                    onClear: () =>
                        context.go(AppRoute.wavetables.tab('create')),
                  )
              else
                const SignInPrompt(
                  message: 'Sign in to create wavetables',
                ),
              if (isSignedIn)
                UploadWavetableTab(
                  onUploaded: () => _tabController.animateTo(0),
                )
              else
                const SignInPrompt(
                  message: 'Sign in to create wavetables',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
