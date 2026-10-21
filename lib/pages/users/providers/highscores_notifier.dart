// ignore_for_file: experimental_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plinkyhub/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'highscores_notifier.freezed.dart';

final highscoresProvider =
    NotifierProvider<HighscoresNotifier, HighscoresState>(
      HighscoresNotifier.new,
    );

@freezed
abstract class HighscoresState with _$HighscoresState {
  const factory HighscoresState({
    @Default([]) List<UserHighscore> highscores,
    @Default(false) bool isLoading,
    @Default(false) bool hasLoaded,
    String? errorMessage,
  }) = _HighscoresState;
}

@freezed
abstract class UserHighscore with _$UserHighscore {
  const factory UserHighscore({
    required String userId,
    required String username,
    required int totalStars,
    required int totalUploads,
  }) = _UserHighscore;

  factory UserHighscore.fromRow(GetUserHighscoresRow row) => UserHighscore(
    userId: row.userId ?? '',
    username: row.username ?? '',
    totalStars: row.totalStars ?? 0,
    totalUploads: row.totalUploads ?? 0,
  );
}

class HighscoresNotifier extends Notifier<HighscoresState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  HighscoresState build() => const HighscoresState();

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final rows = await _supabase.rpc.getUserHighscores();
      final highscores = rows.map(UserHighscore.fromRow).toList();

      state = HighscoresState(
        highscores: highscores,
        hasLoaded: true,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: error.toString(),
      );
    }
  }
}
