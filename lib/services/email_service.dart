import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/logger.dart';
import '../core/utils/firestore_utils.dart';
import '../core/monitoring/analytics_service.dart';

/// Email service for sending various types of emails to users
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Email API configuration (using a mock service for demo)
  static const String _emailApiBaseUrl = 'https://api.emailjs.com/api/v1.0';
  static const String _serviceId = 'service_gitalong';
  static const String _templateId_welcome = 'template_welcome';
  static const String _templateId_verification = 'template_verification';
  static const String _templateId_notification = 'template_notification';
  static const String _publicKey =
      'your_emailjs_public_key'; // Replace with actual key

  /// Send welcome email to new user
  Future<bool> sendWelcomeEmail({
    required String userEmail,
    required String userName,
    required String userId,
    bool isEmailVerified = false,
  }) async {
    try {
      AppLogger.logger.i('📧 Sending welcome email to: $userEmail');

      // Record email attempt
      await _recordEmailAttempt(
        userId: userId,
        email: userEmail,
        type: isEmailVerified ? 'welcome_verified' : 'welcome',
        status: 'sending',
      );

      // Choose template based on verification status
      final templateId =
          isEmailVerified ? _templateId_welcome : _templateId_verification;

      final emailData = {
        'service_id': _serviceId,
        'template_id': templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_name': userName,
          'to_email': userEmail,
          'user_name': userName,
          'app_name': 'GitAlong',
          'verification_status': isEmailVerified ? 'verified' : 'pending',
          'dashboard_url': 'https://gitalong.app/dashboard',
          'support_email': 'support@gitalong.app',
          'year': DateTime.now().year.toString(),
        },
      };

      // For demo purposes, we'll simulate the email sending
      // In production, replace this with actual email service integration
      final success = await _sendEmailViaService(emailData);

      if (success) {
        // Record successful email
        await _recordEmailSuccess(
          userId: userId,
          email: userEmail,
          type: isEmailVerified ? 'welcome_verified' : 'welcome',
        );

        // Track analytics
        await AnalyticsService.trackCustomEvent(
          eventName: 'welcome_email_sent',
          parameters: {
            'user_id': userId,
            'email': userEmail,
            'verification_status': isEmailVerified ? 'verified' : 'pending',
          },
        );

        AppLogger.logger
            .success('✅ Welcome email sent successfully to: $userEmail');
        return true;
      } else {
        throw Exception('Email service returned failure');
      }
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to send welcome email',
          error: error, stackTrace: stackTrace);

      // Record email failure
      await _recordEmailFailure(
        userId: userId,
        email: userEmail,
        type: isEmailVerified ? 'welcome_verified' : 'welcome',
        error: error.toString(),
      );

      return false;
    }
  }

  /// Send email verification reminder
  Future<bool> sendVerificationReminder({
    required String userEmail,
    required String userName,
    required String userId,
  }) async {
    try {
      AppLogger.logger.i('📧 Sending verification reminder to: $userEmail');

      final emailData = {
        'service_id': _serviceId,
        'template_id': _templateId_verification,
        'user_id': _publicKey,
        'template_params': {
          'to_name': userName,
          'to_email': userEmail,
          'user_name': userName,
          'app_name': 'GitAlong',
          'verification_url': 'https://gitalong.app/verify-email',
          'support_email': 'support@gitalong.app',
          'reminder_type': 'verification_reminder',
        },
      };

      final success = await _sendEmailViaService(emailData);

      if (success) {
        await _recordEmailSuccess(
          userId: userId,
          email: userEmail,
          type: 'verification_reminder',
        );

        AppLogger.logger.success('✅ Verification reminder sent to: $userEmail');
        return true;
      } else {
        throw Exception('Email service returned failure');
      }
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to send verification reminder',
          error: error, stackTrace: stackTrace);

      await _recordEmailFailure(
        userId: userId,
        email: userEmail,
        type: 'verification_reminder',
        error: error.toString(),
      );

      return false;
    }
  }

  /// Send notification email
  Future<bool> sendNotificationEmail({
    required String userEmail,
    required String userName,
    required String userId,
    required String subject,
    required String message,
    String? actionUrl,
    String? actionLabel,
  }) async {
    try {
      AppLogger.logger.i('📧 Sending notification email to: $userEmail');

      final emailData = {
        'service_id': _serviceId,
        'template_id': _templateId_notification,
        'user_id': _publicKey,
        'template_params': {
          'to_name': userName,
          'to_email': userEmail,
          'subject': subject,
          'message': message,
          'action_url': actionUrl ?? '',
          'action_label': actionLabel ?? '',
          'app_name': 'GitAlong',
          'support_email': 'support@gitalong.app',
        },
      };

      final success = await _sendEmailViaService(emailData);

      if (success) {
        await _recordEmailSuccess(
          userId: userId,
          email: userEmail,
          type: 'notification',
        );

        await AnalyticsService.trackCustomEvent(
          eventName: 'notification_email_sent',
          parameters: {
            'user_id': userId,
            'subject': subject,
          },
        );

        AppLogger.logger.success('✅ Notification email sent to: $userEmail');
        return true;
      } else {
        throw Exception('Email service returned failure');
      }
    } catch (error, stackTrace) {
      AppLogger.logger.e('❌ Failed to send notification email',
          error: error, stackTrace: stackTrace);

      await _recordEmailFailure(
        userId: userId,
        email: userEmail,
        type: 'notification',
        error: error.toString(),
      );

      return false;
    }
  }

  /// Send welcome email automatically when user verifies email
  Future<void> handleUserEmailVerification(User user) async {
    try {
      if (user.emailVerified && user.email != null) {
        // Check if we already sent a welcome email
        final alreadySent = await _hasWelcomeEmailBeenSent(user.uid);

        if (!alreadySent) {
          await sendWelcomeEmail(
            userEmail: user.email!,
            userName: user.displayName ?? 'User',
            userId: user.uid,
            isEmailVerified: true,
          );
        }
      }
    } catch (error) {
      AppLogger.logger.e('❌ Failed to handle email verification', error: error);
    }
  }

  /// Check if welcome email has been sent
  Future<bool> _hasWelcomeEmailBeenSent(String userId) async {
    try {
      final querySnapshot = await safeQuery(() async {
        return await FirebaseFirestore.instance
            .collection('welcome_emails')
            .where('user_id', isEqualTo: userId)
          .where('type', whereIn: ['welcome', 'welcome_verified'])
            .where('status', isEqualTo: 'sent')
          .limit(1)
          .get();
      });

      return querySnapshot?.docs.isNotEmpty ?? false;
    } catch (error) {
      AppLogger.logger
          .e('❌ Failed to check welcome email status', error: error);
      return false;
    }
  }

  /// Mock email sending service (replace with actual service)
  Future<bool> _sendEmailViaService(Map<String, dynamic> emailData) async {
    try {
      // For demo purposes, we'll simulate email sending
      // In production, integrate with EmailJS, SendGrid, or another service

      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate API call

      // Simulate 95% success rate
      final random = DateTime.now().millisecond;
      final success = random % 20 != 0; // 95% success rate

      if (success) {
        AppLogger.logger.d('📧 Email sent successfully (simulated)');
        return true;
      } else {
        throw Exception('Simulated email service failure');
      }

      /* 
      // Actual EmailJS implementation:
      final response = await http.post(
        Uri.parse('$_emailApiBaseUrl/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      */
    } catch (error) {
      AppLogger.logger.e('❌ Email service error', error: error);
      return false;
    }
  }

  /// Record email attempt in Firestore
  Future<void> _recordEmailAttempt({
    required String userId,
    required String email,
    required String type,
    required String status,
  }) async {
    try {
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('welcome_emails').add({
          'user_id': userId,
          'email': email,
          'type': type,
          'status': status,
          'attempted_at': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      AppLogger.logger.e('❌ Failed to record email attempt', error: error);
    }
  }

  /// Record successful email
  Future<void> _recordEmailSuccess({
    required String userId,
    required String email,
    required String type,
  }) async {
    try {
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('welcome_emails').add({
          'user_id': userId,
          'email': email,
          'type': type,
          'status': 'sent',
          'sent_at': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
        });
      });

      // Also record in analytics
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('email_analytics').add({
          'user_id': userId,
          'email_type': type,
          'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      AppLogger.logger.e('❌ Failed to record email success', error: error);
    }
  }

  /// Record email failure
  Future<void> _recordEmailFailure({
    required String userId,
    required String email,
    required String type,
    required String error,
  }) async {
    try {
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('email_errors').add({
          'user_id': userId,
          'email': email,
          'type': type,
          'status': 'failed',
          'error': error,
          'failed_at': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
        });
      });

      // Also record in analytics
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('email_analytics').add({
          'user_id': userId,
          'email_type': type,
          'status': 'failure',
          'error': error,
        'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      AppLogger.logger.e('❌ Failed to record email failure', error: error);
    }
  }

  /// Get email analytics for user
  Future<EmailAnalytics> getEmailAnalytics(String userId) async {
    try {
      final analytics = await safeQuery(() async {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('email_analytics')
            .where('user_id', isEqualTo: userId)
            .get();

        int totalSent = 0;
        int totalFailed = 0;
        int welcomeEmails = 0;
        int notificationEmails = 0;

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          final status = data['status'] as String;
          final type = data['email_type'] as String;

          if (status == 'success') {
            totalSent++;
          } else if (status == 'failure') {
            totalFailed++;
          }

          if (type.contains('welcome')) {
            welcomeEmails++;
          } else if (type == 'notification') {
            notificationEmails++;
          }
        }

        return EmailAnalytics(
          totalSent: totalSent,
          totalFailed: totalFailed,
          welcomeEmails: welcomeEmails,
          notificationEmails: notificationEmails,
          successRate: totalSent + totalFailed > 0
              ? totalSent / (totalSent + totalFailed)
              : 0.0,
        );
      });

      return analytics ?? EmailAnalytics.empty();
    } catch (error) {
      AppLogger.logger.e('❌ Failed to get email analytics', error: error);
      return EmailAnalytics.empty();
    }
  }

  /// Send welcome email after user verifies their email
  static Future<void> sendWelcomeEmailAfterVerification(User user) async {
    final emailService = EmailService();
    await emailService.handleUserEmailVerification(user);
  }

  /// Check and trigger welcome email if needed
  static Future<void> checkAndTriggerWelcomeEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        final emailService = EmailService();
        await emailService.handleUserEmailVerification(user);
      }
    } catch (error) {
      AppLogger.logger.e('❌ Error checking welcome email', error: error);
    }
  }

  /// Send custom verification email
  static Future<void> sendCustomVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.logger.success('✅ Verification email sent');
      }
    } catch (error) {
      AppLogger.logger.e('❌ Error sending verification email', error: error);
      rethrow;
    }
  }

  /// Get user notifications stream
  static Stream<List<Map<String, dynamic>>> getUserNotifications(
      String userId) {
    return FirebaseFirestore.instance
        .collection('user_notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(20)
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
      await FirebaseFirestore.instance
          .collection('user_notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      AppLogger.logger.e('❌ Error marking notification as read', error: error);
      rethrow;
    }
  }

  /// Test email connectivity
  Future<bool> testEmailService() async {
    try {
      AppLogger.logger.i('🔍 Testing email service connectivity...');

      // Record health check
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('_email_health_check').add({
          'test_performed_at': FieldValue.serverTimestamp(),
          'service_status': 'testing',
        });
      });

      // Simulate service test
      await Future.delayed(const Duration(milliseconds: 200));

      final success =
          DateTime.now().millisecond % 10 != 0; // 90% success rate for tests

      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('_email_health_check').add({
          'test_completed_at': FieldValue.serverTimestamp(),
          'service_status': success ? 'healthy' : 'unhealthy',
          'connectivity': success ? 'ok' : 'failed',
        });
      });

      if (success) {
        AppLogger.logger.success('✅ Email service is healthy');
    } else {
        AppLogger.logger.w('⚠️ Email service connectivity issues detected');
      }

      return success;
    } catch (error) {
      AppLogger.logger.e('❌ Email service test failed', error: error);
      return false;
    }
  }
}

/// Email analytics model
class EmailAnalytics {
  final int totalSent;
  final int totalFailed;
  final int welcomeEmails;
  final int notificationEmails;
  final double successRate;

  const EmailAnalytics({
    required this.totalSent,
    required this.totalFailed,
    required this.welcomeEmails,
    required this.notificationEmails,
    required this.successRate,
  });

  factory EmailAnalytics.empty() {
    return const EmailAnalytics(
      totalSent: 0,
      totalFailed: 0,
      welcomeEmails: 0,
      notificationEmails: 0,
      successRate: 0.0,
    );
  }

  int get totalAttempts => totalSent + totalFailed;

  Map<String, dynamic> toJson() {
      return {
      'total_sent': totalSent,
      'total_failed': totalFailed,
      'welcome_emails': welcomeEmails,
      'notification_emails': notificationEmails,
      'success_rate': successRate,
      'total_attempts': totalAttempts,
    };
  }
}
