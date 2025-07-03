import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/logger.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    AppLogger.logger.ui('📱 SplashScreen initialized');

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800), // Much faster
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600), // Much faster
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 400), // Much faster
      vsync: this,
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start animations in parallel for faster loading
    _backgroundController.forward();
    _logoController.forward();
    _textController.forward();

    // Much shorter wait time - just enough for visual feedback
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Navigate using new router system with STRICT email verification
    _performAuthCheck();
  }

  /// 🔒 STRICT AUTHENTICATION CHECK - No access until email verified
  Future<void> _performAuthCheck() async {
    if (!mounted) return;

    try {
      final user = ref.read(authStateProvider).value;

      if (user == null) {
        // No user signed in - go to login
        AppLogger.logger.auth('🔐 No user authenticated, redirecting to login');
        if (mounted) context.go('/login');
        return;
      }

      // User exists, but check email verification status
      await user.reload(); // Get fresh data
      final refreshedUser = ref.read(authStateProvider).value;

      if (refreshedUser == null) {
        AppLogger.logger.auth('🔐 User session expired, redirecting to login');
        if (mounted) context.go('/login');
        return;
      }

      if (!refreshedUser.emailVerified) {
        // 🚨 BLOCKED: Email not verified - stay on current screen to show verification banner
        AppLogger.logger.auth('❌ Email not verified, blocking app access');
        // Don't navigate - let the EmailVerificationBanner handle this
        return;
      }

      // Email is verified, check if profile exists
      try {
        final profile =
            await FirestoreService.getUserProfile(refreshedUser.uid);

        if (profile == null) {
          AppLogger.logger
              .auth('📝 No profile found, redirecting to onboarding');
          if (mounted) context.go('/onboarding');
          return;
        }

        // Everything checks out - go to home
        AppLogger.logger
            .auth('✅ User authenticated and verified, redirecting to home');
        if (mounted) context.go('/home');
      } catch (e) {
        AppLogger.logger.e('❌ Error checking user profile', error: e);
        // If profile check fails, assume no profile and go to onboarding
        if (mounted) context.go('/onboarding');
      }
    } catch (error) {
      AppLogger.logger.e('❌ Error in auth check', error: error);
      // On any error, go to login for safety
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub black
      body: authState.when(
        data: (user) {
          // Show verification banner if user exists but email not verified
          if (user != null && !user.emailVerified) {
            return _buildEmailVerificationBlockingScreen();
          }

          // Otherwise show loading splash
          return _buildLoadingSplash();
        },
        loading: () => _buildLoadingSplash(),
        error: (error, stack) {
          AppLogger.logger.e('❌ Auth state error', error: error);
          return _buildErrorScreen(error.toString());
        },
      ),
    );
  }

  /// 🚨 BLOCKING SCREEN: Forces email verification before proceeding
  Widget _buildEmailVerificationBlockingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            const Color(0xFFE09800).withValues(alpha: 0.1), // Warning orange
            const Color(0xFF161B22).withValues(alpha: 0.8),
            const Color(0xFF0D1117),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE09800), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE09800).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Email Verification Required',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF0F6FC),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'You must verify your email address before accessing GitAlong.\n\nThis ensures account security and enables all features.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF7D8590),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Email verification banner will be shown here automatically
              // by the auth state management

              const SizedBox(height: 20),

              // Sign out option
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(authServiceProvider).signOut();
                    if (mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    AppLogger.logger.e('Error signing out', error: e);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7D8590),
                ),
                child: Text(
                  'Sign Out and Use Different Account',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSplash() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            const Color(0xFF238636).withValues(alpha: 0.1),
            const Color(0xFF161B22).withValues(alpha: 0.8),
            const Color(0xFF0D1117),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + (_logoController.value * 0.5),
                  child: Opacity(
                    opacity: _logoController.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF238636),
                            Color(0xFF2EA043),
                            Color(0xFF3FB950),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF238636).withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.code,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // App name
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textController.value,
                  child: Text(
                    'GitAlong',
                    style: GoogleFonts.orbitron(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textController.value * 0.8,
                  child: Text(
                    'Connect • Collaborate • Create',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF7D8590),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF238636)),
                backgroundColor: Color(0xFF30363D),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFDA3633),
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Initialization Error',
              style: TextStyle(
                color: Color(0xFFF0F6FC),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to initialize the app. Please restart.',
              style: GoogleFonts.inter(
                color: const Color(0xFF7D8590),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
