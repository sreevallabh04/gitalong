import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_text_styles.dart';

/// Matches screen
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.heart,
              size: 80.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No matches yet',
              style: AppTextStyles.titleMedium(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start swiping to find your matches',
              style: AppTextStyles.bodyMedium(
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



