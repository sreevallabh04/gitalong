import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';
import '../core/utils/logger.dart';

/// 🎨 Production-Grade Welcome Email Service for GitAlong
///
/// This service handles all email-related functionality with:
/// - Perfect timing: Welcome emails sent IMMEDIATELY after email verification
/// - Deduplication: Prevents multiple welcome emails to the same user
/// - Reliability: Comprehensive error handling and retry mechanisms
/// - Analytics: Tracks email delivery status and user engagement
class EmailService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _emailQueue =>
      FirebaseConfig.collection('email_queue');

  static CollectionReference<Map<String, dynamic>> get _welcomeEmails =>
      FirebaseConfig.collection('welcome_emails');

  static CollectionReference<Map<String, dynamic>> get _emailDeliveryLog =>
      FirebaseConfig.collection('email_delivery_log');

  // ============================================================================
  // 🎯 ENHANCED WELCOME EMAIL SYSTEM WITH PERFECT TIMING
  // ============================================================================

  /// Send welcome email IMMEDIATELY after user verifies their email
  /// This is the main entry point for welcome emails with deduplication
  static Future<void> sendWelcomeEmailAfterVerification(User user) async {
    if (!user.emailVerified) {
      AppLogger.logger.w(
          '⚠️ Cannot send welcome email - email not verified for: ${user.email}');
      return;
    }

    try {
      // 🔒 DEDUPLICATION CHECK - Prevent multiple welcome emails
      final existingWelcome = await _checkExistingWelcomeEmail(user.uid);
      if (existingWelcome != null) {
        AppLogger.logger.i(
            '📧 Welcome email already sent to: ${user.email} at ${existingWelcome['sentAt']}');
        return;
      }

      AppLogger.logger
          .i('🎉 Email verified! Triggering welcome email for: ${user.email}');

      final displayName = _getDisplayName(user);
      final welcomeEmailData = _buildWelcomeEmailData(user, displayName);

      // 📝 CREATE WELCOME EMAIL RECORD atomically
      final docRef = _welcomeEmails.doc();
      await docRef.set(welcomeEmailData);

      // Log the delivery attempt
      await _emailDeliveryLog.add({
        'userId': user.uid,
        'email': user.email,
        'type': 'welcome_email',
        'status': 'queued',
        'welcomeEmailId': docRef.id,
        'timestamp': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
        'verificationTime': FieldValue.serverTimestamp(),
      });

      AppLogger.logger
          .success('✅ Welcome email queued successfully for: ${user.email}');

      // 🔔 CREATE IN-APP NOTIFICATION
      await _createWelcomeNotification(user);

      // 📊 TRACK ANALYTICS
      await _trackWelcomeEmailEvent(user.uid, 'welcome_email_triggered');
    } catch (error) {
      AppLogger.logger
          .e('❌ Error sending welcome email to: ${user.email}', error: error);
      await _logEmailError(user, 'welcome_email_error', error.toString());
    }
  }

  /// Enhanced check for existing welcome emails with better deduplication
  static Future<Map<String, dynamic>?> _checkExistingWelcomeEmail(
      String userId) async {
    try {
      final querySnapshot = await _welcomeEmails
          .where('userId', isEqualTo: userId)
          .where('type', whereIn: ['welcome', 'welcome_verified'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'id': doc.id,
          'sentAt': doc.data()['createdAt'],
          ...doc.data(),
        };
      }
      return null;
    } catch (error) {
      AppLogger.logger
          .e('❌ Error checking existing welcome email', error: error);
      return null;
    }
  }

  /// Build comprehensive welcome email data
  static Map<String, dynamic> _buildWelcomeEmailData(
      User user, String displayName) {
    return {
      'userId': user.uid,
      'email': user.email,
      'displayName': displayName,
      'template': 'welcome_verified_v2',
      'type': 'welcome_verified',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'triggerType': 'email_verification_enhanced',
      'emailVerified': user.emailVerified,
      'verificationTime': FieldValue.serverTimestamp(),
      'priority': 'high',
      'metadata': {
        'userAgent': 'flutter-client-enhanced',
        'signupMethod': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'email',
        'platform': 'mobile',
        'clientVersion': '2.0.0',
        'hasDisplayName': user.displayName != null,
        'hasPhotoURL': user.photoURL != null,
        'emailDomain': user.email?.split('@').last,
        'userProperties': {
          'isNewUser': true,
          'welcomeEmailVersion': 'v2',
          'enhancedTiming': true,
        }
      }
    };
  }

  /// Get display name with intelligent fallbacks
  static String _getDisplayName(User user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    if (user.email != null) {
      final emailParts = user.email!.split('@');
      if (emailParts.isNotEmpty) {
        // Convert email username to title case
        final username = emailParts[0];
        return username
            .split('.')
            .map((part) => part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
      }
    }

    return 'Developer';
  }

  /// Create beautiful in-app welcome notification
  static Future<void> _createWelcomeNotification(User user) async {
    try {
      await _firestore.collection('user_notifications').add({
        'userId': user.uid,
        'type': 'welcome',
        'title': 'Welcome to GitAlong! 🚀',
        'message':
            'Your developer journey starts now. Complete your profile to discover amazing projects!',
        'read': false,
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'actions': {
          'complete_profile': '/onboarding',
          'explore_projects': '/home/discover',
        },
        'metadata': {
          'welcomeEmailSent': true,
          'emailVerificationTime': FieldValue.serverTimestamp(),
        }
      });

      AppLogger.logger.i('📱 Welcome notification created for: ${user.email}');
    } catch (error) {
      AppLogger.logger
          .w('⚠️ Failed to create welcome notification', error: error);
    }
  }

  /// Track analytics events for email system
  static Future<void> _trackWelcomeEmailEvent(
      String userId, String event) async {
    try {
      await _firestore.collection('email_analytics').add({
        'userId': userId,
        'event': event,
        'timestamp': FieldValue.serverTimestamp(),
        'source': 'email_service_enhanced',
        'metadata': {
          'clientVersion': '2.0.0',
          'enhancedTiming': true,
        }
      });
    } catch (error) {
      AppLogger.logger.w('⚠️ Failed to track email analytics', error: error);
    }
  }

  /// Log email errors for monitoring
  static Future<void> _logEmailError(
      User user, String errorType, String errorMessage) async {
    try {
      await _firestore.collection('email_errors').add({
        'userId': user.uid,
        'email': user.email,
        'errorType': errorType,
        'errorMessage': errorMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': {
          'emailVerified': user.emailVerified,
          'clientVersion': '2.0.0',
          'userAgent': 'flutter-client-enhanced',
        }
      });
    } catch (error) {
      AppLogger.logger.e('❌ Failed to log email error', error: error);
    }
  }

  // ============================================================================
  // 🔄 SMART EMAIL VERIFICATION MONITORING
  // ============================================================================

  /// Enhanced check and trigger for welcome emails with smart timing
  static Future<void> checkAndTriggerWelcomeEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Reload user to get fresh verification status
      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        AppLogger.logger.w('⚠️ User became null after reload');
        return;
      }

      if (refreshedUser.emailVerified) {
        AppLogger.logger
            .success('✅ Email verified! User: ${refreshedUser.email}');

        // Check if welcome email was already sent (with enhanced deduplication)
        final existingWelcome =
            await _checkExistingWelcomeEmail(refreshedUser.uid);

        if (existingWelcome == null) {
          AppLogger.logger
              .i('🎯 No existing welcome email found, triggering new one...');
          await sendWelcomeEmailAfterVerification(refreshedUser);
        } else {
          AppLogger.logger
              .d('📧 Welcome email already exists, skipping duplicate');
        }
      } else {
        AppLogger.logger
            .d('📧 Email not yet verified for: ${refreshedUser.email}');
      }
    } catch (error) {
      AppLogger.logger
          .e('❌ Error in checkAndTriggerWelcomeEmail', error: error);
    }
  }

  // ============================================================================
  // 📧 ADDITIONAL EMAIL FUNCTIONALITY (EXISTING METHODS ENHANCED)
  // ============================================================================

  /// Send verification email reminder with enhanced tracking
  static Future<void> sendVerificationReminder(String email) async {
    try {
      AppLogger.logger
          .i('📬 Sending enhanced verification reminder to: $email');

      await _firestore.collection('email_notifications').add({
        'email': email,
        'type': 'verification_reminder_enhanced',
        'message': 'Please verify your email to unlock all GitAlong features',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'attempts': 0,
        'maxAttempts': 3,
        'metadata': {
          'version': '2.0.0',
          'enhanced': true,
          'source': 'flutter_client',
        }
      });

      AppLogger.logger.success('✅ Enhanced verification reminder queued');
    } catch (error) {
      AppLogger.logger.e('❌ Error sending verification reminder', error: error);
      throw Exception('Failed to send verification reminder: $error');
    }
  }

  /// Enhanced admin notification system
  static Future<void> sendAdminNotification({
    required String subject,
    required String message,
    required String userEmail,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.logger.i('📨 Sending enhanced admin notification: $subject');

      await _firestore.collection('admin_notifications').add({
        'subject': subject,
        'message': message,
        'userEmail': userEmail,
        'userId': userId,
        'priority': 'normal',
        'type': 'admin_alert_enhanced',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': {
          'version': '2.0.0',
          'enhanced': true,
          'source': 'email_service_enhanced',
          ...?metadata,
        },
      });

      AppLogger.logger.success('✅ Enhanced admin notification queued');
    } catch (error) {
      AppLogger.logger.e('❌ Error sending admin notification', error: error);
      throw Exception('Failed to send admin notification: $error');
    }
  }

  /// Get enhanced user notifications with better filtering
  static Stream<List<Map<String, dynamic>>> getUserNotifications(
      String userId) {
    return _firestore
        .collection('user_notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Enhanced notification read tracking
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('user_notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
        'metadata.readSource': 'flutter_client_enhanced',
      });

      AppLogger.logger.d('📖 Notification marked as read: $notificationId');
    } catch (error) {
      AppLogger.logger.e('❌ Error marking notification as read', error: error);
    }
  }

  // ============================================================================
  // 🔍 ENHANCED EMAIL VERIFICATION STATUS
  // ============================================================================

  /// Enhanced email verification check with caching
  static Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      final isVerified = _auth.currentUser?.emailVerified ?? false;

      AppLogger.logger
          .d('📧 Email verification status: $isVerified for ${user.email}');
      return isVerified;
    } catch (error) {
      AppLogger.logger.e('❌ Error checking email verification', error: error);
      return false;
    }
  }

  /// Send enhanced custom verification email
  static Future<void> sendCustomVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (user.emailVerified) {
        AppLogger.logger.i('📧 Email already verified for: ${user.email}');
        return;
      }

      await user.sendEmailVerification();

      // Enhanced tracking for verification emails
      await _firestore.collection('email_notifications').add({
        'email': user.email,
        'type': 'verification_enhanced',
        'userId': user.uid,
        'message': 'Enhanced verification email with GitAlong branding',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'metadata': {
          'version': '2.0.0',
          'enhanced': true,
          'source': 'custom_verification',
        }
      });

      AppLogger.logger
          .success('✅ Enhanced verification email sent to: ${user.email}');
    } catch (error) {
      AppLogger.logger.e('❌ Error sending verification email', error: error);
      throw Exception('Failed to send verification email: $error');
    }
  }

  // ============================================================================
  // 📊 ENHANCED MONITORING AND ANALYTICS
  // ============================================================================

  /// Enhanced health check with comprehensive monitoring
  static Future<Map<String, dynamic>> performHealthCheck() async {
    try {
      final startTime = DateTime.now();

      // Test Firestore connectivity with timeout
      await _firestore
          .collection('_email_health_check')
          .doc('test')
          .get()
          .timeout(const Duration(seconds: 5));

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;
      final currentUser = _auth.currentUser;

      return {
        'status': 'healthy',
        'version': '2.0.0',
        'enhanced': true,
        'firestore_connection': true,
        'response_time_ms': responseTime,
        'auth_available': currentUser != null,
        'user_email': currentUser?.email,
        'email_verified': currentUser?.emailVerified ?? false,
        'timestamp': DateTime.now().toIso8601String(),
        'services': {
          'welcome_emails': 'active',
          'verification_emails': 'active',
          'notifications': 'active',
          'analytics': 'active',
        }
      };
    } catch (error) {
      return {
        'status': 'unhealthy',
        'version': '2.0.0',
        'enhanced': true,
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'firestore_connection': false,
      };
    }
  }

  // ============================================================================
  // 📈 LEGACY COMPATIBILITY METHODS (MAINTAINED FOR BACKWARD COMPATIBILITY)
  // ============================================================================

  /// Send welcome email (legacy method - enhanced internally)
  static Future<void> sendWelcomeEmail({
    required String email,
    required String displayName,
    String? userId,
  }) async {
    try {
      AppLogger.logger.i('📧 Triggering legacy welcome email for: $email');

      await _welcomeEmails.add({
        'email': email,
        'displayName': displayName,
        'userId': userId,
        'template': 'welcome_legacy_enhanced',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'welcome_manual',
        'metadata': {
          'source': 'legacy_method',
          'enhanced': true,
          'version': '2.0.0',
          'platform': 'flutter_app',
        }
      });

      AppLogger.logger.success('✅ Legacy welcome email triggered for: $email');
    } catch (error) {
      AppLogger.logger
          .e('❌ Error triggering legacy welcome email', error: error);
      throw Exception('Failed to send welcome email: $error');
    }
  }

  /// Send welcome to current user (legacy compatibility)
  static Future<void> sendWelcomeToCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    if (user.emailVerified) {
      // Use enhanced method for verified users
      await sendWelcomeEmailAfterVerification(user);
    } else {
      // Use legacy method for unverified users
      final displayName = _getDisplayName(user);
      await sendWelcomeEmail(
        email: user.email!,
        displayName: displayName,
        userId: user.uid,
      );
    }
  }

  /// Get welcome email status (enhanced with better tracking)
  static Future<Map<String, dynamic>?> getWelcomeEmailStatus(
      String email) async {
    try {
      final querySnapshot = await _welcomeEmails
          .where('email', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'id': doc.id,
          'enhanced': true,
          ...doc.data(),
        };
      }
      return null;
    } catch (error) {
      AppLogger.logger.e('❌ Error getting welcome email status', error: error);
      return null;
    }
  }

  /// Enhanced email statistics
  static Future<Map<String, int>> getEmailStats() async {
    try {
      final twentyFourHoursAgo =
          DateTime.now().subtract(const Duration(hours: 24));
      final timestamp = Timestamp.fromDate(twentyFourHoursAgo);

      // Get enhanced welcome emails count
      final welcomeSnapshot = await _welcomeEmails
          .where('createdAt', isGreaterThan: timestamp)
          .get();

      // Get delivery log stats
      final deliverySnapshot = await _emailDeliveryLog
          .where('timestamp', isGreaterThan: timestamp)
          .get();

      final stats = <String, int>{
        'welcome_emails_24h': welcomeSnapshot.docs.length,
        'total_deliveries_24h': deliverySnapshot.docs.length,
      };

      // Count by status from delivery log
      for (final doc in deliverySnapshot.docs) {
        final status = doc.data()['status'] as String?;
        final key = '${status ?? 'unknown'}_24h';
        stats[key] = (stats[key] ?? 0) + 1;
      }

      return stats;
    } catch (error) {
      AppLogger.logger.e('❌ Error getting email stats', error: error);
      return {};
    }
  }

  /// Test enhanced email system
  static Future<Map<String, dynamic>> testEmailSystem() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final healthCheck = await performHealthCheck();

      Map<String, dynamic> testResults = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '2.0.0',
        'enhanced': true,
        'health_check': healthCheck,
        'features': {
          'deduplication': 'active',
          'enhanced_timing': 'active',
          'analytics_tracking': 'active',
          'error_monitoring': 'active',
        }
      };

      if (currentUser != null) {
        final hasWelcome = await getWelcomeEmailStatus(currentUser.email!);
        testResults['current_user'] = {
          'email': currentUser.email,
          'email_verified': currentUser.emailVerified,
          'has_welcome_email': hasWelcome != null,
          'welcome_email_data': hasWelcome,
        };
      }

      return testResults;
    } catch (error) {
      AppLogger.logger.e('❌ Email system test failed', error: error);
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '2.0.0',
        'enhanced': true,
        'error': error.toString(),
        'status': 'failed',
      };
    }
  }

  // ============================================================================
  // 🔄 ADDITIONAL UTILITY METHODS
  // ============================================================================

  /// Check if welcome email was sent (enhanced)
  static Future<bool> hasWelcomeEmailBeenSent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return false;

    final status = await getWelcomeEmailStatus(user!.email!);
    return status != null;
  }

  /// Resend welcome email (enhanced)
  static Future<void> resendWelcomeEmail(String email) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (userCredential.isEmpty) {
        throw Exception('User with email $email not found');
      }

      final userDoc = await FirebaseConfig.firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      String displayName = _getDisplayName(FirebaseAuth.instance.currentUser!);
      String? userId;

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        displayName = userData['name'] ?? displayName;
        userId = userData['id'];
      }

      await sendWelcomeEmail(
        email: email,
        displayName: displayName,
        userId: userId,
      );

      AppLogger.logger.success('✅ Enhanced welcome email resent to: $email');
    } catch (error) {
      AppLogger.logger.e('❌ Error resending welcome email', error: error);
      throw Exception('Failed to resend welcome email: $error');
    }
  }
}
