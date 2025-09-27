import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../../core/theme/app_theme.dart';

/// Swipe screen for discovering projects and developers
class SwipeScreen extends StatefulWidget {
  /// Creates the swipe screen
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  late SwiperController _swiperController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isLiked = false;
  bool _isPassed = false;

  // Dummy data for demonstration
  final List<SwipeCardData> _cards = [
    SwipeCardData(
      id: '1',
      type: SwipeCardType.user,
      title: 'Alex Chen',
      subtitle: 'Full Stack Developer',
      description:
          'Passionate about React, Node.js, and building scalable web applications. Looking for collaboration on open-source projects.',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      technologies: ['React', 'Node.js', 'TypeScript', 'MongoDB'],
      stats: {'repos': 45, 'stars': 1200, 'followers': 850},
    ),
    SwipeCardData(
      id: '2',
      type: SwipeCardType.project,
      title: 'EcoTracker',
      subtitle: 'Environmental Monitoring App',
      description:
          'A mobile app that helps users track their carbon footprint and suggests eco-friendly alternatives.',
      imageUrl:
          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400',
      technologies: ['Flutter', 'Firebase', 'Dart', 'Google Maps API'],
      stats: {'stars': 89, 'forks': 23, 'issues': 5},
    ),
    SwipeCardData(
      id: '3',
      type: SwipeCardType.user,
      title: 'Sarah Johnson',
      subtitle: 'Mobile Developer',
      description:
          'iOS and Android developer with 5+ years experience. Love working on fintech and health apps.',
      imageUrl:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      technologies: ['Swift', 'Kotlin', 'Flutter', 'React Native'],
      stats: {'repos': 32, 'stars': 890, 'followers': 650},
    ),
    SwipeCardData(
      id: '4',
      type: SwipeCardType.project,
      title: 'DevTools Suite',
      subtitle: 'Developer Productivity Tools',
      description:
          'A collection of CLI tools to boost developer productivity. Includes code formatters, linters, and automation scripts.',
      imageUrl:
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400',
      technologies: ['Python', 'Rust', 'Go', 'Shell'],
      stats: {'stars': 234, 'forks': 67, 'issues': 12},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    setState(() {
      _isPassed = true;
      _isLiked = false;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
      _swiperController.next();
    });
  }

  void _onSwipeRight() {
    setState(() {
      _isLiked = true;
      _isPassed = false;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
      _swiperController.next();
    });
  }

  void _onSuperLike() {
    // TODO(swipe): Implement super like functionality
    _swiperController.next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO(swipe): Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Swipe Cards
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Swiper(
                controller: _swiperController,
                itemBuilder: (context, index) {
                  if (index >= _cards.length) {
                    return _buildEmptyState();
                  }
                  return _buildSwipeCard(_cards[index]);
                },
                itemCount: _cards.length + 1,
                itemWidth: double.infinity,
                itemHeight: double.infinity,
                layout: SwiperLayout.STACK,
                onIndexChanged: (index) {
                  setState(() {
                    _isLiked = false;
                    _isPassed = false;
                  });
                },
              ),
            ),
          ),

          // Action Buttons
          Expanded(flex: 2, child: _buildActionButtons()),
        ],
      ),
    );
  }

  Widget _buildSwipeCard(SwipeCardData card) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.network(
                      card.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            card.type == SwipeCardType.user
                                ? Icons.person
                                : Icons.code,
                            size: 80.sp,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title and Subtitle
                          Text(
                            card.title,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            card.subtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Description
                          Text(
                            card.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16.h),

                          // Technologies
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children:
                                card.technologies.take(4).map((tech) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      tech,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          SizedBox(height: 16.h),

                          // Stats
                          Row(
                            children:
                                card.stats.entries.map((stat) {
                                  return Expanded(
                                    child: _buildStatItem(
                                      stat.key,
                                      stat.value.toString(),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Like/Pass Overlay
                  if (_isLiked || _isPassed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: (_isLiked ? Colors.green : Colors.red)
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: _isLiked ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Text(
                              _isLiked ? 'LIKED' : 'PASSED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onTap: _onSwipeLeft,
          ),

          // Super Like Button
          _buildActionButton(
            icon: Icons.star,
            color: Colors.blue,
            onTap: _onSuperLike,
            size: 60.w,
          ),

          // Like Button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onTap: _onSwipeRight,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No more cards!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for new matches',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data for a swipe card
class SwipeCardData {
  /// Unique identifier for the card
  final String id;

  /// Type of the swipe card
  final SwipeCardType type;

  /// Title of the card
  final String title;

  /// Subtitle of the card
  final String subtitle;

  /// Description of the card
  final String description;

  /// Image URL for the card
  final String imageUrl;

  /// Technologies associated with the card
  final List<String> technologies;

  /// Statistics for the card
  final Map<String, int> stats;

  /// Creates swipe card data
  SwipeCardData({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.technologies,
    required this.stats,
  });
}

/// Type of swipe card
enum SwipeCardType {
  /// User profile card
  user,

  /// Project card
  project,
}
