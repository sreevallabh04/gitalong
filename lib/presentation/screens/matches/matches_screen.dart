import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/feedback_service.dart';
import '../../../domain/entities/match_entity.dart';
import '../../bloc/matches/matches_bloc.dart';
import '../../bloc/matches/matches_event.dart';
import '../../bloc/matches/matches_state.dart';

/// Matches screen — new matches row + all matches list
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
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
          title: const Text('Matches'),
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
                      onPressed: () =>
                          _matchesBloc.add(RefreshMatchesEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (state is MatchesLoaded) {
              if (state.matches.isEmpty) {
                return _EmptyMatchesView();
              }

              final newMatches = state.matches
                  .where((m) => m.lastMessage == null)
                  .toList();
              final conversations = state.matches
                  .where((m) => m.lastMessage != null)
                  .toList()
                ..sort((a, b) {
                  final aTime = a.lastMessageAt ?? a.matchedAt;
                  final bTime = b.lastMessageAt ?? b.matchedAt;
                  return bTime.compareTo(aTime);
                });

              return RefreshIndicator(
                onRefresh: () async =>
                    _matchesBloc.add(RefreshMatchesEvent()),
                child: CustomScrollView(
                  slivers: [
                    // New Matches horizontal row
                    if (newMatches.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          child: Text(
                            'New Matches',
                            style: AppTextStyles.titleMedium(
                              Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 100.h,
                          child: ListView.separated(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: newMatches.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: 16.w),
                            itemBuilder: (context, index) {
                              return _NewMatchAvatar(
                                match: newMatches[index],
                                onTap: () =>
                                    _openChat(context, newMatches[index]),
                              ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.2);
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                    ],

                    // Conversations section
                    if (conversations.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                          child: Text(
                            'Messages',
                            style: AppTextStyles.titleMedium(
                              Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ConversationTile(
                          match: conversations[index],
                          onTap: () =>
                              _openChat(context, conversations[index]),
                        ).animate().fade(duration: 500.ms, delay: (index * 30).ms).slideY(begin: 0.1),
                        childCount: conversations.length,
                      ),
                    ),

                    // If only new matches, show nudge
                    if (conversations.isEmpty && newMatches.isNotEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIconsRegular.chatCircleDots,
                                  size: 64.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Start a conversation!',
                                  style: AppTextStyles.titleMedium(
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Tap a match above to send the first message.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium(
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _openChat(BuildContext context, MatchEntity match) {
    FeedbackService.onButtonPress();
    context.push(
      '/chats/${match.id}',
      extra: {
        'otherUserName': match.user.name ?? match.user.username,
        'otherUserAvatar': match.user.avatarUrl,
      },
    );
  }
}

class _EmptyMatchesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
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
              'Start swiping to find your dev matches',
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

class _NewMatchAvatar extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onTap;

  const _NewMatchAvatar({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage: match.user.avatarUrl != null
                    ? CachedNetworkImageProvider(match.user.avatarUrl!)
                    : null,
                child: match.user.avatarUrl == null
                    ? Icon(PhosphorIconsRegular.user, size: 28.sp)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14.r,
                  height: 14.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 64.w,
            child: Text(
              match.user.name ?? match.user.username,
              style: AppTextStyles.bodySmall(
                Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onTap;

  const _ConversationTile({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = !match.isRead;
    final timeAgo = _formatTime(match.lastMessageAt ?? match.matchedAt);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
        match.lastMessage ?? 'Say hi! 👋',
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
