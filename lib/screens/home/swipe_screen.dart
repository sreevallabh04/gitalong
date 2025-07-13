import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../core/theme/github_theme.dart';
import '../../core/utils/logger.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swipe_provider.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/github_button.dart';
import '../../widgets/common/contribution_graph.dart';
import '../../widgets/swipe/developer_card.dart';
import '../../widgets/swipe/match_overlay.dart';
import '../../widgets/swipe/action_buttons.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen>
    with TickerProviderStateMixin {
  final SwiperController _swiperController = SwiperController();

  late AnimationController _matchAnimationController;
  late AnimationController _likeAnimationController;
  late AnimationController _passAnimationController;

  late Animation<double> _matchScaleAnimation;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _passScaleAnimation;

  bool _showMatchOverlay = false;
  UserModel? _currentMatchedUser;
  bool _isSwipeEnabled = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    Future.microtask(_loadRecommendations);
  }

  void _setupAnimations() {
    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _passAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _matchScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _matchAnimationController,
      curve: Curves.elasticOut,
    ));

    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    ));

    _passScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _passAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _matchAnimationController.dispose();
    _likeAnimationController.dispose();
    _passAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) return;

    await ref.read(swipeProvider.notifier).loadRecommendations(currentUser.uid);
  }

  Future<void> _handleSwipe(UserModel user, bool isLike) async {
    if (!_isSwipeEnabled) return;

    setState(() => _isSwipeEnabled = false);

    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) return;

    try {
      // Trigger animation
      if (isLike) {
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reverse();
        });
      } else {
        _passAnimationController.forward().then((_) {
          _passAnimationController.reverse();
        });
      }

      // Record swipe and check for match
      final isMatch = await UserService.recordSwipe(
        swiperId: currentUser.uid,
        swipedUserId: user.uid,
        isLike: isLike,
      );

      // Update provider state
      await ref.read(swipeProvider.notifier).recordSwipe(user.uid, isLike);

      if (isMatch && isLike) {
        _showMatch(user);
      }

      AppLogger.logger.d('👆 Swipe recorded: ${isLike ? "LIKE" : "PASS"}');
    } catch (e) {
      AppLogger.logger.e('❌ Failed to record swipe', error: e);
      _showErrorSnackBar('Failed to record swipe. Please try again.');
    } finally {
      // Re-enable swiping after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isSwipeEnabled = true);
        }
      });
    }
  }

  void _showMatch(UserModel matchedUser) {
    setState(() {
      _showMatchOverlay = true;
      _currentMatchedUser = matchedUser;
    });

    _matchAnimationController.forward();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideMatch();
      }
    });
  }

  void _hideMatch() {
    _matchAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showMatchOverlay = false;
          _currentMatchedUser = null;
        });
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GitHubTheme.dangerEmphasis,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final swipeState = ref.watch(swipeProvider);

    return Scaffold(
      backgroundColor: GitHubTheme.canvasDefault,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background pattern
          _buildBackgroundPattern(),

          // Main content
          _buildMainContent(swipeState),

          // Action buttons
          Positioned(
            bottom: GitHubTheme.space6,
            left: 0,
            right: 0,
            child: _buildActionButtons(swipeState),
          ),

          // Match overlay
          if (_showMatchOverlay && _currentMatchedUser != null)
            MatchOverlay(
              currentUser: ref.read(userProfileProvider).value!,
              matchedUser: _currentMatchedUser!,
              onContinue: _hideMatch,
              onMessage: () {
                _hideMatch();
                // TODO: Navigate to chat
              },
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: GitHubTheme.canvasDefault,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: GitHubTheme.accentFg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.code,
              color: GitHubTheme.fgOnEmphasis,
              size: 20,
            ),
          ),
          const SizedBox(width: GitHubTheme.space2),
          Text(
            'Discover',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GitHubTheme.fgDefault,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () {
            // TODO: Show filters
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadRecommendations,
        ),
      ],
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      size: Size.infinite,
      painter: GitHubPatternPainter(),
    );
  }

  Widget _buildMainContent(AsyncValue<List<UserModel>> swipeState) {
    return swipeState.when(
      data: (users) {
        if (users.isEmpty) {
          return _buildEmptyState();
        }

        return _buildSwipeCards(users);
      },
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }

  Widget _buildSwipeCards(List<UserModel> users) {
    return Padding(
      padding: const EdgeInsets.only(
        top: GitHubTheme.space4,
        left: GitHubTheme.space4,
        right: GitHubTheme.space4,
        bottom: GitHubTheme.space10,
      ),
      child: Swiper(
        controller: _swiperController,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              _likeScaleAnimation,
              _passScaleAnimation,
            ]),
            builder: (context, child) {
              double scale = 1.0;
              if (index == 0) {
                // Apply scale to top card only
                scale = math.max(
                    _likeScaleAnimation.value, _passScaleAnimation.value);
              }

              return Transform.scale(
                scale: scale,
                child: DeveloperCard(
                  user: users[index],
                  onTap: () => _showUserDetails(users[index]),
                ),
              );
            },
          );
        },
        onIndexChanged: (index) {
          // Pre-load more recommendations when nearing the end
          if (index >= users.length - 2) {
            _loadRecommendations();
          }
        },
        viewportFraction: 0.9,
        scale: 0.9,
        loop: false,
        duration: 300,
        curve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        customLayoutOption: CustomLayoutOption(
          startIndex: -1,
          stateCount: 3,
        )
          ..addRotate([
            -30.0 / 180,
            0.0,
            30.0 / 180,
          ])
          ..addScale([0.8, 1.0, 0.8], Alignment.center)
          ..addTranslate([
            const Offset(-100, 0),
            const Offset(0, 0),
            const Offset(100, 0),
          ]),
        layout: SwiperLayout.STACK,
        itemWidth: MediaQuery.of(context).size.width * 0.85,
        itemHeight: MediaQuery.of(context).size.height * 0.65,
      ),
    );
  }

  Widget _buildActionButtons(AsyncValue<List<UserModel>> swipeState) {
    return swipeState.maybeWhen(
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();

        return SwipeActionButtons(
          onPass: _isSwipeEnabled
              ? () {
                  _swiperController.previous();
                  _handleSwipe(users[0], false);
                }
              : null,
          onLike: _isSwipeEnabled
              ? () {
                  _swiperController.next();
                  _handleSwipe(users[0], true);
                }
              : null,
          onSuperLike: _isSwipeEnabled
              ? () {
                  // TODO: Implement super like
                  _handleSwipe(users[0], true);
                }
              : null,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(GitHubTheme.space4),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: GitHubTheme.space4),
                  child: ShimmerCard(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GitHubTheme.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: GitHubTheme.canvasOverlay,
                shape: BoxShape.circle,
                border: Border.all(color: GitHubTheme.borderDefault),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 60,
                color: GitHubTheme.fgMuted,
              ),
            ).animate().scale(),
            const SizedBox(height: GitHubTheme.space4),
            Text(
              'No More Developers',
              style: GitHubTheme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: GitHubTheme.space2),
            Text(
              'You\'ve seen all available developers in your area. Check back later for new matches!',
              style: GitHubTheme.textTheme.bodyMedium?.copyWith(
                color: GitHubTheme.fgMuted,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: GitHubTheme.space6),
            GitHubPrimaryButton(
              text: 'Refresh',
              icon: Icons.refresh,
              onPressed: _loadRecommendations,
            ).animate().fadeIn(delay: 600.ms).slideY(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GitHubTheme.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: GitHubTheme.dangerSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: GitHubTheme.dangerMuted),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: GitHubTheme.dangerFg,
              ),
            ).animate().scale(),
            const SizedBox(height: GitHubTheme.space4),
            Text(
              'Something went wrong',
              style: GitHubTheme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: GitHubTheme.space2),
            Text(
              'Failed to load recommendations. Please check your connection and try again.',
              style: GitHubTheme.textTheme.bodyMedium?.copyWith(
                color: GitHubTheme.fgMuted,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: GitHubTheme.space6),
            GitHubPrimaryButton(
              text: 'Try Again',
              icon: Icons.refresh,
              onPressed: _loadRecommendations,
            ).animate().fadeIn(delay: 600.ms).slideY(),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: GitHubTheme.canvasOverlay,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: UserDetailsSheet(
              user: user,
              scrollController: scrollController,
              onLike: () {
                Navigator.pop(context);
                _handleSwipe(user, true);
              },
              onPass: () {
                Navigator.pop(context);
                _handleSwipe(user, false);
              },
            ),
          );
        },
      ),
    );
  }
}

// Background pattern painter
class GitHubPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GitHubTheme.borderDefault.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// User details sheet
class UserDetailsSheet extends StatelessWidget {
  final UserModel user;
  final ScrollController scrollController;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const UserDetailsSheet({
    super.key,
    required this.user,
    required this.scrollController,
    required this.onLike,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: GitHubTheme.space2),
          decoration: BoxDecoration(
            color: GitHubTheme.borderDefault,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(GitHubTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: GitHubTheme.canvasInset,
                      child: user.profileImageUrl != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.profileImageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: GitHubTheme.fgMuted,
                            ),
                    ),
                    const SizedBox(width: GitHubTheme.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'Unknown',
                            style: GitHubTheme.textTheme.headlineSmall,
                          ),
                          if (user.githubHandle != null)
                            Text(
                              '@${user.githubHandle}',
                              style: GitHubTheme.textTheme.bodyMedium?.copyWith(
                                color: GitHubTheme.fgMuted,
                              ),
                            ),
                          if (user.location != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: GitHubTheme.fgMuted,
                                ),
                                const SizedBox(width: GitHubTheme.space1),
                                Text(
                                  user.location!,
                                  style: GitHubTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: GitHubTheme.space4),

                // Bio
                if (user.bio != null) ...[
                  Text(
                    'About',
                    style: GitHubTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: GitHubTheme.space2),
                  Text(
                    user.bio!,
                    style: GitHubTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: GitHubTheme.space4),
                ],

                // Tech stack
                if (user.techStack != null && user.techStack!.isNotEmpty) ...[
                  Text(
                    'Tech Stack',
                    style: GitHubTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: GitHubTheme.space2),
                  Wrap(
                    spacing: GitHubTheme.space1,
                    runSpacing: GitHubTheme.space1,
                    children: user.techStack!.map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GitHubTheme.space2,
                          vertical: GitHubTheme.space1,
                        ),
                        decoration: BoxDecoration(
                          color: GitHubTheme.accentSubtle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GitHubTheme.accentMuted),
                        ),
                        child: Text(
                          tech,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: GitHubTheme.accentFg,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: GitHubTheme.space4),
                ],

                // GitHub activity (if available)
                if (user.githubData != null) ...[
                  Text(
                    'GitHub Activity',
                    style: GitHubTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: GitHubTheme.space2),
                  ContributionGraph(
                    githubUsername: user.githubUsername,
                  ),
                  const SizedBox(height: GitHubTheme.space4),
                ],

                const SizedBox(height: GitHubTheme.space8),
              ],
            ),
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.all(GitHubTheme.space4),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: GitHubTheme.borderDefault),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GitHubOutlineButton(
                  text: 'Pass',
                  icon: Icons.close,
                  onPressed: onPass,
                ),
              ),
              const SizedBox(width: GitHubTheme.space3),
              Expanded(
                child: GitHubPrimaryButton(
                  text: 'Like',
                  icon: Icons.favorite,
                  onPressed: onLike,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
