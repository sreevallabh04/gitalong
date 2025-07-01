import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/logger.dart';
import 'swipe_screen.dart';
import 'messages_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

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

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const SwipeScreen(),
    const MessagesScreen(),
    const SavedScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(PhosphorIcons.heart(PhosphorIconsStyle.regular)),
      selectedIcon: Icon(PhosphorIcons.heart(PhosphorIconsStyle.fill)),
      label: 'Swipe',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIcons.chatCircle(PhosphorIconsStyle.regular)),
      selectedIcon: Icon(PhosphorIcons.chatCircle(PhosphorIconsStyle.fill)),
      label: 'Messages',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIcons.bookmark(PhosphorIconsStyle.regular)),
      selectedIcon: Icon(PhosphorIcons.bookmark(PhosphorIconsStyle.fill)),
      label: 'Saved',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
      selectedIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    AppLogger.logger.navigation(
        '🏠 Main navigation initialized with index: $_currentIndex');
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    AppLogger.logger.navigation('🔄 Navigation tab changed to index: $index');

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
        context.goToProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub black
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22), // GitHub dark gray
          border: Border(
            top: BorderSide(
              color: const Color(0xFF30363D), // GitHub border
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          destinations: _destinations,
          selectedIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
          backgroundColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFF238636).withOpacity(0.1),
          overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFF238636).withOpacity(0.1);
            }
            if (states.contains(MaterialState.hovered)) {
              return const Color(0xFF238636).withOpacity(0.05);
            }
            return null;
          }),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
