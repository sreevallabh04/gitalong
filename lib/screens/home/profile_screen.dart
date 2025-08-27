import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/contributions_provider.dart';
import '../../core/utils/logger.dart';
import '../../models/models.dart';
import '../../widgets/profile/role_switch_card.dart';
import '../../widgets/profile/stats_card.dart';
import '../../widgets/profile/project_preview_card.dart';
import '../../widgets/profile/enhanced_security_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/utils/accessibility_utils.dart';
import '../../widgets/common/accessible_button.dart';
import '../../models/user_roles.dart' as roles;
import 'package:flutter/services.dart';

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
  late AnimationController _fabController;

  bool _isLoading = false;
  bool _isPickingImage = false;
  bool _showFloatingActions = false;

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
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _fabController.dispose();
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
            return _buildEnhancedProfileContent(userProfile, currentUser);
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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

  Widget _buildEnhancedProfileContent(
      UserModel userProfile, User? currentUser) {
    return CustomScrollView(
      slivers: [
        // Enhanced App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildProfileHeader(userProfile),
          ),
          actions: [
            IconButton(
              icon: Icon(
                PhosphorIcons.gear(PhosphorIconsStyle.regular),
                color: Colors.white,
              ),
              onPressed: () => _showSettingsDialog(context),
            ),
            IconButton(
              icon: Icon(
                PhosphorIcons.share(PhosphorIconsStyle.regular),
                color: Colors.white,
              ),
              onPressed: () => _shareProfile(userProfile),
            ),
          ],
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info Card
                _buildUserInfoCard(userProfile)
                    .animate()
                    .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic)
                    .fadeIn(duration: 800.ms),

                const SizedBox(height: 20),

                // Stats Cards
                _buildStatsSection(userProfile)
                    .animate()
                    .slideY(
                        begin: 0.3,
                        duration: 700.ms,
                        curve: Curves.easeOutCubic)
                    .fadeIn(duration: 900.ms),

                const SizedBox(height: 20),

                // Role Switch Card
                _buildRoleSwitchSection(userProfile)
                    .animate()
                    .slideY(
                        begin: 0.3,
                        duration: 800.ms,
                        curve: Curves.easeOutCubic)
                    .fadeIn(duration: 1000.ms),

                const SizedBox(height: 20),

                // Recent Projects
                _buildRecentProjectsSection(userProfile)
                    .animate()
                    .slideY(
                        begin: 0.3,
                        duration: 900.ms,
                        curve: Curves.easeOutCubic)
                    .fadeIn(duration: 1100.ms),

                const SizedBox(height: 20),

                // Security Section
                _buildSecuritySection(userProfile)
                    .animate()
                    .slideY(
                        begin: 0.3,
                        duration: 1000.ms,
                        curve: Curves.easeOutCubic)
                    .fadeIn(duration: 1200.ms),

                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserModel userProfile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.8),
            const Color(0xFFEC4899).withValues(alpha: 0.6),
            const Color(0xFF1F6FEB).withValues(alpha: 0.4),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image
            GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: userProfile.effectivePhotoUrl != null
                      ? Image.network(
                          userProfile.effectivePhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultProfileImage(),
                        )
                      : _buildDefaultProfileImage(),
                ),
              ),
            ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 16),

            // User Name
            Text(
              userProfile.displayName ?? 'Anonymous Developer',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().slideY(
                  begin: 0.5,
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                ),

            // User Bio
            if (userProfile.bio != null && userProfile.bio!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Text(
                  userProfile.bio!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ).animate().slideY(
                    begin: 0.5,
                    duration: 1000.ms,
                    curve: Curves.easeOutCubic,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFFEC4899),
          ],
        ),
      ),
      child: Icon(
        PhosphorIcons.user(PhosphorIconsStyle.fill),
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildUserInfoCard(UserModel userProfile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF30363D).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.info(PhosphorIconsStyle.regular),
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Profile Information',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email
          _buildInfoRow(
            icon: PhosphorIcons.envelope(PhosphorIconsStyle.regular),
            label: 'Email',
            value: userProfile.email ?? 'Not provided',
            color: const Color(0xFF1F6FEB),
          ),

          const SizedBox(height: 12),

          // GitHub
          if (userProfile.githubUrl != null)
            _buildInfoRow(
              icon: PhosphorIcons.githubLogo(PhosphorIconsStyle.fill),
              label: 'GitHub',
              value: userProfile.githubUrl!,
              color: const Color(0xFFE09800),
              isLink: true,
            ),

          const SizedBox(height: 12),

          // Location
          if (userProfile.location != null)
            _buildInfoRow(
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
              label: 'Location',
              value: userProfile.location!,
              color: const Color(0xFF10B981),
            ),

          const SizedBox(height: 12),

          // Join Date
          _buildInfoRow(
            icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
            label: 'Joined',
            value: _formatJoinDate(userProfile.createdAt),
            color: const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLink = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: const Color(0xFF7D8590),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (isLink)
          Icon(
            PhosphorIcons.arrowUpRight(PhosphorIconsStyle.regular),
            color: const Color(0xFF7D8590),
            size: 16,
          ),
      ],
    );
  }

  Widget _buildStatsSection(UserModel userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.chartBar(PhosphorIconsStyle.regular),
              color: const Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Statistics',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: PhosphorIcons.star(PhosphorIconsStyle.fill),
                title: 'Projects',
                value: '12',
                color: const Color(0xFFE09800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: PhosphorIcons.users(PhosphorIconsStyle.fill),
                title: 'Contributions',
                value: '45',
                color: const Color(0xFF1F6FEB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                title: 'Matches',
                value: '8',
                color: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF30363D).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: const Color(0xFF7D8590),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSwitchSection(UserModel userProfile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF30363D).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.regular),
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Role Management',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Role Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.fill),
                    color: const Color(0xFF8B5CF6),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Role',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: const Color(0xFF7D8590),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Collaborator',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRoleSwitchDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Switch',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjectsSection(UserModel userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.folder(PhosphorIconsStyle.regular),
              color: const Color(0xFFE09800),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Projects',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/projects'),
              child: Text(
                'View All',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Placeholder for recent projects
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF30363D).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                PhosphorIcons.folderOpen(PhosphorIconsStyle.regular),
                color: const Color(0xFF7D8590),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No Recent Projects',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start contributing to projects to see them here',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: const Color(0xFF7D8590),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/discover'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE09800),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Discover Projects',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(UserModel userProfile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF30363D).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.shield(PhosphorIconsStyle.regular),
                color: const Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Security & Privacy',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Security Options
          _buildSecurityOption(
            icon: PhosphorIcons.lock(PhosphorIconsStyle.regular),
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            color: const Color(0xFF10B981),
            onTap: () => _showTwoFactorDialog(context),
          ),

          const SizedBox(height: 12),

          _buildSecurityOption(
            icon: PhosphorIcons.eye(PhosphorIconsStyle.regular),
            title: 'Privacy Settings',
            subtitle: 'Control your profile visibility',
            color: const Color(0xFF1F6FEB),
            onTap: () => _showPrivacyDialog(context),
          ),

          const SizedBox(height: 12),

          _buildSecurityOption(
            icon: PhosphorIcons.download(PhosphorIconsStyle.regular),
            title: 'Export Data',
            subtitle: 'Download your personal data',
            color: const Color(0xFFE09800),
            onTap: () => _exportUserData(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF30363D).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: const Color(0xFF7D8590),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                color: const Color(0xFF7D8590),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_fabController.value * 0.1),
          child: FloatingActionButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              _fabController.forward().then((_) {
                _fabController.reverse();
              });
              _showQuickActionsDialog(context);
            },
            backgroundColor: const Color(0xFF8B5CF6),
            child: Icon(
              PhosphorIcons.plus(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  void _showQuickActionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  Widget _buildQuickActionsSheet() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF21262D).withValues(alpha: 0.95),
            const Color(0xFF161B22).withValues(alpha: 0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(0xFF30363D).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF7D8590).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildQuickActionItem(
                    icon: PhosphorIcons.pencil(PhosphorIconsStyle.bold),
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile/edit');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    icon: PhosphorIcons.upload(PhosphorIconsStyle.bold),
                    title: 'Upload Project',
                    subtitle: 'Share your work',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/project/upload');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    icon: PhosphorIcons.users(PhosphorIconsStyle.bold),
                    title: 'Find Contributors',
                    subtitle: 'Search for developers',
                    color: const Color(0xFF1F6FEB),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/search');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(
          begin: 1,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF21262D).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF30363D).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: const Color(0xFF7D8590),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                color: const Color(0xFF7D8590),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _formatJoinDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.year}';
  }

  void _pickProfileImage() async {
    // Implementation for picking profile image
  }

  void _showSettingsDialog(BuildContext context) {
    // Implementation for settings dialog
  }

  void _shareProfile(UserModel userProfile) {
    // Implementation for sharing profile
  }

  void _showRoleSwitchDialog(BuildContext context) {
    // Implementation for role switch dialog
  }

  void _showTwoFactorDialog(BuildContext context) {
    // Implementation for 2FA dialog
  }

  void _showPrivacyDialog(BuildContext context) {
    // Implementation for privacy dialog
  }

  void _exportUserData() {
    // Implementation for data export
  }

  Future<void> _handleRoleSwitch(roles.UserRole newRole) async {
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
          skills: currentProfile.skills ?? [],
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
    if (_isPickingImage || _isLoading) return;
    _isPickingImage = true;
    final picker = ImagePicker();
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile == null) return;
      if (mounted) setState(() => _isLoading = true);
      try {
        // Create a safe reference with fallback error handling
        final userId = userProfile.id ?? 'unknown';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${userId}_$timestamp.jpg';

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(fileName);

        AppLogger.logger.d('📤 Uploading profile picture: $fileName');

        // Upload with metadata
        final uploadTask = storageRef.putData(
          await pickedFile.readAsBytes(),
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': userId,
              'uploadedAt': timestamp.toString(),
            },
          ),
        );

        // Wait for upload completion
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        AppLogger.logger.success('✅ Profile picture uploaded: $downloadUrl');

        // Update user profile with new photoURL
        await ref.read(userProfileProvider.notifier).updateProfile(
              userProfile.copyWith(photoURL: downloadUrl),
            );
        AppLogger.logger.success('✅ Profile picture updated in database');
      } on FirebaseException catch (e) {
        AppLogger.logger.e('❌ Firebase Storage error', error: e);
        if (mounted) {
          String userFriendlyMessage = 'Failed to upload profile picture';
          if (e.code == 'storage/object-not-found') {
            userFriendlyMessage = 'Storage path not found. Please try again.';
          } else if (e.code == 'storage/unauthorized') {
            userFriendlyMessage =
                'Not authorized to upload images. Please sign in again.';
          } else if (e.code == 'storage/canceled') {
            userFriendlyMessage = 'Upload was canceled. Please try again.';
          } else if (e.code == 'storage/unknown') {
            userFriendlyMessage =
                'Unknown storage error. Please check your connection.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userFriendlyMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } on PlatformException catch (e) {
        AppLogger.logger.e('❌ Platform error', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Platform error: ${e.message ?? e.code}')),
          );
        }
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
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        AppLogger.logger.e('❌ Image picker already active', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image picker is already open. Please wait.')),
          );
        }
      } else {
        AppLogger.logger.e('❌ Platform error', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Platform error: ${e.message ?? e.code}')),
          );
        }
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error picking image', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }
}
