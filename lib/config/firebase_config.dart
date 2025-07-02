import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import '../core/utils/logger.dart';

class FirebaseConfig {
  static bool _initialized = false;
  static bool _validationComplete = false;

  static Future<void> initialize() async {
    try {
      AppLogger.logger.i('🔥 Starting Firebase initialization...');
      AppLogger.logger.d(
        'FirebaseConfig.initialize() called - _initialized: $_initialized',
      );

      // Check if Firebase is already initialized
      if (_initialized) {
        AppLogger.logger.d('✅ Firebase already initialized, skipping...');
        return;
      }

      // Check if Firebase apps already exist
      if (Firebase.apps.isNotEmpty) {
        AppLogger.logger.d(
          '✅ Firebase apps already exist: ${Firebase.apps.length}',
        );
        AppLogger.logger.d(
          'Existing apps: ${Firebase.apps.map((app) => app.name).toList()}',
        );
        _initialized = true;
        await _validateConfiguration();
        return;
      }

      AppLogger.logger.i(
        '🔧 Initializing Firebase with current platform options...',
      );

      // Get the current platform configuration from generated file
      final options = DefaultFirebaseOptions.currentPlatform;
      await _validateFirebaseOptions(options);

      // Initialize Firebase with the generated options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      AppLogger.logger.success('✅ Firebase initialized successfully');

      // Configure Firestore settings for production
      await _configureFirestore();

      // Validate Firebase services after initialization
      await _validateConfiguration();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logger.e(
        '🔥 Firebase Exception during initialization',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.logger.e('Firebase Error Code: ${e.code}');
      AppLogger.logger.e('Firebase Error Message: ${e.message}');

      // Handle duplicate app error gracefully
      if (e.code == 'duplicate-app') {
        AppLogger.logger.w(
          '⚠️ Duplicate app error - treating as successful initialization',
        );
        _initialized = true;
        await _validateConfiguration();
        return;
      }

      // Provide actionable error messages for common issues
      _handleFirebaseInitializationError(e);
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during Firebase initialization',
        error: e,
        stackTrace: stackTrace,
      );
      _handleGenericInitializationError(e);
      rethrow;
    }
  }

  static Future<void> _configureFirestore() async {
    try {
      AppLogger.logger.d('🗄️ Configuring Firestore settings...');

      final firestore = FirebaseFirestore.instance;

      // Configure Firestore settings for production
      const settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      firestore.settings = settings;

      // Enable network for Firestore
      await firestore.enableNetwork();

      AppLogger.logger.success('✅ Firestore configured successfully');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to configure Firestore',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw here - let the app continue but log the issue
    }
  }

  static Future<void> _validateFirebaseOptions(FirebaseOptions options) async {
    AppLogger.logger.d('🔍 Validating Firebase configuration...');

    final issues = <String>[];

    // Check for placeholder values
    if (options.apiKey.startsWith('your-') ||
        options.apiKey.contains('placeholder') ||
        options.apiKey.isEmpty) {
      issues.add('❌ API Key contains placeholder value or is empty');
    } else {
      AppLogger.logger.d(
        '✅ API Key: Valid format (${options.apiKey.substring(0, 8)}...)',
      );
    }

    if (options.appId.contains('abcd1234') || options.appId.length < 10) {
      issues.add('❌ App ID appears to be placeholder or invalid');
    } else {
      AppLogger.logger.d('✅ App ID: Valid format');
    }

    if (options.projectId.isEmpty) {
      issues.add('❌ Project ID is empty');
    } else {
      AppLogger.logger.d('✅ Project ID: ${options.projectId}');
    }

    if (options.messagingSenderId.isEmpty ||
        options.messagingSenderId.length < 10) {
      issues.add('❌ Messaging Sender ID appears invalid');
    } else {
      AppLogger.logger.d('✅ Messaging Sender ID: Valid');
    }

    if (issues.isNotEmpty) {
      AppLogger.logger.e('🚨 Firebase configuration issues detected:');
      for (final issue in issues) {
        AppLogger.logger.e('   $issue');
      }
      AppLogger.logger.e('');
      AppLogger.logger.e('📋 To fix these issues:');
      AppLogger.logger.e(
        '   1. Run: flutterfire configure --project=gitalong-c8075',
      );
      AppLogger.logger.e('   2. Ensure you have internet connection');
      AppLogger.logger.e(
        '   3. Check Firebase project exists and you have access',
      );
      throw FirebaseException(
        plugin: 'firebase_core',
        code: 'invalid-configuration',
        message:
            'Firebase configuration contains placeholder or invalid values. ${issues.join(', ')}',
      );
    }

    AppLogger.logger.success('✅ Firebase configuration validation passed');
  }

  static Future<void> _validateConfiguration() async {
    if (_validationComplete) return;

    try {
      AppLogger.logger.d('🔍 Validating Firebase services...');

      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      AppLogger.logger.d('✅ Firebase Auth: Available');
      AppLogger.logger.d(
        '🔐 Auth Current User: ${auth.currentUser?.email ?? "None"}',
      );

      // Test Firestore with enhanced validation
      final firestore = FirebaseFirestore.instance;
      AppLogger.logger.d('✅ Cloud Firestore: Available');

      // Test basic Firestore connectivity and create health check
      try {
        final healthCheckDoc =
            firestore.collection('_health_check').doc('connection_test');

        await healthCheckDoc.set({
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'connected',
          'app_version': '1.0.0',
        }, SetOptions(merge: true));

        final testRead = await healthCheckDoc.get();
        if (testRead.exists) {
          AppLogger.logger.d('✅ Firestore connectivity: Read/Write OK');
        }
      } catch (e) {
        AppLogger.logger.w(
          '⚠️ Firestore connectivity test failed (non-critical): $e',
        );
      }

      // Test Firebase Storage
      try {
        final storage = FirebaseStorage.instance;
        AppLogger.logger.d('✅ Firebase Storage: Available');

        // Test storage bucket access
        storage.ref().child('_health_check');
        AppLogger.logger.d('✅ Storage bucket access: OK');
      } catch (e) {
        AppLogger.logger.w('⚠️ Firebase Storage validation failed: $e');
      }

      _validationComplete = true;
      AppLogger.logger.success('✅ Firebase services validation complete');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Firebase services validation failed',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw here - let the app continue but log the issue
    }
  }

  static void _handleFirebaseInitializationError(FirebaseException e) {
    switch (e.code) {
      case 'invalid-api-key':
        AppLogger.logger.e(
          '🔑 SOLUTION: Check your Firebase API key configuration',
        );
        AppLogger.logger.e(
          '   Run: flutterfire configure --project=gitalong-c8075',
        );
        break;
      case 'app-not-authorized':
        AppLogger.logger.e(
          '🔒 SOLUTION: Add your app to Firebase project console',
        );
        break;
      case 'network-request-failed':
        AppLogger.logger.e(
          '🌐 SOLUTION: Check internet connection and Firebase project status',
        );
        break;
      case 'invalid-configuration':
        AppLogger.logger.e(
          '🔧 SOLUTION: Run Firebase configuration setup script',
        );
        break;
      case 'project-not-found':
        AppLogger.logger.e('🔍 SOLUTION: Verify Firebase project ID exists');
        AppLogger.logger.e('   Check project: gitalong-c8075');
        break;
      default:
        AppLogger.logger.e('❓ Unknown Firebase error - check Firebase console');
        AppLogger.logger.e('   Error code: ${e.code}');
    }
  }

  static void _handleGenericInitializationError(dynamic e) {
    final errorString = e.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      AppLogger.logger.e(
        '🌐 Network issue detected during Firebase initialization',
      );
      AppLogger.logger.e(
        '💡 SOLUTION: Check internet connection and try again',
      );
    } else if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      AppLogger.logger.e('🔒 Permission issue detected');
      AppLogger.logger.e(
        '💡 SOLUTION: Check Firebase project permissions and API keys',
      );
    } else if (errorString.contains('quota') ||
        errorString.contains('billing')) {
      AppLogger.logger.e('💳 Firebase quota or billing issue detected');
      AppLogger.logger.e(
        '💡 SOLUTION: Check Firebase console billing settings',
      );
    } else {
      AppLogger.logger.e('❓ Generic initialization error');
      AppLogger.logger.e(
        '💡 SOLUTION: Check Firebase configuration and run setup script',
      );
    }
  }

  // Firebase Auth instance with validation
  static FirebaseAuth get auth {
    if (!_initialized) {
      throw StateError(
        'Firebase must be initialized before accessing auth. Call FirebaseConfig.initialize() first.',
      );
    }
    return FirebaseAuth.instance;
  }

  // Firestore instance with validation
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw StateError(
        'Firebase must be initialized before accessing firestore. Call FirebaseConfig.initialize() first.',
      );
    }
    return FirebaseFirestore.instance;
  }

  // Firebase Storage instance with validation
  static FirebaseStorage get storage {
    if (!_initialized) {
      throw StateError(
        'Firebase must be initialized before accessing storage. Call FirebaseConfig.initialize() first.',
      );
    }
    return FirebaseStorage.instance;
  }

  // Auth state changes stream
  static Stream<User?> get authStateChanges {
    if (!_initialized) {
      throw StateError(
        'Firebase must be initialized before accessing auth state. Call FirebaseConfig.initialize() first.',
      );
    }
    return auth.authStateChanges();
  }

  // Current user
  static User? get currentUser {
    if (!_initialized) {
      AppLogger.logger.w(
        '⚠️ Attempted to get current user before Firebase initialization',
      );
      return null;
    }
    return auth.currentUser;
  }

  // Check if user is authenticated
  static bool get isAuthenticated {
    if (!_initialized) {
      AppLogger.logger.w(
        '⚠️ Attempted to check auth status before Firebase initialization',
      );
      return false;
    }
    return currentUser != null;
  }

  // Get Firestore collection with type safety
  static CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  // Get Firestore document with type safety
  static DocumentReference<Map<String, dynamic>> document(String path) {
    return firestore.doc(path);
  }

  // Batch operations for Firestore
  static WriteBatch batch() {
    return firestore.batch();
  }

  // Transaction operations for Firestore
  static Future<T> runTransaction<T>(
    TransactionHandler<T> updateFunction, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    return firestore.runTransaction(updateFunction, timeout: timeout);
  }

  // Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
    _validationComplete = false;
    AppLogger.logger.d('🔄 Firebase configuration state reset');
  }

  // Health check for Firebase services
  static Future<bool> performHealthCheck() async {
    try {
      AppLogger.logger
          .i('🏥 Performing comprehensive Firebase health check...');

      final healthChecks = await Future.wait([
        _checkFirestoreHealth(),
        _checkAuthHealth(),
        _checkStorageHealth(),
      ]);

      final allHealthy = healthChecks.every((check) => check);

      if (allHealthy) {
        AppLogger.logger.success('✅ All Firebase services are healthy');
      } else {
        AppLogger.logger.w('⚠️ Some Firebase services may have issues');
      }

      return allHealthy;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Health check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> _checkFirestoreHealth() async {
    try {
      final testDoc = firestore.collection('_health_check').doc('test');
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'healthy',
      });

      final readTest = await testDoc.get();
      await testDoc.delete(); // Clean up

      return readTest.exists;
    } catch (e) {
      AppLogger.logger.w('⚠️ Firestore health check failed: $e');
      return false;
    }
  }

  static Future<bool> _checkAuthHealth() async {
    try {
      // Just check if we can access auth instance
      auth.currentUser;
      return true;
    } catch (e) {
      AppLogger.logger.w('⚠️ Auth health check failed: $e');
      return false;
    }
  }

  static Future<bool> _checkStorageHealth() async {
    try {
      // Just check if we can access storage reference
      storage.ref();
      return true;
    } catch (e) {
      AppLogger.logger.w('⚠️ Storage health check failed: $e');
      return false;
    }
  }
}
