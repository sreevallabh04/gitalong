import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/auth_service.dart' as auth;
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import '../../core/router/app_router.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/main_navigation_screen.dart';
import 'package:go_router/go_router.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureSignUpPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

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
    _emailController.dispose();
    _passwordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Authentication methods
  Future<void> _signIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        AppLogger.logger.navigation('✅ Sign in successful, navigating to home');
        context.goToHome();
      }
    } on auth.AuthException catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      AppLogger.logger.e('❌ Unexpected sign in error', error: e);
      if (mounted) {
        _showErrorSnackbar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signUp() async {
    if (_signUpFormKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the improved AuthService with proper credential validation
      await ref.read(authServiceProvider).createUserWithEmailAndPassword(
            email:
                _signUpEmailController.text, // Already trimmed in AuthService
            password: _signUpPasswordController
                .text, // Already trimmed in AuthService
          );

      if (mounted) {
        // Navigate to onboarding for profile setup instead of home
        AppLogger.logger.navigation(
            '✅ Sign-up successful, navigating to onboarding for profile setup');
        context.goToOnboarding();
      }
    } on auth.AuthException catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.message);
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during sign-up',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create account. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.logger.auth('🔐 Starting Google Sign-In process...');

      // Use the improved AuthService with comprehensive error handling
      final credential = await ref.read(authServiceProvider).signInWithGoogle();

      if (credential.user != null) {
        AppLogger.logger
            .auth('✅ Google sign-in successful for: ${credential.user!.email}');

        if (mounted) {
          // Navigate using GoRouter - this will trigger the auth redirect
          AppLogger.logger
              .navigation('✅ Google sign-in successful, navigating to home');
          context.goToHome();
        }
      } else {
        throw const auth.AuthException(
          'Google sign-in completed but no user was returned.',
          code: 'no-user-returned',
        );
      }
    } on auth.AuthException catch (e) {
      AppLogger.logger.e('❌ Auth error during Google sign-in', error: e);

      if (mounted) {
        String userFriendlyMessage;

        // Provide more specific error messages based on the error code
        switch (e.code) {
          case 'sign-in-cancelled':
            userFriendlyMessage =
                'Google sign-in was cancelled. Please try again.';
            break;
          case 'network-request-failed':
            userFriendlyMessage =
                'Network error. Please check your connection and try again.';
            break;
          case 'operation-not-allowed':
            userFriendlyMessage =
                'Google sign-in is not enabled. Please contact support.';
            break;
          case 'invalid-credential':
            userFriendlyMessage =
                'Invalid credentials. Please try signing in again.';
            break;
          default:
            userFriendlyMessage = e.message;
        }

        setState(() {
          _errorMessage = userFriendlyMessage;
        });

        // Show snackbar for better visibility
        _showErrorSnackbar(userFriendlyMessage);
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during Google sign-in',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        String errorMessage = 'Google sign-in failed. Please try again.';

        // Handle specific platform errors
        if (e.toString().contains('DEVELOPER_ERROR') ||
            e.toString().contains('Error 10')) {
          errorMessage =
              'Google sign-in configuration error. Please contact support.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        }

        setState(() {
          _errorMessage = errorMessage;
        });

        _showErrorSnackbar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the improved AuthService with comprehensive error handling
      await ref.read(authServiceProvider).signInWithApple();

      if (mounted) {
        // Navigate using GoRouter - this will trigger the auth redirect
        AppLogger.logger
            .navigation('✅ Apple sign-in successful, navigating to home');
        context.goToHome();
      }
    } on auth.AuthException catch (e) {
      AppLogger.logger.e('❌ Auth error during Apple sign-in', error: e);

      if (mounted) {
        setState(() {
          _errorMessage = e.message; // This will now be a user-friendly message
        });
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during Apple sign-in',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _errorMessage = 'Apple sign-in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the improved AuthService for password reset
      await ref.read(authServiceProvider).sendPasswordResetEmail(
            _emailController.text, // Already trimmed in AuthService
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to ${_emailController.text.trim()}',
              style: GoogleFonts.inter(color: const Color(0xFFF0F6FC)),
            ),
            backgroundColor: const Color(0xFF238636), // GitHub green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } on auth.AuthException catch (e) {
      AppLogger.logger.e('❌ Auth error during password reset', error: e);

      if (mounted) {
        setState(() {
          _errorMessage = e.message; // This will now be a user-friendly message
        });
      }
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Unexpected error during password reset',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to send password reset email. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          const Color(0xFF238636).withValues(alpha: 0.1), // GitHub green
          const Color(0xFF161B22).withValues(alpha: 0.8), // GitHub dark gray
          const Color(0xFF0D1117), // GitHub black
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with GitHub-style glow effect
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF238636), // GitHub green
                Color(0xFF2EA043), // GitHub bright green
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF238636).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.code, size: 50, color: Colors.white),
        ).animate().scale(duration: 800.ms).fadeIn(duration: 600.ms),

        const SizedBox(height: 24),

        // App title with GitHub-style gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF238636), // GitHub green
              Color(0xFF3FB950), // GitHub lime green
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

        // Subtitle with GitHub-style muted text
        Text(
          'Connect • Collaborate • Create',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF7D8590), // GitHub muted text
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
                    const Color(
                      0xFF21262D,
                    ).withValues(alpha: 0.2), // GitHub gray
                    const Color(
                      0xFF161B22,
                    ).withValues(alpha: 0.1), // GitHub dark gray
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    const Color(
                      0xFF238636,
                    ).withValues(alpha: 0.3), // GitHub green
                    const Color(
                      0xFF30363D,
                    ).withValues(alpha: 0.2), // GitHub border
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
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          backgroundColor: const Color(0xFF21262D), // GitHub gray
          borderColor: const Color(0xFF30363D), // GitHub border
          textColor: const Color(0xFFF0F6FC), // GitHub white
        ),

        const SizedBox(height: 16),

        // Apple Sign In (iOS/macOS only)
        if (Platform.isIOS || Platform.isMacOS)
          _buildOAuthButton(
            onPressed: _isLoading ? null : _signInWithApple,
            icon: Icons.apple,
            label: 'Continue with Apple',
            backgroundColor: const Color(0xFF21262D), // GitHub gray
            borderColor: const Color(0xFF30363D), // GitHub border
            textColor: const Color(0xFFF0F6FC), // GitHub white
          ),
      ],
    );
  }

  Widget _buildOAuthButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: textColor),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered)) {
              return const Color(0xFF30363D); // GitHub light gray
            }
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFF238636); // GitHub green
            }
            return backgroundColor;
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(MaterialState.hovered)) {
              return const BorderSide(
                color: Color(0xFF238636),
                width: 1,
              ); // GitHub green
            }
            return BorderSide(color: borderColor, width: 1);
          }),
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
            color: const Color(0xFF30363D), // GitHub border
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF7D8590), // GitHub muted text
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF30363D), // GitHub border
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
      constraints: const BoxConstraints(minHeight: 300, maxHeight: 400),
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
            controller: _emailController,
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
          const SizedBox(height: 16),

          _buildTextField(
            controller: _passwordController,
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
              onPressed: _forgotPassword,
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

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
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _signUpEmailController,
            label: 'Email',
            icon: Icon(PhosphorIcons.envelope(PhosphorIconsStyle.bold)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _signUpPasswordController,
            label: 'Password',
            icon: Icon(PhosphorIcons.lock(PhosphorIconsStyle.bold)),
            obscureText: _obscureSignUpPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpPassword
                    ? PhosphorIcons.eye(PhosphorIconsStyle.bold)
                    : PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold),
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => setState(
                () => _obscureSignUpPassword = !_obscureSignUpPassword,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain letters and numbers';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

          // Sign up button
          _buildActionButton(
            onPressed: _isLoading ? null : _signUp,
            label: 'Create Account & Set Up Profile',
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
