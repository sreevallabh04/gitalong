import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/logger.dart';
import '../../widgets/email_admin_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub dark
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFFF0F6FC), // GitHub white
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF21262D), // GitHub dark secondary
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFDA3633), // GitHub red
            ),
            tooltip: 'Sign Out',
            onPressed: () => _handleSignOut(context, ref),
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.goToLogin();
              }
            });
            return const _LoadingWidget();
          }

          return userProfile.when(
            data: (profile) {
              if (profile == null) {
                return _NoProfileWidget(
                  user: user,
                  onCreateProfile: () => _handleCreateProfile(context),
                  onRefresh: () => ref.refresh(userProfileProvider),
                );
              }

              return _ProfileContentWidget(profile: profile);
            },
            loading: () => const _LoadingWidget(),
            error: (error, stack) => _ErrorWidget(
              error: error,
              onRetry: () => ref.refresh(userProfileProvider),
              onCreateProfile: () => _handleCreateProfile(context),
            ),
          );
        },
        loading: () => const _LoadingWidget(),
        error: (error, stack) => _ErrorWidget(
          error: error,
          onRetry: () => ref.refresh(authStateProvider),
          onCreateProfile: () => _handleCreateProfile(context),
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      AppLogger.logger.auth('🚪 User initiated sign out');

      // Show confirmation dialog
      final shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF21262D),
          title: const Text(
            'Sign Out',
            style: TextStyle(color: Color(0xFFF0F6FC)),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Color(0xFF7D8590)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF7D8590)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDA3633),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );

      if (shouldSignOut == true && context.mounted) {
        await ref.read(userProfileProvider.notifier).signOut();
        AppLogger.logger.auth('✅ User signed out successfully');

        if (context.mounted) {
          context.goToLogin();
        }
      }
    } catch (error) {
      AppLogger.logger.e('❌ Error during sign out', error: error);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing out. Please try again.'),
            backgroundColor: Color(0xFFDA3633),
          ),
        );
      }
    }
  }

  void _handleCreateProfile(BuildContext context) {
    AppLogger.logger.navigation('🔄 Redirecting to profile creation');
    context.goToOnboarding();
  }
}

// ============================================================================
// 🎨 BEAUTIFUL WIDGET COMPONENTS - GODS OF FLUTTER APPROVED
// ============================================================================

class _NoProfileWidget extends StatelessWidget {
  final dynamic user;
  final VoidCallback onCreateProfile;
  final VoidCallback onRefresh;

  const _NoProfileWidget({
    required this.user,
    required this.onCreateProfile,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated GitHub Octocat-style icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF238636), Color(0xFF2EA043)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF238636).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Welcome message
            Text(
              'Welcome to GitAlong!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFF0F6FC),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Hello ${user.email ?? user.displayName ?? 'Developer'}! 👋',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2EA043),
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF30363D),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF58A6FF),
                    size: 32,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Let\'s set up your developer profile to start connecting with amazing open source projects and contributors!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF7D8590),
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Create Profile Button - GitHub style
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onCreateProfile,
                icon: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Create Your Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Refresh button
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF7D8590),
                size: 20,
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  color: Color(0xFF7D8590),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContentWidget extends StatelessWidget {
  final dynamic profile;

  const _ProfileContentWidget({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with GitHub-style design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF21262D), Color(0xFF30363D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              children: [
                // Avatar with glow effect
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF238636).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF238636),
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFFF0F6FC),
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF238636),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.role.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bio section
          if (profile.bio != null) ...[
            _SectionCard(
              icon: Icons.description_rounded,
              title: 'Bio',
              child: Text(
                profile.bio!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF7D8590),
                      height: 1.6,
                    ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Skills section
          if (profile.skills.isNotEmpty) ...[
            _SectionCard(
              icon: Icons.code_rounded,
              title: 'Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.skills.map<Widget>((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF30363D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF238636).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: Color(0xFFF0F6FC),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // GitHub link
          if (profile.githubUrl != null) ...[
            _SectionCard(
              icon: Icons.link_rounded,
              title: 'GitHub',
              child: InkWell(
                onTap: () {
                  // TODO: Open GitHub URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening GitHub profile...'),
                      backgroundColor: Color(0xFF238636),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF30363D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.open_in_new_rounded,
                        color: Color(0xFF58A6FF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.githubUrl!,
                          style: const TextStyle(
                            color: Color(0xFF58A6FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Edit profile button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile functionality coming soon! 🚀'),
                    backgroundColor: Color(0xFF238636),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF7D8590),
                size: 20,
              ),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Color(0xFF7D8590),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF30363D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Email Admin Widget for testing
          const EmailAdminWidget(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF238636),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFF0F6FC),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF238636)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading your profile...',
            style: TextStyle(
              color: Color(0xFF7D8590),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  final VoidCallback onCreateProfile;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
    required this.onCreateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isProfileMissing = error.toString().toLowerCase().contains('profile');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isProfileMissing ? Icons.person_add_rounded : Icons.error_rounded,
              size: 80,
              color: isProfileMissing
                  ? const Color(0xFF238636)
                  : const Color(0xFFDA3633),
            ),
            const SizedBox(height: 24),
            Text(
              isProfileMissing ? 'Profile Not Found' : 'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFF0F6FC),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isProfileMissing
                  ? 'Let\'s create your developer profile!'
                  : error.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF7D8590),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isProfileMissing) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onCreateProfile,
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: const Text('Create Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
