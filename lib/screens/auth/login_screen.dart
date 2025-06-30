import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/main_navigation_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _cardController;

  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController =
      TextEditingController();
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cardController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Authentication methods
  Future<void> _signIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signIn(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text,
      );

      if (response.user != null && mounted) {
        final hasProfile = await ref.read(hasUserProfileProvider.future);
        if (hasProfile) {
          _navigateToHome();
        } else {
          _navigateToOnboarding();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signUp(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
        name: _signUpNameController.text.trim(),
      );

      if (response.user != null && mounted) {
        _showSuccessSnackBar(
          'Account created! Please check your email to verify.',
        );
        _tabController.animateTo(0);
        _clearSignUpForm();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithGoogle();

      if (response.user != null && mounted) {
        final hasProfile = await ref.read(hasUserProfileProvider.future);
        if (hasProfile) {
          _navigateToHome();
        } else {
          _navigateToOnboarding();
        }
      }
    } catch (e) {
      if (mounted) {
        // Production-ready error handling for Google Sign-In
        String errorMessage;

        if (e.toString().contains('ApiException: 10') ||
            e.toString().contains('DEVELOPER_ERROR')) {
          errorMessage = '🔧 App Configuration Required\n\n'
              'To enable Google Sign-In, the Firebase project needs to be properly configured.\n\n'
              '📋 Required Steps:\n'
              '• Add SHA-1 fingerprint to Firebase console\n'
              '• Download real google-services.json\n'
              '• Update Firebase configuration\n\n'
              'See FIREBASE_SETUP_GUIDE.md for detailed instructions.\n\n'
              'For now, you can use Email/Password sign-in below.';
        } else if (e.toString().contains('ApiException: 12500')) {
          errorMessage = '🔐 Google Play Services Required\n\n'
              'Please sign in to Google Play Services on this device and try again.';
        } else if (e.toString().contains('ApiException: 7')) {
          errorMessage = '🌐 Network Error\n\n'
              'Please check your internet connection and try again.';
        } else if (e.toString().contains('sign in was cancelled')) {
          // Don't show error for user cancellation
          return;
        } else {
          errorMessage = '❌ Google Sign-In Failed\n\n'
              'Please try email/password sign-in below or check your network connection.\n\n'
              'Error: ${e.toString().replaceAll('AuthException: ', '')}';
        }

        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      _showErrorSnackBar('Apple Sign In is only available on iOS and macOS');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithApple();

      if (response.user != null && mounted) {
        final hasProfile = await ref.read(hasUserProfileProvider.future);
        if (hasProfile) {
          _navigateToHome();
        } else {
          _navigateToOnboarding();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_signInEmailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email address first.');
      return;
    }

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(_signInEmailController.text.trim());
      _showSuccessSnackBar('Password reset email sent!');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _clearSignUpForm() {
    _signUpNameController.clear();
    _signUpEmailController.clear();
    _signUpPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    // For multi-line messages, show dialog instead of snackbar
    if (message.contains('\n\n')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Authentication Error',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            message.replaceAll('AuthException: ', ''),
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Simple messages show as snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.replaceAll('AuthException: ', ''),
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildAuthCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          Theme.of(context).scaffoldBackgroundColor,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with glow effect
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.code, size: 50, color: Colors.white),
        ).animate().scale(duration: 800.ms).fadeIn(duration: 600.ms),

        const SizedBox(height: 24),

        // App title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: Text(
            'GitAlong',
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 800.ms).slideY(begin: 0.3),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Connect • Collaborate • Create',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ).animate(delay: 600.ms).fadeIn(duration: 800.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildAuthCard() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardController.value,
          child: Opacity(
            opacity: _cardController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: BoxConstraints(
                minHeight: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 24,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24), // Reduced padding
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildOAuthButtons(),
                        const SizedBox(height: 24), // Reduced spacing
                        _buildDivider(),
                        const SizedBox(height: 24), // Reduced spacing
                        _buildTabBar(),
                        const SizedBox(height: 20), // Reduced spacing
                        _buildTabViews(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOAuthButtons() {
    return Column(
      children: [
        // Google Sign In
        _buildOAuthButton(
          onPressed: _isLoading ? null : _signInWithGoogle,
          icon: Icon(PhosphorIcons.googleLogo(PhosphorIconsStyle.bold)),
          label: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
        ),

        const SizedBox(height: 16),

        // Apple Sign In (iOS/macOS only)
        if (Platform.isIOS || Platform.isMacOS)
          _buildOAuthButton(
            onPressed: _isLoading ? null : _signInWithApple,
            icon: Icon(PhosphorIcons.appleLogo(PhosphorIconsStyle.bold)),
            label: 'Continue with Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
      ],
    );
  }

  Widget _buildOAuthButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
      ),
    );
  }

  Widget _buildTabViews() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 300,
        maxHeight: 400,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildSignInForm(),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildSignUpForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _signInEmailController,
            label: 'Email',
            icon: Icon(PhosphorIcons.envelope(PhosphorIconsStyle.bold)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _signInPasswordController,
            label: 'Password',
            icon: Icon(PhosphorIcons.lock(PhosphorIconsStyle.bold)),
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? PhosphorIcons.eye(PhosphorIconsStyle.bold)
                    : PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold),
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign in button
          _buildActionButton(
            onPressed: _isLoading ? null : _signIn,
            label: 'Sign In',
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _signUpNameController,
            label: 'Full Name',
            icon: Icon(PhosphorIcons.user(PhosphorIconsStyle.bold)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _signUpEmailController,
            label: 'Email',
            icon: Icon(PhosphorIcons.envelope(PhosphorIconsStyle.bold)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _signUpPasswordController,
            label: 'Password',
            icon: Icon(PhosphorIcons.lock(PhosphorIconsStyle.bold)),
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? PhosphorIcons.eye(PhosphorIconsStyle.bold)
                    : PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold),
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            icon: Icon(PhosphorIcons.lockOpen(PhosphorIconsStyle.bold)),
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? PhosphorIcons.eye(PhosphorIconsStyle.bold)
                    : PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold),
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _signUpPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Sign up button
          _buildActionButton(
            onPressed: _isLoading ? null : _signUp,
            label: 'Create Account',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(padding: const EdgeInsets.all(16), child: icon),
        suffixIcon: suffixIcon,
        labelStyle: GoogleFonts.inter(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
