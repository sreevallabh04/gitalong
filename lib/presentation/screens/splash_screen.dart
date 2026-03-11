import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/logger.dart';

/// Splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Add initialization logic here
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if user is authenticated
      // For now, navigate to login
      if (mounted) {
        context.go(RoutePaths.login);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing app', e, stackTrace);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🚀',
                    style: TextStyle(fontSize: 60.sp),
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // App Name
              Text(
                'GitAlong',
                style: AppTextStyles.headlineLarge(Colors.white),
              ),
              
              SizedBox(height: 8.h),
              
              // App Tagline
              Text(
                'Connect with Developers',
                style: AppTextStyles.bodyLarge(
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),
              
              SizedBox(height: 48.h),
              
              // Loading Indicator
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

