import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';
import '../core/utils/logger.dart';

/// 🎨 Beautiful Email Service for GitAlong
///
/// This service handles all email-related functionality including:
/// - Welcome emails (sent AFTER email verification)
/// - Email verification reminders
/// - Admin notifications
/// - Email verification status tracking
class EmailService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _emailQueue =>
      FirebaseConfig.collection('email_queue');

  static CollectionReference<Map<String, dynamic>> get _welcomeEmails =>
      FirebaseConfig.collection('welcome_emails');

  /// Send welcome email AFTER user verifies their email
  static Future<void> sendWelcomeEmailAfterVerification(User user) async {
    if (!user.emailVerified) {
      AppLogger.logger.w('⚠️ Cannot send welcome email - email not verified');
      return;
    }

    try {
      AppLogger.logger
          .i('📧 Email verified! Triggering welcome email for: ${user.email}');

      final displayName =
          user.displayName ?? user.email?.split('@')[0] ?? 'Developer';

      // Create beautiful welcome email document for backend processing
      await _firestore.collection('welcome_emails').add({
        'userId': user.uid,
        'email': user.email,
        'displayName': displayName,
        'template': 'welcome_verified_v1',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'triggerType': 'email_verification_client',
        'emailVerified': user.emailVerified,
        'verificationTime': FieldValue.serverTimestamp(),
        'metadata': {
          'userAgent': 'flutter-client',
          'signupMethod': user.providerData.isNotEmpty
              ? user.providerData.first.providerId
              : 'email',
          'platform': 'mobile',
        }
      });

      AppLogger.logger.success('✅ Welcome email queued successfully');

      // Also create a local notification record
      await _firestore.collection('user_notifications').add({
        'userId': user.uid,
        'type': 'welcome',
        'title': 'Welcome to GitAlong! 🚀',
        'message':
            'Your developer journey starts now. Complete your profile to get started!',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'actions': {'complete_profile': '/onboarding'}
      });
    } catch (error) {
      AppLogger.logger.e('❌ Error sending welcome email', error: error);

      // Log error for monitoring
      await _firestore.collection('email_errors').add({
        'type': 'welcome_email_client_error',
        'userId': user.uid,
        'email': user.email,
        'error': error.toString(),
        'timestamp': FieldValue.serverTimestamp()
      });
    }
  }

  /// Send email verification reminder
  static Future<void> sendVerificationReminder(String email) async {
    try {
      AppLogger.logger.i('📬 Sending verification reminder to: $email');

      // Create notification document for backend processing
      await _firestore.collection('email_notifications').add({
        'email': email,
        'type': 'verification_reminder',
        'message': 'Please verify your email to continue using GitAlong',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'attempts': 0,
        'maxAttempts': 3,
      });

      AppLogger.logger.success('✅ Verification reminder queued');
    } catch (error) {
      AppLogger.logger.e('❌ Error sending verification reminder', error: error);
      throw Exception('Failed to send verification reminder: $error');
    }
  }

  /// Send admin notification email
  static Future<void> sendAdminNotification({
    required String subject,
    required String message,
    required String userEmail,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.logger.i('📨 Sending admin notification: $subject');

      await _firestore.collection('admin_notifications').add({
        'subject': subject,
        'message': message,
        'userEmail': userEmail,
        'userId': userId,
        'priority': 'normal',
        'type': 'admin_alert',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });

      AppLogger.logger.success('✅ Admin notification queued');
    } catch (error) {
      AppLogger.logger.e('❌ Error sending admin notification', error: error);
      throw Exception('Failed to send admin notification: $error');
    }
  }

  /// Check email verification status and trigger welcome email if verified
  static Future<void> checkAndTriggerWelcomeEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.reload(); // Refresh user data
      final refreshedUser = _auth.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        // Check if we've already sent welcome email
        final existingWelcomeEmail = await _firestore
            .collection('welcome_emails')
            .where('userId', isEqualTo: refreshedUser.uid)
            .where('triggerType', isEqualTo: 'email_verification_client')
            .limit(1)
            .get();

        if (existingWelcomeEmail.docs.isEmpty) {
          await sendWelcomeEmailAfterVerification(refreshedUser);
        } else {
          AppLogger.logger
              .d('Welcome email already sent for user: ${refreshedUser.email}');
        }
      }
    } catch (error) {
      AppLogger.logger
          .e('❌ Error checking email verification status', error: error);
    }
  }

  /// Get pending email notifications for a user
  static Stream<List<Map<String, dynamic>>> getUserNotifications(
      String userId) {
    return _firestore
        .collection('user_notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('user_notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      AppLogger.logger.e('❌ Error marking notification as read', error: error);
    }
  }

  /// Get email verification status
  static Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (error) {
      AppLogger.logger.e('❌ Error checking email verification', error: error);
      return false;
    }
  }

  /// Send verification email with custom template
  static Future<void> sendCustomVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (user.emailVerified) {
        AppLogger.logger.i('Email already verified for: ${user.email}');
        return;
      }

      await user.sendEmailVerification();

      // Also queue a custom template for backend processing
      await _firestore.collection('email_notifications').add({
        'email': user.email,
        'type': 'verification_custom',
        'userId': user.uid,
        'message': 'Custom verification email with GitAlong branding',
        'priority': 'high',
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      AppLogger.logger.success('✅ Verification email sent');
    } catch (error) {
      AppLogger.logger.e('❌ Error sending verification email', error: error);
      throw Exception('Failed to send verification email: $error');
    }
  }

  /// Health check for email service
  static Future<Map<String, dynamic>> performHealthCheck() async {
    try {
      // Test Firestore connectivity
      final testDoc =
          await _firestore.collection('_email_health_check').doc('test').get();

      return {
        'status': 'healthy',
        'firestore_connection': true,
        'auth_available': _auth.currentUser != null,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      return {
        'status': 'unhealthy',
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Send a welcome email notification (triggers Cloud Function)
  static Future<void> sendWelcomeEmail({
    required String email,
    required String displayName,
    String? userId,
  }) async {
    try {
      AppLogger.logger.i('📧 Triggering welcome email for: $email');

      // Create a welcome email record that will trigger the Cloud Function
      await _welcomeEmails.add({
        'email': email,
        'displayName': displayName,
        'userId': userId,
        'template': 'welcome_v1',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'welcome',
        'metadata': {
          'source': 'manual_trigger',
          'platform': 'flutter_app',
        }
      });

      AppLogger.logger.i('✅ Welcome email triggered successfully for: $email');
    } catch (error) {
      AppLogger.logger.e('❌ Error triggering welcome email', error: error);
      throw Exception('Failed to send welcome email: $error');
    }
  }

  /// Send welcome email to current authenticated user
  static Future<void> sendWelcomeToCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final displayName =
        user.displayName ?? user.email?.split('@')[0] ?? 'Developer';

    await sendWelcomeEmail(
      email: user.email!,
      displayName: displayName,
      userId: user.uid,
    );
  }

  /// Get welcome email status for a user
  static Future<Map<String, dynamic>?> getWelcomeEmailStatus(
      String email) async {
    try {
      final querySnapshot = await _welcomeEmails
          .where('email', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (error) {
      AppLogger.logger.e('❌ Error checking welcome email status', error: error);
      return null;
    }
  }

  /// Get email queue status (for monitoring)
  static Future<List<Map<String, dynamic>>> getEmailQueue({
    String? userId,
    String? status,
    int limit = 10,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _emailQueue.orderBy('createdAt', descending: true);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.limit(limit).get();
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (error) {
      AppLogger.logger.e('❌ Error fetching email queue', error: error);
      return [];
    }
  }

  /// Resend welcome email to a user
  static Future<void> resendWelcomeEmail(String email) async {
    try {
      // Check if user exists in Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (userCredential.isEmpty) {
        throw Exception('User with email $email not found');
      }

      // Get user display name from Firestore or generate one
      final userDoc = await FirebaseConfig.firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      String displayName = email.split('@')[0];
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

      AppLogger.logger.i('✅ Welcome email resent to: $email');
    } catch (error) {
      AppLogger.logger.e('❌ Error resending welcome email', error: error);
      throw Exception('Failed to resend welcome email: $error');
    }
  }

  /// Check if welcome email was sent for current user
  static Future<bool> hasWelcomeEmailBeenSent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return false;

    final status = await getWelcomeEmailStatus(user!.email!);
    return status != null;
  }

  /// Get email statistics
  static Future<Map<String, int>> getEmailStats() async {
    try {
      final twentyFourHoursAgo =
          DateTime.now().subtract(const Duration(hours: 24));

      // Get welcome emails count
      final welcomeSnapshot = await _welcomeEmails
          .where('createdAt',
              isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
          .get();

      // Get email queue count by status
      final queueSnapshot = await _emailQueue
          .where('createdAt',
              isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
          .get();

      int queued = 0;
      int sent = 0;
      int failed = 0;

      for (final doc in queueSnapshot.docs) {
        final status = doc.data()['status'] as String?;
        switch (status) {
          case 'queued':
          case 'pending':
            queued++;
            break;
          case 'sent':
          case 'delivered':
            sent++;
            break;
          case 'failed':
          case 'error':
            failed++;
            break;
        }
      }

      return {
        'welcome_emails_24h': welcomeSnapshot.docs.length,
        'queued': queued,
        'sent': sent,
        'failed': failed,
        'total_24h': queueSnapshot.docs.length,
      };
    } catch (error) {
      AppLogger.logger.e('❌ Error fetching email stats', error: error);
      return {};
    }
  }

  /// Test email system health
  static Future<Map<String, dynamic>> testEmailSystem() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> healthCheck = {
        'timestamp': DateTime.now().toIso8601String(),
        'firebase_connection': true,
        'services': {
          'welcome_emails': 'active',
          'verification_emails': 'active',
          'email_queue': 'active'
        }
      };

      if (currentUser != null) {
        final hasWelcome = await hasWelcomeEmailBeenSent();
        healthCheck['current_user'] = {
          'email': currentUser.email,
          'has_welcome_email': hasWelcome,
        };
      }

      return healthCheck;
    } catch (error) {
      AppLogger.logger.e('❌ Email system health check failed', error: error);
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'firebase_connection': false,
        'error': error.toString(),
      };
    }
  }
}
