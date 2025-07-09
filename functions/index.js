const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// ============================================================================
// 🎨 ENHANCED WELCOME EMAIL SYSTEM v2.0
// ============================================================================

/**
 * 🚀 Enhanced Welcome Email Trigger - Fires ONLY after email verification
 * 
 * This function is triggered when a user's emailVerified status changes from false to true.
 * It features:
 * - Perfect timing (only after verification)
 * - Deduplication (prevents multiple emails)
 * - Beautiful responsive templates
 * - Comprehensive error handling
 * - Analytics tracking
 */
exports.sendWelcomeEmailAfterVerification = functions.auth.user().onUpdate(async (change, context) => {
  const beforeData = change.before;
  const afterData = change.after;
  
  // 🎯 TRIGGER CONDITION: Email verification status changed from false to true
  const wasUnverified = !beforeData.emailVerified;
  const isNowVerified = afterData.emailVerified;
  
  if (!(wasUnverified && isNowVerified)) {
    console.log(`ℹ️  Email verification status unchanged for ${afterData.email}`);
    return null;
  }

  const email = afterData.email;
  const displayName = _getEnhancedDisplayName(afterData);
  const userId = afterData.uid;

  try {
    console.log(`🎉 Email verified! Triggering enhanced welcome email for: ${email}`);
    
    // 🔒 DEDUPLICATION CHECK - Prevent multiple welcome emails
    const existingWelcome = await _checkExistingWelcomeEmail(userId);
    if (existingWelcome) {
      console.log(`📧 Welcome email already sent to ${email} at ${existingWelcome.createdAt}`);
      return { success: true, message: 'Welcome email already sent', skipped: true };
    }

    // 🎨 CREATE ENHANCED WELCOME EMAIL TEMPLATE
    const emailTemplate = _createEnhancedWelcomeTemplate(displayName, email, afterData);

    // 📝 STORE WELCOME EMAIL RECORD with enhanced metadata
    const welcomeEmailData = {
      userId: userId,
      email: email,
      displayName: displayName,
      template: 'welcome_verified_v2_enhanced',
      htmlContent: emailTemplate,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      triggerType: 'email_verification_functions_v2',
      emailVerified: afterData.emailVerified,
      verificationTime: admin.firestore.FieldValue.serverTimestamp(),
      priority: 'high',
      metadata: {
        functionVersion: '2.0.0',
        enhanced: true,
        userAgent: 'firebase-functions-enhanced',
        signupMethod: afterData.providerData?.[0]?.providerId || 'email',
        platform: 'server-side',
        hasDisplayName: !!afterData.displayName,
        hasPhotoURL: !!afterData.photoURL,
        emailDomain: email?.split('@')[1],
        userProperties: {
          isNewUser: true,
          welcomeEmailVersion: 'v2_enhanced',
          enhancedTiming: true,
          serverSide: true,
        }
      }
    };

    // Store the enhanced welcome email
    const welcomeEmailRef = await admin.firestore().collection('welcome_emails').add(welcomeEmailData);

    // 📊 LOG DELIVERY TRACKING
    await admin.firestore().collection('email_delivery_log').add({
      userId: userId,
      email: email,
      type: 'welcome_email_enhanced',
      status: 'queued',
      welcomeEmailId: welcomeEmailRef.id,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      emailVerified: afterData.emailVerified,
      verificationTime: admin.firestore.FieldValue.serverTimestamp(),
      source: 'firebase_functions_v2',
    });

    // 🔔 CREATE ENHANCED IN-APP NOTIFICATION
    await _createEnhancedInAppNotification(userId, email, displayName);

    // 📊 TRACK ANALYTICS
    await _trackWelcomeEmailAnalytics(userId, 'welcome_email_triggered_server', email);

    console.log(`✅ Enhanced welcome email queued successfully for: ${email}`);
    return { 
      success: true, 
      email: email, 
      displayName: displayName,
      welcomeEmailId: welcomeEmailRef.id,
      version: '2.0.0'
    };

  } catch (error) {
    console.error(`❌ Error sending enhanced welcome email to ${email}:`, error);
    
    // 📝 LOG ERROR for monitoring
    await _logEnhancedEmailError(userId, email, 'welcome_email_functions_error', error.message);
    
    return { success: false, error: error.message, email: email };
  }
});

/**
 * 📧 Enhanced Welcome Email Processor
 * 
 * Processes welcome emails from the queue with beautiful templates
 * and comprehensive delivery tracking.
 */
exports.processEnhancedWelcomeEmails = functions.firestore
  .document('welcome_emails/{emailId}')
  .onCreate(async (snap, context) => {
    const emailData = snap.data();
    const { email, displayName, htmlContent, userId, template } = emailData;
    const emailId = context.params.emailId;

    try {
      console.log(`📬 Processing enhanced welcome email for: ${email}`);

      // 🎯 ENHANCED EMAIL QUEUE for external email service integration
      const emailQueueData = {
        to: email,
        subject: `Welcome to GitAlong, ${displayName}! 🚀 Your Developer Journey Starts Now`,
        html: htmlContent || _createEnhancedWelcomeTemplate(displayName, email),
        type: 'welcome_enhanced',
            priority: 'high',
        userId: userId,
        welcomeEmailId: emailId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'queued',
        metadata: {
          version: '2.0.0',
          enhanced: true,
          template: template || 'welcome_enhanced_default',
          processor: 'firebase_functions_v2',
        }
      };

      // Add to email queue for external processing
      const queueRef = await admin.firestore().collection('email_queue').add(emailQueueData);

      // 📱 SEND ENHANCED PUSH NOTIFICATION (if FCM token available)
      try {
        await _sendEnhancedPushNotification(userId, email, displayName);
      } catch (notifError) {
        console.warn(`⚠️  Could not send push notification to ${email}:`, notifError);
        // Don't fail the entire process if push notification fails
      }

      // 📊 UPDATE WELCOME EMAIL STATUS
      await snap.ref.update({
        status: 'queued_for_delivery',
        queuedAt: admin.firestore.FieldValue.serverTimestamp(),
        emailQueueId: queueRef.id,
        processorVersion: '2.0.0',
      });

      // 📈 TRACK PROCESSING ANALYTICS
      await _trackWelcomeEmailAnalytics(userId, 'welcome_email_queued', email);

      console.log(`✅ Enhanced welcome email queued for delivery: ${email}`);
      
    } catch (error) {
      console.error(`❌ Error processing enhanced welcome email for ${email}:`, error);
      
      // Update status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
        processorVersion: '2.0.0',
      });

      // Log the error
      await _logEnhancedEmailError(userId, email, 'welcome_email_processing_error', error.message);
    }
  });

/**
 * 📧 Enhanced Email Verification Processor
 * 
 * Processes email verification reminders with beautiful templates
 */
exports.processEnhancedEmailNotifications = functions.firestore
  .document('email_notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const { email, type, message } = notification;

    if (!type.includes('verification')) {
      console.log(`ℹ️  Skipping non-verification notification: ${type}`);
      return;
    }

    try {
      console.log(`📬 Processing enhanced verification email for: ${email}`);

      // Get the user by email
      const userRecord = await admin.auth().getUserByEmail(email);
      
      if (userRecord.emailVerified) {
        console.log(`✅ Email already verified for: ${email}`);
        await snap.ref.update({ 
          processed: true, 
          result: 'already_verified',
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
          processorVersion: '2.0.0',
        });
        return;
      }

      // 🔗 GENERATE ENHANCED VERIFICATION EMAIL LINK
      const actionCodeSettings = {
        url: 'https://gitalong.dev/email-verified',
        handleCodeInApp: true,
      };

      const verificationLink = await admin.auth().generateEmailVerificationLink(
        email, 
        actionCodeSettings
      );

      // 🎨 CREATE ENHANCED VERIFICATION EMAIL TEMPLATE
      const verificationTemplate = _createEnhancedVerificationTemplate(
        email, 
        verificationLink, 
        userRecord.displayName || email.split('@')[0]
      );

      // 📝 QUEUE THE ENHANCED VERIFICATION EMAIL
      await admin.firestore().collection('email_queue').add({
        to: email,
        subject: '🔐 Verify Your GitAlong Account - Unlock Your Developer Journey',
        html: verificationTemplate,
        type: 'verification_enhanced',
        priority: 'high',
        verificationLink: verificationLink,
        userId: userRecord.uid,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'queued',
        metadata: {
          version: '2.0.0',
          enhanced: true,
          notificationId: context.params.notificationId,
        }
      });
      
      // 📊 MARK NOTIFICATION AS PROCESSED
      await snap.ref.update({ 
        processed: true, 
        result: 'verification_queued_enhanced',
        verificationLink: verificationLink,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        processorVersion: '2.0.0',
      });

      console.log(`✅ Enhanced verification email queued for: ${email}`);
      
    } catch (error) {
      console.error(`❌ Error processing enhanced verification for ${email}:`, error);
      
      await snap.ref.update({ 
        processed: true, 
        result: 'error',
        errorMessage: error.message,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        processorVersion: '2.0.0',
      });
    }
  });

/**
 * 🔔 Swipe Notification Handler
 * 
 * Triggers when a user swipes right on a project and sends notification to project owner
 */
exports.handleSwipeNotification = functions.firestore
  .document('swipes/{swipeId}')
  .onCreate(async (snap, context) => {
    const swipeData = snap.data();
    const { swiper_id, target_id, direction, target_type } = swipeData;
    const swipeId = context.params.swipeId;

    try {
      console.log(`👆 Processing swipe: ${swiper_id} -> ${target_id} (${direction})`);

      // Only handle right swipes on projects
      if (direction !== 'right' || target_type !== 'project') {
        console.log(`ℹ️ Skipping non-project right swipe: ${direction} on ${target_type}`);
        return null;
      }

      // Get project details
      const projectDoc = await admin.firestore()
        .collection('projects')
        .doc(target_id)
        .get();

      if (!projectDoc.exists) {
        console.log(`⚠️ Project not found: ${target_id}`);
        return null;
      }

      const projectData = projectDoc.data();
      const projectOwnerId = projectData.owner_id;
      const projectTitle = projectData.title;

      // Don't notify if swiper is the project owner
      if (swiper_id === projectOwnerId) {
        console.log(`ℹ️ Skipping notification - swiper is project owner`);
        return null;
      }

      // Get swiper details
      const swiperDoc = await admin.firestore()
        .collection('users')
        .doc(swiper_id)
        .get();

      let swiperName = 'A developer';
      if (swiperDoc.exists) {
        const swiperData = swiperDoc.data();
        swiperName = swiperData.display_name || swiperData.username || 'A developer';
      }

      console.log(`📧 Sending swipe notification to project owner: ${projectOwnerId}`);

      // Create notification record
      const notificationData = {
        userId: projectOwnerId,
        type: 'swipe',
        title: '👋 New Swipe!',
        message: `${swiperName} swiped right on your project "${projectTitle}"`,
        read: false,
        priority: 'medium',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 7 days
        actions: {
          view_project: `/projects/${target_id}`,
          view_profile: `/profile/${swiper_id}`,
        },
        metadata: {
          swipeId: swipeId,
          projectId: target_id,
          swiperId: swiper_id,
          swiperName: swiperName,
          projectTitle: projectTitle,
          functionVersion: '1.0.0',
        }
      };

      // Add to user notifications
      await admin.firestore()
        .collection('user_notifications')
        .add(notificationData);

      // Send push notification
      try {
        await _sendSwipePushNotification(
          projectOwnerId,
          swiperName,
          projectTitle,
          target_id,
          swiper_id
        );
      } catch (notifError) {
        console.warn(`⚠️ Could not send push notification for swipe:`, notifError);
      }

      console.log(`✅ Swipe notification processed successfully`);
      return { success: true, projectOwnerId, swiperName, projectTitle };

    } catch (error) {
      console.error(`❌ Error processing swipe notification:`, error);
      
      // Log the error for monitoring
      await admin.firestore().collection('error_logs').add({
        type: 'swipe_notification_error',
        swipeId: swipeId,
        error: error.message,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        functionVersion: '1.0.0',
      });
      
      return { success: false, error: error.message };
    }
  });

// ============================================================================
// 🛠️ HELPER FUNCTIONS - Enhanced Utilities
// ============================================================================

/**
 * Get enhanced display name with intelligent fallbacks
 */
function _getEnhancedDisplayName(userData) {
  if (userData.displayName) {
    return userData.displayName;
  }
  
  if (userData.email) {
    const username = userData.email.split('@')[0];
    // Convert to title case and handle common separators
    return username
      .split(/[._-]/)
      .map(part => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' ');
  }
  
  return 'Developer';
}

/**
 * Check for existing welcome emails (deduplication)
 */
async function _checkExistingWelcomeEmail(userId) {
  try {
    const existingEmails = await admin.firestore()
      .collection('welcome_emails')
      .where('userId', '==', userId)
      .where('status', 'in', ['pending', 'queued_for_delivery', 'sent'])
      .limit(1)
      .get();

    return existingEmails.docs.length > 0 ? existingEmails.docs[0].data() : null;
      } catch (error) {
    console.warn(`⚠️  Error checking existing welcome email for ${userId}:`, error);
    return null;
  }
}

/**
 * Create enhanced in-app notification
 */
async function _createEnhancedInAppNotification(userId, email, displayName) {
  try {
    await admin.firestore().collection('user_notifications').add({
      userId: userId,
      type: 'welcome_enhanced',
      title: 'Welcome to GitAlong! 🚀',
      message: `Hey ${displayName}! Your developer journey starts now. Complete your profile to discover amazing projects!`,
      read: false,
      priority: 'high',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 7 days
      actions: {
        complete_profile: '/onboarding',
        explore_projects: '/home/discover',
        view_tutorials: '/help/getting-started',
      },
      metadata: {
        welcomeEmailSent: true,
        emailVerificationTime: admin.firestore.FieldValue.serverTimestamp(),
        functionVersion: '2.0.0',
        enhanced: true,
      }
    });
    
    console.log(`📱 Enhanced in-app notification created for: ${email}`);
  } catch (error) {
    console.warn(`⚠️  Failed to create in-app notification for ${email}:`, error);
  }
}

/**
 * Send enhanced push notification
 */
async function _sendEnhancedPushNotification(userId, email, displayName) {
  try {
    // Check if user has FCM tokens
    const userTokens = await admin.firestore()
      .collection('user_fcm_tokens')
      .where('userId', '==', userId)
      .where('active', '==', true)
      .get();

    if (userTokens.docs.length === 0) {
      console.log(`ℹ️  No FCM tokens found for user: ${email}`);
      return;
    }

    const tokens = userTokens.docs.map(doc => doc.data().token);

    const message = {
      notification: {
        title: 'Welcome to GitAlong! 🚀',
        body: `Hey ${displayName}! Your developer journey starts now.`,
        icon: 'https://gitalong.dev/icon-192.png',
      },
              data: {
        type: 'welcome_enhanced',
        action: 'open_onboarding',
        userId: userId,
        version: '2.0.0',
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendMulticast(message);
    console.log(`📱 Enhanced push notification sent to ${response.successCount}/${tokens.length} devices for: ${email}`);
    
    // Clean up invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          invalidTokens.push(tokens[idx]);
        }
      });
      
      // Mark invalid tokens as inactive
      const batch = admin.firestore().batch();
      for (const token of invalidTokens) {
        const tokenDoc = await admin.firestore()
          .collection('user_fcm_tokens')
          .where('token', '==', token)
          .limit(1)
          .get();
        
        if (tokenDoc.docs.length > 0) {
          batch.update(tokenDoc.docs[0].ref, { active: false });
        }
      }
      await batch.commit();
      }
    } catch (error) {
    console.warn(`⚠️  Failed to send push notification for ${email}:`, error);
  }
}

/**
 * Send swipe push notification
 */
async function _sendSwipePushNotification(projectOwnerId, swiperName, projectTitle, projectId, swiperId) {
  try {
    // Check if user has FCM tokens
    const userTokens = await admin.firestore()
      .collection('user_fcm_tokens')
      .where('userId', '==', projectOwnerId)
      .where('active', '==', true)
      .get();

    if (userTokens.docs.length === 0) {
      console.log(`ℹ️ No FCM tokens found for project owner: ${projectOwnerId}`);
      return;
    }

    const tokens = userTokens.docs.map(doc => doc.data().token);

    const message = {
      notification: {
        title: '👋 New Swipe!',
        body: `${swiperName} swiped right on your project "${projectTitle}"`,
        icon: 'https://gitalong.dev/icon-192.png',
      },
      data: {
        type: 'swipe',
        action: 'open_project',
        projectId: projectId,
        swiperId: swiperId,
        swiperName: swiperName,
        projectTitle: projectTitle,
        version: '1.0.0',
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendMulticast(message);
    console.log(`📱 Swipe push notification sent to ${response.successCount}/${tokens.length} devices`);
    
    // Clean up invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          invalidTokens.push(tokens[idx]);
        }
      });
      
      // Mark invalid tokens as inactive
      const batch = admin.firestore().batch();
      for (const token of invalidTokens) {
        const tokenDoc = await admin.firestore()
          .collection('user_fcm_tokens')
          .where('token', '==', token)
          .limit(1)
          .get();
        
        if (tokenDoc.docs.length > 0) {
          batch.update(tokenDoc.docs[0].ref, { active: false });
        }
      }
      await batch.commit();
    }
  } catch (error) {
    console.warn(`⚠️ Failed to send swipe push notification:`, error);
  }
}

/**
 * Track welcome email analytics
 */
async function _trackWelcomeEmailAnalytics(userId, event, email) {
  try {
    await admin.firestore().collection('email_analytics').add({
      userId: userId,
      email: email,
      event: event,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      source: 'firebase_functions_v2_enhanced',
      metadata: {
        functionVersion: '2.0.0',
        enhanced: true,
        serverSide: true,
      }
    });
  } catch (error) {
    console.warn(`⚠️  Failed to track analytics for ${email}:`, error);
  }
}

/**
 * Log enhanced email errors
 */
async function _logEnhancedEmailError(userId, email, errorType, errorMessage) {
  try {
    await admin.firestore().collection('email_errors').add({
      userId: userId,
      email: email,
      errorType: errorType,
      errorMessage: errorMessage,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      source: 'firebase_functions_v2_enhanced',
      metadata: {
        functionVersion: '2.0.0',
        enhanced: true,
        serverSide: true,
      }
    });
  } catch (error) {
    console.error(`❌ Failed to log email error for ${email}:`, error);
  }
}

/**
 * 🎨 Create Enhanced Welcome Email Template
 */
function _createEnhancedWelcomeTemplate(displayName, email, userData = {}) {
  const firstName = displayName.split(' ')[0];
  const emailDomain = email.split('@')[1];
  const isGoogleUser = userData?.providerData?.[0]?.providerId === 'google.com';
  
  return `
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to GitAlong, ${displayName}!</title>
          <style>
              * { margin: 0; padding: 0; box-sizing: border-box; }
              body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #0d1117 0%, #161b22 50%, #21262d 100%);
                  padding: 20px;
                  min-height: 100vh;
            line-height: 1.6;
              }
              .container {
                  max-width: 600px;
                  margin: 0 auto;
                  background: #21262d;
            border-radius: 20px;
                  overflow: hidden;
            box-shadow: 0 25px 50px rgba(0,0,0,0.5);
                  border: 1px solid #30363d;
              }
              .header {
            background: linear-gradient(135deg, #238636 0%, #2ea043 50%, #7c3aed 100%);
            padding: 50px 30px;
                  text-align: center;
                  position: relative;
                  overflow: hidden;
              }
              .header::before {
                  content: '';
                  position: absolute;
                  top: -50%;
                  left: -50%;
                  width: 200%;
                  height: 200%;
                  background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: shine 4s ease-in-out infinite;
              }
              @keyframes shine {
                  0%, 100% { transform: translate(-50%, -50%) rotate(0deg); }
                  50% { transform: translate(-50%, -50%) rotate(180deg); }
              }
              .logo {
            width: 100px;
            height: 100px;
                  background: rgba(255,255,255,0.15);
                  border-radius: 50%;
            margin: 0 auto 25px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
            font-size: 50px;
                  position: relative;
                  z-index: 1;
            backdrop-filter: blur(10px);
              }
              .header h1 {
                  color: white;
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 15px;
                  position: relative;
                  z-index: 1;
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
              }
              .header p {
            color: rgba(255,255,255,0.95);
            font-size: 18px;
                  position: relative;
                  z-index: 1;
            font-weight: 500;
              }
              .content {
            padding: 50px 40px;
                  color: #c9d1d9;
              }
              .greeting {
            font-size: 26px;
            font-weight: 700;
                  color: #f0f6fc;
            margin-bottom: 25px;
                  text-align: center;
              }
              .message {
            font-size: 18px;
            line-height: 1.7;
            margin-bottom: 35px;
                  text-align: center;
                  color: #8b949e;
              }
              .features {
            background: linear-gradient(135deg, #161b22 0%, #21262d 100%);
            border-radius: 16px;
            padding: 35px;
            margin: 35px 0;
                  border: 1px solid #30363d;
            box-shadow: inset 0 2px 10px rgba(0,0,0,0.2);
              }
              .features h3 {
                  color: #2ea043;
            font-size: 22px;
            margin-bottom: 25px;
                  text-align: center;
                  display: flex;
                  align-items: center;
                  justify-content: center;
            gap: 12px;
              }
              .feature-list {
                  list-style: none;
                  padding: 0;
              }
              .feature-list li {
            padding: 15px 0;
                  border-bottom: 1px solid #30363d;
                  display: flex;
                  align-items: center;
            gap: 18px;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        .feature-list li:hover {
            background: rgba(46, 160, 67, 0.05);
            border-radius: 8px;
            padding-left: 10px;
            margin: 0 -10px;
              }
              .feature-list li:last-child {
                  border-bottom: none;
              }
              .feature-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #2ea043 0%, #238636 100%);
            border-radius: 10px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
            font-size: 18px;
                  flex-shrink: 0;
            box-shadow: 0 4px 15px rgba(46, 160, 67, 0.3);
              }
              .cta-section {
                  text-align: center;
            margin: 40px 0;
              }
              .cta-button {
                  display: inline-block;
            background: linear-gradient(135deg, #238636 0%, #2ea043 50%, #7c3aed 100%);
                  color: white;
                  text-decoration: none;
            padding: 18px 40px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 18px;
            box-shadow: 0 10px 25px rgba(46, 160, 67, 0.4);
                  transition: all 0.3s ease;
                  border: 2px solid transparent;
            text-transform: uppercase;
            letter-spacing: 0.5px;
              }
              .cta-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(46, 160, 67, 0.6);
              }
        .stats {
                  background: linear-gradient(135deg, #1f2937 0%, #374151 100%);
            border-radius: 16px;
            padding: 30px;
            margin: 30px 0;
            border-left: 5px solid #2ea043;
            box-shadow: 0 8px 25px rgba(0,0,0,0.3);
        }
        .stats h4 {
            color: #f59e0b;
            font-size: 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .stat-item {
            text-align: center;
            padding: 15px;
            background: rgba(46, 160, 67, 0.1);
                  border-radius: 12px;
            border: 1px solid rgba(46, 160, 67, 0.2);
        }
        .stat-number {
            font-size: 24px;
            font-weight: 800;
            color: #2ea043;
            display: block;
        }
        .stat-label {
            font-size: 12px;
            color: #8b949e;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .tips {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            border-radius: 16px;
            padding: 30px;
            margin: 30px 0;
            border-left: 5px solid #7c3aed;
            box-shadow: 0 8px 25px rgba(124, 58, 237, 0.2);
              }
              .tips h4 {
            color: #a855f7;
            font-size: 20px;
            margin-bottom: 20px;
                  display: flex;
                  align-items: center;
            gap: 12px;
              }
              .tips p {
            color: #cbd5e1;
            font-size: 16px;
            line-height: 1.6;
              }
              .footer {
                  background: #0d1117;
            padding: 40px 30px;
                  text-align: center;
                  border-top: 1px solid #30363d;
              }
              .footer p {
                  color: #7d8590;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 20px;
              }
              .social-links {
            margin: 25px 0;
                  display: flex;
                  justify-content: center;
            gap: 25px;
              }
              .social-link {
            width: 50px;
            height: 50px;
                  background: #21262d;
                  border-radius: 50%;
                  display: inline-flex;
                  align-items: center;
                  justify-content: center;
                  text-decoration: none;
                  color: #7d8590;
            border: 2px solid #30363d;
                  transition: all 0.3s ease;
            font-size: 20px;
              }
              .social-link:hover {
                  background: #2ea043;
                  color: white;
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(46, 160, 67, 0.4);
        }
        .personalization {
            background: rgba(124, 58, 237, 0.1);
            border: 1px solid rgba(124, 58, 237, 0.3);
            border-radius: 12px;
            padding: 20px;
            margin: 25px 0;
            text-align: center;
        }
        .personalization .email-info {
            color: #a855f7;
            font-size: 14px;
            margin-bottom: 10px;
        }
        @media (max-width: 600px) {
            .container { margin: 10px; border-radius: 16px; }
            .header { padding: 30px 20px; }
            .content { padding: 30px 25px; }
            .header h1 { font-size: 26px; }
            .greeting { font-size: 22px; }
            .message { font-size: 16px; }
            .cta-button { padding: 15px 30px; font-size: 16px; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
              }
          </style>
      </head>
      <body>
          <div class="container">
              <div class="header">
                  <div class="logo">🚀</div>
                  <h1>Welcome to GitAlong!</h1>
            <p>Your journey in open source collaboration starts here</p>
              </div>
              
              <div class="content">
                  <div class="greeting">
                Hey ${firstName}! 👋
                  </div>
                  
                  <div class="message">
                We're absolutely thrilled to have you join the GitAlong community! You've just unlocked access to a vibrant ecosystem where developers connect, collaborate, and contribute to amazing open source projects. Your adventure in meaningful coding starts right now!
                  </div>

            ${isGoogleUser ? `
            <div class="personalization">
                <div class="email-info">
                    ✨ Signed up with Google • ${emailDomain}
                </div>
                <p style="color: #8b949e; font-size: 14px;">
                    Your account is automatically verified and ready to go!
                </p>
            </div>
            ` : ''}

                  <div class="features">
                      <h3>🌟 What you can do with GitAlong</h3>
                      <ul class="feature-list">
                          <li>
                              <div class="feature-icon">🔍</div>
                              <div>
                            <strong>Discover Amazing Projects</strong><br>
                            <span style="color: #6e7681;">Find projects that match your skills and interests</span>
                              </div>
                          </li>
                          <li>
                              <div class="feature-icon">🤝</div>
                              <div>
                                  <strong>Connect with Maintainers</strong><br>
                            <span style="color: #6e7681;">Build relationships with project creators and contributors</span>
                              </div>
                          </li>
                          <li>
                              <div class="feature-icon">📊</div>
                              <div>
                            <strong>Track Your Contributions</strong><br>
                            <span style="color: #6e7681;">Monitor your open source journey and achievements</span>
                              </div>
                          </li>
                          <li>
                              <div class="feature-icon">🎯</div>
                              <div>
                            <strong>Smart Project Matching</strong><br>
                            <span style="color: #6e7681;">AI-powered recommendations based on your preferences</span>
                        </div>
                    </li>
                    <li>
                        <div class="feature-icon">💬</div>
                        <div>
                            <strong>Real-time Collaboration</strong><br>
                            <span style="color: #6e7681;">Chat with other developers and share knowledge</span>
                              </div>
                          </li>
                      </ul>
                  </div>

            <div class="stats">
                <h4>🔥 Join Our Growing Community</h4>
                <div class="stats-grid">
                    <div class="stat-item">
                        <span class="stat-number">10K+</span>
                        <span class="stat-label">Active Developers</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">500+</span>
                        <span class="stat-label">Open Projects</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">25K+</span>
                        <span class="stat-label">Contributions</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">50+</span>
                        <span class="stat-label">Countries</span>
                    </div>
                </div>
            </div>

                  <div class="cta-section">
                <a href="https://gitalong.dev/onboarding?utm_source=welcome_email&utm_medium=email&utm_campaign=welcome_v2" class="cta-button">
                    Complete Your Profile 🎯
                      </a>
                <p style="margin-top: 20px; color: #6e7681; font-size: 14px;">
                    Takes less than 2 minutes • Unlock personalized project recommendations
                </p>
                  </div>

                  <div class="tips">
                <h4>💡 Pro Tips for Success</h4>
                      <p>
                    <strong>Complete your profile</strong> with your skills, interests, and GitHub information to get better project recommendations. 
                    <strong>Start small</strong> with good first issues, and don't hesitate to <strong>ask questions</strong> in project discussions. 
                    The GitAlong community is here to help you succeed! 🌟
                      </p>
                  </div>
              </div>

              <div class="footer">
                  <div class="social-links">
                <a href="https://github.com/gitalong" class="social-link">📘</a>
                <a href="https://twitter.com/gitalongdev" class="social-link">🐦</a>
                <a href="https://discord.gg/gitalong" class="social-link">💬</a>
                <a href="https://gitalong.dev/blog" class="social-link">📝</a>
                  </div>
            <p>
                Need help getting started? Check out our <a href="https://gitalong.dev/help" style="color: #2ea043;">Getting Started Guide</a><br>
                You're receiving this email because you recently joined GitAlong.<br>
                <a href="https://gitalong.dev/unsubscribe?email=${encodeURIComponent(email)}" style="color: #7d8590;">Unsubscribe</a> • 
                <a href="https://gitalong.dev/privacy" style="color: #7d8590;">Privacy Policy</a><br><br>
                <strong>Happy Coding! 🚀</strong><br>
                — The GitAlong Team
                  </p>
              </div>
          </div>
      </body>
      </html>
      `;
}

/**
 * 🎨 Create Enhanced Email Verification Template
 */
function _createEnhancedVerificationTemplate(email, verificationLink, displayName) {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Your GitAlong Account</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0d1117 0%, #161b22 100%);
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: #21262d;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.4);
            border: 1px solid #30363d;
        }
        .header {
            background: linear-gradient(135deg, #1f6feb 0%, #7c3aed 100%);
            padding: 40px 30px;
            text-align: center;
            color: white;
        }
        .header h1 {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        .content {
            padding: 40px 30px;
            color: #c9d1d9;
            text-align: center;
        }
        .verify-button {
            display: inline-block;
            background: linear-gradient(135deg, #238636 0%, #2ea043 100%);
            color: white;
            text-decoration: none;
            padding: 16px 32px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 16px;
            margin: 20px 0;
            box-shadow: 0 8px 20px rgba(46, 160, 67, 0.4);
            transition: all 0.3s ease;
        }
        .verify-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(46, 160, 67, 0.6);
        }
        .footer {
            background: #161b22;
            padding: 20px;
            text-align: center;
            font-size: 12px;
            color: #7d8590;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Verify Your Email</h1>
            <p>Almost there, ${displayName}!</p>
        </div>
        <div class="content">
            <p style="margin-bottom: 20px;">
                Click the button below to verify your email address and unlock your GitAlong account:
            </p>
            <a href="${verificationLink}" class="verify-button">
                Verify My Email ✨
            </a>
            <p style="font-size: 14px; color: #8b949e; margin-top: 20px;">
                This link will expire in 24 hours for security reasons.
            </p>
        </div>
        <div class="footer">
            <p>If you didn't create a GitAlong account, you can safely ignore this email.</p>
        </div>
    </div>
</body>
</html>
`;
}

// ============================================================================
// 🛠️ LEGACY SUPPORT - Maintain backward compatibility
// ============================================================================

/**
 * Original welcome email function (for backward compatibility)
 * Enhanced with improved logging and error handling
 */
exports.sendWelcomeEmail = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  const displayName = _getEnhancedDisplayName(user);

  try {
    console.log(`📝 User account created: ${email} (Enhanced welcome email will be sent after verification)`);
    
    // Enhanced user signup logging
    await admin.firestore().collection('user_signups').add({
      userId: user.uid,
      email: email,
      displayName: displayName,
      emailVerified: user.emailVerified,
      signupTime: admin.firestore.FieldValue.serverTimestamp(),
      status: 'awaiting_verification',
      metadata: {
        functionVersion: '2.0.0',
        enhanced: true,
        signupMethod: user.providerData?.[0]?.providerId || 'email',
        hasDisplayName: !!user.displayName,
        hasPhotoURL: !!user.photoURL,
      }
    });

    console.log(`✅ Enhanced user signup logged for: ${email}`);
    return { success: true, email: email, message: 'Account created, awaiting verification', version: '2.0.0' };

  } catch (error) {
    console.error(`❌ Error logging enhanced user signup for ${email}:`, error);
    return { success: false, error: error.message, version: '2.0.0' };
  }
});

// ============================================================================
// 🔍 HEALTH CHECK AND MONITORING
// ============================================================================

/**
 * Enhanced email system health check endpoint
 */
exports.emailSystemHealthCheck = functions.https.onRequest((req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    res.json({
      status: 'healthy',
      version: '2.0.0',
      enhanced: true,
      timestamp: new Date().toISOString(),
      services: {
        welcome_emails: 'active',
        verification_emails: 'active',
        email_queue: 'active',
        push_notifications: 'active',
        analytics: 'active',
      },
      features: {
        deduplication: 'enabled',
        enhanced_templates: 'enabled',
        smart_timing: 'enabled',
        error_monitoring: 'enabled',
        analytics_tracking: 'enabled',
      },
      environment: process.env.NODE_ENV || 'development',
    });
    } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      version: '2.0.0',
      enhanced: true,
        error: error.message,
      timestamp: new Date().toISOString(),
      });
    }
  });

/**
 * Enhanced email analytics endpoint
 */
exports.getEmailAnalytics = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  
  try {
    const timeframe = req.query.timeframe || '24h';
    const hoursBack = timeframe === '7d' ? 168 : timeframe === '30d' ? 720 : 24;
    
    const cutoffTime = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - hoursBack * 60 * 60 * 1000)
    );

    const [welcomeEmails, analytics, errors] = await Promise.all([
      admin.firestore()
        .collection('welcome_emails')
        .where('createdAt', '>=', cutoffTime)
        .get(),
      admin.firestore()
        .collection('email_analytics')
        .where('timestamp', '>=', cutoffTime)
        .get(),
      admin.firestore()
        .collection('email_errors')
        .where('timestamp', '>=', cutoffTime)
        .get(),
    ]);

    res.json({
      timeframe: timeframe,
      welcome_emails_sent: welcomeEmails.size,
      total_events: analytics.size,
      errors: errors.size,
      success_rate: errors.size > 0 ? 
        ((welcomeEmails.size / (welcomeEmails.size + errors.size)) * 100).toFixed(2) + '%' : 
        '100%',
      version: '2.0.0',
      enhanced: true,
      timestamp: new Date().toISOString(),
    });
    } catch (error) {
    res.status(500).json({
      error: error.message,
      version: '2.0.0',
      timestamp: new Date().toISOString(),
    });
  }
}); 