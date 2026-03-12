import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/match_entity.dart';
import '../../bloc/matches/matches_bloc.dart';
import '../../bloc/matches/matches_event.dart';
import '../../bloc/matches/matches_state.dart';

/// Chat list screen — shows active conversations ordered by recency
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late MatchesBloc _matchesBloc;

  @override
  void initState() {
    super.initState();
    _matchesBloc = getIt<MatchesBloc>()..add(LoadMatchesEvent());
  }

  @override
  void dispose() {
    _matchesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchesBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            if (state is MatchesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MatchesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsRegular.wifiX,
                      size: 64.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Something went wrong',
                      style: AppTextStyles.titleMedium(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () => _matchesBloc.add(RefreshMatchesEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (state is MatchesLoaded) {
              // Show all matches (with or without messages) sorted by recency
              final conversations = List<MatchEntity>.from(state.matches)
                ..sort((a, b) {
                  final aTime = a.lastMessageAt ?? a.matchedAt;
                  final bTime = b.lastMessageAt ?? b.matchedAt;
                  return bTime.compareTo(aTime);
                });

              if (conversations.isEmpty) {
                return _EmptyChatsView();
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    _matchesBloc.add(RefreshMatchesEvent()),
                child: ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final match = conversations[index];
                    return _ChatTile(
                      match: match,
                      onTap: () {
                        context.push(
                          '/chats/${match.id}',
                          extra: {
                            'otherUserName':
                                match.user.name ?? match.user.username,
                            'otherUserAvatar': match.user.avatarUrl,
                          },
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _EmptyChatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
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
              textAlign: TextAlign.center,
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

class _ChatTile extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onTap;

  const _ChatTile({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = !match.isRead && match.lastMessage != null;
    final timeAgo = _formatTime(match.lastMessageAt ?? match.matchedAt);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      leading: CircleAvatar(
        radius: 28.r,
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        backgroundImage: match.user.avatarUrl != null
            ? CachedNetworkImageProvider(match.user.avatarUrl!)
            : null,
        child: match.user.avatarUrl == null
            ? Icon(PhosphorIconsRegular.user, size: 24.sp)
            : null,
      ),
      title: Text(
        match.user.name ?? match.user.username,
        style: hasUnread
            ? AppTextStyles.titleSmall(
                Theme.of(context).colorScheme.onSurface)
            : AppTextStyles.bodyMedium(
                Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(
        match.lastMessage ?? 'Matched! Say hi 👋',
        style: hasUnread
            ? AppTextStyles.bodyMedium(AppColors.primary)
            : AppTextStyles.bodyMedium(
                Theme.of(context).colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeAgo,
            style: AppTextStyles.bodySmall(
              hasUnread
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasUnread) ...[
            SizedBox(height: 4.h),
            Container(
              width: 10.r,
              height: 10.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
