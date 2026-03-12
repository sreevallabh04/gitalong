import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final headStyle = AppTextStyles.titleMedium(colors.onSurface);
    final bodyStyle = AppTextStyles.bodyMedium(colors.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: March 12, 2026', style: bodyStyle),
            SizedBox(height: 20.h),

            Text('1. Information We Collect', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'When you sign in with GitHub, we collect your public profile '
              'information including your username, display name, avatar, bio, '
              'location, company, email address, public repository metadata, '
              'and programming language usage statistics.\n\n'
              'We also collect usage data such as swipe activity, matches, and '
              'chat messages that you send through the app.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('2. How We Use Your Information', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              '- To create and manage your GitAlong profile.\n'
              '- To generate personalised developer recommendations based on '
              'your languages, interests, and GitHub activity.\n'
              '- To facilitate matches and real-time chat between users.\n'
              '- To improve the app experience and fix issues.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('3. Data Sharing', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'Your public profile information is visible to other GitAlong '
              'users. We do not sell your personal data to third parties. We '
              'may share anonymised, aggregated data for analytics purposes.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('4. Data Storage & Security', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'Your data is stored securely in Supabase (hosted on AWS) with '
              'row-level security policies. Chat messages are transmitted via '
              'encrypted channels. We retain your data for as long as your '
              'account is active.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('5. Your Rights', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'You may view and edit your profile at any time. You can delete '
              'your account and all associated data from the Settings screen. '
              'Upon deletion, your profile, matches, and messages are '
              'permanently removed.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('6. Third-Party Services', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'GitAlong uses the GitHub API to retrieve your public profile '
              'and repository data. Your use of GitHub is subject to GitHub\'s '
              'own privacy policy. We also use Google Sign-In and Sign in with '
              'Apple as alternative authentication methods, each governed by '
              'their respective privacy policies.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('7. Changes to This Policy', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'We may update this privacy policy from time to time. We will '
              'notify you of significant changes via the app or email.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('8. Contact Us', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'If you have questions about this privacy policy, please contact '
              'us at support@gitalong.app.',
              style: bodyStyle,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
