import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swipe_provider.dart';
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
    final userId = userProfile.id;

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
                    ? _buildContributorSwipe(context, userId)
                    : _buildMaintainerSwipe(context, userId),
              ),

              // Action Buttons
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
                      : 'Talented Contributors',
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
                Icon(
                  PhosphorIcons.fire(PhosphorIconsStyle.fill),
                  color: const Color(0xFF238636),
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

  Widget _buildContributorSwipe(BuildContext context, String userId) {
    final projectsAsync = ref.watch(projectsToSwipeProvider(userId));
    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) return _buildEmptyState();
        return _buildProjectCards(projects);
      },
      loading: () => _buildLoadingStateWithTimeout(
        () => _buildMockProjectCards(),
        3000, // Show mock data after 3 seconds
      ),
      error: (error, stack) {
        AppLogger.logger.e('❌ Error loading projects', error: error);
        return _buildMockProjectCards(); // Fallback to mock data
      },
    );
  }

  Widget _buildMaintainerSwipe(BuildContext context, String userId) {
    final usersAsync = ref.watch(usersToSwipeProvider(userId));
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) return _buildEmptyState();
        return _buildUserCards(users);
      },
      loading: () => _buildLoadingStateWithTimeout(
        () => _buildMockUserCards(),
        3000, // Show mock data after 3 seconds
      ),
      error: (error, stack) {
        AppLogger.logger.e('❌ Error loading users', error: error);
        return _buildMockUserCards(); // Fallback to mock data
      },
    );
  }

  Widget _buildLoadingStateWithTimeout(
      Widget Function() fallback, int timeoutMs) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: timeoutMs)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return fallback();
        }
        return _buildLoadingState();
      },
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

  Widget _buildMockUserCards() {
    final mockUsers = [
      UserModel(
        id: 'mock-user-1',
        email: 'alex@example.com',
        displayName: 'Alex Chen',
        bio:
            'Full-stack developer passionate about clean code and innovative solutions. Love working on challenging projects that make a real impact.',
        role: UserRole.contributor,
        skills: ['React', 'Node.js', 'TypeScript', 'GraphQL'],
        createdAt: DateTime.now(),
        photoURL: null,
      ),
      UserModel(
        id: 'mock-user-2',
        email: 'sarah@example.com',
        displayName: 'Sarah Johnson',
        bio:
            'Mobile developer with 5+ years experience. Specialized in Flutter and React Native. Always excited to contribute to open source projects.',
        role: UserRole.contributor,
        skills: ['Flutter', 'Dart', 'Swift', 'Kotlin'],
        createdAt: DateTime.now(),
        photoURL: null,
      ),
      UserModel(
        id: 'mock-user-3',
        email: 'marcus@example.com',
        displayName: 'Marcus Rodriguez',
        bio:
            'DevOps engineer and backend specialist. Expertise in cloud architecture, microservices, and building scalable systems.',
        role: UserRole.contributor,
        skills: ['Docker', 'Kubernetes', 'AWS', 'Python'],
        createdAt: DateTime.now(),
        photoURL: null,
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
                color: const Color(0xFF238636).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF238636).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF238636),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Demo Contributors - Real data loading...',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: const Color(0xFF238636),
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
                  itemCount: mockUsers.length,
                  itemBuilder: (context, index) {
                    return _buildEnhancedUserCard(mockUsers[index]);
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

  Widget _buildUserCards(List<UserModel> users) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 600,
          child: PageView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _buildEnhancedUserCard(users[index]);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F6FEB), Color(0xFF388BFD)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.folder(PhosphorIconsStyle.fill),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
                      Text(
                        'Open Source Project',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF7D8590),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  color: const Color(0xFFE09800),
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              project.description,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: const Color(0xFFC9D1D9),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 24),

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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.skillsRequired.take(6).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF238636).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF238636).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF238636),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const Spacer(),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF30363D),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.gitBranch(PhosphorIconsStyle.regular),
                    color: const Color(0xFF7D8590),
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
                  Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.regular),
                    color: const Color(0xFF238636),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedUserCard(UserModel user) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF238636),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF238636).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: user.photoURL != null
                        ? Image.network(
                            user.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Anonymous User',
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
                          user.role.toString().split('.').last.toUpperCase(),
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
                Icon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  color: const Color(0xFFE09800),
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bio
            if (user.bio?.isNotEmpty == true) ...[
              Text(
                user.bio!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: const Color(0xFFC9D1D9),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
            ],

            // Skills
            if (user.skills.isNotEmpty) ...[
              Text(
                'Skills & Expertise',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF238636),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.take(6).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F6FEB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1F6FEB).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F6FEB),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const Spacer(),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF30363D),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.users(PhosphorIconsStyle.regular),
                    color: const Color(0xFF7D8590),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Swipe right to connect',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF7D8590),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.regular),
                    color: const Color(0xFF238636),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF238636), Color(0xFF2EA043)],
        ),
      ),
      child: Icon(
        PhosphorIcons.user(PhosphorIconsStyle.fill),
        color: Colors.white,
        size: 32,
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
            icon: PhosphorIcons.x(PhosphorIconsStyle.bold),
            color: const Color(0xFFDA3633),
            onTap: () => _programmaticSwipe('left'),
          ),
          _buildActionButton(
            icon: PhosphorIcons.star(PhosphorIconsStyle.fill),
            color: const Color(0xFFE09800),
            onTap: () => _showSuperLike(),
            size: 56,
          ),
          _buildActionButton(
            icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
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
  }

  void _showSuperLike() {
    AppLogger.logger.d('⭐ Super like triggered');
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
            'Finding Amazing Matches',
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
            child: Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 60,
            ),
          )
              .animate()
              .scale(duration: 1000.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 800.ms),
          const SizedBox(height: 32),
          Text(
            'No More Matches',
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF0F6FC),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.3),
        ],
      ),
    );
  }
}
