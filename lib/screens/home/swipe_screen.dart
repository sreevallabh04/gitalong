import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/github_user_model.dart';
import '../../widgets/github_profile_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ml_matching_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import '../../models/swipe_model.dart';
import '../../services/swipe_service.dart';
import '../../widgets/user_card.dart';
import '../../core/constants/app_constants.dart';

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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialRecommendations();
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

  void _loadInitialRecommendations() {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile != null) {
        ref
            .read(mlRecommendationsProvider.notifier)
            .fetchRecommendations(userProfile);
      }
    }
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _matchAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleSwipe(SwipeDirection direction) async {
    final user = ref.read(authStateProvider).value;
    final userProfile = ref.read(userProfileProvider).value;
    final recommendation =
        ref.read(mlRecommendationsProvider.notifier).getNextRecommendation();

    if (user == null || userProfile == null || recommendation == null) {
      AppLogger.logger
          .w('⚠️ Cannot swipe: missing user data or recommendations');
      return;
    }

    try {
      AppLogger.logger.d(
          '👆 Processing ${direction.name} swipe on ${recommendation.targetUserId}');

      // Create swipe model
      final swipe = SwipeModel(
        id: '', // Will be set by Firestore
        swiperId: user.uid,
        targetId: recommendation.targetUserId,
        direction: direction,
        createdAt: DateTime.now(),
      );

      // Record swipe in both ML backend and Firestore
      await Future.wait([
        SwipeService.recordSwipe(swipe),
        ref
            .read(mlRecommendationsProvider.notifier)
            .recordSwipeAndUpdate(swipe, userProfile),
      ]);

      // Check for mutual match if it's a right swipe
      if (direction == SwipeDirection.right) {
        final isMatch = await SwipeService.checkForMatch(
            user.uid, recommendation.targetUserId);
        if (isMatch && mounted) {
          _showMatchAnimation();
        }
      }

      // Animate card out
      _cardAnimationController.forward().then((_) {
        _cardAnimationController.reset();
      });
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Error processing swipe', error: e, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process swipe. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showMatchAnimation() {
    setState(() {
      _showingMatch = true;
    });

    _matchAnimationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _matchAnimationController.reverse().then((_) {
            setState(() {
              _showingMatch = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mlRecommendations = ref.watch(mlRecommendationsProvider);
    final mlHealth = ref.watch(mlHealthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub dark
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
        actions: [
          // ML Health indicator
          mlHealth.when(
            data: (isHealthy) => Icon(
              isHealthy ? Icons.psychology : Icons.psychology_outlined,
              color:
                  isHealthy ? const Color(0xFF2EA043) : const Color(0xFFDA3633),
            ),
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Icon(
              Icons.psychology_outlined,
              color: Color(0xFFDA3633),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          mlRecommendations.when(
            data: (recommendations) {
              if (recommendations.isEmpty) {
                return _buildEmptyState();
              }
              return _buildSwipeCards(recommendations);
            },
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error),
          ),

          // Match animation overlay
          if (_showingMatch)
            AnimatedBuilder(
              animation: _matchScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _matchScaleAnimation.value,
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 100,
                            color: const Color(0xFFDA3633),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'It\'s a Match!',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFF0F6FC),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You both swiped right!',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF7D8590),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSwipeCards(List<MLRecommendation> recommendations) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Match reasons display
            if (recommendations.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
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
                          Icons.psychology,
                          color: const Color(0xFF2EA043),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Match Insights',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFF0F6FC),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recommendations.first.matchReasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: const Color(0xFF2EA043),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reason,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF7D8590),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Card stack
            Expanded(
              child: Stack(
                children: [
                  // Background cards (for depth effect)
                  for (int i = recommendations.length - 1;
                      i >= 0 && i >= recommendations.length - 3;
                      i--)
                    Positioned.fill(
                      child: Transform.translate(
                        offset:
                            Offset(0, (recommendations.length - 1 - i) * 8.0),
                        child: Transform.scale(
                          scale: 1.0 - (recommendations.length - 1 - i) * 0.05,
                          child: UserCard(
                            recommendation: recommendations[i],
                            isInteractive: i == 0,
                            onSwipe: i == 0 ? _handleSwipe : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: const Color(0xFFDA3633),
            onPressed: () => _handleSwipe(SwipeDirection.left),
          ),
          _buildActionButton(
            icon: Icons.refresh,
            color: const Color(0xFF7D8590),
            onPressed: _loadInitialRecommendations,
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: const Color(0xFF2EA043),
            onPressed: () => _handleSwipe(SwipeDirection.right),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2EA043)),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding your perfect matches...',
            style: GoogleFonts.inter(
              color: const Color(0xFF7D8590),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is analyzing compatibility',
            style: GoogleFonts.inter(
              color: const Color(0xFF7D8590),
              fontSize: 14,
            ),
          ),
        ],
      ),
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
            'No More Matches',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFFF0F6FC),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve seen all available developers.\nCheck back later for new matches!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF7D8590),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadInitialRecommendations,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
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
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadInitialRecommendations,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
