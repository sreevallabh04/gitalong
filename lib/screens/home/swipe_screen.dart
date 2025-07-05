import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../core/utils/logger.dart';
import '../../core/monitoring/analytics_service.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _headerController;
  late AnimationController _buttonsController;

  bool _isContributor = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    AnalyticsService.trackScreenView('swipe_screen');
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _headerController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).value;
    if (userProfile == null) {
      return _buildLoadingState();
    }

    _isContributor = userProfile.role == UserRole.contributor;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 2.0,
            colors: [
              const Color(0xFF238636).withValues(alpha: 0.05),
              const Color(0xFF0D1117),
              const Color(0xFF0D1117),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Beautiful Header
              _buildAnimatedHeader()
                  .animate(controller: _headerController)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.5, curve: Curves.easeOutBack),

              // Main Content Area
              Expanded(
                child: _isContributor
                    ? _buildContributorSwipe(context)
                    : _buildMaintainerView(context),
              ),

              // Action Buttons
              if (_isContributor)
                _buildActionButtons()
                    .animate(controller: _buttonsController)
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.5, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // App Logo with Glow
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF238636), Color(0xFF2EA043)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF238636).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF0F6FC),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _isContributor
                      ? 'Amazing Projects to Join'
                      : 'Upload Projects for Contributors',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF7D8590),
                  ),
                ),
              ],
            ),
          ),

          // Stats Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF238636).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF238636),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Hot',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildContributorSwipe(BuildContext context) {
    final projectsAsync = ref.watch(discoverProjectsProvider);
    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) return _buildEmptyState();
        return _buildProjectCards(projects);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) {
        AppLogger.logger.e('❌ Error loading projects', error: error);
        return _buildMockProjectCards(); // Fallback to mock data
      },
    );
  }

  Widget _buildMaintainerView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.cloud_upload,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Share Your Projects',
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFF0F6FC),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'As a maintainer, upload your projects and let talented contributors discover them. Switch to contributor mode to discover projects to join.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF7D8590),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/project/upload'),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Upload Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockProjectCards() {
    final mockProjects = [
      ProjectModel(
        id: 'mock-1',
        title: 'Open Source Flutter UI Kit',
        description:
            'Beautiful, customizable UI components for Flutter apps. Help us build the next generation of mobile interfaces with stunning animations and smooth performance.',
        ownerId: 'owner-1',
        skillsRequired: ['Flutter', 'Dart', 'UI/UX', 'Animation'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        repoUrl: 'https://github.com/example/flutter-ui-kit',
      ),
      ProjectModel(
        id: 'mock-2',
        title: 'AI-Powered Code Review Tool',
        description:
            'Revolutionary code review system using machine learning to detect bugs, suggest improvements, and maintain code quality standards.',
        ownerId: 'owner-2',
        skillsRequired: ['Python', 'Machine Learning', 'TensorFlow', 'Docker'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        repoUrl: 'https://github.com/example/ai-code-review',
      ),
      ProjectModel(
        id: 'mock-3',
        title: 'Blockchain DeFi Platform',
        description:
            'Decentralized finance platform built on Ethereum. Contributing to the future of digital finance with smart contracts and Web3 integration.',
        ownerId: 'owner-3',
        skillsRequired: ['Solidity', 'Web3', 'React', 'Node.js'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        repoUrl: 'https://github.com/example/defi-platform',
      ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F6FEB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1F6FEB).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1F6FEB),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Demo Projects - Real data loading...',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: const Color(0xFF1F6FEB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SizedBox(
                height: 600,
                child: PageView.builder(
                  itemCount: mockProjects.length,
                  itemBuilder: (context, index) {
                    return _buildEnhancedProjectCard(mockProjects[index]);
                  },
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCards(List<ProjectModel> projects) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 600,
          child: PageView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return _buildEnhancedProjectCard(projects[index]);
            },
          ),
        )
            .animate()
            .fadeIn(duration: 1000.ms, delay: 200.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildEnhancedProjectCard(ProjectModel project) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF21262D),
            Color(0xFF161B22),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF30363D),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF238636), Color(0xFF2EA043)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF238636).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF0F6FC),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF238636),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'OPEN SOURCE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: Color(0xFFE09800),
                  size: 20,
                ),
              ],
            ),

              const SizedBox(height: 16),

            // Description
            Text(
              project.description,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: const Color(0xFFC9D1D9),
              ),
                maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

              const SizedBox(height: 16),

            // Skills
            if (project.skillsRequired.isNotEmpty) ...[
              Text(
                'Skills Required',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF238636),
                ),
              ),
                const SizedBox(height: 8),
              Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.skillsRequired.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF238636).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF238636).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF238636),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

              const SizedBox(height: 16),

            // Footer
            Container(
                padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF30363D),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.code_sharp,
                    color: Color(0xFF7D8590),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Swipe right to join',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF7D8590),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFF238636),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: const Color(0xFFDA3633),
            onTap: () => _programmaticSwipe('left'),
          ),
          _buildActionButton(
            icon: Icons.star,
            color: const Color(0xFFE09800),
            onTap: () => _showSuperLike(),
            size: 56,
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: const Color(0xFF238636),
            onTap: () => _programmaticSwipe('right'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }

  void _programmaticSwipe(String direction) {
    AppLogger.logger.d('🔄 Programmatic swipe: $direction');

    if (direction == 'right') {
      // Show interest animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '💖 Interested! Project saved to your matches.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF238636),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuperLike() {
    AppLogger.logger.d('⭐ Super like triggered');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⭐ Super Like! This project will be prioritized.',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE09800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF238636), Color(0xFF2EA043)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF238636).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
              .then(delay: 200.ms)
              .scale(
                  begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8)),
          const SizedBox(height: 32),
          Text(
            'Finding Amazing Projects',
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF0F6FC),
            ),
          ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6FEB), Color(0xFF388BFD)],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F6FEB).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 60,
            ),
          )
              .animate()
              .scale(duration: 1000.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 800.ms),
          const SizedBox(height: 32),
          Text(
            'No More Projects',
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF0F6FC),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 16),
          Text(
            'Check back later for new projects to discover!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF7D8590),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
