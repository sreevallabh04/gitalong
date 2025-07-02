const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
const SENDGRID_API_KEY = functions.config().sendgrid.key;
sgMail.setApiKey(SENDGRID_API_KEY);

exports.sendWelcomeEmail = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  const displayName = user.displayName || email.split('@')[0];

  const msg = {
    to: email,
    from: {
      email: 'welcome@gitalong.dev',
      name: 'Gitalong Team'
    },
    subject: `Welcome to Gitalong, ${displayName}!`,
    html: `
      <div style="background:#0D1117;padding:32px;border-radius:12px;color:#C9D1D9;font-family:'JetBrains Mono',monospace;">
        <h2 style="color:#2EA043;">Hey ${displayName}, welcome to Gitalong! 👋</h2>
        <p>We're excited to help you contribute to open-source. 🧑‍💻✨</p>
        <hr style="border:1px solid #21262D;">
        <h3>Getting Started</h3>
        <ul>
          <li><a href="https://docs.gitalong.dev" style="color:#2EA043;">Read the Docs</a></li>
          <li><a href="https://github.com/gitalong-dev/gitalong" style="color:#2EA043;">GitHub Repo</a></li>
          <li><a href="https://discord.gg/yourdiscord" style="color:#2EA043;">Join our Discord</a></li>
        </ul>
        <p style="margin-top:32px;font-size:13px;color:#7D8590;">Happy hacking!<br/>— The Gitalong Team</p>
      </div>
    `
  };

  try {
    await sgMail.send(msg);
    console.log('Welcome email sent to', email);
  } catch (error) {
    console.error('Error sending welcome email:', error);
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

      // Generate verification email link
      const actionCodeSettings = {
        url: 'https://gitalong.dev/email-verified', // Your app's verification completion URL
        handleCodeInApp: true,
      };

      const verificationLink = await admin.auth().generateEmailVerificationLink(
        email, 
        actionCodeSettings
      );

      // Send custom verification email via SendGrid
      const msg = {
        to: email,
        from: {
          email: 'noreply@gitalong.dev',
          name: 'Gitalong Team'
        },
        subject: 'Please Verify Your Email - Gitalong',
        html: `
          <div style="background:#0D1117;padding:32px;border-radius:12px;color:#C9D1D9;font-family:'JetBrains Mono',monospace;">
            <h2 style="color:#2EA043;">Email Verification Required 📧</h2>
            <p>Hi there!</p>
            <p>Please verify your email address to continue using Gitalong.</p>
            <div style="margin:24px 0;">
              <a href="${verificationLink}" 
                 style="background:#2EA043;color:#FFFFFF;padding:12px 24px;text-decoration:none;border-radius:6px;display:inline-block;">
                Verify Email Address
              </a>
            </div>
            <p style="font-size:13px;color:#7D8590;">
              If the button doesn't work, copy and paste this link into your browser:<br/>
              <a href="${verificationLink}" style="color:#2EA043;">${verificationLink}</a>
            </p>
            <hr style="border:1px solid #21262D;margin:24px 0;">
            <p style="font-size:13px;color:#7D8590;">
              If you didn't request this email, you can safely ignore it.<br/>
              — The Gitalong Team
            </p>
          </div>
        `
      };

      await sgMail.send(msg);
      
      // Mark notification as processed
      await snap.ref.update({ 
        processed: true, 
        result: 'verification_sent',
        verification_link: verificationLink,
        processed_at: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log('Verification email sent to:', email);
    } catch (error) {
      console.error('Error processing verification notification:', error);
      
      // Mark notification as failed
      await snap.ref.update({ 
        processed: true, 
        result: 'error',
        error_message: error.message,
        processed_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

// Cloud Function to resend verification emails for unverified users
exports.resendVerificationEmails = functions.https.onCall(async (data, context) => {
  // Check if the request is from an authenticated admin user
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admin users can trigger bulk verification emails.'
    );
  }

  try {
    let nextPageToken;
    let totalSent = 0;
    let totalErrors = 0;

    do {
      // List users in batches
      const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
      
      const unverifiedUsers = listUsersResult.users.filter(user => 
        user.email && !user.emailVerified
      );

      // Process users in parallel (but limit concurrency)
      const batchPromises = unverifiedUsers.map(async (user) => {
        try {
          // Create notification document to trigger the email function
          await admin.firestore().collection('email_notifications').add({
            email: user.email,
            type: 'verification_reminder',
            message: 'Bulk verification reminder',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            processed: false,
            triggered_by: 'admin_bulk_resend'
          });
          
          totalSent++;
        } catch (error) {
          console.error(`Error creating notification for ${user.email}:`, error);
          totalErrors++;
        }
      });

      await Promise.all(batchPromises);
      nextPageToken = listUsersResult.pageToken;
    } while (nextPageToken);

    return {
      success: true,
      totalSent,
      totalErrors,
      message: `Triggered verification emails for ${totalSent} users with ${totalErrors} errors.`
    };
  } catch (error) {
    console.error('Error in bulk verification:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to process bulk verification emails.'
    );
  }
}); 