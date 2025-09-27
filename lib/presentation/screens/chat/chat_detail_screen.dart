import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Chat detail screen for individual conversations
class ChatDetailScreen extends StatelessWidget {
  /// ID of the chat
  final String chatId;

  /// Creates the chat detail screen
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildMessageBubble(context, index);
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, int index) {
    final isMe = index % 2 == 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: const Color(0xFF6366F1),
                size: 16.sp,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF6366F1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'This is a sample message ${index + 1}',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 16.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                // TODO(chat): Send message
              },
            ),
          ),
        ],
      ),
    );
  }
}
