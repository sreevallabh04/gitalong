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
          'FirebaseConfig.initialize() called - _initialized: $_initialized');

      // Check if Firebase is already initialized
      if (_initialized) {
        AppLogger.logger.d('✅ Firebase already initialized, skipping...');
        return;
      }

      // Check if Firebase apps already exist
      if (Firebase.apps.isNotEmpty) {
        AppLogger.logger
            .d('✅ Firebase apps already exist: ${Firebase.apps.length}');
        AppLogger.logger.d(
            'Existing apps: ${Firebase.apps.map((app) => app.name).toList()}');
        _initialized = true;
        await _validateConfiguration();
        return;
      }

      AppLogger.logger.i('🔧 Initializing Firebase with options...');

      // Validate configuration before initialization
      final options = DefaultFirebaseOptions.currentPlatform;
      await _validateFirebaseOptions(options);

      // Initialize Firebase
      await Firebase.initializeApp(
        options: options,
      );

      _initialized = true;
      AppLogger.logger.i('✅ Firebase initialized successfully');

      // Validate Firebase services after initialization
      await _validateConfiguration();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logger.e('🔥 Firebase Exception during initialization',
          error: e, stackTrace: stackTrace);
      AppLogger.logger.e('Firebase Error Code: ${e.code}');
      AppLogger.logger.e('Firebase Error Message: ${e.message}');

      // Handle duplicate app error gracefully
      if (e.code == 'duplicate-app') {
        AppLogger.logger.w(
            '⚠️ Duplicate app error - treating as successful initialization');
        _initialized = true;
        await _validateConfiguration();
        return;
      }

      // Provide actionable error messages for common issues
      _handleFirebaseInitializationError(e);
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.logger.e('❌ Unexpected error during Firebase initialization',
          error: e, stackTrace: stackTrace);
      _handleGenericInitializationError(e);
      rethrow;
    }
  }

  static Future<void> _validateFirebaseOptions(FirebaseOptions options) async {
    AppLogger.logger.d('🔍 Validating Firebase configuration...');

    final issues = <String>[];

    // Check for placeholder values
    if (options.apiKey.startsWith('your-') ||
        options.apiKey.contains('placeholder')) {
      issues.add('❌ API Key contains placeholder value');
    } else {
      AppLogger.logger.d('✅ API Key: Valid format');
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
      AppLogger.logger.e('   1. Run: dart scripts/setup_firebase.dart');
      AppLogger.logger.e('   2. Follow the Firebase setup guide');
      AppLogger.logger
          .e('   3. Ensure google-services.json is properly configured');
      throw FirebaseException(
        plugin: 'firebase_core',
        code: 'invalid-configuration',
        message:
            'Firebase configuration contains placeholder or invalid values. ${issues.join(', ')}',
      );
    }

    AppLogger.logger.i('✅ Firebase configuration validation passed');
  }

  static Future<void> _validateConfiguration() async {
    if (_validationComplete) return;

    try {
      AppLogger.logger.d('🔍 Validating Firebase services...');

      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      AppLogger.logger.d('✅ Firebase Auth: Available');
      AppLogger.logger
          .d('🔐 Auth Current User: ${auth.currentUser?.email ?? "None"}');

      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      AppLogger.logger.d('✅ Cloud Firestore: Available');

      // Test basic Firestore connectivity (non-blocking)
      try {
        final testDoc = firestore.collection('_health_check').doc('test');
        await testDoc.get().timeout(const Duration(seconds: 5));
        AppLogger.logger.d('✅ Firestore connectivity: OK');
      } catch (e) {
        AppLogger.logger
            .w('⚠️ Firestore connectivity test failed (non-critical): $e');
      }

      // Test Firebase Storage
      try {
        FirebaseStorage.instance;
        AppLogger.logger.d('✅ Firebase Storage: Available');
      } catch (e) {
        AppLogger.logger.w('⚠️ Firebase Storage validation failed: $e');
      }

      _validationComplete = true;
      AppLogger.logger.i('✅ Firebase services validation complete');
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
        AppLogger.logger
            .e('🔑 SOLUTION: Check your Firebase API key configuration');
        break;
      case 'app-not-authorized':
        AppLogger.logger
            .e('🔒 SOLUTION: Add your app to Firebase project console');
        break;
      case 'network-request-failed':
        AppLogger.logger.e(
            '🌐 SOLUTION: Check internet connection and Firebase project status');
        break;
      case 'invalid-configuration':
        AppLogger.logger
            .e('🔧 SOLUTION: Run Firebase configuration setup script');
        break;
      default:
        AppLogger.logger.e('❓ Unknown Firebase error - check Firebase console');
    }
  }

  static void _handleGenericInitializationError(dynamic e) {
    final errorString = e.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      AppLogger.logger
          .e('🌐 Network issue detected during Firebase initialization');
      AppLogger.logger
          .e('💡 SOLUTION: Check internet connection and try again');
    } else if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      AppLogger.logger.e('🔒 Permission issue detected');
      AppLogger.logger
          .e('💡 SOLUTION: Check Firebase project permissions and API keys');
    } else {
      AppLogger.logger.e('❓ Generic initialization error');
      AppLogger.logger
          .e('💡 SOLUTION: Check Firebase configuration and run setup script');
    }
  }

  // Firebase Auth instance
  static FirebaseAuth get auth {
    if (!_initialized) {
      throw StateError('Firebase must be initialized before accessing auth');
    }
    return FirebaseAuth.instance;
  }

  // Firestore instance
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw StateError(
          'Firebase must be initialized before accessing firestore');
    }
    return FirebaseFirestore.instance;
  }

  // Firebase Storage instance
  static FirebaseStorage get storage {
    if (!_initialized) {
      throw StateError('Firebase must be initialized before accessing storage');
    }
    return FirebaseStorage.instance;
  }

  // Auth state changes stream
  static Stream<User?> get authStateChanges {
    if (!_initialized) {
      throw StateError(
          'Firebase must be initialized before accessing auth state');
    }
    return auth.authStateChanges();
  }

  // Current user
  static User? get currentUser {
    if (!_initialized) {
      AppLogger.logger
          .w('⚠️ Attempted to get current user before Firebase initialization');
      return null;
    }
    return auth.currentUser;
  }

  // Check if user is authenticated
  static bool get isAuthenticated {
    if (!_initialized) {
      AppLogger.logger.w(
          '⚠️ Attempted to check auth status before Firebase initialization');
      return false;
    }
    return currentUser != null;
  }

  // Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
    _validationComplete = false;
    AppLogger.logger.d('🔄 Firebase configuration state reset');
  }
}
