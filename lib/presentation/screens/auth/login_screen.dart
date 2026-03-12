import 'dart:io';

import 'package:flutter/gestures.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  void _signInWithGitHub() {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    context.read<AuthBloc>().add(SignInWithGitHubEvent());
  }

  void _signInWithGoogle() {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    context.read<AuthBloc>().add(SignInWithGoogleEvent());
  }

  void _signInWithApple() {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    context.read<AuthBloc>().add(SignInWithAppleEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() => _loading = false);
        } else if (state is AuthError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AuthUnauthenticated) {
          setState(() => _loading = false);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
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
                          size: 56.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                Text(
                  'Welcome to GitAlong',
                  style: AppTextStyles.headlineMedium(colors.onSurface),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Find your ultimate open-source companion',
                  style: AppTextStyles.bodyLarge(colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Sign-in buttons
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _loading ? _buildLoadingState() : _buildButtons(),
                ),

                const Spacer(),

                // Terms & Privacy
                _buildLegalText(context),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      key: const ValueKey('buttons'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // GitHub (primary)
        _SignInButton(
          label: 'Continue with GitHub',
          icon: PhosphorIconsRegular.githubLogo,
          backgroundColor: AppColors.github,
          foregroundColor: Colors.white,
          onPressed: _signInWithGitHub,
        ),

        SizedBox(height: 12.h),

        // Google
        _SignInButton(
          label: 'Continue with Google',
          icon: PhosphorIconsRegular.googleLogo,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          borderColor: Colors.grey.shade300,
          onPressed: _signInWithGoogle,
        ),

        // Apple -- only on iOS / macOS
        if (Platform.isIOS || Platform.isMacOS) ...[
          SizedBox(height: 12.h),
          _SignInButton(
            label: 'Continue with Apple',
            icon: PhosphorIconsRegular.appleLogo,
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
            foregroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
            onPressed: _signInWithApple,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      key: const ValueKey('loading'),
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
          'Signing in...',
          style: AppTextStyles.bodyMedium(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () => setState(() => _loading = false),
          child: Text('Cancel', style: AppTextStyles.bodyMedium(AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildLegalText(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.bodySmall(muted),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.bodySmall(AppColors.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push(RoutePaths.termsOfService),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.bodySmall(AppColors.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push(RoutePaths.privacyPolicy),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22.sp, color: foregroundColor),
        label: Text(label, style: AppTextStyles.titleMedium(foregroundColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
