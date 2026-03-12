import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Splash screen — purely visual.
/// Navigation is handled by the GoRouter redirect listening to AuthBloc.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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

              Text(
                'GitAlong',
                style: AppTextStyles.headlineLarge(Colors.white),
              ),

              SizedBox(height: 8.h),

              Text(
                'Connect with Developers',
                style: AppTextStyles.bodyLarge(
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),

              SizedBox(height: 48.h),

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
