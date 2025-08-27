import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/logger.dart';
import '../../core/monitoring/analytics_service.dart';
import '../../core/utils/accessibility_utils.dart';
import '../../core/utils/accessibility_utils.dart';
import 'swipe_screen.dart';
import 'messages_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import '../search/user_search_screen.dart';
import '../../widgets/role_specific/collaborator_dashboard.dart';
import '../../widgets/role_specific/maintainer_dashboard.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_roles.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  final UserRole? userRole;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.userRole,
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
  late AnimationController _floatingActionController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _floatingActionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    AppLogger.logger.navigation(
        '🏠 Enhanced main navigation initialized with index: $_currentIndex');
    AnalyticsService.trackScreenView('main_navigation');
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    _floatingActionController.dispose();
    super.dispose();
  }

  List<Widget> get _screens {
    final userRole = widget.userRole ?? UserRole.collaborator;

    if (userRole == UserRole.maintainer || userRole == UserRole.admin) {
      return [
        const MaintainerDashboard(),
        const UserSearchScreen(),
        const MessagesScreen(),
        const SavedScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const CollaboratorDashboard(),
        const UserSearchScreen(),
        const MessagesScreen(),
        const SavedScreen(),
        const ProfileScreen(),
      ];
    }
  }

  List<_NavigationItem> get _navigationItems {
    final userRole = widget.userRole ?? UserRole.collaborator;

    if (userRole == UserRole.maintainer || userRole == UserRole.admin) {
      return [
        _NavigationItem(
          icon: PhosphorIcons.squaresFour(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.squaresFour(PhosphorIconsStyle.fill),
          label: 'Dashboard',
          color: const Color(0xFF10B981),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
          label: 'Discover',
          color: const Color(0xFF7C3AED),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
          label: 'Messages',
          color: const Color(0xFF1F6FEB),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.bookmark(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
          label: 'Saved',
          color: const Color(0xFFE09800),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
          label: 'Profile',
          color: const Color(0xFF8B5CF6),
          badge: null,
        ),
      ];
    } else {
      return [
        _NavigationItem(
          icon: PhosphorIcons.heart(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
          label: 'Discover',
          color: const Color(0xFFE91E63),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
          label: 'Search',
          color: const Color(0xFF7C3AED),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
          label: 'Messages',
          color: const Color(0xFF1F6FEB),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.bookmark(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
          label: 'Saved',
          color: const Color(0xFFE09800),
          badge: null,
        ),
        _NavigationItem(
          icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
          activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
          label: 'Profile',
          color: const Color(0xFF8B5CF6),
          badge: null,
        ),
      ];
    }
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );

    // Enhanced haptic feedback
    HapticUtils.lightImpact();

    // Trigger background animation
    if (mounted) {
      _backgroundController.forward().then((_) {
        _backgroundController.reverse();
      });
    }

    AppLogger.logger.navigation('🔄 Navigation tab changed to index: $index');
    AnalyticsService.trackScreenView(_getScreenName(index));
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0:
        return widget.userRole == UserRole.maintainer
            ? 'maintainer_dashboard'
            : 'collaborator_dashboard';
      case 1:
        return 'search_screen';
      case 2:
        return 'messages_screen';
      case 3:
        return 'saved_screen';
      case 4:
        return 'profile_screen';
      default:
        return 'unknown_screen';
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
              _navigationItems[_currentIndex].color.withValues(alpha: 0.05),
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
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildEnhancedBottomNavigationBar(),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _floatingActionController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_floatingActionController.value * 0.1),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _navigationItems[_currentIndex].color,
                  _navigationItems[_currentIndex].color.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _navigationItems[_currentIndex]
                      .color
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                _floatingActionController.forward().then((_) {
                  _floatingActionController.reverse();
                });
                // Add your FAB action here
                _showQuickActionsDialog(context);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                PhosphorIcons.plus(PhosphorIconsStyle.bold),
                color: Colors.white,
                size: 24,
              ),
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
                    icon: PhosphorIcons.plus(PhosphorIconsStyle.bold),
                    title: 'Create Project',
                    subtitle: 'Start a new open source project',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to project creation
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    icon: PhosphorIcons.upload(PhosphorIconsStyle.bold),
                    title: 'Upload Project',
                    subtitle: 'Share your existing project',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to project upload
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    icon: PhosphorIcons.users(PhosphorIconsStyle.bold),
                    title: 'Find Contributors',
                    subtitle: 'Search for developers to join',
                    color: const Color(0xFF1F6FEB),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to contributor search
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

  Widget _buildEnhancedBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF21262D).withValues(alpha: 0.98),
                const Color(0xFF161B22).withValues(alpha: 0.98),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF30363D).withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return Expanded(
                child: _buildEnhancedNavigationItem(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          duration: 800.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(
          duration: 600.ms,
        );
  }

  Widget _buildEnhancedNavigationItem({
    required _NavigationItem item,
    required int index,
    required bool isSelected,
  }) {
    return Semantics(
      label: AccessibilityUtils.getNavigationLabel(item.label, isSelected),
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _onDestinationSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isSelected
                ? item.color.withValues(alpha: 0.15)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: item.color.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? item.color.withValues(alpha: 0.25)
                          : Colors.transparent,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        key: ValueKey(isSelected),
                        size: 20,
                        color:
                            isSelected ? item.color : const Color(0xFF7D8590),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? item.color : const Color(0xFF7D8590),
                      letterSpacing: 0.5,
                    ),
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (item.badge != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF0D1117),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      item.badge!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().scale(
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      ),
                ),
            ],
          ),
        ),
      ).animate(target: isSelected ? 1 : 0).scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.15, 1.15),
            duration: 300.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final String? badge;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    this.badge,
  });
}
