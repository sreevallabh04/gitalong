import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/logger.dart';
import '../../core/monitoring/analytics_service.dart';
import 'swipe_screen.dart';
import 'messages_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import '../github/github_explore_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _backgroundController;
  late PageController _pageController;

  final List<Widget> _screens = [
    const SwipeScreen(),
    const MessagesScreen(),
    const SavedScreen(),
    const GitHubExploreScreen(),
    const ProfileScreen(),
  ];

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: PhosphorIcons.heart(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
      label: 'Discover',
      color: const Color(0xFFE91E63),
    ),
    _NavigationItem(
      icon: PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
      label: 'Messages',
      color: const Color(0xFF1F6FEB),
    ),
    _NavigationItem(
      icon: PhosphorIcons.bookmark(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
      label: 'Saved',
      color: const Color(0xFFE09800),
    ),
    _NavigationItem(
      icon: PhosphorIcons.gitBranch(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.gitBranch(PhosphorIconsStyle.fill),
      label: 'Explore',
      color: const Color(0xFF238636),
    ),
    _NavigationItem(
      icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
      label: 'Profile',
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    AppLogger.logger.navigation(
        '🏠 Main navigation initialized with index: $_currentIndex');
    AnalyticsService.trackScreenView('main_navigation');
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );

    // Trigger haptic feedback
    if (mounted) {
      _backgroundController.forward().then((_) {
        _backgroundController.reverse();
      });
    }

    AppLogger.logger.navigation('🔄 Navigation tab changed to index: $index');
    AnalyticsService.trackScreenView(_getScreenName(index));

    // Optional: Update the URL for deep linking
    switch (index) {
      case 0:
        context.goToSwipe();
        break;
      case 1:
        context.goToMessages();
        break;
      case 2:
        context.goToSaved();
        break;
      case 3:
        // GitHub Explorer - no route update needed as it's embedded
        break;
      case 4:
        context.goToProfile();
        break;
    }
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0: return 'swipe_screen';
      case 1: return 'messages_screen';
      case 2: return 'saved_screen';
      case 3: return 'github_explore_screen';
      case 4: return 'profile_screen';
      default: return 'unknown_screen';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 2.0,
            colors: [
              _navigationItems[_currentIndex].color.withValues(alpha: 0.03),
              const Color(0xFF0D1117),
              const Color(0xFF0D1117),
            ],
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _screens.length,
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF21262D).withValues(alpha: 0.95),
                const Color(0xFF161B22).withValues(alpha: 0.95),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF30363D).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;
              
              return _buildNavigationItem(
                item: item,
                index: index,
                isSelected: isSelected,
              );
            }).toList(),
          ),
        ),
      ),
    ).animate()
      .slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutBack)
      .fadeIn(duration: 400.ms);
  }

  Widget _buildNavigationItem({
    required _NavigationItem item,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onDestinationSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected 
            ? item.color.withValues(alpha: 0.15)
            : Colors.transparent,
          border: isSelected
            ? Border.all(
                color: item.color.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                  ? item.color.withValues(alpha: 0.2)
                  : Colors.transparent,
                boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  size: 24,
                  color: isSelected ? item.color : const Color(0xFF7D8590),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? item.color : const Color(0xFF7D8590),
                letterSpacing: 0.5,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.1, 1.1),
        duration: 200.ms,
        curve: Curves.easeInOut,
      );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
