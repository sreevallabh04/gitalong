import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'github_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Intelligent recommendation engine for matching developers
@lazySingleton
class RecommendationService {
  final GitHubService _githubService;
  final SupabaseClient _supabase;
  
  RecommendationService(
    this._githubService,
    this._supabase,
  );
  
  /// Get personalized recommendations for current user
  Future<List<UserEntity>> getRecommendations({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user signed in');
      }
      
      AppLogger.d('Generating recommendations for user ${currentUser.id}');
      
      // 1. Get current user's profile and preferences
      final userProfile = await _getUserProfile(currentUser.id);
      if (userProfile == null) {
        AppLogger.w('User profile not found, returning random users');
        return await _getRandomUsers(limit, currentUser.id);
      }
      
      // 2. Get GitHub data for current user
      final userGitHubData = await _githubService.calculateDeveloperScore(
        userProfile.username,
      );
      
      // 3. Get already swiped user IDs to exclude
      final swipedUserIds = await _getSwipedUserIds(currentUser.id);
      AppLogger.d('Excluding ${swipedUserIds.length} already-swiped users');
      
      // 4. Get candidate users (excluding self and swiped)
      final candidates = await _getCandidateUsers(
        currentUserId: currentUser.id,
        excludeUserIds: swipedUserIds,
        limit: limit * 3, // Get more candidates for better filtering
      );
      
      if (candidates.isEmpty) {
        AppLogger.w('No candidates found, returning empty list');
        return [];
      }
      
      // 5. Calculate match scores for each candidate
      final scoredCandidates = <ScoredUser>[];
      
      for (final candidate in candidates) {
        try {
          final score = await _calculateMatchScore(
            currentUser: userProfile,
            currentUserGitHub: userGitHubData,
            candidate: candidate,
          );
          
          scoredCandidates.add(ScoredUser(
            user: candidate,
            score: score,
          ));
        } catch (e) {
          AppLogger.e('Error scoring candidate ${candidate.username}', e);
        }
      }
      
      // 6. Sort by score (highest first) and return top N
      scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
      
      final recommendations = scoredCandidates
          .take(limit)
          .map((scored) => scored.user)
          .toList();
      
      AppLogger.i('Generated ${recommendations.length} recommendations with scores: '
          '${scoredCandidates.take(5).map((s) => s.score.toStringAsFixed(1)).join(", ")}');
      
      return recommendations;
    } catch (e, stackTrace) {
      AppLogger.e('Error generating recommendations', e, stackTrace);
      return [];
    }
  }
  
  /// Calculate match score between current user and candidate (0-100)
  Future<double> _calculateMatchScore({
    required UserEntity currentUser,
    required DeveloperScore currentUserGitHub,
    required UserEntity candidate,
  }) async {
    double totalScore = 0;
    
    // 1. Language Similarity Score (40 points max)
    final languageScore = _calculateLanguageSimilarity(
      currentUserGitHub.languages,
      candidate.languages,
    ) * 40;
    totalScore += languageScore;
    
    // 2. Interest/Topic Similarity Score (30 points max)
    final interestScore = _calculateInterestSimilarity(
      currentUserGitHub.topics,
      candidate.interests,
    ) * 30;
    totalScore += interestScore;
    
    // 3. Activity Level Compatibility (15 points max)
    final activityScore = _calculateActivityCompatibility(
      currentUserGitHub.activityScore,
      candidate.publicRepos.toDouble(),
    ) * 15;
    totalScore += activityScore;
    
    // 4. Location Bonus (10 points max)
    final locationScore = _calculateLocationBonus(
      currentUser.location,
      candidate.location,
    ) * 10;
    totalScore += locationScore;
    
    // 5. Recency Bonus (5 points max)
    final recencyScore = _calculateRecencyBonus(
      candidate.lastActiveAt ?? candidate.createdAt,
    ) * 5;
    totalScore += recencyScore;
    
    return totalScore.clamp(0, 100);
  }
  
  /// Calculate language similarity using Jaccard index
  double _calculateLanguageSimilarity(
    List<String> userLanguages,
    List<String> candidateLanguages,
  ) {
    if (userLanguages.isEmpty || candidateLanguages.isEmpty) {
      return 0.0;
    }
    
    final userSet = userLanguages.toSet();
    final candidateSet = candidateLanguages.toSet();
    
    final intersection = userSet.intersection(candidateSet).length;
    final union = userSet.union(candidateSet).length;
    
    return union > 0 ? intersection / union : 0.0;
  }
  
  /// Calculate interest similarity using Jaccard index
  double _calculateInterestSimilarity(
    List<String> userInterests,
    List<String> candidateInterests,
  ) {
    if (userInterests.isEmpty || candidateInterests.isEmpty) {
      return 0.0;
    }
    
    final userSet = userInterests.map((s) => s.toLowerCase()).toSet();
    final candidateSet = candidateInterests.map((s) => s.toLowerCase()).toSet();
    
    final intersection = userSet.intersection(candidateSet).length;
    final union = userSet.union(candidateSet).length;
    
    return union > 0 ? intersection / union : 0.0;
  }
  
  /// Calculate activity compatibility (prefer similar activity levels)
  double _calculateActivityCompatibility(
    double userActivity,
    double candidateRepos,
  ) {
    // Normalize candidate repos to 0-100 scale
    final candidateActivity = (candidateRepos / 50).clamp(0, 100);
    
    // Calculate similarity (inverse of difference)
    final difference = (userActivity - candidateActivity).abs();
    return (100 - difference) / 100;
  }
  
  /// Calculate location bonus (same location = bonus)
  double _calculateLocationBonus(String? userLocation, String? candidateLocation) {
    if (userLocation == null || candidateLocation == null) {
      return 0.5; // Neutral
    }
    
    if (userLocation.toLowerCase().trim() == 
        candidateLocation.toLowerCase().trim()) {
      return 1.0; // Perfect match
    }
    
    // Check if same country/region (simplified)
    if (userLocation.toLowerCase().contains(candidateLocation.toLowerCase()) ||
        candidateLocation.toLowerCase().contains(userLocation.toLowerCase())) {
      return 0.7; // Partial match
    }
    
    return 0.3; // Different location
  }
  
  /// Calculate recency bonus (more recent activity = higher score)
  double _calculateRecencyBonus(DateTime lastActive) {
    final daysSinceActive = DateTime.now().difference(lastActive).inDays;
    
    if (daysSinceActive <= 7) return 1.0;
    if (daysSinceActive <= 30) return 0.8;
    if (daysSinceActive <= 90) return 0.5;
    if (daysSinceActive <= 180) return 0.3;
    return 0.1;
  }
  
  /// Get user profile from Supabase
  Future<UserEntity?> _getUserProfile(String userId) async {
    try {
      final data = await _supabase.from('users').select().eq('id', userId).maybeSingle();
      
      if (data == null) return null;
      
      return UserModel.fromJson(data).toEntity();
    } catch (e) {
      AppLogger.e('Error fetching user profile', e);
      return null;
    }
  }
  
  /// Get list of user IDs that current user has already swiped
  Future<Set<String>> _getSwipedUserIds(String currentUserId) async {
    try {
      final data = await _supabase
          .from('swipes')
          .select('swipedUserId')
          .eq('swiperId', currentUserId);
      
      return data
          .map((doc) => doc['swipedUserId'] as String)
          .toSet();
    } catch (e) {
      AppLogger.e('Error fetching swiped user IDs', e);
      return {};
    }
  }
  
  /// Get candidate users for recommendation
  Future<List<UserEntity>> _getCandidateUsers({
    required String currentUserId,
    required Set<String> excludeUserIds,
    int limit = 60,
  }) async {
    try {
      // Add current user to exclude list
      final excludeList = {...excludeUserIds, currentUserId}.toList();
      
      // Fetch users, excluding already swiped ones
      // Since supabase doesn't have a simple not in filter for large arrays easily, 
      // we'll fetch more and filter locally if list is too large, or we can use not.in
      final data = await _supabase
          .from('users')
          .select()
          .not('id', 'in', excludeList.isEmpty ? ['dummy'] : excludeList)
          .limit(limit);
      
      final candidates = data
          .map((doc) => UserModel.fromJson(doc).toEntity())
          .toList();
      
      AppLogger.d('Fetched ${candidates.length} candidate users');
      return candidates;
    } catch (e) {
      AppLogger.e('Error fetching candidate users', e);
      return [];
    }
  }
  
  /// Get random users as fallback
  Future<List<UserEntity>> _getRandomUsers(int limit, String currentUserId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .limit(limit);
      
      final users = data
          .map((doc) => UserModel.fromJson(doc).toEntity())
          .toList();
      
      // Shuffle for randomness
      users.shuffle(Random());
      
      return users;
    } catch (e) {
      AppLogger.e('Error fetching random users', e);
      return [];
    }
  }
  
  /// Refresh GitHub data for user (cache with 24h TTL)
  Future<void> refreshUserGitHubData(String userId, String username) async {
    try {
      final score = await _githubService.calculateDeveloperScore(username);
      
      // Upsert
      final json = score.toJson();
      json['id'] = userId;
      
      await _supabase.from('github_cache').upsert(json);
      
      AppLogger.i('Refreshed GitHub data for $username');
    } catch (e) {
      AppLogger.e('Error refreshing GitHub data', e);
    }
  }
}

/// User with calculated match score
class ScoredUser {
  final UserEntity user;
  final double score;
  
  ScoredUser({
    required this.user,
    required this.score,
  });
}
