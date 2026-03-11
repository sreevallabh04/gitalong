import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../services/recommendation_service.dart';
import '../services/github_service.dart';
import '../../core/utils/logger.dart';

/// User repository implementation
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;
  final RecommendationService _recommendationService;
  final GitHubService _githubService;
  
  UserRepositoryImpl(
    this._supabase,
    this._recommendationService,
    this._githubService,
  );
  
  @override
  Future<UserEntity> getUserById(String userId) async {
    try {
      final doc = await _supabase.from('users').select().eq('id', userId).maybeSingle();
      
      if (doc == null) {
        throw Exception('User not found');
      }
      
      return UserModel.fromJson(doc).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting user by ID', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<UserEntity> getUserByUsername(String username) async {
    try {
      final doc = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .limit(1)
          .maybeSingle();
      
      if (doc == null) {
        throw Exception('User not found');
      }
      
      return UserModel.fromJson(doc).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Error getting user by username', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<UserEntity> getCurrentUserProfile() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user signed in');
      }
      
      return await getUserById(currentUser.id);
    } catch (e, stackTrace) {
      AppLogger.e('Error getting current user profile', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<UserEntity> updateUserProfile(UserEntity user) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user signed in');
      }
      
      final userModel = UserModel.fromEntity(user);
      
      final doc = await _supabase
          .from('users')
          .update(userModel.toJson())
          .eq('id', currentUser.id)
          .select()
          .single();
      
      return UserModel.fromJson(doc).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Error updating user profile', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<List<UserEntity>> getRecommendedUsers({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user signed in');
      }
      
      AppLogger.i('Getting intelligent recommendations for user ${currentUser.id}');
      
      // Use intelligent recommendation engine
      final recommendations = await _recommendationService.getRecommendations(
        limit: limit,
        forceRefresh: cursor == null, // Refresh on first page
      );
      
      AppLogger.i('Retrieved ${recommendations.length} personalized recommendations');
      
      return recommendations;
    } catch (e, stackTrace) {
      AppLogger.e('Error getting recommended users', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<List<UserEntity>> searchUsers({
    required String query,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final docs = await _supabase
          .from('users')
          .select()
          .gte('username', query)
          .lt('username', '${query}z')
          .limit(limit);
      
      return docs
          .map((doc) => UserModel.fromJson(doc).toEntity())
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Error searching users', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<Map<String, dynamic>> getUserGitHubStats(String username) async {
    try {
      AppLogger.d('Fetching GitHub stats for $username');
      
      // Use GitHub service to get real stats
      final score = await _githubService.calculateDeveloperScore(username);
      
      return {
        'totalStars': score.totalStars,
        'totalForks': score.totalForks,
        'totalRepos': score.publicRepos,
        'totalCommits': score.totalCommits,
        'topLanguages': score.languages.take(5).toList(),
        'topics': score.topics.take(10).toList(),
        'activityScore': score.activityScore,
      };
    } catch (e, stackTrace) {
      AppLogger.e('Error getting GitHub stats for $username', e, stackTrace);
      
      // Return fallback data
      return {
        'totalStars': 0,
        'totalForks': 0,
        'totalRepos': 0,
        'totalCommits': 0,
        'topLanguages': <String>[],
        'topics': <String>[],
        'activityScore': 0.0,
      };
    }
  }
}
