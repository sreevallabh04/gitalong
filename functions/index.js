const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ============================================================================
// 🔔 PUSH NOTIFICATION HANDLERS
// ============================================================================

// Process push notifications from Firestore queue
exports.processPushNotifications = functions.firestore
  .document('push_notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notificationData = snap.data();
    const { userId, fcmToken, title, body, data, imageUrl } = notificationData;

    try {
      // Send push notification via FCM
      const message = {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
          imageUrl: imageUrl,
        },
        data: data || {},
        android: {
          notification: {
            channelId: 'general',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: '@mipmap/launcher_icon',
            color: '#238636',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      
      // Update notification status
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
      });

      console.log(`✅ Push notification sent successfully to user ${userId}`);
    } catch (error) {
      console.error(`❌ Failed to send push notification to user ${userId}:`, error);
      
      // Update notification status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

// Send notification when user swipes right on a project
exports.onSwipeRight = functions.firestore
  .document('swipes/{swipeId}')
  .onCreate(async (snap, context) => {
    const swipeData = snap.data();
    const { swiper_id, target_id, project_id, direction } = swipeData;

    if (direction === 'right') {
      try {
        // Get project details
        const projectDoc = await admin.firestore().collection('projects').doc(project_id).get();
        const projectData = projectDoc.data();
        
        if (projectData) {
          // Get swiper details
          const swiperDoc = await admin.firestore().collection('users').doc(swiper_id).get();
          const swiperData = swiperDoc.data();
          
          if (swiperData && projectData.owner_id !== swiper_id) {
            // Send notification to project owner
            await admin.firestore().collection('push_notifications').add({
              userId: projectData.owner_id,
              fcmToken: projectData.owner_fcm_token,
              title: '👋 New Swipe!',
              body: `${swiperData.name || 'Someone'} swiped right on your project "${projectData.title}"`,
              data: {
                type: 'swipe',
                action: 'open_project',
                swiperName: swiperData.name || 'Someone',
                projectTitle: projectData.title,
                projectId: project_id,
              },
              status: 'pending',
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (error) {
        console.error('❌ Error processing swipe notification:', error);
      }
    }
  });

// Send notification when a match is created
exports.onMatchCreated = functions.firestore
  .document('matches/{matchId}')
  .onCreate(async (snap, context) => {
    const matchData = snap.data();
    const { user1_id, user2_id, project_id } = matchData;

    try {
      // Get project details
      const projectDoc = await admin.firestore().collection('projects').doc(project_id).get();
      const projectData = projectDoc.data();
      
      if (projectData) {
        // Get user details
        const [user1Doc, user2Doc] = await Promise.all([
          admin.firestore().collection('users').doc(user1_id).get(),
          admin.firestore().collection('users').doc(user2_id).get(),
        ]);
        
        const user1Data = user1Doc.data();
        const user2Data = user2Doc.data();
        
        if (user1Data && user2Data) {
          // Send notification to both users
          const notifications = [
            {
              userId: user1_id,
              fcmToken: user1Data.fcm_token,
              title: '🎉 New Match!',
              body: `You matched with ${user2Data.name || 'Someone'} on "${projectData.title}"`,
              data: {
                type: 'match',
                action: 'open_match',
                matchedUserName: user2Data.name || 'Someone',
                projectTitle: projectData.title,
                matchId: snap.id,
              },
            },
            {
              userId: user2_id,
              fcmToken: user2Data.fcm_token,
              title: '🎉 New Match!',
              body: `You matched with ${user1Data.name || 'Someone'} on "${projectData.title}"`,
              data: {
                type: 'match',
                action: 'open_match',
                matchedUserName: user1Data.name || 'Someone',
                projectTitle: projectData.title,
                matchId: snap.id,
              },
            },
          ];
          
          // Add notifications to queue
          const batch = admin.firestore().batch();
          notifications.forEach((notification) => {
            const notificationRef = admin.firestore().collection('push_notifications').doc();
            batch.set(notificationRef, {
              ...notification,
              status: 'pending',
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          });
          
          await batch.commit();
        }
      }
    } catch (error) {
      console.error('❌ Error processing match notification:', error);
    }
  });

// Send welcome email AFTER email verification, not during signup
exports.sendWelcomeEmailAfterVerification = functions.auth.user().onUpdate(async (change, context) => {
  const beforeData = change.before;
  const afterData = change.after;
  
  // Check if email verification status changed from false to true
  const wasUnverified = !beforeData.emailVerified;
  const isNowVerified = afterData.emailVerified;
  
  if (wasUnverified && isNowVerified) {
    const email = afterData.email;
    const displayName = afterData.displayName || afterData.email?.split('@')[0] || 'Developer';

    try {
      AppLogger.logger.i('📧 Email verified! Sending welcome email to: ${email}');
      
      // Create beautiful welcome email template
      const welcomeEmailTemplate = `
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Welcome to GitAlong!</title>
          <style>
              * { margin: 0; padding: 0; box-sizing: border-box; }
              body { 
                  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                  background: linear-gradient(135deg, #0d1117 0%, #161b22 100%);
                  padding: 20px;
                  min-height: 100vh;
              }
              .container {
                  max-width: 600px;
                  margin: 0 auto;
                  background: #21262d;
                  border-radius: 16px;
                  overflow: hidden;
                  box-shadow: 0 20px 40px rgba(0,0,0,0.3);
                  border: 1px solid #30363d;
              }
              .header {
                  background: linear-gradient(135deg, #238636 0%, #2ea043 100%);
                  padding: 40px 30px;
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
                  animation: shine 3s ease-in-out infinite;
              }
              @keyframes shine {
                  0%, 100% { transform: translate(-50%, -50%) rotate(0deg); }
                  50% { transform: translate(-50%, -50%) rotate(180deg); }
              }
              .logo {
                  width: 80px;
                  height: 80px;
                  background: rgba(255,255,255,0.15);
                  border-radius: 50%;
                  margin: 0 auto 20px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  font-size: 40px;
                  position: relative;
                  z-index: 1;
              }
              .header h1 {
                  color: white;
                  font-size: 28px;
                  font-weight: 700;
                  margin-bottom: 10px;
                  position: relative;
                  z-index: 1;
              }
              .header p {
                  color: rgba(255,255,255,0.9);
                  font-size: 16px;
                  position: relative;
                  z-index: 1;
              }
              .content {
                  padding: 40px 30px;
                  color: #c9d1d9;
              }
              .greeting {
                  font-size: 24px;
                  font-weight: 600;
                  color: #f0f6fc;
                  margin-bottom: 20px;
                  text-align: center;
              }
              .message {
                  font-size: 16px;
                  line-height: 1.6;
                  margin-bottom: 30px;
                  text-align: center;
                  color: #8b949e;
              }
              .features {
                  background: #161b22;
                  border-radius: 12px;
                  padding: 30px;
                  margin: 30px 0;
                  border: 1px solid #30363d;
              }
              .features h3 {
                  color: #2ea043;
                  font-size: 20px;
                  margin-bottom: 20px;
                  text-align: center;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  gap: 10px;
              }
              .feature-list {
                  list-style: none;
                  padding: 0;
              }
              .feature-list li {
                  padding: 12px 0;
                  border-bottom: 1px solid #30363d;
                  display: flex;
                  align-items: center;
                  gap: 15px;
                  font-size: 15px;
              }
              .feature-list li:last-child {
                  border-bottom: none;
              }
              .feature-icon {
                  width: 32px;
                  height: 32px;
                  background: #2ea043;
                  border-radius: 8px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  font-size: 16px;
                  flex-shrink: 0;
              }
              .cta-section {
                  text-align: center;
                  margin: 30px 0;
              }
              .cta-button {
                  display: inline-block;
                  background: linear-gradient(135deg, #238636 0%, #2ea043 100%);
                  color: white;
                  text-decoration: none;
                  padding: 16px 32px;
                  border-radius: 12px;
                  font-weight: 600;
                  font-size: 16px;
                  box-shadow: 0 8px 16px rgba(46, 160, 67, 0.3);
                  transition: all 0.3s ease;
                  border: 2px solid transparent;
              }
              .cta-button:hover {
                  transform: translateY(-2px);
                  box-shadow: 0 12px 24px rgba(46, 160, 67, 0.4);
              }
              .tips {
                  background: linear-gradient(135deg, #1f2937 0%, #374151 100%);
                  border-radius: 12px;
                  padding: 25px;
                  margin: 25px 0;
                  border-left: 4px solid #2ea043;
              }
              .tips h4 {
                  color: #fbbf24;
                  font-size: 18px;
                  margin-bottom: 15px;
                  display: flex;
                  align-items: center;
                  gap: 10px;
              }
              .tips p {
                  color: #d1d5db;
                  font-size: 14px;
                  line-height: 1.5;
              }
              .footer {
                  background: #0d1117;
                  padding: 30px;
                  text-align: center;
                  border-top: 1px solid #30363d;
              }
              .footer p {
                  color: #7d8590;
                  font-size: 13px;
                  line-height: 1.5;
              }
              .social-links {
                  margin: 20px 0;
                  display: flex;
                  justify-content: center;
                  gap: 20px;
              }
              .social-link {
                  width: 40px;
                  height: 40px;
                  background: #21262d;
                  border-radius: 50%;
                  display: inline-flex;
                  align-items: center;
                  justify-content: center;
                  text-decoration: none;
                  color: #7d8590;
                  border: 1px solid #30363d;
                  transition: all 0.3s ease;
              }
              .social-link:hover {
                  background: #2ea043;
                  color: white;
                  transform: translateY(-2px);
              }
          </style>
      </head>
      <body>
          <div class="container">
              <div class="header">
                  <div class="logo">🚀</div>
                  <h1>Welcome to GitAlong!</h1>
                  <p>Your journey in open source starts here</p>
              </div>
              
              <div class="content">
                  <div class="greeting">
                      Hey ${displayName}! 👋
                  </div>
                  
                  <div class="message">
                      <strong>Congratulations on verifying your email!</strong><br><br>
                      We're absolutely thrilled to have you join the GitAlong community! You're now part of a vibrant ecosystem where developers connect, collaborate, and contribute to amazing open source projects.
                  </div>

                  <div class="features">
                      <h3>🌟 What you can do with GitAlong</h3>
                      <ul class="feature-list">
                          <li>
                              <div class="feature-icon">🔍</div>
                              <div>
                                  <strong>Discover Projects</strong><br>
                                  Find open source projects that match your interests and skills
                              </div>
                          </li>
                          <li>
                              <div class="feature-icon">🤝</div>
                              <div>
                                  <strong>Connect with Maintainers</strong><br>
                                  Get matched with project maintainers looking for contributors
                              </div>
                          </li>
                          <li>
                              <div class="feature-icon">📊</div>
                              <div>
                                  <strong>Track Your Journey</strong><br>
                                  Monitor your contributions and build your open source portfolio
                              </div>
                          </li>
                          <li>
                              <div class="feature-icon">🎯</div>
                              <div>
                                  <strong>Smart Matching</strong><br>
                                  Our AI finds the perfect projects based on your experience
                              </div>
                          </li>
                      </ul>
                  </div>

                  <div class="cta-section">
                      <a href="https://gitalong.dev/onboarding" class="cta-button">
                          Complete Your Profile 🎨
                      </a>
                  </div>

                  <div class="tips">
                      <h4>💡 Pro Tip</h4>
                      <p>
                          Complete your profile with your skills, interests, and GitHub information to get better project recommendations. The more we know about you, the better we can match you with exciting opportunities!
                      </p>
                  </div>

                  <div class="message">
                      <strong>Ready to make your mark in open source?</strong><br>
                      Start by setting up your developer profile and let us help you find the perfect projects to contribute to. Every great developer started with their first contribution! 🌱
                  </div>
              </div>

              <div class="footer">
                  <div class="social-links">
                      <a href="https://github.com/gitalong-dev" class="social-link" title="GitHub">📱</a>
                      <a href="https://twitter.com/gitalong_dev" class="social-link" title="Twitter">🐦</a>
                      <a href="https://discord.gg/gitalong" class="social-link" title="Discord">💬</a>
                  </div>
                  
                  <p>
                      Happy coding! 🚀<br>
                      <strong>The GitAlong Team</strong>
                  </p>
                  
                  <p style="margin-top: 20px; font-size: 11px;">
                      You're receiving this email because you verified your email with GitAlong.<br>
                      If you didn't sign up, please ignore this email.
                  </p>
              </div>
          </div>
      </body>
      </html>
      `;

      // Store the welcome email in Firestore to be processed
      await admin.firestore().collection('welcome_emails').add({
        userId: afterData.uid,
        email: email,
        displayName: displayName,
        template: 'welcome_verified_v1',
        htmlContent: welcomeEmailTemplate,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        triggerType: 'email_verification',
        metadata: {
          userAgent: 'firebase-function',
          signupMethod: afterData.providerData?.[0]?.providerId || 'email',
          emailVerified: afterData.emailVerified,
          verificationTime: admin.firestore.FieldValue.serverTimestamp()
        }
      });

      console.log(`✅ Welcome email triggered after verification for: ${email}`);
      return { success: true, email: email, displayName: displayName };

    } catch (error) {
      console.error('❌ Error sending welcome email after verification:', error);
      
      // Log error to Firestore for monitoring
      await admin.firestore().collection('email_errors').add({
        type: 'welcome_email_verification_error',
        userId: afterData.uid,
        email: email,
        error: error.message,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
      
      return { success: false, error: error.message };
    }
  }
  
  return null; // No action needed if email verification didn't change
});

// Keep the original function for manual sending (but remove auto-trigger)
exports.sendWelcomeEmail = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  const displayName = user.displayName || user.email?.split('@')[0] || 'Developer';

  try {
    console.log(`📝 User account created: ${email} (Welcome email will be sent after verification)`);
    
    // Just log the account creation, don't send welcome email yet
    await admin.firestore().collection('user_signups').add({
      userId: user.uid,
      email: email,
      displayName: displayName,
      emailVerified: user.emailVerified,
      signupTime: admin.firestore.FieldValue.serverTimestamp(),
      status: 'awaiting_verification'
    });

    console.log(`✅ User signup logged for: ${email}`);
    return { success: true, email: email, message: 'Account created, awaiting verification' };

  } catch (error) {
    console.error('❌ Error logging user signup:', error);
    return { success: false, error: error.message };
  }
});

// Process welcome emails with beautiful templates
exports.processWelcomeEmails = functions.firestore
  .document('welcome_emails/{emailId}')
  .onCreate(async (snap, context) => {
    const emailData = snap.data();
    const { email, displayName, htmlContent, userId } = emailData;

    try {
      // Here you could integrate with any email service
      // For now, we'll use Firebase's built-in messaging or trigger email via Firestore
      
      // Option 1: Use Firebase Cloud Messaging for in-app notifications
      if (userId) {
        try {
          await admin.messaging().sendToTopic(`user_${userId}`, {
            notification: {
              title: 'Welcome to GitAlong! 🚀',
              body: `Hey ${displayName}! Your developer journey starts now.`,
              icon: 'https://gitalong.dev/icon-192.png'
            },
            data: {
              type: 'welcome',
              action: 'open_onboarding'
            }
          });
          console.log(`Push notification sent to user ${userId}`);
        } catch (notifError) {
          console.warn('Could not send push notification:', notifError);
        }
      }

      // Option 2: Store for email service integration
      await admin.firestore().collection('email_queue').add({
        to: email,
        subject: `Welcome to GitAlong, ${displayName}! 🚀`,
        html: htmlContent,
        type: 'welcome',
        priority: 'high',
        userId: userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'queued'
      });

      // Update status
      await snap.ref.update({
        status: 'queued_for_delivery',
        queuedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`✅ Welcome email queued for delivery: ${email}`);
      
    } catch (error) {
      console.error('❌ Error processing welcome email:', error);
      
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

// Cloud Function to process email verification reminders
exports.processEmailNotifications = functions.firestore
  .document('email_notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const { email, type, message } = notification;

    if (type !== 'verification_reminder') {
      console.log('Skipping non-verification notification:', type);
      return;
    }

    try {
      // Get the user by email
      const userRecord = await admin.auth().getUserByEmail(email);
      
      if (userRecord.emailVerified) {
        console.log('Email already verified for:', email);
        await snap.ref.update({ 
          processed: true, 
          result: 'already_verified',
          processed_at: admin.firestore.FieldValue.serverTimestamp()
        });
        return;
      }

      // Generate verification email link with beautiful template
      const actionCodeSettings = {
        url: 'https://gitalong.dev/email-verified',
        handleCodeInApp: true,
      };

      const verificationLink = await admin.auth().generateEmailVerificationLink(
        email, 
        actionCodeSettings
      );

      // Create beautiful verification email template
      const verificationEmailTemplate = `
      <!DOCTYPE html>
      <html>
      <head>
          <meta charset="UTF-8">
          <style>
              body { font-family: 'Segoe UI', sans-serif; background: #0d1117; margin: 0; padding: 20px; }
              .container { max-width: 500px; margin: 0 auto; background: #21262d; border-radius: 12px; overflow: hidden; }
              .header { background: linear-gradient(135deg, #2ea043, #238636); padding: 30px; text-align: center; }
              .header h2 { color: white; margin: 0; font-size: 24px; }
              .content { padding: 30px; color: #c9d1d9; }
              .verify-btn { 
                  display: inline-block; background: #2ea043; color: white; 
                  padding: 15px 30px; text-decoration: none; border-radius: 8px; 
                  font-weight: bold; margin: 20px 0; 
              }
              .footer { padding: 20px; text-align: center; color: #7d8590; font-size: 12px; }
          </style>
      </head>
      <body>
          <div class="container">
              <div class="header">
                  <h2>📧 Verify Your Email</h2>
              </div>
              <div class="content">
                  <p>Hi there!</p>
                  <p>Please verify your email address to continue using GitAlong and unlock all features.</p>
                  <div style="text-align: center;">
                      <a href="${verificationLink}" class="verify-btn">Verify Email Address</a>
                  </div>
                  <p style="font-size: 13px; color: #7d8590; margin-top: 20px;">
                      If the button doesn't work, copy and paste this link:<br>
                      <a href="${verificationLink}" style="color: #2ea043;">${verificationLink}</a>
                  </p>
              </div>
              <div class="footer">
                  <p>If you didn't request this, you can safely ignore this email.<br>— The GitAlong Team</p>
              </div>
          </div>
      </body>
      </html>
      `;

      // Queue the verification email
      await admin.firestore().collection('email_queue').add({
        to: email,
        subject: 'Please Verify Your Email - GitAlong',
        html: verificationEmailTemplate,
        type: 'verification',
        priority: 'high',
        verificationLink: verificationLink,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'queued'
      });
      
      // Mark notification as processed
      await snap.ref.update({ 
        processed: true, 
        result: 'verification_queued',
        verification_link: verificationLink,
        processed_at: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log('✅ Verification email queued for:', email);
      
    } catch (error) {
      console.error('❌ Error processing verification notification:', error);
      
      await snap.ref.update({ 
        processed: true, 
        result: 'error',
        error_message: error.message,
        processed_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

// Health check endpoint
exports.emailSystemHealth = functions.https.onRequest((req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    services: {
      welcome_emails: 'active',
      verification_emails: 'active',
      email_queue: 'active'
    }
  });
}); 