import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Chat list screen showing all conversations
class ChatListScreen extends StatelessWidget {
  /// Creates the chat list screen
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO(chat): Implement search
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildChatItem(context, index);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    final chatData = [
      {
        'name': 'Alex Chen',
        'lastMessage': 'Hey! I saw your project on GitHub, it looks amazing!',
        'time': '2 min ago',
        'unread': 2,
        'isOnline': true,
      },
      {
        'name': 'Sarah Johnson',
        'lastMessage': 'Thanks for the collaboration opportunity!',
        'time': '1 hour ago',
        'unread': 0,
        'isOnline': false,
      },
      {
        'name': 'Mike Wilson',
        'lastMessage': 'Can we schedule a call to discuss the project?',
        'time': '3 hours ago',
        'unread': 1,
        'isOnline': true,
      },
      {
        'name': 'EcoTracker Team',
        'lastMessage': 'New feature added to the project!',
        'time': '1 day ago',
        'unread': 0,
        'isOnline': false,
      },
      {
        'name': 'DevTools Suite',
        'lastMessage': 'Welcome to the project!',
        'time': '2 days ago',
        'unread': 0,
        'isOnline': false,
      },
    ];

    final chat = chatData[index];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: const Color(0xFF6366F1),
                size: 25.sp,
              ),
            ),
            if (chat['isOnline'] as bool)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat['name'] as String,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          chat['lastMessage'] as String,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat['time'] as String,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            if ((chat['unread'] as int) > 0) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${chat['unread']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          // TODO(chat): Navigate to chat detail
        },
      ),
    );
  }
}
