import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'highscores_notifier.freezed.dart';
part 'highscores_notifier.g.dart';

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

  factory UserHighscore.fromJson(Map<String, dynamic> json) =>
      _$UserHighscoreFromJson(json);
}

class HighscoresNotifier extends Notifier<HighscoresState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  HighscoresState build() => const HighscoresState();

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _supabase.rpc('get_user_highscores');
      final highscores = (response as List).map((row) {
        final map = row as Map<String, dynamic>;
        return UserHighscore(
          userId: map['user_id'] as String,
          username: map['username'] as String,
          totalStars: (map['total_stars'] as num).toInt(),
          totalUploads: (map['total_uploads'] as num).toInt(),
        );
      }).toList();

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
