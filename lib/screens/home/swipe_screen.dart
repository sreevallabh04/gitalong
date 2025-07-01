import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import '../../widgets/contribution_graph.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.logger.navigation('💕 Swipe screen initialized');

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GitAlongTheme.carbonBlack,
      appBar: AppBar(
        backgroundColor: GitAlongTheme.surfaceGray,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GitAlongTheme.neonGreen, GitAlongTheme.accentGreen],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [GitAlongTheme.subtleGlow],
              ),
              child: Icon(
                PhosphorIcons.gitBranch(PhosphorIconsStyle.fill),
                size: 18,
                color: GitAlongTheme.carbonBlack,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Discover',
              style: GitAlongTheme.titleStyle,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                AppLogger.logger.navigation('🔍 Filters tapped');
                _showFiltersDialog();
              },
              icon: Icon(
                PhosphorIcons.faders(PhosphorIconsStyle.regular),
                color: GitAlongTheme.devGray,
              ),
              style: IconButton.styleFrom(
                backgroundColor: GitAlongTheme.carbonBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: GitAlongTheme.borderGray,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _buildHeroSection(),

              const SizedBox(height: 32),

              // Contribution Graph
              ContributionGraph(
                title: 'Your Coding Journey',
                animateOnLoad: true,
              ),

              const SizedBox(height: 32),

              // Stats Cards
              _buildStatsSection(),

              const SizedBox(height: 32),

              // Call to Action
              _buildCallToAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GitAlongTheme.surfaceGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GitAlongTheme.borderGray, width: 1),
        boxShadow: [GitAlongTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          GitAlongTheme.neonGreen,
                          GitAlongTheme.accentGreen
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: GitAlongTheme.neonGreen
                              .withOpacity(0.4 * _glowAnimation.value),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 5 * _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: Icon(
                      PhosphorIcons.heart(PhosphorIconsStyle.fill),
                      size: 30,
                      color: GitAlongTheme.carbonBlack,
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Your Code Soulmate',
                      style: GitAlongTheme.headlineStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect with developers who share your passion for clean code and innovative solutions.',
                      style: GitAlongTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Terminal-style command
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GitAlongTheme.carbonBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GitAlongTheme.borderGray, width: 1),
            ),
            child: Row(
              children: [
                Text(
                  '\$ ',
                  style: GitAlongTheme.codeStyle.copyWith(
                    color: GitAlongTheme.neonGreen,
                  ),
                ),
                Expanded(
                  child: Text(
                    'git clone https://github.com/your-perfect-match.git',
                    style: GitAlongTheme.codeStyle,
                  ),
                ),
                Icon(
                  PhosphorIcons.copy(PhosphorIconsStyle.regular),
                  size: 16,
                  color: GitAlongTheme.devGray,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(
          begin: 0.3,
          duration: 1000.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Active\nDevelopers', '12.5K',
                PhosphorIcons.users(PhosphorIconsStyle.fill))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Successful\nMatches', '3.2K',
                PhosphorIcons.handshake(PhosphorIconsStyle.fill))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Projects\nCreated', '8.7K',
                PhosphorIcons.rocket(PhosphorIconsStyle.fill))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GitAlongTheme.surfaceGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GitAlongTheme.borderGray, width: 1),
        boxShadow: [GitAlongTheme.cardShadow],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: GitAlongTheme.neonGreen,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GitAlongTheme.headlineStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GitAlongTheme.mutedStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.8, 0.8),
          duration: 800.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildCallToAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GitAlongTheme.neonGreen.withOpacity(0.1),
            GitAlongTheme.accentGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GitAlongTheme.neonGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [GitAlongTheme.primaryGlow],
      ),
      child: Column(
        children: [
          Text(
            'Ready to Start Swiping?',
            style: GitAlongTheme.titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Discover developers who complement your coding style and project interests.',
            style: GitAlongTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              AppLogger.logger.navigation('🚀 Start swiping tapped');
              _startSwiping();
            },
            style: GitAlongTheme.primaryButtonStyle.copyWith(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.play(PhosphorIconsStyle.fill),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Start Swiping',
                  style: GitAlongTheme.codeStyle.copyWith(
                    color: GitAlongTheme.carbonBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 800.ms).slideY(
          begin: 0.2,
          duration: 1000.ms,
          curve: Curves.easeOutCubic,
        );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: GitAlongTheme.surfaceGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GitAlongTheme.borderGray, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.faders(PhosphorIconsStyle.fill),
                    color: GitAlongTheme.neonGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Swipe Preferences',
                    style: GitAlongTheme.titleStyle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Customize your discovery experience',
                style: GitAlongTheme.bodyStyle,
              ),
              const SizedBox(height: 24),
              // Add filter options here
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: GitAlongTheme.ghostButtonStyle,
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 200.ms),
    );
  }

  void _startSwiping() {
    // TODO: Navigate to actual swiping interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.rocket(PhosphorIconsStyle.fill),
              color: GitAlongTheme.neonGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Swipe interface coming soon!',
              style: GitAlongTheme.bodyStyle,
            ),
          ],
        ),
        backgroundColor: GitAlongTheme.surfaceGray,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: GitAlongTheme.borderGray, width: 1),
        ),
      ),
    );
  }
}
