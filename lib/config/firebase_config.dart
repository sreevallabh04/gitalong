import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import '../core/utils/logger.dart';

class FirebaseConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      AppLogger.logger.d(
          'FirebaseConfig.initialize() called - _initialized: $_initialized');

      // Check if Firebase is already initialized
      if (_initialized) {
        AppLogger.logger.d('Firebase already initialized, skipping...');
        return;
      }

      // Check if Firebase apps already exist
      if (Firebase.apps.isNotEmpty) {
        AppLogger.logger
            .d('Firebase apps already exist: ${Firebase.apps.length}');
        AppLogger.logger.d(
            'Existing apps: ${Firebase.apps.map((app) => app.name).toList()}');
        _initialized = true;
        return;
      }

      AppLogger.logger.i('Initializing Firebase with options...');

      // Log Firebase configuration details
      final options = DefaultFirebaseOptions.currentPlatform;
      AppLogger.logger.d('🔧 Firebase Configuration Details:');
      AppLogger.logger.d('   📱 Platform: Current Platform');
      AppLogger.logger.d('   🆔 App ID: ${options.appId}');
      AppLogger.logger.d(
          '   🔑 API Key: ${options.apiKey.isNotEmpty ? "PRESENT" : "MISSING"}');
      AppLogger.logger.d('   📊 Project ID: ${options.projectId}');
      AppLogger.logger
          .d('   💾 Storage Bucket: ${options.storageBucket ?? "NOT_SET"}');
      AppLogger.logger
          .d('   📨 Messaging Sender ID: ${options.messagingSenderId}');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      AppLogger.logger.i('Firebase initialized successfully');

      // Validate Firebase services
      AppLogger.logger.d('🔍 Validating Firebase services...');
      try {
        final auth = FirebaseAuth.instance;
        FirebaseFirestore.instance;
        AppLogger.logger.d('   ✅ Firebase Auth: Available');
        AppLogger.logger.d('   ✅ Cloud Firestore: Available');
        AppLogger.logger
            .d('   🔐 Auth Current User: ${auth.currentUser?.email ?? "None"}');
      } catch (e) {
        AppLogger.logger
            .e('   ❌ Firebase services validation failed', error: e);
      }
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logger.e('🔥 Firebase Exception during initialization',
          error: e, stackTrace: stackTrace);
      AppLogger.logger.e('Firebase Error Code: ${e.code}');
      AppLogger.logger.e('Firebase Error Message: ${e.message}');

      // Handle duplicate app error gracefully
      if (e.code == 'duplicate-app') {
        AppLogger.logger
            .w('Duplicate app error - treating as successful initialization');
        _initialized = true;
        return;
      }
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during Firebase initialization',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Firebase Storage instance
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // Current user
  static User? get currentUser => auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
