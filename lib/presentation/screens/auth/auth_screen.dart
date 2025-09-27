import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

/// Authentication screen for GitHub OAuth login
class AuthScreen extends StatefulWidget {
  /// Creates the authentication screen
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _signInWithGitHub() {
    // TODO(auth): Implement GitHub OAuth
    _goToHome();
  }

  void _signInWithApple() {
    // TODO(auth): Implement Apple Sign In
    _goToHome();
  }

  void _goToHome() {
    context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // App Logo
                          Container(
                            height: 120.h,
                            width: 120.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.code,
                              size: 60.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // App Name
                          Text(
                            'GitAlong',
                            style: Theme.of(
                              context,
                            ).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Tagline
                          Text(
                            'Connect with developers through code',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Auth Buttons
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // GitHub Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGitHub,
                        icon: Icon(
                          Icons.code,
                          size: 24.sp,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Continue with GitHub',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24292E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Apple Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton.icon(
                        onPressed: _signInWithApple,
                        icon: Icon(
                          Icons.apple,
                          size: 24.sp,
                          color: Colors.black,
                        ),
                        label: Text(
                          'Continue with Apple',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Terms and Privacy
                    Text(
                      'By continuing, you agree to our Terms of Service and '
                      'Privacy Policy',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
