import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/swipe_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/discover/discover_bloc.dart';
import '../../bloc/discover/discover_event.dart';
import '../../bloc/discover/discover_state.dart';

/// Swipe screen for discovering developers
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with SingleTickerProviderStateMixin {
  late DiscoverBloc _discoverBloc;

  // Drag state
  double _dragX = 0;
  double _dragY = 0;

  // Animation when card snaps back
  late final AnimationController _snapController;
  late Animation<double> _snapX;
  late Animation<double> _snapY;

  // Threshold (px) to trigger a swipe
  static const double _swipeThreshold = 100;

  @override
  void initState() {
    super.initState();
    _discoverBloc = getIt<DiscoverBloc>()..add(LoadRecommendationsEvent());

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _dragX = _snapX.value;
          _dragY = _snapY.value;
        });
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    _discoverBloc.close();
    super.dispose();
  }

  void _handleSwipe(String userId, SwipeAction action) {
    _discoverBloc.add(SwipeUserEvent(swipedUserId: userId, action: action));
    setState(() {
      _dragX = 0;
      _dragY = 0;
    });
  }

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy;
    });
  }

  void _onDragEnd(DragEndDetails details, String userId) {

    if (_dragX > _swipeThreshold) {
      _handleSwipe(userId, SwipeAction.like);
    } else if (_dragX < -_swipeThreshold) {
      _handleSwipe(userId, SwipeAction.dislike);
    } else if (_dragY < -_swipeThreshold) {
      _handleSwipe(userId, SwipeAction.superLike);
    } else {
      // Snap back
      _snapX = Tween<double>(begin: _dragX, end: 0).animate(
        CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
      );
      _snapY = Tween<double>(begin: _dragY, end: 0).animate(
        CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
      );
      _snapController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _discoverBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          actions: [
            IconButton(
              icon: Icon(PhosphorIconsRegular.funnel, size: 24.sp),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocConsumer<DiscoverBloc, DiscoverState>(
          listener: (context, state) {
            if (state is DiscoverMatch) {
              _showMatchDialog(context, state);
            }
          },
          builder: (context, state) {
            if (state is DiscoverLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DiscoverError) {
              return _ErrorRetryView(
                message: state.message,
                onRetry: () =>
                    _discoverBloc.add(LoadRecommendationsEvent()),
              );
            }

            if (state is DiscoverEmpty) {
              return _EmptyView(
                onRefresh: () =>
                    _discoverBloc.add(LoadRecommendationsEvent()),
              );
            }

            if (state is DiscoverLoaded) {
              if (state.users.isEmpty) {
                return _EmptyView(
                  onRefresh: () =>
                      _discoverBloc.add(LoadRecommendationsEvent()),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background card (next user)
                          if (state.users.length > 1)
                            _buildCard(
                              context,
                              state.users[1],
                              scale: 0.95,
                              elevation: 1,
                            ),
                          // Top card (draggable)
                          GestureDetector(
                            onPanStart: _onDragStart,
                            onPanUpdate: _onDragUpdate,
                            onPanEnd: (d) =>
                                _onDragEnd(d, state.users.first.id),
                            child: _buildDraggableCard(
                              context,
                              state.users.first,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding:
                        EdgeInsets.only(bottom: 32.h, left: 32.w, right: 32.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: PhosphorIconsRegular.x,
                          color: AppColors.swipeDislike,
                          onPressed: () => _handleSwipe(
                              state.users.first.id, SwipeAction.dislike),
                        ),
                        _ActionButton(
                          icon: PhosphorIconsRegular.star,
                          color: AppColors.swipeSuperLike,
                          size: 52.w,
                          onPressed: () => _handleSwipe(
                              state.users.first.id, SwipeAction.superLike),
                        ),
                        _ActionButton(
                          icon: PhosphorIconsRegular.heart,
                          color: AppColors.swipeLike,
                          onPressed: () => _handleSwipe(
                              state.users.first.id, SwipeAction.like),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDraggableCard(BuildContext context, UserEntity user) {
    final angle = _dragX / 1000;
    final opacity = (_dragX.abs() / _swipeThreshold).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(_dragX, _dragY),
      child: Transform.rotate(
        angle: angle,
        child: Stack(
          children: [
            _buildCard(context, user),
            // Like overlay
            if (_dragX > 20)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.swipeLike.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -0.3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.swipeLike, width: 3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'LIKE',
                            style: AppTextStyles.headlineMedium(
                                AppColors.swipeLike),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Nope overlay
            if (_dragX < -20)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.swipeDislike.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: 0.3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.swipeDislike, width: 3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'NOPE',
                            style: AppTextStyles.headlineMedium(
                                AppColors.swipeDislike),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Super Like overlay
            if (_dragY < -20)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: (_dragY.abs() / _swipeThreshold).clamp(0.0, 1.0),
                  duration: Duration.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.swipeSuperLike.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.swipeSuperLike, width: 3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'SUPER',
                          style: AppTextStyles.headlineMedium(
                              AppColors.swipeSuperLike),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    UserEntity user, {
    double scale = 1.0,
    double elevation = 4,
  }) {
    return Transform.scale(
      scale: scale,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar / Hero Image
              Expanded(
                flex: 3,
                child: user.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Icon(PhosphorIconsRegular.user,
                              size: 80.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Icon(PhosphorIconsRegular.user, size: 80.sp),
                        ),
                      )
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Icon(PhosphorIconsRegular.user,
                            size: 80.sp,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
              ),
              // Info section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name ?? user.username,
                              style: AppTextStyles.headlineSmall(
                                  Theme.of(context).colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.matchScore != null)
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '${user.matchScore!.toInt()}% Match',
                                style: AppTextStyles.labelSmall(Colors.white),
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '@${user.username}',
                              style: AppTextStyles.bodySmall(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      if (user.bio != null)
                        Text(
                          user.bio!,
                          style: AppTextStyles.bodyMedium(
                              Theme.of(context).colorScheme.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          _InfoChip(
                              icon: PhosphorIconsRegular.code,
                              label: '${user.publicRepos} repos'),
                          SizedBox(width: 8.w),
                          _InfoChip(
                              icon: PhosphorIconsRegular.users,
                              label: '${user.followers} followers'),
                          if (user.location != null) ...[
                            SizedBox(width: 8.w),
                            _InfoChip(
                                icon: PhosphorIconsRegular.mapPin,
                                label: user.location!,
                                maxWidth: 100.w),
                          ],
                        ],
                      ),
                      if (user.languages.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          children: user.languages
                              .take(4)
                              .map((lang) => _LanguageChip(lang: lang))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchDialog(BuildContext context, DiscoverMatch state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉', style: TextStyle(fontSize: 60.sp)),
            SizedBox(height: 16.h),
            Text(
              "It's a Match!",
              style: AppTextStyles.headlineMedium(
                  Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 8.h),
            Text(
              'You and ${state.match.user.name ?? state.match.user.username} liked each other.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                  Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Keep Swiping'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                        '/chats/${state.match.id}',
                        extra: {
                          'otherUserName': state.match.user.name ??
                              state.match.user.username,
                          'otherUserAvatar': state.match.user.avatarUrl,
                        },
                      );
                    },
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback? onRefresh;

  const _EmptyView({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.cards,
              size: 80.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No more developers',
              style: AppTextStyles.titleMedium(
                  Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for more matches',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                  Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            if (onRefresh != null) ...[
              SizedBox(height: 24.h),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: Icon(PhosphorIconsRegular.arrowClockwise, size: 18.sp),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetryView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.warning,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleMedium(
                  Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium(
                  Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(PhosphorIconsRegular.arrowClockwise, size: 18.sp),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double? size;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final sz = size ?? 64.w;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, size: sz * 0.45, color: color),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? maxWidth;

  const _InfoChip(
      {required this.icon, required this.label, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.primary),
        SizedBox(width: 4.w),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Text(
            label,
            style: AppTextStyles.bodySmall(
                Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String lang;

  const _LanguageChip({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        lang,
        style: AppTextStyles.labelSmall(
            Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
