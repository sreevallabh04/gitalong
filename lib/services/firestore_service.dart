import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';
import '../models/models.dart';
import '../core/utils/logger.dart';
import '../core/utils/firestore_utils.dart';

/// Custom exception for Firestore authentication errors
class FirestoreAuthException implements Exception {
  final String message;
  final String code;

  const FirestoreAuthException(this.message, {required this.code});

  @override
  String toString() => 'FirestoreAuthException: $message (Code: $code)';
}

class FirestoreService {
  // Collection references with type safety
  static CollectionReference<Map<String, dynamic>> get _usersCollection =>
      FirebaseConfig.collection('users');

  static CollectionReference<Map<String, dynamic>> get _projectsCollection =>
      FirebaseConfig.collection('projects');

  static CollectionReference<Map<String, dynamic>> get _matchesCollection =>
      FirebaseConfig.collection('matches');

  static CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      FirebaseConfig.collection('messages');

  // ============================================================================
  // 🔐 AUTHENTICATION VALIDATION
  // ============================================================================

  /// Validate user authentication and refresh token if needed
  static Future<User> _validateAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      AppLogger.logger.e('❌ User not authenticated');
      throw FirestoreAuthException(
        'User not authenticated. Please sign in again.',
        code: 'unauthenticated',
      );
    }

    try {
      // Refresh ID token to ensure it's valid
      await user.getIdToken(true);
      AppLogger.logger.d('✅ Auth token refreshed successfully');
      return user;
    } catch (e) {
      AppLogger.logger.e('❌ Failed to refresh auth token', error: e);
      throw FirestoreAuthException(
        'Authentication expired. Please sign in again.',
        code: 'token-expired',
      );
    }
  }

  /// Handle Firestore permission and auth errors with user-friendly messages
  static Exception _handleFirestoreError(dynamic error, String operation) {
    AppLogger.logger.e('❌ Firestore error during $operation', error: error);

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return FirestoreAuthException(
            'Permission denied. Please check your authentication or try signing in again.',
            code: error.code,
          );
        case 'unauthenticated':
          return FirestoreAuthException(
            'Authentication required. Please sign in to continue.',
            code: error.code,
          );
        case 'unavailable':
          return Exception(
              'Service temporarily unavailable. Please try again in a moment.');
        case 'deadline-exceeded':
          return Exception(
              'Request timed out. Please check your connection and try again.');
        case 'resource-exhausted':
          return Exception(
              'Service is currently busy. Please try again in a moment.');
        case 'invalid-argument':
          return Exception(
              'Invalid data provided. Please check your input and try again.');
        case 'not-found':
          return Exception('Requested data not found.');
        case 'already-exists':
          return Exception('Data already exists.');
        case 'failed-precondition':
          return Exception(
              'Operation failed due to current state. Please refresh and try again.');
        default:
          return Exception(
              'Database error: ${error.message ?? 'Unknown error'}');
      }
    }

    return Exception(
        'An unexpected error occurred during $operation. Please try again.');
  }

  // User Profile Operations
  static Future<UserModel?> getUserProfile(String userId) async {
    final result = await safeQuery(() async {
      AppLogger.logger.d('📄 Fetching user profile: $userId');
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        AppLogger.logger.d('✅ User profile found');
        return UserModel.fromJson(doc.data()!);
      } else {
        AppLogger.logger.w('⚠️ User profile not found: $userId');
        return null;
      }
    });
    return result;
  }

  static Future<UserModel> createUserProfile(UserModel user) async {
    final result = await safeQuery(() async {
      // Validate authentication first
      final authUser = await _validateAuth();

      // Ensure user can only create their own profile
      if (authUser.uid != user.id) {
        throw FirestoreAuthException(
          'You can only create your own profile.',
          code: 'unauthorized-profile-creation',
        );
      }

      AppLogger.logger.firestore('📝 Creating user profile: ${user.email}');

      // Create Firestore-safe data without client timestamps
      final userData = user.toFirestoreJson();

      // Add server timestamps to avoid timezone/serialization issues
      userData['created_at'] = FieldValue.serverTimestamp();
      userData['updated_at'] = FieldValue.serverTimestamp();

      // Perform the write operation with proper error handling
      await _usersCollection
          .doc(user.id)
          .set(userData, SetOptions(merge: false));

      AppLogger.logger.success('✅ User profile created successfully');

      // Return the original user model with current timestamp
      return user.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
    if (result == null) throw Exception('Failed to create user profile');
    return result;
  }

  static Future<UserModel> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      AppLogger.logger.d('📝 Updating user profile: $userId');

      final updateData = Map<String, dynamic>.from(updates);
      updateData['updated_at'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(userId).update(updateData);

      // Fetch updated profile
      final updatedProfile = await getUserProfile(userId);
      if (updatedProfile == null) {
        throw Exception('Failed to fetch updated profile');
      }

      AppLogger.logger.success('✅ User profile updated successfully');
      return updatedProfile;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to update user profile',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Project Operations
  static Future<List<ProjectModel>> getProjects({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      AppLogger.logger.d('📄 Fetching projects (limit: $limit)');

      Query<Map<String, dynamic>> query = _projectsCollection
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      final projects = querySnapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.logger.d('✅ Fetched ${projects.length} projects');
      return projects;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to fetch projects',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      AppLogger.logger.d('📝 Creating project: ${project.title}');

      final projectData = project.toJson();
      projectData['created_at'] = FieldValue.serverTimestamp();
      projectData['updated_at'] = FieldValue.serverTimestamp();

      final docRef = await _projectsCollection.add(projectData);

      AppLogger.logger.success('✅ Project created successfully: ${docRef.id}');
      return project.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to create project',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Match Operations
  static Future<List<MatchModel>> getUserMatches(String userId) async {
    try {
      AppLogger.logger.d('📄 Fetching matches for user: $userId');

      final querySnapshot = await _matchesCollection
          .where('contributor_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      final matches = querySnapshot.docs
          .map((doc) => MatchModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      AppLogger.logger.d('✅ Fetched ${matches.length} matches');
      return matches;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to fetch user matches',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<MatchModel> createMatch(MatchModel match) async {
    try {
      AppLogger.logger.d('📝 Creating match between contributor and project');

      final matchData = match.toJson();
      matchData['created_at'] = FieldValue.serverTimestamp();

      final docRef = await _matchesCollection.add(matchData);

      AppLogger.logger.success('✅ Match created successfully: ${docRef.id}');
      return match.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to create match',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Message Operations
  static Stream<List<MessageModel>> getMessages(String receiverId) {
    try {
      AppLogger.logger
          .d('📄 Setting up message stream for receiver: $receiverId');

      return _messagesCollection
          .where('receiver_id', isEqualTo: receiverId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList();

        AppLogger.logger.d('📨 Received ${messages.length} messages');
        return messages;
      });
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to set up message stream',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      AppLogger.logger.d('📝 Sending message to: ${message.receiverId}');

      final messageData = message.toJson();
      messageData['timestamp'] = FieldValue.serverTimestamp();

      final docRef = await _messagesCollection.add(messageData);

      AppLogger.logger.success('✅ Message sent successfully: ${docRef.id}');
      return message.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to send message',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Swipe Operations
  static Future<void> recordSwipe(SwipeModel swipe) async {
    try {
      AppLogger.logger
          .d('📝 Recording swipe: ${swipe.swiperId} -> ${swipe.targetId}');

      final swipeData = swipe.toJson();
      swipeData['created_at'] = FieldValue.serverTimestamp();

      await FirebaseConfig.collection('swipes').add(swipeData);

      // Check for mutual swipe and create match if needed (for right swipes)
      if (swipe.direction == SwipeDirection.right) {
        await _checkForMutualSwipe(swipe);
      }

      AppLogger.logger.success('✅ Swipe recorded successfully');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to record swipe',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> _checkForMutualSwipe(SwipeModel swipe) async {
    try {
      AppLogger.logger.d('🔍 Checking for mutual swipe');

      final mutualSwipeQuery = await FirebaseConfig.collection('swipes')
          .where('swiper_id', isEqualTo: swipe.targetId)
          .where('target_id', isEqualTo: swipe.swiperId)
          .where('direction', isEqualTo: SwipeDirection.right.name)
          .get();

      if (mutualSwipeQuery.docs.isNotEmpty) {
        AppLogger.logger.d('💕 Mutual swipe detected, creating match');

        final match = MatchModel(
          id: '',
          contributorId: swipe.swiperId,
          projectId: swipe.targetId,
          createdAt: DateTime.now(),
        );

        await createMatch(match);
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to check for mutual swipe',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow here as this is a secondary operation
    }
  }

  // Search and Filtering
  static Future<List<UserModel>> searchUsers({
    String? query,
    List<String>? skills,
    UserRole? role,
    int limit = 20,
  }) async {
    try {
      AppLogger.logger.d('🔍 Searching users with filters');

      Query<Map<String, dynamic>> queryRef = _usersCollection.limit(limit);

      if (role != null) {
        queryRef = queryRef.where('role', isEqualTo: role.name);
      }

      if (skills != null && skills.isNotEmpty) {
        queryRef = queryRef.where('skills', arrayContainsAny: skills);
      }

      final querySnapshot = await queryRef.get();

      List<UserModel> users = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      // Filter by name/bio if query is provided (client-side filtering)
      if (query != null && query.isNotEmpty) {
        users = users.where((user) {
          final searchText = '${user.name} ${user.bio ?? ''}'.toLowerCase();
          return searchText.contains(query.toLowerCase());
        }).toList();
      }

      AppLogger.logger.d('✅ Found ${users.length} users matching criteria');
      return users;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to search users',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Analytics and Metrics
  static Future<Map<String, dynamic>> getAppMetrics() async {
    try {
      AppLogger.logger.d('📊 Fetching app metrics');

      final results = await Future.wait([
        _usersCollection.count().get(),
        _projectsCollection.count().get(),
        _matchesCollection.count().get(),
      ]);

      final metrics = {
        'total_users': results[0].count,
        'total_projects': results[1].count,
        'total_matches': results[2].count,
        'timestamp': DateTime.now().toIso8601String(),
      };

      AppLogger.logger.d('✅ App metrics fetched');
      return metrics;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to fetch app metrics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Health Check
  static Future<bool> healthCheck() async {
    try {
      AppLogger.logger.d('🏥 Performing Firestore health check');

      final healthDoc = FirebaseConfig.document('_health_check/connectivity');

      await healthDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'healthy',
        'version': '1.0.0',
      }, SetOptions(merge: true));

      final readTest = await healthDoc.get();

      AppLogger.logger.success('✅ Firestore health check passed');
      return readTest.exists;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Firestore health check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Data Cleanup and Maintenance
  static Future<void> cleanupOldData() async {
    try {
      AppLogger.logger.d('🧹 Starting data cleanup');

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      // Delete old health check documents
      final oldHealthChecks = await FirebaseConfig.collection('_health_check')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = FirebaseConfig.batch();
      for (final doc in oldHealthChecks.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      AppLogger.logger.success('✅ Data cleanup completed');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Data cleanup failed',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow as this is a maintenance operation
    }
  }
}
