import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/match_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';

/// Chat detail screen
class ChatDetailScreen extends StatefulWidget {
  final String matchId;
  
  const ChatDetailScreen({
    super.key,
    required this.matchId,
  });
  
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatBloc _chatBloc;
  String _otherUserId = ''; // Store other user ID
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>()..add(LoadMessagesEvent(widget.matchId));
    
    // We need to resolve `receiverId`. Easiest way is to fetch MatchEntity or user from Auth state
    _fetchUsers();
  }
  
  Future<void> _fetchUsers() async {
     try {
       final authBloc = context.read<AuthBloc>();
       if (authBloc.state is AuthAuthenticated) {
         _currentUserId = (authBloc.state as AuthAuthenticated).user.id;
       }
       
       // Just grab the specific match using repo instance to extract the other user ID
       // Or from a passed-in entity, but we only have string.
       final matchRepo = getIt<MatchRepository>();
       final match = await matchRepo.getMatchById(widget.matchId);
       _otherUserId = match.user.id;
     } catch (e) {
       // Log
     }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatBloc.close();
    super.dispose();
  }
  
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _otherUserId.isEmpty) return;
    
    _chatBloc.add(
      SendMessageEvent(
        matchId: widget.matchId,
        receiverId: _otherUserId,
        content: text,
      )
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is ChatError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  
                  if (state is ChatLoaded) {
                    final messages = state.messages;
                    
                    if (messages.isEmpty) {
                      return Center(
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
                              'No messages yet',
                              style: AppTextStyles.titleMedium(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Send a message to start the conversation',
                              style: AppTextStyles.bodyMedium(
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;
                        
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16.r).copyWith(
                                bottomRight: isMe ? const Radius.circular(0) : null,
                                bottomLeft: !isMe ? const Radius.circular(0) : null,
                              ),
                            ),
                            child: Text(
                              message.content,
                              style: AppTextStyles.bodyMedium(
                                isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
            
            // Message Input
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      PhosphorIconsFill.paperPlaneTilt,
                      size: 24.sp,
                      color: AppColors.primary,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

