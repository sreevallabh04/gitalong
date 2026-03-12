import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final headStyle = AppTextStyles.titleMedium(colors.onSurface);
    final bodyStyle = AppTextStyles.bodyMedium(colors.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last updated: March 12, 2026', style: bodyStyle),
            SizedBox(height: 20.h),

            Text('1. Service Description', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'GitAlong is a developer-matching platform that connects '
              'software developers based on shared programming languages, '
              'interests, and GitHub activity. The service is provided '
              '"as is" and is intended for personal, non-commercial use.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('2. Eligibility', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'You must be at least 13 years of age to use GitAlong. By '
              'creating an account, you represent that you meet this '
              'requirement and have the authority to agree to these terms.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('3. User Accounts', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'You are responsible for maintaining the security of your '
              'account. You may not impersonate another person or create '
              'multiple accounts. We reserve the right to suspend or '
              'terminate accounts that violate these terms.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('4. Acceptable Use', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'You agree not to:\n'
              '- Harass, abuse, or threaten other users.\n'
              '- Post spam, misleading content, or malicious links.\n'
              '- Attempt to reverse-engineer or exploit the service.\n'
              '- Use the platform for any illegal activity.\n'
              '- Scrape or bulk-collect user data.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('5. Content & Intellectual Property', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'You retain ownership of the content you submit (profile info, '
              'messages). By submitting content, you grant GitAlong a limited '
              'licence to display it within the service. GitAlong\'s branding, '
              'design, and code remain our intellectual property.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('6. Termination', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'You may delete your account at any time from the Settings '
              'screen. We may also suspend or terminate your access if you '
              'violate these terms, with or without prior notice.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('7. Disclaimers', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'GitAlong is provided "as is" without warranty of any kind. We '
              'do not guarantee uninterrupted service, the accuracy of '
              'recommendations, or the behaviour of other users.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('8. Limitation of Liability', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'To the maximum extent permitted by law, GitAlong shall not be '
              'liable for any indirect, incidental, special, or consequential '
              'damages arising from your use of the service.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('9. Changes to These Terms', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'We may update these terms from time to time. Continued use of '
              'the app after changes are posted constitutes acceptance of the '
              'revised terms.',
              style: bodyStyle,
            ),
            SizedBox(height: 16.h),

            Text('10. Contact', style: headStyle),
            SizedBox(height: 8.h),
            Text(
              'For questions about these terms, contact us at '
              'support@gitalong.app.',
              style: bodyStyle,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
