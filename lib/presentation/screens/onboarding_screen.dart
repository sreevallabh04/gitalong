import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: '👋',
      title: 'Welcome to GitAlong',
      description: 'Connect with developers who share your interests and build amazing projects together.',
    ),
    OnboardingPage(
      icon: '💻',
      title: 'Discover Projects',
      description: 'Swipe through developers and their GitHub projects. Find your perfect coding match!',
    ),
    OnboardingPage(
      icon: '💬',
      title: 'Start Collaborating',
      description: 'Match with developers and start chatting. Build the next big thing together!',
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(RoutePaths.login),
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLarge(AppColors.primary),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Text(
                          page.icon,
                          style: TextStyle(fontSize: 100.sp),
                        ),
                        
                        SizedBox(height: 48.h),
                        
                        // Title
                        Text(
                          page.title,
                          style: AppTextStyles.headlineMedium(
                            Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Description
                        Text(
                          page.description,
                          style: AppTextStyles.bodyLarge(
                            Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Continue Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go(RoutePaths.login);
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: AppTextStyles.labelLarge(Colors.white),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

/// Onboarding page model
class OnboardingPage {
  final String icon;
  final String title;
  final String description;
  
  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

