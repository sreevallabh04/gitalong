import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/swipe_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/swipe_repository.dart';
import '../models/user_model.dart';
import '../../core/utils/logger.dart';

/// Swipe repository implementation
@LazySingleton(as: SwipeRepository)
class SwipeRepositoryImpl implements SwipeRepository {
  final SupabaseClient _supabase;

  SwipeRepositoryImpl(this._supabase);

  @override
  Future<void> swipeUser({
    required String swipedUserId,
    required SwipeAction action,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final swipe = {
        'swiper_id': currentUser.id,
        'swiped_user_id': swipedUserId,
        'action': action.toString().split('.').last,
        'swiped_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('swipes').insert(swipe);
    } catch (e, stackTrace) {
      AppLogger.e('Error swiping user', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<MatchEntity?> checkForMatch(String swipedUserId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      // Check if the other user has also liked current user
      final reverseSwipe = await _supabase
          .from('swipes')
          .select()
          .eq('swiper_id', swipedUserId)
          .eq('swiped_user_id', currentUser.id)
          .inFilter('action', ['like', 'superLike'])
          .limit(1)
          .maybeSingle();

      if (reverseSwipe == null) return null;

      // Create a match
      final matchData = {
        'users': [currentUser.id, swipedUserId],
        'matched_at': DateTime.now().toIso8601String(),
      };

      final createdMatch = await _supabase
          .from('matches')
          .insert(matchData)
          .select()
          .single();

      final userDoc = await _supabase
          .from('users')
          .select()
          .eq('id', swipedUserId)
          .maybeSingle();

      if (userDoc != null) {
        final userEntity = UserModel.fromJson(userDoc).toEntity();
        return MatchEntity(
          id: createdMatch['id'].toString(),
          user: userEntity,
          matchedAt: DateTime.parse(createdMatch['matched_at'] as String),
          isRead: false,
        );
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking for match', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<SwipeEntity>> getSwipeHistory({
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final response = await _supabase
          .from('swipes')
          .select()
          .eq('swiper_id', currentUser.id)
          .order('swiped_at', ascending: false)
          .limit(limit);

      return response.map((data) {
        return SwipeEntity(
          id: data['id']?.toString() ?? '',
          swiperId: data['swiper_id'] as String,
          swipedUserId: data['swiped_user_id'] as String,
          action: SwipeAction.values.firstWhere(
            (e) => e.toString().split('.').last == data['action'],
            orElse: () => SwipeAction.dislike,
          ),
          swipedAt: DateTime.parse(data['swiped_at'] as String),
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting swipe history', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> undoLastSwipe() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final lastSwipe = await _supabase
          .from('swipes')
          .select('id')
          .eq('swiper_id', currentUser.id)
          .order('swiped_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastSwipe != null) {
        await _supabase.from('swipes').delete().eq('id', lastSwipe['id']);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error undoing last swipe', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<String>> getSwipedUserIds() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      final swipes = await _supabase
          .from('swipes')
          .select('swiped_user_id')
          .eq('swiper_id', currentUser.id);

      return swipes
          .map((doc) => doc['swiped_user_id'] as String)
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting swiped user IDs', e, stackTrace);
      rethrow;
    }
  }
}
