import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/feedback_service.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

/// Profile screen — premium glassmorphic design
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late ProfileBloc _profileBloc;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>()..add(LoadProfileEvent());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(PhosphorIconsRegular.gear, size: 24.sp),
              onPressed: () {
                FeedbackService.onButtonPress();
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
              return _buildProfile(context, state, colors, isDark);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    ProfileLoaded state,
    ColorScheme colors,
    bool isDark,
  ) {
    final user = state.user;
    final matchCount = state.matchCount;
    final chatCount = state.chatCount;

    return RefreshIndicator(
      onRefresh: () async => _profileBloc.add(LoadProfileEvent()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Hero header with gradient bg ──
            _buildHeroHeader(context, user, isDark),

            // ── Stats row (glassmorphic cards) ──
            Transform.translate(
              offset: Offset(0, -30.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _GlassStatsRow(
                  matchCount: matchCount,
                  chatCount: chatCount,
                  repoCount: user.publicRepos,
                  followers: user.followers,
                ),
              ),
            ),

            // ── Languages section ──
            if (user.languages.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _LanguagesSection(languages: user.languages),
              ),

            SizedBox(height: 16.h),

            // ── Quick actions ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _QuickActions(
                githubUrl: user.githubUrl,
                onEditProfile: () async {
                  FeedbackService.onButtonPress();
                  await context.push(RoutePaths.editProfile);
                  if (context.mounted) {
                    _profileBloc.add(LoadProfileEvent());
                  }
                },
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, dynamic user, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 8.h,
        bottom: 50.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A2E1A),
                  const Color(0xFF0D1F0D),
                  const Color(0xFF0A0A0A),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                  Colors.white,
                ],
        ),
      ),
      child: Column(
        children: [
          // Animated avatar ring
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    startAngle: _animController.value * 2 * math.pi,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.3),
                      const Color(0xFF10B981),
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary,
                    ],
                  ),
                ),
                padding: EdgeInsets.all(3.w),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  padding: EdgeInsets.all(3.w),
                  child: ClipOval(
                    child: (user.avatarUrl != null &&
                            user.avatarUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: user.avatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(PhosphorIconsRegular.user,
                                  size: 50.sp, color: AppColors.primary),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(PhosphorIconsRegular.user,
                                  size: 50.sp, color: AppColors.primary),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(PhosphorIconsRegular.user,
                                size: 50.sp, color: AppColors.primary),
                          ),
                  ),
                ),
              );
            },
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

          // Username badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsRegular.githubLogo,
                    size: 14.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  '@${user.username}',
                  style: AppTextStyles.labelMedium(AppColors.primary),
                ),
              ],
            ),
          ),

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                user.bio!,
                style: AppTextStyles.bodyMedium(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          if (user.location != null && user.location!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.mapPin,
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text(
                  user.location!,
                  style: AppTextStyles.bodySmall(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Glassmorphic stats row
class _GlassStatsRow extends StatelessWidget {
  final int matchCount;
  final int chatCount;
  final int repoCount;
  final int followers;

  const _GlassStatsRow({
    required this.matchCount,
    required this.chatCount,
    required this.repoCount,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GlassStat(
            icon: PhosphorIconsFill.heart,
            value: matchCount.toString(),
            label: 'Matches',
            color: const Color(0xFFEF4444),
          ),
          _divider(context),
          _GlassStat(
            icon: PhosphorIconsFill.chatCircle,
            value: chatCount.toString(),
            label: 'Chats',
            color: const Color(0xFF3B82F6),
          ),
          _divider(context),
          _GlassStat(
            icon: PhosphorIconsFill.gitBranch,
            value: repoCount.toString(),
            label: 'Repos',
            color: AppColors.primary,
          ),
          _divider(context),
          _GlassStat(
            icon: PhosphorIconsFill.users,
            value: followers.toString(),
            label: 'Followers',
            color: const Color(0xFFA855F7),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 40.h,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _GlassStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTextStyles.titleMedium(
            Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.labelSmall(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Languages as colorful progress-style chips
class _LanguagesSection extends StatelessWidget {
  final List<String> languages;
  const _LanguagesSection({required this.languages});

  static const _langColors = <String, Color>{
    'javascript': Color(0xFFF7DF1E),
    'typescript': Color(0xFF3178C6),
    'python': Color(0xFF3776AB),
    'dart': Color(0xFF0175C2),
    'java': Color(0xFFED8B00),
    'kotlin': Color(0xFF7F52FF),
    'swift': Color(0xFFF05138),
    'go': Color(0xFF00ADD8),
    'rust': Color(0xFFDEA584),
    'c++': Color(0xFF00599C),
    'c#': Color(0xFF239120),
    'ruby': Color(0xFFCC342D),
    'php': Color(0xFF777BB4),
    'html': Color(0xFFE34F26),
    'css': Color(0xFF1572B6),
    'shell': Color(0xFF89E051),
    'c': Color(0xFFA8B9CC),
  };

  Color _getColor(String lang) {
    return _langColors[lang.toLowerCase()] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsFill.code, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              'Tech Stack',
              style: AppTextStyles.titleSmall(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: languages
              .take(12)
              .map((lang) => _LanguageChip(
                    language: lang,
                    color: _getColor(lang),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String language;
  final Color color;

  const _LanguageChip({required this.language, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            language,
            style: AppTextStyles.labelMedium(
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action buttons
class _QuickActions extends StatelessWidget {
  final String? githubUrl;
  final VoidCallback onEditProfile;

  const _QuickActions({
    required this.githubUrl,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Edit profile — primary action
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: onEditProfile,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsRegular.pencilSimple,
                        size: 20.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      'Edit Profile',
                      style: AppTextStyles.titleSmall(Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (githubUrl != null) ...[
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  FeedbackService.onButtonPress();
                  launchUrl(Uri.parse(githubUrl!),
                      mode: LaunchMode.externalApplication);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.githubLogo,
                          size: 20.sp,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      SizedBox(width: 8.w),
                      Text(
                        'View on GitHub',
                        style: AppTextStyles.titleSmall(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(PhosphorIconsRegular.arrowSquareOut,
                          size: 16.sp,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
