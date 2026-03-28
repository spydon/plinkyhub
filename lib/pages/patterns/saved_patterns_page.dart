import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/pages/patterns/pattern_card.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/saved_patterns_notifier.dart';
import 'package:plinkyhub/widgets/searchable_item_list.dart';
import 'package:plinkyhub/widgets/sign_in_prompt.dart';

class SavedPatternsPage extends ConsumerStatefulWidget {
  const SavedPatternsPage({super.key});

  @override
  ConsumerState<SavedPatternsPage> createState() => _SavedPatternsPageState();
}

class _SavedPatternsPageState extends ConsumerState<SavedPatternsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPatternsProvider.notifier).fetchPublicPatterns();
    });
  }

  @override
  void dispose() {
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
                  items: savedPatternsState.userPatterns,
                  starredItems: savedPatternsState.starredPatterns,
                  isLoading: savedPatternsState.isLoading,
                  isOwned: true,
                  onRefresh: () => ref
                      .read(savedPatternsProvider.notifier)
                      .fetchUserPatterns(),
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
                items: savedPatternsState.publicPatterns,
                isLoading: savedPatternsState.isLoading,
                isOwned: false,
                onRefresh: () => ref
                    .read(savedPatternsProvider.notifier)
                    .fetchPublicPatterns(),
                itemBuilder: (pattern) => PatternCard(
                  pattern: pattern,
                  isOwned: false,
                ),
                itemLabel: 'pattern',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
