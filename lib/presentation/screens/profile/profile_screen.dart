import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

/// Profile screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>()..add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(PhosphorIconsRegular.gear, size: 24.sp),
              onPressed: () {
                context.push(RoutePaths.settings);
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
               return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
               return Center(child: Text('Error: ${state.message}'));
            }

            if (state is ProfileLoaded) {
               final user = state.user;
               final matchCount = state.matchCount;
               final chatCount = state.chatCount;

               return SingleChildScrollView(
                 padding: EdgeInsets.all(16.w),
                 child: Column(
                   children: [
                     // Profile Avatar
                     Container(
                       width: 120.w,
                       height: 120.w,
                       decoration: BoxDecoration(
                         gradient: AppColors.primaryGradient,
                         shape: BoxShape.circle,
                       ),
                       child: ClipOval(
                         child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                             ? Image.network(user.avatarUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(PhosphorIconsRegular.user, size: 60.sp, color: Colors.white))
                             : Icon(PhosphorIconsRegular.user, size: 60.sp, color: Colors.white),
                       ),
                     ),
                     
                     SizedBox(height: 16.h),
                     
                     // Name
                     Text(
                       user.name ?? user.username,
                       style: AppTextStyles.headlineSmall(
                         Theme.of(context).colorScheme.onSurface,
                       ),
                     ),
                     
                     SizedBox(height: 4.h),
                     
                     // Username
                     Text(
                       '@${user.username}',
                       style: AppTextStyles.bodyLarge(
                         Theme.of(context).colorScheme.onSurfaceVariant,
                       ),
                     ),
                     
                     SizedBox(height: 24.h),
                     
                     // Stats
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         _StatItem(
                           icon: PhosphorIconsRegular.heart,
                           label: 'Matches',
                           value: matchCount.toString(),
                         ),
                         _StatItem(
                           icon: PhosphorIconsRegular.chatCircle,
                           label: 'Chats',
                           value: chatCount.toString(),
                         ),
                         _StatItem(
                           icon: PhosphorIconsRegular.githubLogo,
                           label: 'Repos',
                           value: user.publicRepos.toString(),
                         ),
                       ],
                     ),
                     
                     SizedBox(height: 32.h),
                     
                     // Edit Profile Button
                     SizedBox(
                       width: double.infinity,
                       child: OutlinedButton.icon(
                         onPressed: () {
                           // Open github url or a web view to edit
                         },
                         icon: Icon(PhosphorIconsRegular.pencil, size: 20.sp),
                         label: const Text('Edit Profile'),
                       ),
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

/// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32.sp, color: AppColors.primary),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTextStyles.titleLarge(
            Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.bodySmall(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}



