// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'users_search_notifier.freezed.dart';

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
}

class UsersSearchNotifier extends Notifier<UsersSearchState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  UsersSearchState build() => const UsersSearchState();

  Future<void> search(String query) async {
    state = const UsersSearchState(isLoading: true);

    try {
      final rows = await _supabase
          .table(Profiles.table)
          .selectOnly([Profiles.username])
          .where(Profiles.username.ilike('%$query%'))
          .order(Profiles.username.asc())
          .limit(50);

      final users = [
        for (final row in rows)
          UserProfile(username: row.read(Profiles.username)),
      ];

      state = UsersSearchState(users: users);
    } on Exception catch (error) {
      debugPrint('$error');
      state = UsersSearchState(errorMessage: error.toString());
    }
  }
}
