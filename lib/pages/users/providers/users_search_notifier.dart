import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'users_search_notifier.freezed.dart';
part 'users_search_notifier.g.dart';

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

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({required String username}) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
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
          .select('username')
          .ilike('username', '%$query%')
          .order('username')
          .limit(50);

      final users = (response as List)
          .map((row) => UserProfile.fromJson(row as Map<String, dynamic>))
          .toList();

      state = UsersSearchState(users: users);
    } on Exception catch (error) {
      debugPrint('$error');
      state = UsersSearchState(errorMessage: error.toString());
    }
  }
}
