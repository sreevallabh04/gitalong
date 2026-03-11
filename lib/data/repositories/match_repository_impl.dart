import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/match_repository.dart';
import '../../domain/entities/match_entity.dart';
import '../models/user_model.dart';
import '../../core/utils/logger.dart';

/// Match repository implementation
@LazySingleton(as: MatchRepository)
class MatchRepositoryImpl implements MatchRepository {
  final SupabaseClient _supabase;

  MatchRepositoryImpl(this._supabase);

  @override
  Future<List<MatchEntity>> getMatches({
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final response = await _supabase
          .from('matches')
          .select()
          .contains('users', [currentUser.id])
          .order('matched_at', ascending: false)
          .limit(limit);

      final matchesList = <MatchEntity>[];

      for (final doc in response) {
        final users = List<String>.from(doc['users'] as List);
        final otherUserId = users.firstWhere(
          (id) => id != currentUser.id,
          orElse: () => users.first,
        );

        final userDoc = await _supabase
            .from('users')
            .select()
            .eq('id', otherUserId)
            .maybeSingle();

        if (userDoc != null) {
          final userEntity = UserModel.fromJson(userDoc).toEntity();
          matchesList.add(MatchEntity(
            id: doc['id'].toString(),
            user: userEntity,
            matchedAt: DateTime.parse(doc['matched_at'] as String),
            lastMessage: doc['last_message'] as String?,
            lastMessageAt: doc['last_message_at'] != null
                ? DateTime.parse(doc['last_message_at'] as String)
                : null,
            isRead: doc['is_read'] as bool? ?? true,
          ));
        }
      }

      AppLogger.d('Found ${matchesList.length} matches for user ${currentUser.id}');
      return matchesList;
    } catch (e, stackTrace) {
      AppLogger.e('Error getting matches', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<MatchEntity> getMatchById(String matchId) async {
    try {
      final doc = await _supabase
          .from('matches')
          .select()
          .eq('id', matchId)
          .maybeSingle();

      if (doc == null) throw Exception('Match not found');

      final users = List<String>.from(doc['users'] as List);
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final otherUserId = users.firstWhere(
        (id) => id != currentUser.id,
        orElse: () => users.first,
      );

      final userDoc = await _supabase
          .from('users')
          .select()
          .eq('id', otherUserId)
          .maybeSingle();

      if (userDoc == null) throw Exception('User not found');

      final userEntity = UserModel.fromJson(userDoc).toEntity();

      return MatchEntity(
        id: doc['id'].toString(),
        user: userEntity,
        matchedAt: DateTime.parse(doc['matched_at'] as String),
        lastMessage: doc['last_message'] as String?,
        lastMessageAt: doc['last_message_at'] != null
            ? DateTime.parse(doc['last_message_at'] as String)
            : null,
        isRead: doc['is_read'] as bool? ?? true,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error getting match by ID', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> unmatch(String matchId) async {
    try {
      await _supabase.from('matches').delete().eq('id', matchId);
    } catch (e, stackTrace) {
      AppLogger.e('Error unmatching', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isMatched(String userId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final response = await _supabase
          .from('matches')
          .select()
          .contains('users', [currentUser.id])
          .contains('users', [userId])
          .limit(1)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking if matched', e, stackTrace);
      rethrow;
    }
  }
}
