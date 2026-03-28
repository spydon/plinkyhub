import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/models/saved_pack.dart';
import 'package:plinkyhub/models/saved_preset.dart';
import 'package:plinkyhub/models/saved_sample.dart';
import 'package:plinkyhub/state/authentication_notifier.dart';
import 'package:plinkyhub/state/user_profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
      UserProfileNotifier.new,
    );

final userProfileByUsernameProvider = FutureProvider.autoDispose
    .family<UserProfileState, String>((ref, username) async {
      final supabase = Supabase.instance.client;
      final currentUserId = ref.read(authenticationProvider).user?.id;

      final profileResponse = await supabase
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (profileResponse == null) {
        throw Exception('User "$username" not found');
      }

      final userId = profileResponse['id'] as String;
      final isOwnProfile = currentUserId == userId;

      Future<Set<String>> fetchStarredIds(String table, String idColumn) async {
        if (currentUserId == null) {
          return {};
        }
        final stars = await supabase
            .from(table)
            .select(idColumn)
            .eq('user_id', currentUserId);
        return {
          for (final row in stars as List)
            (row as Map<String, dynamic>)[idColumn] as String,
        };
      }

      var presetsQuery = supabase
          .from('presets')
          .select('*, profiles(username), preset_stars(count)')
          .eq('user_id', userId);
      if (!isOwnProfile) {
        presetsQuery = presetsQuery.eq('is_public', true);
      }

      var packsQuery = supabase
          .from('packs')
          .select('*, pack_slots(*), profiles(username), pack_stars(count)')
          .eq('user_id', userId);
      if (!isOwnProfile) {
        packsQuery = packsQuery.eq('is_public', true);
      }

      var samplesQuery = supabase
          .from('samples')
          .select('*, profiles(username), sample_stars(count)')
          .eq('user_id', userId);
      if (!isOwnProfile) {
        samplesQuery = samplesQuery.eq('is_public', true);
      }

      final queryResults = await Future.wait([
        presetsQuery.order('updated_at', ascending: false),
        packsQuery.order('updated_at', ascending: false),
        samplesQuery.order('updated_at', ascending: false),
      ]);
      final starredResults = await Future.wait([
        fetchStarredIds('preset_stars', 'preset_id'),
        fetchStarredIds('pack_stars', 'pack_id'),
        fetchStarredIds('sample_stars', 'sample_id'),
      ]);

      final presetsResponse = queryResults[0];
      final packsResponse = queryResults[1];
      final samplesResponse = queryResults[2];
      final starredPresetIds = starredResults[0];
      final starredPackIds = starredResults[1];
      final starredSampleIds = starredResults[2];

      return UserProfileState(
        userId: userId,
        username: username,
        presets: presetsResponse.map((map) {
          return SavedPreset.fromJson({
            ...map,
            'is_starred': starredPresetIds.contains(map['id']),
          });
        }).toList(),
        packs: packsResponse.map((map) {
          return SavedPack.fromJson({
            ...map,
            'is_starred': starredPackIds.contains(map['id']),
          });
        }).toList(),
        samples: samplesResponse.map((map) {
          return SavedSample.fromJson({
            ...map,
            'is_starred': starredSampleIds.contains(map['id']),
          });
        }).toList(),
      );
    });

class UserProfileNotifier extends Notifier<UserProfileState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  UserProfileState build() => const UserProfileState();

  Future<void> loadUserProfileByUsername(String username) async {
    if (state.username == username && !state.isLoading) {
      return;
    }

    state = UserProfileState(
      username: username,
      isLoading: true,
    );

    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User "$username" not found',
        );
        return;
      }

      final userId = response['id'] as String;
      await loadUserProfile(userId, username);
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadUserProfile(String userId, String username) async {
    state = UserProfileState(
      userId: userId,
      username: username,
      isLoading: true,
    );

    try {
      final currentUserId = ref.read(authenticationProvider).user?.id;
      final isOwnProfile = currentUserId == userId;

      final presetsFuture = _fetchPresets(userId, isOwnProfile);
      final packsFuture = _fetchPacks(userId, isOwnProfile);
      final samplesFuture = _fetchSamples(userId, isOwnProfile);

      final results = await Future.wait([
        presetsFuture,
        packsFuture,
        samplesFuture,
      ]);

      state = state.copyWith(
        presets: results[0] as List<SavedPreset>,
        packs: results[1] as List<SavedPack>,
        samples: results[2] as List<SavedSample>,
        isLoading: false,
      );
    } on Exception catch (error) {
      debugPrint('$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<List<SavedPreset>> _fetchPresets(
    String userId,
    bool isOwnProfile,
  ) async {
    var query = _supabase
        .from('presets')
        .select('*, profiles(username), preset_stars(count)')
        .eq('user_id', userId);

    if (!isOwnProfile) {
      query = query.eq('is_public', true);
    }

    final response = await query.order('updated_at', ascending: false);

    final starredIds = await _fetchStarredIds('preset_stars', 'preset_id');
    return (response as List).map((row) {
      final map = row as Map<String, dynamic>;
      return SavedPreset.fromJson({
        ...map,
        'is_starred': starredIds.contains(map['id']),
      });
    }).toList();
  }

  Future<List<SavedPack>> _fetchPacks(
    String userId,
    bool isOwnProfile,
  ) async {
    var query = _supabase
        .from('packs')
        .select('*, pack_slots(*), profiles(username), pack_stars(count)')
        .eq('user_id', userId);

    if (!isOwnProfile) {
      query = query.eq('is_public', true);
    }

    final response = await query.order('updated_at', ascending: false);

    final starredIds = await _fetchStarredIds('pack_stars', 'pack_id');
    return (response as List).map((row) {
      final map = row as Map<String, dynamic>;
      return SavedPack.fromJson({
        ...map,
        'is_starred': starredIds.contains(map['id']),
      });
    }).toList();
  }

  Future<List<SavedSample>> _fetchSamples(
    String userId,
    bool isOwnProfile,
  ) async {
    var query = _supabase
        .from('samples')
        .select('*, profiles(username), sample_stars(count)')
        .eq('user_id', userId);

    if (!isOwnProfile) {
      query = query.eq('is_public', true);
    }

    final response = await query.order('updated_at', ascending: false);

    final starredIds = await _fetchStarredIds('sample_stars', 'sample_id');
    return (response as List).map((row) {
      final map = row as Map<String, dynamic>;
      return SavedSample.fromJson({
        ...map,
        'is_starred': starredIds.contains(map['id']),
      });
    }).toList();
  }

  Future<Set<String>> _fetchStarredIds(
    String table,
    String idColumn,
  ) async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return {};
    }
    final stars = await _supabase
        .from(table)
        .select(idColumn)
        .eq('user_id', userId);
    return {
      for (final row in stars as List)
        (row as Map<String, dynamic>)[idColumn] as String,
    };
  }
}
