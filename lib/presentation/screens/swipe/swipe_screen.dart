import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/swipe_entity.dart';
import '../../bloc/discover/discover_bloc.dart';
import '../../bloc/discover/discover_event.dart';
import '../../bloc/discover/discover_state.dart';

/// Swipe screen for discovering developers
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});
  
  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late DiscoverBloc _discoverBloc;

  @override
  void initState() {
    super.initState();
    _discoverBloc = getIt<DiscoverBloc>()..add(LoadRecommendationsEvent());
  }

  @override
  void dispose() {
    _discoverBloc.close();
    super.dispose();
  }

  void _handleSwipe(String userId, SwipeAction action) {
    _discoverBloc.add(SwipeUserEvent(swipedUserId: userId, action: action));
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
              onPressed: () {
                // Open filters logic
              },
            ),
          ],
        ),
        body: BlocConsumer<DiscoverBloc, DiscoverState>(
          listener: (context, state) {
            if (state is DiscoverError) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(state.message)),
               );
            }
            if (state is DiscoverMatch) {
               showDialog(
                 context: context, 
                 builder: (_) => AlertDialog(
                   title: const Text('It\'s a Match! 🎉'),
                   content: Text('You matched with ${state.match.user.name ?? state.match.user.username}!'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Swiping')),
                   ]
                 )
               );
            }
          },
          builder: (context, state) {
            if (state is DiscoverLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DiscoverEmpty) {
              return Center(
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
                      'No more developers to show',
                      style: AppTextStyles.titleMedium(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check back later for more matches',
                      style: AppTextStyles.bodyMedium(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is DiscoverLoaded) {
              if (state.users.isEmpty) return const SizedBox.shrink(); // Handled by empty above usually

              final topUser = state.users.first;
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Swipe Cards Container 
                    Container(
                      width: double.infinity,
                      height: 500.h,
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                color: Colors.blueGrey.shade100,
                                child: (topUser.avatarUrl != null && topUser.avatarUrl!.isNotEmpty)
                                    ? Image.network(topUser.avatarUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(PhosphorIconsRegular.user, size: 80.sp))
                                    : Icon(PhosphorIconsRegular.user, size: 80.sp),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topUser.name ?? topUser.username,
                                      style: AppTextStyles.headlineMedium(Theme.of(context).colorScheme.onSurface),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      topUser.bio ?? 'Developer',
                                      style: AppTextStyles.bodyMedium(Theme.of(context).colorScheme.onSurfaceVariant),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(PhosphorIconsRegular.code, size: 16.sp, color: AppColors.primary),
                                        SizedBox(width: 4.w),
                                        Text('${topUser.publicRepos} Repos'),
                                        SizedBox(width: 16.w),
                                        Icon(PhosphorIconsRegular.users, size: 16.sp, color: AppColors.primary),
                                        SizedBox(width: 4.w),
                                        Text('${topUser.followers} Followers'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dislike Button
                        _ActionButton(
                          icon: PhosphorIconsRegular.x,
                          color: AppColors.swipeDislike,
                          onPressed: () => _handleSwipe(topUser.id, SwipeAction.dislike),
                        ),
                        
                        SizedBox(width: 24.w),
                        
                        // Super Like Button
                        _ActionButton(
                          icon: PhosphorIconsRegular.star,
                          color: AppColors.swipeSuperLike,
                          onPressed: () => _handleSwipe(topUser.id, SwipeAction.superLike),
                        ),
                        
                        SizedBox(width: 24.w),
                        
                        // Like Button
                        _ActionButton(
                          icon: PhosphorIconsRegular.heart,
                          color: AppColors.swipeLike,
                          onPressed: () => _handleSwipe(topUser.id, SwipeAction.like),
                        ),
                      ],
                    ),
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
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, size: 32.sp, color: color),
        onPressed: onPressed,
      ),
    );
  }
}

