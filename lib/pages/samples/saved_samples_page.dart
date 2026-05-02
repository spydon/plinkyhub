import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/samples/load_sample_tab.dart';
import 'package:plinkyhub/pages/samples/providers/saved_samples_notifier.dart';
import 'package:plinkyhub/pages/samples/sample_card.dart';
import 'package:plinkyhub/pages/samples/upload_sample_tab.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/routing/routes.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

enum SampleTab {
  my,
  community,
  create,
  load,
}

class SavedSamplesPage extends ConsumerStatefulWidget {
  const SavedSamplesPage({this.editSampleSlug, this.initialTab, super.key});

  final String? editSampleSlug;
  final String? initialTab;

  @override
  ConsumerState<SavedSamplesPage> createState() => _SavedSamplesPageState();
}

class _SavedSamplesPageState extends ConsumerState<SavedSamplesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    var initialIndex = 0;
    if (widget.editSampleSlug != null) {
      initialIndex = SampleTab.create.index;
    } else if (widget.initialTab != null) {
      initialIndex = SampleTab.values
          .firstWhere(
            (t) => t.name == widget.initialTab,
            orElse: () => SampleTab.my,
          )
          .index;
    }

    _tabController = TabController(
      length: SampleTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedSamplesProvider.notifier).fetchPublicItems();
      if (widget.editSampleSlug != null || initialIndex == 0) {
        ref.read(savedSamplesProvider.notifier).fetchUserItems();
      }
    });
  }

  @override
  void didUpdateWidget(SavedSamplesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = SampleTab.values.firstWhere(
        (t) => t.name == widget.initialTab,
        orElse: () => SampleTab.my,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = SampleTab.values[_tabController.index].name;
      context.go(AppRoute.samples.tab(tabName));
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
    final savedSamplesState = ref.watch(savedSamplesProvider);
    final isSignedIn = authenticationState.user != null;

    final editSample = widget.editSampleSlug != null
        ? savedSamplesState.userItems
              .where((s) => s.slug == widget.editSampleSlug)
              .firstOrNull
        : null;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Samples'),
            Tab(text: 'Community Samples'),
            Tab(text: 'Create Sample'),
            Tab(text: 'Load from Plinky'),
          ],
        ),
        if (savedSamplesState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: CopyableErrorMessage(
              message: savedSamplesState.errorMessage!,
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
                  items: savedSamplesState.userItems,
                  starredItems: savedSamplesState.starredItems,
                  isLoading: !savedSamplesState.hasLoadedUserItems,
                  isOwned: true,
                  onRefresh: () =>
                      ref.read(savedSamplesProvider.notifier).fetchUserItems(),
                  itemBuilder: (sample) => SampleCard(
                    sample: sample,
                    isOwned: sample.userId == authenticationState.user?.id,
                  ),
                  itemLabel: 'sample',
                )
              else
                const SignInPrompt(
                  message: 'Sign in to upload and manage your samples',
                ),
              SearchableItemList(
                items: savedSamplesState.publicItems,
                isLoading: !savedSamplesState.hasLoadedPublicItems,
                isOwned: false,
                onRefresh: () =>
                    ref.read(savedSamplesProvider.notifier).fetchPublicItems(),
                itemBuilder: (sample) => SampleCard(
                  sample: sample,
                  isOwned: false,
                ),
                itemLabel: 'sample',
              ),
              if (isSignedIn)
                if (widget.editSampleSlug != null &&
                    editSample == null &&
                    savedSamplesState.isLoading)
                  const Center(child: PlinkyLoadingAnimation())
                else
                  UploadSampleTab(
                    sampleToEdit: editSample,
                    onUploaded: () => _tabController.animateTo(0),
                    onClear: () => context.go(AppRoute.samples.tab('create')),
                  )
              else
                const SignInPrompt(
                  message: 'Sign in to create samples',
                ),
              if (isSignedIn)
                LoadSampleTab(
                  onLoaded: () => _tabController.animateTo(0),
                )
              else
                const SignInPrompt(
                  message: 'Sign in to load samples from Plinky',
                ),
            ],
          ),
        ),
      ],
    );
  }
}
