import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

class SwipeService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final Uuid _uuid = const Uuid();

  // Get projects to swipe for contributors
  Future<List<ProjectModel>> getProjectsToSwipe(String userId) async {
    try {
      // Get projects that user hasn't swiped on
      final swipedProjectIds = await _getSwipedTargetIds(
        userId,
        SwipeTargetType.project,
      );

      var query = _supabase
          .from('projects')
          .select('*')
          .eq('status', 'active')
          .neq('owner_id', userId);

      if (swipedProjectIds.isNotEmpty) {
        query = query.not('id', 'in', swipedProjectIds);
      }

      final response = await query.limit(10);

      return response
          .map<ProjectModel>((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw SwipeException('Failed to fetch projects: $e');
    }
  }

  // Get users to swipe for maintainers
  Future<List<UserModel>> getUsersToSwipe(String userId) async {
    try {
      // Get users that maintainer hasn't swiped on
      final swipedUserIds = await _getSwipedTargetIds(
        userId,
        SwipeTargetType.user,
      );

      var query = _supabase
          .from('users')
          .select('*')
          .eq('role', 'contributor')
          .neq('id', userId);

      if (swipedUserIds.isNotEmpty) {
        query = query.not('id', 'in', swipedUserIds);
      }

      final response = await query.limit(10);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw SwipeException('Failed to fetch users: $e');
    }
  }

  // Record a swipe
  Future<bool> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeDirection direction,
    required SwipeTargetType targetType,
  }) async {
    try {
      final swipeData = {
        'id': _uuid.v4(),
        'swiper_id': swiperId,
        'target_id': targetId,
        'direction': direction.name,
        'target_type': targetType.name,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('swipes').insert(swipeData);

      // Check for match if it's a right swipe
      if (direction == SwipeDirection.right) {
        return await _checkForMatch(swiperId, targetId, targetType);
      }

      return false;
    } catch (e) {
      throw SwipeException('Failed to record swipe: $e');
    }
  }

  // Get matches for a user
  Future<List<MatchModel>> getUserMatches(String userId) async {
    try {
      final response = await _supabase
          .from('matches')
          .select('*')
          .or(
            'contributor_id.eq.$userId,project_id.in.(select id from projects where owner_id = $userId)',
          )
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response
          .map<MatchModel>((json) => MatchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw SwipeException('Failed to fetch matches: $e');
    }
  }

  // Get smart recommendations based on skills
  Future<List<ProjectModel>> getSmartRecommendations(String userId) async {
    try {
      // Get user's skills
      final userResponse =
          await _supabase
              .from('users')
              .select('skills')
              .eq('id', userId)
              .single();

      final userSkills = List<String>.from(userResponse['skills'] ?? []);

      if (userSkills.isEmpty) {
        return getProjectsToSwipe(userId);
      }

      // Get swiped project IDs
      final swipedProjectIds = await _getSwipedTargetIds(
        userId,
        SwipeTargetType.project,
      );

      // Find projects that match user's skills
      var query = _supabase
          .from('projects')
          .select('*')
          .eq('status', 'active')
          .neq('owner_id', userId)
          .overlaps('skills_required', userSkills);

      if (swipedProjectIds.isNotEmpty) {
        query = query.not('id', 'in', swipedProjectIds);
      }

      final response = await query.limit(10);

      return response
          .map<ProjectModel>((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw SwipeException('Failed to fetch smart recommendations: $e');
    }
  }

  // Private helper to get swiped target IDs
  Future<List<String>> _getSwipedTargetIds(
    String userId,
    SwipeTargetType targetType,
  ) async {
    try {
      final response = await _supabase
          .from('swipes')
          .select('target_id')
          .eq('swiper_id', userId)
          .eq('target_type', targetType.name);

      return response
          .map<String>((item) => item['target_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Private helper to check for matches
  Future<bool> _checkForMatch(
    String swiperId,
    String targetId,
    SwipeTargetType targetType,
  ) async {
    try {
      bool hasMatch = false;

      if (targetType == SwipeTargetType.project) {
        // Contributor swiped right on project, check if project owner swiped right on contributor
        final projectResponse =
            await _supabase
                .from('projects')
                .select('owner_id')
                .eq('id', targetId)
                .single();

        final ownerId = projectResponse['owner_id'] as String;

        final ownerSwipeResponse =
            await _supabase
                .from('swipes')
                .select('direction')
                .eq('swiper_id', ownerId)
                .eq('target_id', swiperId)
                .eq('target_type', 'user')
                .eq('direction', 'right')
                .maybeSingle();

        hasMatch = ownerSwipeResponse != null;

        if (hasMatch) {
          // Create match
          await _createMatch(swiperId, targetId);
        }
      } else {
        // Maintainer swiped right on contributor, check if contributor swiped right on any of maintainer's projects
        final maintainerProjectsResponse = await _supabase
            .from('projects')
            .select('id')
            .eq('owner_id', swiperId);

        final projectIds =
            maintainerProjectsResponse
                .map<String>((item) => item['id'] as String)
                .toList();

        if (projectIds.isNotEmpty) {
          final contributorSwipeResponse =
              await _supabase
                  .from('swipes')
                  .select('target_id')
                  .eq('swiper_id', targetId)
                  .eq('target_type', 'project')
                  .eq('direction', 'right')
                  .inFilter('target_id', projectIds)
                  .limit(1)
                  .maybeSingle();

          if (contributorSwipeResponse != null) {
            hasMatch = true;
            await _createMatch(
              targetId,
              contributorSwipeResponse['target_id'] as String,
            );
          }
        }
      }

      return hasMatch;
    } catch (e) {
      return false;
    }
  }

  // Private helper to create a match
  Future<void> _createMatch(String contributorId, String projectId) async {
    try {
      final matchData = {
        'id': _uuid.v4(),
        'contributor_id': contributorId,
        'project_id': projectId,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'active',
      };

      await _supabase.from('matches').insert(matchData);
    } catch (e) {
      throw SwipeException('Failed to create match: $e');
    }
  }
}

class SwipeException implements Exception {
  final String message;

  const SwipeException(this.message);

  @override
  String toString() => 'SwipeException: $message';
}
