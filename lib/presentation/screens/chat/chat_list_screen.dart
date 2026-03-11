import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_text_styles.dart';

/// Chat list screen
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.chatCircle,
              size: 80.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No conversations yet',
              style: AppTextStyles.titleMedium(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Match with developers to start chatting',
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



