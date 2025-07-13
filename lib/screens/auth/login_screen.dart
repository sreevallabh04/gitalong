import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/logger.dart';
import '../../widgets/common/accessible_button.dart';
import '../../widgets/common/accessible_form_field.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/auth_service.dart' as auth_service;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isTestMode = false; // Test mode flag

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _githubLogoController;
  late AnimationController _bounceController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _githubLogoAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkTestMode();
  }

  void _checkTestMode() {
    // Check if test mode is enabled via environment variable
    final testMode = dotenv.env['TEST_MODE']?.toLowerCase() == 'true';
    setState(() {
      _isTestMode = testMode;
    });
    AppLogger.logger.i('🧪 Test mode: ${_isTestMode ? 'ENABLED' : 'DISABLED'}');
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _githubLogoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _githubLogoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _githubLogoController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _githubLogoController.forward();
    });

    // Start bounce animation after logo appears
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _bounceController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _githubLogoController.dispose();
    _bounceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      AppLogger.logger.auth('🔐 Attempting email sign-in...');

      await ref.read(authServiceProvider).signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      AppLogger.logger.auth('✅ Email sign-in successful');
      _navigateToHome();
    } catch (e) {
      AppLogger.logger.e('❌ Email sign-in failed', error: e);
      _showErrorDialog('Sign In Failed', _getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGitHub() async {
    setState(() => _isLoading = true);

    try {
      AppLogger.logger.auth('🐙 Starting GitHub sign-in process...');

      if (_isTestMode) {
        // Simulate GitHub sign-in for testing
        AppLogger.logger.auth('🧪 Test mode: Simulating GitHub sign-in...');
        await Future.delayed(const Duration(seconds: 2));
        AppLogger.logger
            .auth('✅ Test mode: GitHub sign-in simulation successful');
        _navigateToHome();
        return;
      }

      final userCredential =
          await ref.read(authServiceProvider).signInWithGitHubMobile();

      AppLogger.logger.auth('✅ GitHub sign-in successful');
      AppLogger.logger.auth('👤 User: ${userCredential.user?.email}');
      AppLogger.logger.auth('🔑 User ID: ${userCredential.user?.uid}');

      // Ensure user profile is created
      try {
        await ref.read(authServiceProvider).getCurrentUserProfile();
        AppLogger.logger.auth('✅ User profile ensured/created');
      } catch (profileError) {
        AppLogger.logger
            .e('❌ Failed to create user profile', error: profileError);
        _showErrorDialog('Profile Error',
            'Failed to create user profile. Please try again.');
        return;
      }

      _navigateToHome();
    } catch (e) {
      AppLogger.logger.e('❌ GitHub sign-in failed', error: e);
      _showErrorDialog('GitHub Sign-In Failed', _getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      AppLogger.logger.auth('🔐 Starting Google sign-in process...');

      if (_isTestMode) {
        // Simulate Google sign-in for testing
        AppLogger.logger.auth('🧪 Test mode: Simulating Google sign-in...');
        await Future.delayed(const Duration(seconds: 2));
        AppLogger.logger
            .auth('✅ Test mode: Google sign-in simulation successful');
        _navigateToHome();
        return;
      }

      final userCredential =
          await ref.read(authServiceProvider).signInWithGoogle();

      AppLogger.logger.auth('✅ Google sign-in successful');
      AppLogger.logger.auth('👤 User: ${userCredential.user?.email}');

      // Ensure user profile is created
      try {
        await ref.read(authServiceProvider).getCurrentUserProfile();
        AppLogger.logger.auth('✅ User profile ensured/created');
      } catch (profileError) {
        AppLogger.logger
            .e('❌ Failed to create user profile', error: profileError);
        _showErrorDialog('Profile Error',
            'Failed to create user profile. Please try again.');
        return;
      }

      _navigateToHome();
    } catch (e) {
      AppLogger.logger.e('❌ Google sign-in failed', error: e);
      _showErrorDialog('Google Sign-In Failed', _getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;

    try {
      AppLogger.logger.auth('🚀 Navigating to home screen...');
      context.go('/home');
      AppLogger.logger.auth('✅ Navigation successful');
    } catch (navError) {
      AppLogger.logger.e('❌ Navigation failed', error: navError);
      _showErrorDialog('Navigation Error',
          'Failed to navigate to home screen. Please restart the app.');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is auth_service.AuthException) {
      return error.message;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('timeout')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return 'Sign-in was cancelled. Please try again.';
    }

    if (errorString.contains('invalid-credential')) {
      return 'Invalid credentials. Please check your email and password.';
    }

    if (errorString.contains('user-not-found')) {
      return 'No account found with this email. Please sign up first.';
    }

    if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }

    if (errorString.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a moment before trying again.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  void _showForgotPasswordDialog() {
    if (!mounted) return;

    final emailController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_reset,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reset Password',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive a password reset link.',
              style: GoogleFonts.inter(
                color: AppColors.muted,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                _showErrorDialog('Error', 'Please enter your email address.');
                return;
              }
              
              Navigator.of(context).pop();
              await _sendPasswordResetEmail(email);
            },
            child: Text(
              'Send Reset Link',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      _showErrorDialog(
        'Reset Link Sent',
        'Check your email for password reset instructions.',
      );
    } catch (e) {
      _showErrorDialog('Error', _getErrorMessage(e));
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // GitHub-themed background
            _buildGitHubBackground(),

            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // GitHub logo and title
                      _buildGitHubHeader(),

                      const SizedBox(height: 48),

                      // Login form
                      _buildLoginForm(),

                      const SizedBox(height: 32),

                      // GitHub login button
                      _buildGitHubLoginSection(),

                      const SizedBox(height: 24),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading) _buildLoadingOverlay(),

            // Test mode indicator
            if (_isTestMode) _buildTestModeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildGitHubBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surface.withValues(alpha: 0.3),
            AppColors.background,
          ],
        ),
      ),
      child: CustomPaint(
        painter: GitHubCommitHistoryPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildGitHubHeader() {
    return Column(
      children: [
        // GitHub logo with animation and bounce
        ScaleTransition(
          scale: _githubLogoAnimation,
          child: AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.code,
                    color: AppColors.white,
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Title with GitHub branding
        Text(
          'GitAlong',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Connect with developers through your code',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.muted,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

        const SizedBox(height: 16),

        // GitHub branding
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Powered by GitHub',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            AccessibleFormField(
              label: 'Email',
              hintText: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            AccessibleFormField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.muted,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Remember me checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Flexible(
                  child: Text(
                    'Remember me',
                    style: GoogleFonts.inter(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog();
                    },
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sign in button
            AccessibleButton(
              label: 'Sign In',
              onPressed: _isLoading ? null : _signInWithEmail,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGitHubLoginSection() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),

        const SizedBox(height: 24),

        // Google login button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _signInWithGoogle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    else ...[
                      const Icon(
                        Icons.account_circle,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      'Continue with Google',
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // GitHub login button with enhanced styling
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _signInWithGitHub,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    else ...[
                      const Icon(
                        Icons.code,
                        color: AppColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      'Continue with GitHub',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            context.go('/signup');
          },
          child: Text(
            'Create account',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Signing in...',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestModeIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.science,
              color: AppColors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'TEST MODE',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GitHubCommitHistoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw GitHub-style commit history lines
    for (int i = 0; i < 6; i++) {
      final x = size.width * 0.15 + (i * size.width * 0.12);
      final y = size.height * 0.1 + (i * size.height * 0.15);

      path.moveTo(x, y);
      path.lineTo(x + 20, y + 20);
      path.lineTo(x + 40, y);
      path.lineTo(x + 60, y + 20);

      // Draw commit dots with GitHub green
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.primary.withValues(alpha: 0.4),
      );
      canvas.drawCircle(
        Offset(x + 40, y),
        4,
        Paint()..color = AppColors.primary.withValues(alpha: 0.4),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
