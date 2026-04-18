import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plinkyhub/pages/users/highscore_tab.dart';
import 'package:plinkyhub/pages/users/providers/users_search_notifier.dart';
import 'package:plinkyhub/routes.dart';
import 'package:plinkyhub/widgets/plinky_loading_animation.dart';

enum UsersTab { search, highscore }

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({this.initialTab, super.key});

  final String? initialTab;

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab != null
        ? UsersTab.values
              .firstWhere(
                (tab) => tab.name == widget.initialTab,
                orElse: () => UsersTab.search,
              )
              .index
        : 0;
    _tabController = TabController(
      length: UsersTab.values.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersSearchProvider.notifier).search('');
    });
  }

  @override
  void didUpdateWidget(UsersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null &&
        widget.initialTab != oldWidget.initialTab) {
      final tab = UsersTab.values.firstWhere(
        (entry) => entry.name == widget.initialTab,
        orElse: () => UsersTab.search,
      );
      if (_tabController.index != tab.index) {
        _tabController.animateTo(tab.index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tabName = UsersTab.values[_tabController.index].name;
      context.go(AppRoute.users.tab(tabName));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(usersSearchProvider);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Highscore'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _SearchTab(
                searchController: _searchController,
                searchState: searchState,
                onSearch: (value) {
                  ref.read(usersSearchProvider.notifier).search(value);
                },
                onRefresh: () => ref
                    .read(usersSearchProvider.notifier)
                    .search(_searchController.text),
              ),
              const HighscoreTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab({
    required this.searchController,
    required this.searchState,
    required this.onSearch,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final UsersSearchState searchState;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      tooltip: 'Clear search',
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: onSearch,
          ),
        ),
        if (searchState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              searchState.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: _UsersListContent(
            searchState: searchState,
            onRefresh: onRefresh,
          ),
        ),
      ],
    );
  }
}

class _UsersListContent extends StatelessWidget {
  const _UsersListContent({
    required this.searchState,
    required this.onRefresh,
  });

  final UsersSearchState searchState;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (searchState.isLoading) {
      return const Center(child: PlinkyLoadingAnimation());
    }

    if (searchState.users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        itemCount: searchState.users.length,
        itemBuilder: (context, index) {
          final user = searchState.users[index];
          return UserListTile(user: user);
        },
      ),
    );
  }
}

class UserListTile extends StatelessWidget {
  const UserListTile({required this.user, super.key});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.username[0].toUpperCase()),
        ),
        title: Text(user.username),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(AppRoute.userPage(user.username)),
      ),
    );
  }
}
