import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../config/firebase_config.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';
import '../models/swipe_model.dart';

abstract class ISwipeService {
  Future<List<ProjectModel>> getProjectsToSwipe(String userId);
  Future<List<UserModel>> getUsersToSwipe(String userId);
  Future<bool> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeDirection direction,
    required SwipeTargetType targetType,
  });
  Future<List<MatchModel>> getUserMatches(String userId);
  Future<List<ProjectModel>> getSmartRecommendations(String userId);
}

/// Service for handling swipe operations and match detection
class SwipeService implements ISwipeService {
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final Uuid _uuid = const Uuid();

  // Static instance for convenience methods
  static final SwipeService _instance = SwipeService();

  static const String _projectsCollection = 'projects';
  static const String _usersCollection = 'users';
  static const String _swipesCollection = 'swipes';
  static const String _matchesCollection = 'matches';

  static CollectionReference<Map<String, dynamic>> get swipesRef =>
      FirebaseConfig.collection('swipes');

  static CollectionReference<Map<String, dynamic>> get matchesRef =>
      FirebaseConfig.collection('matches');

  // Static convenience methods for UI
  static Future<bool> recordSwipeStatic({
    required String swiperId,
    required String targetId,
    required SwipeDirection direction,
    required SwipeTargetType targetType,
  }) {
    return _instance.recordSwipe(
      swiperId: swiperId,
      targetId: targetId,
      direction: direction,
      targetType: targetType,
    );
  }

  static Future<bool> checkForMatchStatic(
    String swiperId,
    String targetId,
    SwipeTargetType targetType,
  ) {
    return _instance._checkForMatch(swiperId, targetId, targetType);
  }

  @override
  Future<List<ProjectModel>> getProjectsToSwipe(String userId) async {
    try {
      // Get projects that user hasn't swiped on
      final swipedProjectIds = await _getSwipedTargetIds(
        userId,
        SwipeTargetType.project,
      );

      Query<Map<String, dynamic>> query = _firestore
          .collection(_projectsCollection)
          .where('status', isEqualTo: 'active')
          .where('owner_id', isNotEqualTo: userId);

      if (swipedProjectIds.isNotEmpty) {
        query = query.where('id', whereNotIn: swipedProjectIds);
      }

      final querySnapshot = await query.limit(10).get();

      return querySnapshot.docs
          .map(
              (doc) => ProjectModel.fromJson(_convertFirestoreData(doc.data())))
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to fetch projects', error: e);
      throw SwipeException('Failed to fetch projects: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersToSwipe(String userId) async {
    try {
      // Get users that maintainer hasn't swiped on
      final swipedUserIds = await _getSwipedTargetIds(
        userId,
        SwipeTargetType.user,
      );

      Query<Map<String, dynamic>> query = _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'contributor')
          .where('id', isNotEqualTo: userId);

      if (swipedUserIds.isNotEmpty) {
        query = query.where('id', whereNotIn: swipedUserIds);
      }

      final querySnapshot = await query.limit(10).get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(_convertFirestoreData(doc.data())))
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to fetch users', error: e);
      throw SwipeException('Failed to fetch users: $e');
    }
  }

  @override
  Future<bool> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeDirection direction,
    required SwipeTargetType targetType,
  }) async {
    try {
      // Validate authentication first
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw SwipeException('Authentication required to record swipe');
      }

      // Ensure user can only swipe as themselves
      if (currentUser.uid != swiperId) {
        throw SwipeException('You can only record swipes for your own account');
      }

      // Refresh auth token to ensure permissions are current
      await currentUser.getIdToken(true);

      AppLogger.logger
          .d('📝 Recording swipe: $swiperId -> $targetId ($direction)');

      final swipeId = _uuid.v4();
      final swipeData = {
        'id': swipeId,
        'swiper_id': swiperId,
        'target_id': targetId,
        'direction': direction.name,
        'target_type': targetType.name,
        'created_at': FieldValue.serverTimestamp(),
      };

      await swipesRef.doc(swipeId).set(swipeData);

      AppLogger.logger.success('✅ Swipe recorded successfully');

      // Check for match if it's a right swipe
      if (direction == SwipeDirection.right) {
        return await _checkForMatch(swiperId, targetId, targetType);
      }

      return false;
    } on FirebaseException catch (e) {
      AppLogger.logger.e('❌ Firebase error recording swipe', error: e);

      if (e.code == 'permission-denied') {
        throw SwipeException(
            'Permission denied. Please sign in again and try.');
      } else if (e.code == 'unauthenticated') {
        throw SwipeException('Authentication expired. Please sign in again.');
      } else {
        throw SwipeException('Failed to record swipe: ${e.message}');
      }
    } catch (e) {
      AppLogger.logger.e('❌ Failed to record swipe', error: e);
      throw SwipeException('Failed to record swipe: $e');
    }
  }

  @override
  Future<List<MatchModel>> getUserMatches(String userId) async {
    try {
      // Get matches where user is contributor
      final contributorMatchesSnapshot = await _firestore
          .collection(_matchesCollection)
          .where('contributor_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('created_at', descending: true)
          .get();

      // Get matches where user is project owner
      final ownerProjectsSnapshot = await _firestore
          .collection(_projectsCollection)
          .where('owner_id', isEqualTo: userId)
          .get();

      final projectIds = ownerProjectsSnapshot.docs
          .map((doc) => doc.data()['id'] as String)
          .toList();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> ownerMatches = [];
      if (projectIds.isNotEmpty) {
        final ownerMatchesSnapshot = await _firestore
            .collection(_matchesCollection)
            .where('project_id', whereIn: projectIds)
            .where('status', isEqualTo: 'active')
            .orderBy('created_at', descending: true)
            .get();
        ownerMatches = ownerMatchesSnapshot.docs;
      }

      final allMatches = [
        ...contributorMatchesSnapshot.docs,
        ...ownerMatches,
      ];

      return allMatches
          .map((doc) => MatchModel.fromJson(_convertFirestoreData(doc.data())))
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to fetch matches', error: e);
      throw SwipeException('Failed to fetch matches: $e');
    }
  }

  @override
  Future<List<ProjectModel>> getSmartRecommendations(String userId) async {
    try {
      // Get user's skills
      final userDoc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists) {
        return getProjectsToSwipe(userId);
      }

      final userData = userDoc.data()!;
      final userSkills = List<String>.from(userData['skills'] ?? []);

      if (userSkills.isEmpty) {
        return getProjectsToSwipe(userId);
      }

      // Get swiped project IDs
      final swipedProjectIds = await _getSwipedTargetIds(
        userId,
        SwipeTargetType.project,
      );

      // Find projects that match user's skills
      Query<Map<String, dynamic>> query = _firestore
          .collection(_projectsCollection)
          .where('status', isEqualTo: 'active')
          .where('owner_id', isNotEqualTo: userId)
          .where('skills_required', arrayContainsAny: userSkills);

      if (swipedProjectIds.isNotEmpty) {
        query = query.where('id', whereNotIn: swipedProjectIds);
      }

      final querySnapshot = await query.limit(10).get();

      return querySnapshot.docs
          .map(
              (doc) => ProjectModel.fromJson(_convertFirestoreData(doc.data())))
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to fetch smart recommendations', error: e);
      throw SwipeException('Failed to fetch smart recommendations: $e');
    }
  }

  // Private helper to get swiped target IDs
  Future<List<String>> _getSwipedTargetIds(
    String userId,
    SwipeTargetType targetType,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_swipesCollection)
          .where('swiper_id', isEqualTo: userId)
          .where('target_type', isEqualTo: targetType.name)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['target_id'] as String)
          .toList();
    } catch (e) {
      AppLogger.logger.e('Failed to get swiped target IDs', error: e);
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
        final projectDoc = await _firestore
            .collection(_projectsCollection)
            .doc(targetId)
            .get();

        if (!projectDoc.exists) return false;

        final ownerId = projectDoc.data()!['owner_id'] as String;

        final ownerSwipeQuery = await _firestore
            .collection(_swipesCollection)
            .where('swiper_id', isEqualTo: ownerId)
            .where('target_id', isEqualTo: swiperId)
            .where('target_type', isEqualTo: 'user')
            .where('direction', isEqualTo: 'right')
            .limit(1)
            .get();

        hasMatch = ownerSwipeQuery.docs.isNotEmpty;

        if (hasMatch) {
          // Create match
          await _createMatch(swiperId, targetId);
        }
      } else {
        // Maintainer swiped right on contributor, check if contributor swiped right on any of maintainer's projects
        final maintainerProjectsQuery = await _firestore
            .collection(_projectsCollection)
            .where('owner_id', isEqualTo: swiperId)
            .get();

        final projectIds = maintainerProjectsQuery.docs
            .map((doc) => doc.data()['id'] as String)
            .toList();

        if (projectIds.isNotEmpty) {
          final contributorSwipeQuery = await _firestore
              .collection(_swipesCollection)
              .where('swiper_id', isEqualTo: targetId)
              .where('target_type', isEqualTo: 'project')
              .where('direction', isEqualTo: 'right')
              .where('target_id', whereIn: projectIds)
              .limit(1)
              .get();

          if (contributorSwipeQuery.docs.isNotEmpty) {
            hasMatch = true;
            final matchedProjectId =
                contributorSwipeQuery.docs.first.data()['target_id'] as String;
            await _createMatch(targetId, matchedProjectId);
          }
        }
      }

      return hasMatch;
    } catch (e) {
      AppLogger.logger.e('Failed to check for match', error: e);
      return false;
    }
  }

  // Private helper to create a match
  Future<void> _createMatch(String contributorId, String projectId) async {
    try {
      final matchId = _uuid.v4();
      final matchData = {
        'id': matchId,
        'contributor_id': contributorId,
        'project_id': projectId,
        'created_at': Timestamp.fromDate(DateTime.now()),
        'status': 'active',
      };

      await _firestore
          .collection(_matchesCollection)
          .doc(matchId)
          .set(matchData);
    } catch (e) {
      AppLogger.logger.e('Failed to create match', error: e);
      throw SwipeException('Failed to create match: $e');
    }
  }

  Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    final convertedData = Map<String, dynamic>.from(data);

    // Convert Firestore Timestamp to ISO string
    if (convertedData['created_at'] is Timestamp) {
      convertedData['created_at'] =
          (convertedData['created_at'] as Timestamp).toDate().toIso8601String();
    }

    if (convertedData['updated_at'] is Timestamp) {
      convertedData['updated_at'] =
          (convertedData['updated_at'] as Timestamp).toDate().toIso8601String();
    }

    return convertedData;
  }
}

class SwipeException implements Exception {
  final String message;

  const SwipeException(this.message);

  @override
  String toString() => 'SwipeException: $message';
}
