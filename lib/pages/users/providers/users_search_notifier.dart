import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final usersSearchProvider =
    NotifierProvider<UsersSearchNotifier, UsersSearchState>(
      UsersSearchNotifier.new,
    );

class UsersSearchState {
  const UsersSearchState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<UserProfile> users;
  final bool isLoading;
  final String? errorMessage;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  final String id;
  final String username;
  final DateTime createdAt;
}

class UsersSearchNotifier extends Notifier<UsersSearchState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  UsersSearchState build() => const UsersSearchState();

  Future<void> search(String query) async {
    state = const UsersSearchState(isLoading: true);

    try {
      final response = await _supabase
          .from('profiles')
          .select('id, username, created_at')
          .ilike('username', '%$query%')
          .order('username')
          .limit(50);

      final users = (response as List).map((row) {
        final map = row as Map<String, dynamic>;
        return UserProfile(
          id: map['id'] as String,
          username: map['username'] as String,
          createdAt: DateTime.parse(map['created_at'] as String),
        );
      }).toList();

      state = UsersSearchState(users: users);
    } on Exception catch (error) {
      debugPrint('$error');
      state = UsersSearchState(errorMessage: error.toString());
    }
  }
}
