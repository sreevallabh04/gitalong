import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';
import '../core/monitoring/analytics_service.dart';
import '../core/monitoring/crashlytics_service.dart';

/// Custom exception for Firestore authentication errors
class FirestoreAuthException implements Exception {
  final String message;
  final String code;

  const FirestoreAuthException(this.message, {required this.code});

  @override
  String toString() => 'FirestoreAuthException: $message (Code: $code)';
}

class FirestoreService {
  static late FirebaseFirestore _firestore;
  static bool _initialized = false;

  // Collection references
  static CollectionReference get users => _firestore.collection('users');
  static CollectionReference get projects => _firestore.collection('projects');
  static CollectionReference get swipes => _firestore.collection('swipes');
  static CollectionReference get matches => _firestore.collection('matches');
  static CollectionReference get analytics =>
      _firestore.collection('analytics');

  /// Initialize Firestore with comprehensive configuration
  static Future<void> initialize() async {
    try {
      _firestore = FirebaseFirestore.instance;

      // Configure Firestore settings for production
      await _firestore.enablePersistence();

      _initialized = true;
      AppLogger.logger.i('✅ Firestore initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Failed to initialize Firestore',
          error: e, stackTrace: stackTrace);
      await CrashlyticsService.recordCustomError(
        'FirestoreInitError',
        'Failed to initialize Firestore: $e',
        stackTrace: stackTrace,
        fatal: true,
      );
    }
  }

  /// Create a new user profile
  static Future<void> createUser(UserModel user) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      await users.doc(user.id).set(user.toJson());

      AppLogger.logger.i('👤 User created: ${user.id}');

      // Track analytics
      await AnalyticsService.trackCustomEvent(
        eventName: 'user_created',
        parameters: {
          'user_id': user.id,
          'creation_method': user.authMethod ?? 'unknown',
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to create user', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'createUser',
        'Failed to create user: $e',
        context: {'user_id': user.id},
      );

      await AnalyticsService.trackError(
        errorType: 'database_error',
        errorMessage: 'Failed to create user: $e',
        errorLocation: 'FirestoreService.createUser',
      );

      rethrow;
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'createUser',
        duration: stopwatch.elapsed,
        success: true,
      );
    }
  }

  /// Get user profile by ID (alias for compatibility)
  static Future<UserModel?> getUserProfile(String userId) async {
    return await getUser(userId);
  }

  /// Get user profile by ID
  static Future<UserModel?> getUser(String userId) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      final doc = await users.doc(userId).get();

      if (!doc.exists) {
        AppLogger.logger.w('👤 User not found: $userId');
        return null;
      }

      final user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      AppLogger.logger.d('👤 User retrieved: $userId');

      return user;
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to get user', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'getUser',
        'Failed to get user: $e',
        context: {'user_id': userId},
      );

      rethrow;
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'getUser',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Update user profile
  static Future<void> updateUser(
      String userId, Map<String, dynamic> updates) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await users.doc(userId).update(updates);

      AppLogger.logger.i('👤 User updated: $userId');

      await AnalyticsService.trackCustomEvent(
        eventName: 'user_updated',
        parameters: {
          'user_id': userId,
          'fields_updated': updates.keys.toList(),
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to update user', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'updateUser',
        'Failed to update user: $e',
        context: {'user_id': userId, 'updates': updates},
      );

      rethrow;
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'updateUser',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Get users for matching (excluding current user and already swiped)
  static Future<List<UserModel>> getUsersForMatching(
    String currentUserId, {
    int limit = 10,
    List<String> excludeIds = const [],
  }) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      // Get already swiped user IDs
      final swipedUserIds = await getSwipedUserIds(currentUserId);
      final allExcludeIds = [...excludeIds, currentUserId, ...swipedUserIds];

      Query query = users.where('isActive', isEqualTo: true).limit(
          limit + allExcludeIds.length); // Get extra to account for filtering

      final querySnapshot = await query.get();
      final allUsers = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) => !allExcludeIds.contains(user.id))
          .take(limit)
          .toList();

      AppLogger.logger.d('👥 Retrieved ${allUsers.length} users for matching');

      return allUsers;
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Failed to get users for matching',
          error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'getUsersForMatching',
        'Failed to get users for matching: $e',
        context: {'current_user_id': currentUserId},
      );

      return [];
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'getUsersForMatching',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Create a new project
  static Future<void> createProject(ProjectModel project) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      await projects.doc(project.id).set(project.toJson());

      AppLogger.logger.i('📂 Project created: ${project.id}');

      await AnalyticsService.trackCustomEvent(
        eventName: 'project_created',
        parameters: {
          'project_id': project.id,
          'owner_id': project.ownerId,
          'skills_count': project.skills?.length ?? 0,
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to create project', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'createProject',
        'Failed to create project: $e',
        context: {'project_id': project.id},
      );

      rethrow;
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'createProject',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Get projects for swiping
  static Future<List<ProjectModel>> getProjectsForSwiping(
    String userId, {
    int limit = 10,
    List<String> excludeIds = const [],
  }) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      // Get already swiped project IDs
      final swipedProjectIds = await getSwipedProjectIds(userId);
      final allExcludeIds = [...excludeIds, ...swipedProjectIds];

      Query query = projects
          .where('isActive', isEqualTo: true)
          .where('ownerId', isNotEqualTo: userId) // Don't show own projects
          .orderBy('ownerId')
          .orderBy('createdAt', descending: true)
          .limit(limit + allExcludeIds.length);

      final querySnapshot = await query.get();
      final availableProjects = querySnapshot.docs
          .map((doc) =>
              ProjectModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((project) => !allExcludeIds.contains(project.id))
          .take(limit)
          .toList();

      AppLogger.logger
          .d('📂 Retrieved ${availableProjects.length} projects for swiping');

      return availableProjects;
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Failed to get projects for swiping',
          error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'getProjectsForSwiping',
        'Failed to get projects for swiping: $e',
        context: {'user_id': userId},
      );

      return [];
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'getProjectsForSwiping',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Record a swipe action
  static Future<void> recordSwipe(SwipeModel swipe) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      final batch = _firestore.batch();

      // Add swipe record
      final swipeRef = swipes.doc();
      batch.set(swipeRef, swipe.toJson());

      // Check for mutual swipe and create match if found
      if (swipe.isLike) {
        final mutualSwipe = await _checkForMutualSwipe(swipe);
        if (mutualSwipe != null) {
          final match = MatchModel(
            id: _generateMatchId(swipe.swiperId, swipe.targetId),
            contributorId: swipe.swiperId,
            projectId: swipe.targetId,
            projectOwnerId: mutualSwipe.swiperId,
            createdAt: DateTime.now(),
            status: MatchStatus.active,
          );

          final matchRef = matches.doc(match.id);
          batch.set(matchRef, match.toJson());

          AppLogger.logger.i('💕 Match created: ${match.id}');
        }
      }

      await batch.commit();

      AppLogger.logger
          .d('👆 Swipe recorded: ${swipe.isLike ? 'LIKE' : 'PASS'}');

      // Track analytics
      await AnalyticsService.trackSwipe(
        direction: swipe.isLike ? 'right' : 'left',
        targetType: swipe.targetType.name,
        targetId: swipe.targetId,
        additionalParams: {
          'swiper_id': swipe.swiperId,
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to record swipe', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'recordSwipe',
        'Failed to record swipe: $e',
        context: {
          'swiper_id': swipe.swiperId,
          'target_id': swipe.targetId,
          'is_like': swipe.isLike,
        },
      );

      rethrow;
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'recordSwipe',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Get swipe history for a user
  static Future<List<SwipeModel>> getSwipeHistory(
    String userId, {
    int limit = 50,
  }) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    try {
      final querySnapshot = await swipes
          .where('swiperId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final swipeHistory = querySnapshot.docs
          .map((doc) => SwipeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      AppLogger.logger
          .d('📊 Retrieved ${swipeHistory.length} swipes for user $userId');

      return swipeHistory;
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to get swipe history', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'getSwipeHistory',
        'Failed to get swipe history: $e',
        context: {'user_id': userId},
      );

      return [];
    }
  }

  /// Get matches for a user
  static Future<List<MatchModel>> getMatches(String userId) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    try {
      final querySnapshot = await matches
          .where('contributorId', isEqualTo: userId)
          .where('status', isEqualTo: MatchStatus.active.name)
          .orderBy('createdAt', descending: true)
          .get();

      final userMatches = querySnapshot.docs
          .map((doc) => MatchModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      AppLogger.logger
          .d('💕 Retrieved ${userMatches.length} matches for user $userId');

      return userMatches;
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Failed to get matches', error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'getMatches',
        'Failed to get matches: $e',
        context: {'user_id': userId},
      );

      return [];
    }
  }

  /// Sync trending GitHub repositories
  static Future<void> syncTrendingProjects(
      List<ProjectModel> trendingProjects) async {
    if (!_initialized) throw Exception('Firestore not initialized');

    final stopwatch = Stopwatch()..start();

    try {
      final batch = _firestore.batch();

      for (final project in trendingProjects) {
        final projectRef = projects.doc(project.id);
        batch.set(projectRef, project.toJson(), SetOptions(merge: true));
      }

      await batch.commit();

      AppLogger.logger
          .i('📊 Synced ${trendingProjects.length} trending projects');

      await AnalyticsService.trackCustomEvent(
        eventName: 'projects_synced',
        parameters: {
          'projects_count': trendingProjects.length,
          'sync_type': 'trending',
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Failed to sync trending projects',
          error: e, stackTrace: stackTrace);

      await CrashlyticsService.recordBusinessError(
        'syncTrendingProjects',
        'Failed to sync trending projects: $e',
        context: {'projects_count': trendingProjects.length},
      );

      rethrow;
    } finally {
      stopwatch.stop();
      await AnalyticsService.trackPerformance(
        operation: 'syncTrendingProjects',
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Private helper methods

  static Future<List<String>> getSwipedUserIds(String userId) async {
    try {
      final querySnapshot = await swipes
          .where('swiperId', isEqualTo: userId)
          .where('targetType', isEqualTo: 'user')
          .get();

      return querySnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['targetId'] as String)
          .toList();
    } catch (e) {
      AppLogger.logger.e('❌ Failed to get swiped user IDs', error: e);
      return [];
    }
  }

  static Future<List<String>> getSwipedProjectIds(String userId) async {
    try {
      final querySnapshot = await swipes
          .where('swiperId', isEqualTo: userId)
          .where('targetType', isEqualTo: 'project')
          .get();

      return querySnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['targetId'] as String)
          .toList();
    } catch (e) {
      AppLogger.logger.e('❌ Failed to get swiped project IDs', error: e);
      return [];
    }
  }

  static Future<SwipeModel?> _checkForMutualSwipe(SwipeModel swipe) async {
    try {
      final querySnapshot = await swipes
          .where('swiperId', isEqualTo: swipe.targetId)
          .where('targetId', isEqualTo: swipe.swiperId)
          .where('targetType', isEqualTo: 'user')
          .where('isLike', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SwipeModel.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      AppLogger.logger.e('❌ Failed to check for mutual swipe', error: e);
      return null;
    }
  }

  static String _generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Analytics and monitoring helpers

  static Future<Map<String, dynamic>> getAnalytics() async {
    if (!_initialized) throw Exception('Firestore not initialized');

    try {
      final usersCount = await _getCollectionCount(users);
      final projectsCount = await _getCollectionCount(projects);
      final swipesCount = await _getCollectionCount(swipes);
      final matchesCount = await _getCollectionCount(matches);

      return {
        'users_count': usersCount,
        'projects_count': projectsCount,
        'swipes_count': swipesCount,
        'matches_count': matchesCount,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.logger.e('❌ Failed to get analytics', error: e);
      return {};
    }
  }

  static Future<int> _getCollectionCount(CollectionReference collection) async {
    final snapshot = await collection.count().get();
    return snapshot.count ?? 0;
  }

  /// Check if service is initialized
  static bool get isInitialized => _initialized;
}
