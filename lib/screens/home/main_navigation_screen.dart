import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: PhosphorIcons.heart(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
      label: 'Discover',
      route: AppRoutes.swipe,
    ),
    NavigationItem(
      icon: PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
      label: 'Messages',
      route: AppRoutes.messages,
    ),
    NavigationItem(
      icon: PhosphorIcons.bookmark(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
      label: 'Saved',
      route: AppRoutes.saved,
    ),
    NavigationItem(
      icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
      activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final currentRoute = GoRouterState.of(context).fullPath;

    // Update current index based on route
    _updateIndexFromRoute(currentRoute);

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigation(),
    );
  }

  void _updateIndexFromRoute(String? route) {
    if (route == null) return;

    final newIndex = _navigationItems.indexWhere(
      (item) => route.startsWith(item.route),
    );

    if (newIndex != -1 && newIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = newIndex);
        }
      });
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [_buildAppBar(), Expanded(child: _getCurrentScreen())],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSideNavigation(),
        Expanded(
          child: Column(
            children: [_buildAppBar(), Expanded(child: _getCurrentScreen())],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: AppSizes.appBarHeight.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md.w),
          child: Row(
            children: [
              // Logo
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryNeon, AppColors.secondaryNeon],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.code, color: Colors.white, size: 20.w),
              ),
              SizedBox(width: AppSizes.sm.w),

              // Title
              Text(
                _navigationItems[_currentIndex].label,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const Spacer(),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Notifications
        IconButton(
          onPressed: () {
            // TODO: Implement notifications
          },
          icon: Icon(
            PhosphorIcons.bell(PhosphorIconsStyle.regular),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        // Settings
        IconButton(
          onPressed: () => context.push(AppRoutes.settings),
          icon: Icon(
            PhosphorIcons.gear(PhosphorIconsStyle.regular),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.05),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          Container(
            padding: EdgeInsets.all(AppSizes.lg.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryNeon, AppColors.secondaryNeon],
                    ),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(Icons.code, color: Colors.white, size: 25.w),
                ),
                SizedBox(width: AppSizes.md.w),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          Divider(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: AppSizes.sm.h),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = index == _currentIndex;

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm.w,
                    vertical: AppSizes.xs.h,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.sm.r),
                    ),
                    onTap: () => _onNavigationTap(index),
                  ),
                );
              },
            ),
          ),

          // Bottom section
          Padding(
            padding: EdgeInsets.all(AppSizes.md.w),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    PhosphorIcons.gear(PhosphorIconsStyle.regular),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSizes.bottomNavHeight.h,
          child: Row(
            children:
                _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == _currentIndex;

                  return Expanded(
                    child: InkWell(
                      onTap: () => _onNavigationTap(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.sm.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                              size: 24.w,
                            ),
                            SizedBox(height: AppSizes.xs.h),
                            Text(
                              item.label,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    // This will be handled by the shell route in GoRouter
    // For now, return a placeholder that shows the current route
    return Container(
      padding: EdgeInsets.all(AppSizes.md.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _navigationItems[_currentIndex].activeIcon,
              size: 64.w,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: AppSizes.md.h),
            Text(
              '${_navigationItems[_currentIndex].label} Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSizes.sm.h),
            Text(
              'This screen will show the ${_navigationItems[_currentIndex].label.toLowerCase()} content',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onNavigationTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);
    context.go(_navigationItems[index].route);
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
