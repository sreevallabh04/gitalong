import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

import '../../providers/contributions_provider.dart';
import '../../core/utils/logger.dart';
import '../../models/models.dart';
import '../../widgets/profile/role_switch_card.dart';
import '../../widgets/profile/stats_card.dart';
import '../../widgets/profile/project_preview_card.dart';
import '../../core/widgets/responsive_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _roleSwitchController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _roleSwitchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Start animations
    _headerController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _roleSwitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              const Color(0xFF0D1117),
              const Color(0xFF0D1117),
            ],
          ),
        ),
        child: userProfileAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stackTrace) => _buildErrorState(error.toString()),
          data: (userProfile) {
            if (userProfile == null) {
              return _buildNoProfileState();
            }
            return _buildProfileContent(userProfile, currentUser);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms)
              .scale(
                  begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
          const SizedBox(height: 24),
          Text(
            'Loading Profile...',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              color: const Color(0xFF7D8590),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning,
            color: Color(0xFFDA3633),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Profile',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              color: const Color(0xFFF0F6FC),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7D8590)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(userProfileProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off,
            color: Color(0xFF7D8590),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Not Found',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              color: const Color(0xFFF0F6FC),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete your profile setup',
            style: TextStyle(color: Color(0xFF7D8590)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/onboarding'),
            child: const Text('Setup Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(UserModel userProfile, User? currentUser) {
    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverToBoxAdapter(
          child: _buildProfileHeader(userProfile, currentUser)
              .animate(controller: _headerController)
              .fadeIn(duration: 800.ms)
              .slideY(begin: -0.3, curve: Curves.easeOutCubic),
        ),

        // Role Switch Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoleSwitchCard(
              currentRole: userProfile.role,
              onRoleChanged: _handleRoleSwitch,
              isLoading: _isLoading,
            )
                .animate(controller: _contentController)
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.3, curve: Curves.easeOutCubic),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Stats Section
        SliverToBoxAdapter(
          child: _buildStatsSection(userProfile)
              .animate(controller: _contentController)
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutCubic),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Role-specific Content
        if (userProfile.role == UserRole.maintainer) ...[
          // Maintainer Section
          SliverToBoxAdapter(
            child: _buildMaintainerSection(userProfile)
                .animate(controller: _contentController)
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutCubic),
          ),
        ] else ...[
          // Contributor Section
          SliverToBoxAdapter(
            child: _buildContributorSection(userProfile)
                .animate(controller: _contentController)
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutCubic),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Settings Section
        SliverToBoxAdapter(
          child: _buildSettingsSection()
              .animate(controller: _contentController)
              .fadeIn(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutCubic),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildProfileHeader(UserModel userProfile, User? currentUser) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        children: [
          // Profile Image with Glow Effect
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: userProfile.role == UserRole.maintainer
                        ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
                        : [const Color(0xFF1F6FEB), const Color(0xFF238636)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (userProfile.role == UserRole.maintainer
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF1F6FEB))
                          .withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: userProfile.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(userProfile.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: userProfile.photoURL == null
                        ? const Color(0xFF21262D)
                        : null,
                  ),
                  child: userProfile.photoURL == null
                      ? Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.7),
                        )
                      : null,
                ),
              ),
              // Edit icon overlay
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => _pickAndUploadProfileImage(userProfile),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Name and Role Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  userProfile.displayName ?? 'Unknown User',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0F6FC),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: userProfile.role == UserRole.maintainer
                        ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
                        : [const Color(0xFF1F6FEB), const Color(0xFF238636)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userProfile.role == UserRole.maintainer
                      ? 'MAINTAINER'
                      : 'CONTRIBUTOR',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Email and verification status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email,
                size: 16,
                color: Color(0xFF7D8590),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  userProfile.email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF7D8590),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (userProfile.isEmailVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF238636),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'VERIFIED',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          if (userProfile.bio != null) ...[
            const SizedBox(height: 16),
            Text(
              userProfile.bio!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFC9D1D9),
                height: 1.4,
              ),
            ),
          ],

          // Edit Profile Button
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditProfileDialog(userProfile),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF30363D)),
                foregroundColor: const Color(0xFFC9D1D9),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserModel userProfile) {
    final statsAsync = ref.watch(userStatsProvider(userProfile.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            loading: () => _buildStatsSkeleton(),
            error: (error, stack) => _buildStatsError(),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Projects',
                    value: '${stats.projectsCount}',
                    icon: Icons.folder,
                    color: const Color(0xFF1F6FEB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Matches',
                    value: '${stats.matchesCount}',
                    icon: Icons.favorite,
                    color: const Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Contributions',
                    value: '${stats.matchesCount}',
                    icon: Icons.trending_up,
                    color: const Color(0xFF238636),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms),
        ),
      ],
    );
  }

  Widget _buildStatsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDA3633)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Color(0xFFDA3633),
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load statistics',
              style: TextStyle(
                color: Color(0xFF7D8590),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintainerSection(UserModel userProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Projects',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF0F6FC),
                ),
              ),
              ResponsiveIconLabelButton(
                onPressed: () => context.go('/project/upload'),
                icon: Icons.add,
                label: 'Upload Project',
                foregroundColor: const Color(0xFF8B5CF6),
                isOutlined: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProjectPreviewList(userProfile.id),
        ],
      ),
    );
  }

  Widget _buildContributorSection(UserModel userProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Contributions',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 16),
          _buildContributionsList(userProfile.id),
        ],
      ),
    );
  }

  Widget _buildProjectPreviewList(String userId) {
    final projectsAsync = ref.watch(userProjectsProvider(userId));

    return projectsAsync.when(
      loading: () => _buildProjectSkeleton(),
      error: (error, stack) => const Center(
        child: Text(
          'Failed to load projects',
          style: TextStyle(color: Color(0xFF7D8590)),
        ),
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return _buildEmptyProjectsState();
        }
        return Column(
          children: projects.take(3).map((project) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProjectPreviewCard(project: project),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProjectSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1000.ms);
      }),
    );
  }

  Widget _buildEmptyProjectsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_open,
            size: 48,
            color: Color(0xFF7D8590),
          ),
          const SizedBox(height: 16),
          Text(
            'No Projects Yet',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first project to start finding contributors',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7D8590),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveIconLabelButton(
            onPressed: () => context.go('/project/upload'),
            icon: Icons.add,
            label: 'Upload Project',
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildContributionsList(String userId) {
    final contributionsAsync = ref.watch(userContributionsProvider(userId));

    return contributionsAsync.when(
      loading: () => _buildContributionsSkeleton(),
      error: (error, stack) => _buildContributionsError(),
      data: (contributions) {
        if (contributions.isEmpty) {
          return _buildEmptyContributionsState();
        }
        return Column(
          children: contributions.take(5).map((contribution) {
            return _buildContributionItem(
              contribution.projectName,
              contribution.projectDescription,
              contribution.timeAgo,
              contribution.color,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContributionsSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1000.ms);
      }),
    );
  }

  Widget _buildContributionsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDA3633)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Color(0xFFDA3633),
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load contributions',
              style: TextStyle(
                color: Color(0xFF7D8590),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContributionsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.trending_up,
            size: 48,
            color: Color(0xFF7D8590),
          ),
          const SizedBox(height: 16),
          Text(
            'No Contributions Yet',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start exploring projects to make your first contribution',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7D8590),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveIconLabelButton(
            onPressed: () => context.go('/home/swipe'),
            icon: Icons.explore,
            label: 'Explore Projects',
            backgroundColor: const Color(0xFF238636),
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildContributionItem(
      String title, String description, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF0F6FC),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7D8590),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7D8590),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.settings,
            title: 'Account Settings',
            subtitle: 'Manage your account preferences',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Control your privacy settings',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: _handleSignOut,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isDestructive ? const Color(0xFFDA3633) : const Color(0xFF7D8590),
          size: 20,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? const Color(0xFFDA3633)
                : const Color(0xFFF0F6FC),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7D8590),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF7D8590),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: const Color(0xFF161B22),
      ),
    );
  }

  Future<void> _handleRoleSwitch(UserRole newRole) async {
    setState(() => _isLoading = true);
    _roleSwitchController.forward();

    try {
      AppLogger.logger.i('🔄 Switching role to: ${newRole.name}');

      final authService = ref.read(authServiceProvider);
      final currentProfile = ref.read(userProfileProvider).value;

      if (currentProfile != null) {
        await authService.upsertUserProfile(
          name: currentProfile.displayName ?? '',
          role: newRole,
          bio: currentProfile.bio,
          githubUrl: currentProfile.githubUrl,
          skills: currentProfile.skills,
        );

        // Refresh the profile
        ref.invalidate(userProfileProvider);

        AppLogger.logger
            .success('✅ Role switched successfully to: ${newRole.name}');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Role switched to ${newRole.name.toUpperCase()} successfully!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF238636),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.logger.e('❌ Failed to switch role', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to switch role: ${e.toString()}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDA3633),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _roleSwitchController.reverse();
      }
    }
  }

  void _showEditProfileDialog(UserModel userProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF0F6FC)),
        ),
        content: Text(
          'Profile editing functionality coming soon!',
          style: GoogleFonts.inter(color: const Color(0xFFC9D1D9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      AppLogger.logger.e('❌ Failed to sign out', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: const Color(0xFFDA3633),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadProfileImage(UserModel userProfile) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${userProfile.id}.jpg');
      await storageRef.putData(await pickedFile.readAsBytes());
      final downloadUrl = await storageRef.getDownloadURL();
      // Update user profile with new photoURL
      await ref.read(userProfileProvider.notifier).updateProfile(
            userProfile.copyWith(photoURL: downloadUrl),
          );
      AppLogger.logger.success('✅ Profile picture updated');
    } catch (e) {
      AppLogger.logger.e('❌ Failed to upload profile picture', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile picture: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
