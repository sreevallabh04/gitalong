import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../core/utils/logger.dart';
import 'auth/login_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'home/main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;

  bool _hasNavigated = false;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    AppLogger.logger.ui('📱 SplashScreen initialized');

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _startAnimation();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    if (!mounted) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _logoController.forward();

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _textController.forward();

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _particleController.forward();
    } catch (e) {
      AppLogger.logger
          .w('⚠️ Animation controller disposed during initialization');
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
      AppLogger.logger.ui('📱 Splash status: $message');
    }
  }

  void _checkAuthStatus() async {
    try {
      AppLogger.logger.auth('🔍 Starting authentication check...');
      _updateStatus('Checking authentication...');

      // Give Firebase time to initialize
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted || _hasNavigated) return;

      // Check auth state with error handling
      try {
        _updateStatus('Verifying credentials...');
        final authService = ref.read(authServiceProvider);

        AppLogger.logger.auth('🔐 Auth service obtained, checking status...');

        if (authService.isAuthenticated) {
          AppLogger.logger.auth('✅ User is authenticated, checking profile...');
          _updateStatus('Loading profile...');

          // Check if user has completed onboarding
          final hasProfile = await ref.read(hasUserProfileProvider.future);

          AppLogger.logger.auth('📋 Profile check result: $hasProfile');

          if (mounted && !_hasNavigated) {
            if (hasProfile) {
              AppLogger.logger.navigation('🏠 Navigating to home screen');
              _navigateToHome();
            } else {
              AppLogger.logger.navigation('📝 Navigating to onboarding screen');
              _navigateToOnboarding();
            }
          }
        } else {
          AppLogger.logger.auth('❌ User not authenticated');
          if (mounted && !_hasNavigated) {
            AppLogger.logger.navigation('🔐 Navigating to login screen');
            _navigateToLogin();
          }
        }
      } catch (authError, stackTrace) {
        AppLogger.logger.e(
          '❌ Authentication check failed',
          error: authError,
          stackTrace: stackTrace,
        );

        // Handle specific auth errors
        if (authError.toString().contains('Firebase')) {
          _updateStatus('Firebase connection issue...');
          await Future.delayed(const Duration(seconds: 2));
        }

        if (mounted && !_hasNavigated) {
          AppLogger.logger
              .navigation('⚠️ Auth error - defaulting to login screen');
          _navigateToLogin();
        }
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Critical error during splash screen initialization',
        error: e,
        stackTrace: stackTrace,
      );

      // Always try to navigate somewhere, even if there's an error
      if (mounted && !_hasNavigated) {
        _updateStatus('Initialization error...');
        await Future.delayed(const Duration(seconds: 1));
        AppLogger.logger
            .navigation('🚨 Critical error - defaulting to login screen');
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    AppLogger.logger.navigation('🔐 Navigating to LoginScreen');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _navigateToOnboarding() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    AppLogger.logger.navigation('📝 Navigating to OnboardingScreen');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _navigateToHome() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    AppLogger.logger.navigation('🏠 Navigating to MainNavigationScreen');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            ...List.generate(50, (index) => _buildParticle(index)),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with glassmorphism
                  _buildLogoContainer(),
                  const SizedBox(height: 40),

                  // App name with animation
                  _buildAnimatedTitle(),
                  const SizedBox(height: 16),

                  // Tagline
                  _buildTagline(),
                  const SizedBox(height: 60),

                  // Loading indicator with status
                  _buildLoadingIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = (index * 17) % 100;
    final size = 2.0 + (random % 4);
    final duration = 3000 + (random % 2000);
    final delay = random * 20;

    return Positioned(
      left: (random % 100) * 4.0,
      top: (random % 100) * 8.0,
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _particleController.value * 100 - 50),
            child: Opacity(
              opacity: (1 - _particleController.value) * 0.7,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: Duration(milliseconds: duration))
        .then()
        .fadeOut(duration: Duration(milliseconds: duration));
  }

  Widget _buildLogoContainer() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoController.value,
          child: Transform.rotate(
            angle: _logoController.value * 0.1,
            child: GlassmorphicContainer(
              width: 160,
              height: 160,
              borderRadius: 30,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.5),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.code,
                  size: 80,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textController.value)),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ).createShader(bounds),
              child: Text(
                'GitAlong',
                style: GoogleFonts.orbitron(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    return Text(
      'Find your perfect open source match',
      style: GoogleFonts.inter(
        fontSize: 16,
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    )
        .animate(delay: 1000.ms)
        .fadeIn(duration: 1000.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
          ),
        )
            .animate(delay: 1500.ms)
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 20),
        Text(
          _statusMessage,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ).animate(delay: 2000.ms).fadeIn(duration: 800.ms),
      ],
    );
  }
}
