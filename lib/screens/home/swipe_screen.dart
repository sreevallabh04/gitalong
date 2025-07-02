import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ml_matching_provider.dart';
import '../../core/utils/logger.dart';
import '../../services/swipe_service.dart';
import '../../widgets/user_card.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/swipe_provider.dart';
import '../../widgets/project_card.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<Offset> _cardOffsetAnimation;
  late Animation<double> _cardRotationAnimation;
  late AnimationController _matchAnimationController;
  late Animation<double> _matchScaleAnimation;

  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;
  bool _showingMatch = false;
  bool _isContributor = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _cardAnimationController = AnimationController(
      duration: AppConstants.normalAnimationDuration.milliseconds,
      vsync: this,
    );

    _cardOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));

    _cardRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));

    _matchAnimationController = AnimationController(
      duration: AppConstants.longAnimationDuration.milliseconds,
      vsync: this,
    );

    _matchScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _matchAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _matchAnimationController.dispose();
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
      appBar: AppBar(
        title: Text(
          'Discover',
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFFF0F6FC),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isContributor
          ? _buildContributorSwipe(context, userId)
          : _buildMaintainerSwipe(context, userId),
    );
  }

  Widget _buildContributorSwipe(BuildContext context, String userId) {
    final projectsAsync = ref.watch(projectsToSwipeProvider(userId));
    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) return _buildEmptyState();
        return _buildProjectCards(projects);
      },
      loading: _buildLoadingState,
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildMaintainerSwipe(BuildContext context, String userId) {
    final usersAsync = ref.watch(usersToSwipeProvider(userId));
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) return _buildEmptyState();
        return _buildUserCards(users);
      },
      loading: _buildLoadingState,
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildProjectCards(List<ProjectModel> projects) {
    // You can add swipe logic here if needed
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(project: projects[index]);
      },
    );
  }

  Widget _buildUserCards(List<UserModel> users) {
    // You can add swipe logic here if needed
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserCard(user: users[index]);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: const Color(0xFF7D8590),
          ),
          const SizedBox(height: 24),
          Text(
            'No Matches Found',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFFF0F6FC),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isContributor
                ? 'No projects match your interests right now.'
                : 'No contributors match your project needs right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF7D8590),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: const Color(0xFFDA3633),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFFF0F6FC),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF7D8590),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<T?> safeQuery<T>(Future<T> Function() query,
      {Function(dynamic)? onError}) async {
    try {
      return await query();
    } catch (e) {
      debugPrint('Firestore error: $e');
      if (onError != null) onError(e);
      return null;
    }
  }
}
