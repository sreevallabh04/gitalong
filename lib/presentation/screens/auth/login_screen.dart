import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _waitingForBrowser = false;

  void _signInWithGitHub() async {
    HapticFeedback.lightImpact();
    setState(() => _waitingForBrowser = true);
    if (mounted) {
      context.read<AuthBloc>().add(SignInWithGitHubEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() => _waitingForBrowser = false);
          context.go(RoutePaths.home);
        } else if (state is AuthError) {
          setState(() => _waitingForBrowser = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthUnauthenticated) {
          setState(() => _waitingForBrowser = false);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              PhosphorIconsRegular.githubLogo,
                              size: 60.sp,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  'Welcome to GitAlong',
                  style: AppTextStyles.headlineMedium(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Find your ultimate open-source companion',
                  style: AppTextStyles.bodyLarge(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 64.h),

                // GitHub Sign In Button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _waitingForBrowser
                      ? _buildWaitingState()
                      : _buildSignInButton(),
                ),

                SizedBox(height: 48.h),

                // Terms & Privacy
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: AppTextStyles.bodySmall(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      key: const ValueKey('button'),
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: _signInWithGitHub,
        icon: Icon(PhosphorIconsRegular.githubLogo, size: 24.sp, color: Colors.white),
        label: Text(
          'Continue with GitHub',
          style: AppTextStyles.titleMedium(Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingState() {
    return Column(
      key: const ValueKey('waiting'),
      children: [
        SizedBox(
          width: 32.w,
          height: 32.w,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Waiting for GitHub sign-in...',
          style: AppTextStyles.bodyMedium(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () => setState(() => _waitingForBrowser = false),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyMedium(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
