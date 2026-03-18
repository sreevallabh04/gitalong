import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../domain/repositories/match_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';

/// Chat detail screen
class ChatDetailScreen extends StatefulWidget {
  final String matchId;
  final String? otherUserName;
  final String? otherUserAvatar;

  const ChatDetailScreen({
    super.key,
    required this.matchId,
    this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  String _otherUserId = '';
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>()..add(LoadMessagesEvent(widget.matchId));
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state is AuthAuthenticated) {
        _currentUserId = (authBloc.state as AuthAuthenticated).user.id;
      }

      final matchRepo = getIt<MatchRepository>();
      final match = await matchRepo.getMatchById(widget.matchId);
      if (mounted) {
        setState(() {
          _otherUserId = match.user.id;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _otherUserId.isEmpty) return;

    FeedbackService.onMessageSent();
    _chatBloc.add(
      SendMessageEvent(
        matchId: widget.matchId,
        receiverId: _otherUserId,
        content: text,
      ),
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatSendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40.w,
          title: Row(
            children: [
              _buildAvatar(),
              SizedBox(width: 12.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName ?? 'Chat',
                      style: AppTextStyles.titleSmall(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Matched',
                      style: AppTextStyles.labelSmall(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: AppTextStyles.bodyMedium(
                          Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('👋', style: TextStyle(fontSize: 48.sp)),
                            SizedBox(height: 16.h),
                            Text(
                              'Say hi to ${widget.otherUserName ?? 'your match'}!',
                              style: AppTextStyles.titleSmall(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'You matched — start the conversation',
                              style: AppTextStyles.bodySmall(
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius:
                                      BorderRadius.circular(18.r).copyWith(
                                    bottomRight: isMe
                                        ? const Radius.circular(4)
                                        : null,
                                    bottomLeft: !isMe
                                        ? const Radius.circular(4)
                                        : null,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message.content,
                                      style: AppTextStyles.bodyMedium(
                                        isMe
                                            ? Colors.black87
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      _formatTime(message.sentAt),
                                      style: AppTextStyles.labelSmall(
                                        isMe
                                            ? Colors.black54
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
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
              padding:
                  EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h + MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        PhosphorIconsFill.paperPlaneTilt,
                        size: 20.sp,
                        color: Colors.black87,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAvatar() {
    final url = widget.otherUserAvatar;
    return CircleAvatar(
      radius: 18.r,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                width: 36.r,
                height: 36.r,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Icon(
                  PhosphorIconsRegular.user,
                  size: 18.r,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                PhosphorIconsRegular.user,
                size: 18.r,
                color: AppColors.primary,
              ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
