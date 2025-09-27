import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

/// Onboarding screen for first-time users
class OnboardingScreen extends StatefulWidget {
  /// Creates the onboarding screen
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Connect with Developers',
      description:
          'Discover amazing developers and their projects through our intelligent matching system.',
      lottieAsset: 'assets/animations/sample_onboarding.json',
      color: const Color(0xFF6366F1),
    ),
    OnboardingPage(
      title: 'Swipe & Match',
      description:
          'Swipe through projects and developers to find your perfect collaboration match.',
      lottieAsset: 'assets/animations/sample_onboarding.json',
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingPage(
      title: 'Start Collaborating',
      description:
          'Connect with matched developers and start building amazing projects together.',
      lottieAsset: 'assets/animations/sample_onboarding.json',
      color: const Color(0xFF06B6D4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToAuth();
    }
  }

  void _goToAuth() {
    context.go(AppRouter.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Container(
                height: 300.h,
                width: 300.w,
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Lottie.asset(
                    page.lottieAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.code, size: 120.sp, color: page.color);
                    },
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              // Title
              Text(
                page.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: page.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Description
              Text(
                page.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildPageIndicator(index),
            ),
          ),
          SizedBox(height: 32.h),

          // Next/Get Started Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_currentPage].color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Skip Button
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _goToAuth,
              child: Text(
                'Skip',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: _currentPage == index ? 24.w : 8.w,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? _pages[_currentPage].color
                : Colors.grey[300],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

/// Represents an onboarding page
class OnboardingPage {
  /// Title of the onboarding page
  final String title;

  /// Description of the onboarding page
  final String description;

  /// Lottie animation asset path
  final String lottieAsset;

  /// Color theme for the page
  final Color color;

  /// Creates an onboarding page
  OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
  });
}
