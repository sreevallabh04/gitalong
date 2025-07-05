import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/firestore_utils.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/responsive_buttons.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _basicInfoFormKey = GlobalKey<FormState>();

  // Form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();

  UserRole _selectedRole = UserRole.contributor;
  final List<String> _selectedSkills = [];
  int _currentPage = 0;
  bool _isLoading = false;

  // Common programming languages/skills
  final List<String> _availableSkills = [
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'Dart',
    'Flutter',
    'React',
    'Vue.js',
    'Angular',
    'Node.js',
    'Express',
    'Django',
    'Flask',
    'Spring',
    'C++',
    'C#',
    'Go',
    'Rust',
    'Swift',
    'Kotlin',
    'PHP',
    'Laravel',
    'Ruby',
    'Rails',
    'Scala',
    'HTML',
    'CSS',
    'SASS',
    'Docker',
    'Kubernetes',
    'AWS',
    'Azure',
    'GCP',
    'MongoDB',
    'PostgreSQL',
    'MySQL',
    'Redis',
    'GraphQL',
    'REST API',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1) {
      // Validate basic info page before proceeding
      if (_basicInfoFormKey.currentState?.validate() == false) {
        AppLogger.logger.w('⚠️ Basic info validation failed');
        return;
      }
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateAllData() {
    // Validate required fields
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      _showError('Please enter your name.');
      return false;
    }

    if (trimmedName.length > 100) {
      _showError('Name is too long. Please use a shorter name.');
      return false;
    }

    // Validate GitHub URL if provided
    final githubUrl = _githubController.text.trim();
    if (githubUrl.isNotEmpty && !githubUrl.startsWith('https://github.com/')) {
      _showError(
          'Please enter a valid GitHub URL starting with https://github.com/');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFDA3633),
        ),
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Validate all form data
    if (!_validateAllData()) {
      return;
    }

    // Check if widget is still mounted before proceeding
    if (!mounted) {
      AppLogger.logger.w('⚠️ Widget unmounted, canceling profile creation');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final trimmedName = _nameController.text.trim();
      final githubUrl = _githubController.text.trim();

      // Use the userProfileProvider from auth_provider.dart
      final userProfileNotifier = ref.read(userProfileProvider.notifier);

      await safeQuery(() async {
        await userProfileNotifier.createProfile(
          name: trimmedName,
          bio: _bioController.text.trim(),
          role: _selectedRole.toString().split('.').last,
          skills: List<String>.from(_selectedSkills),
          githubUrl: githubUrl.isEmpty ? null : githubUrl,
        );
      }, onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create profile: $e'),
              backgroundColor: const Color(0xFFDA3633),
            ),
          );
        }
      });

      // After profile creation, check isMaintainer from the updated profile state
      final createdProfile = ref.read(userProfileProvider).value;

      if (createdProfile != null &&
          createdProfile.role == UserRole.maintainer) {
        if (mounted) {
          context.go('/maintainer'); // Use GoRouter for navigation
        }
      } else {
        if (mounted) {
          AppLogger.logger
              .navigation('✅ Onboarding completed, navigating to home');

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome to GitAlong! Your profile has been created successfully.',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF238636),
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to home using direct router replacement
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                // Use go instead of goToHome for more direct navigation
                context.go(AppRoutes.home);
              } catch (e) {
                AppLogger.logger.e('❌ Navigation error', error: e);
                // Fallback: Use pushReplacementNamed
                Navigator.of(context).pushReplacementNamed('/home');
              }
            }
          });
        }
      }
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Error completing onboarding', error: e, stackTrace: stackTrace);

      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDA3633),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _completeOnboarding(),
            ),
          ),
        );
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
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Setup Your Profile',
          style: TextStyle(
            color: Color(0xFFF0F6FC),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF21262D),
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFFF0F6FC),
                ),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFF30363D),
            ),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.transparent,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF238636)),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildRoleSelectionPage(),
                _buildBasicInfoPage(),
                _buildSkillsPage(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF21262D),
              border: Border(
                top: BorderSide(color: Color(0xFF30363D), width: 1),
              ),
            ),
            child: ResponsiveButtonGroup(
              children: [
                if (_currentPage > 0)
                  ResponsiveOutlinedButton(
                      onPressed: _isLoading ? null : _previousPage,
                    child: const Text('Back'),
                      ),
                ResponsiveElevatedButton(
                    onPressed: _isLoading ? null : _nextPage,
                  isLoading: _isLoading,
                  child: Text(
                            _currentPage == 2 ? 'Complete Profile' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'What\'s your role?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF0F6FC),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to participate in open source',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF7D8590),
                ),
          ),
          const SizedBox(height: 48),
          _buildRoleCard(
            role: UserRole.contributor,
            title: 'Contributor',
            description: 'I want to contribute to open source projects',
            icon: Icons.code_rounded,
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.maintainer,
            title: 'Maintainer',
            description: 'I have projects that need contributors',
            icon: Icons.people_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF238636) : const Color(0xFF30363D),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedRole = role),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF238636)
                      : const Color(0xFF30363D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF0F6FC),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7D8590),
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF238636),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0F6FC),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help others get to know you better',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF7D8590),
                  ),
            ),
            const SizedBox(height: 48),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFFF0F6FC)),
              decoration: InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter your full name',
                labelStyle: const TextStyle(color: Color(0xFF7D8590)),
                hintStyle: const TextStyle(color: Color(0xFF484F58)),
                filled: true,
                fillColor: const Color(0xFF0D1117),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF238636)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDA3633)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length > 100) {
                  return 'Name is too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _bioController,
              style: const TextStyle(color: Color(0xFFF0F6FC)),
              decoration: InputDecoration(
                labelText: 'Bio (Optional)',
                hintText: 'Tell us about yourself...',
                labelStyle: const TextStyle(color: Color(0xFF7D8590)),
                hintStyle: const TextStyle(color: Color(0xFF484F58)),
                filled: true,
                fillColor: const Color(0xFF0D1117),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF238636)),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _githubController,
              style: const TextStyle(color: Color(0xFFF0F6FC)),
              decoration: InputDecoration(
                labelText: 'GitHub URL (Optional)',
                hintText: 'https://github.com/username',
                labelStyle: const TextStyle(color: Color(0xFF7D8590)),
                hintStyle: const TextStyle(color: Color(0xFF484F58)),
                prefixIcon:
                    const Icon(Icons.link_rounded, color: Color(0xFF7D8590)),
                filled: true,
                fillColor: const Color(0xFF0D1117),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF30363D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF238636)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDA3633)),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.startsWith('https://github.com/')) {
                    return 'Please enter a valid GitHub URL';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'What are your skills?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF0F6FC),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select up to 5 programming languages or technologies',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF7D8590),
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Text(
              'Selected: ${_selectedSkills.length}/5',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF238636),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(
                      skill,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF7D8590),
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected && _selectedSkills.length < 5) {
                          _selectedSkills.add(skill);
                        } else if (!selected) {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                    backgroundColor: const Color(0xFF21262D),
                    selectedColor: const Color(0xFF238636),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF238636)
                          : const Color(0xFF30363D),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
