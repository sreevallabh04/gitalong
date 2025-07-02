import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../home/main_navigation_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      AppLogger.logger.w('⚠️ Form validation failed');
      return;
    }

    // Validate required fields before proceeding
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      AppLogger.logger.w('⚠️ Name is required');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter your name.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDA3633),
          ),
        );
      }
      return;
    }

    // Additional validation for name length
    if (trimmedName.length > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Name is too long. Please use a shorter name.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDA3633),
          ),
        );
      }
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
      AppLogger.logger.auth('🚀 Starting profile creation...');
      AppLogger.logger.auth('📋 Name: $trimmedName');
      AppLogger.logger.auth('📝 Bio: ${_bioController.text.trim()}');
      AppLogger.logger.auth('🏷️ Role: ${_selectedRole.name}');
      AppLogger.logger.auth('💼 Skills: ${_selectedSkills.join(', ')}');
      AppLogger.logger.auth('🔗 GitHub: ${_githubController.text.trim()}');

      // Validate GitHub URL if provided
      final githubUrl = _githubController.text.trim();
      if (githubUrl.isNotEmpty &&
          !githubUrl.startsWith('https://github.com/')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enter a valid GitHub URL starting with https://github.com/',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFDA3633),
            ),
          );
        }
        return;
      }

      // Create user profile with all collected data
      await ref.read(userProfileProvider.notifier).createProfile(
            name: trimmedName,
            bio: _bioController.text.trim(),
            role: _selectedRole.name,
            skills:
                List<String>.from(_selectedSkills), // Create a defensive copy
            githubUrl: githubUrl.isEmpty ? null : githubUrl,
          );

      // Check if widget is still mounted before navigation
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
            backgroundColor: const Color(0xFF238636), // GitHub green
            duration: const Duration(seconds: 3),
          ),
        );

        // Use addPostFrameCallback to ensure navigation happens after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.goToHome();
          }
        });
      }
    } catch (e, stackTrace) {
      AppLogger.logger
          .e('❌ Error completing onboarding', error: e, stackTrace: stackTrace);

      // Only show error if widget is still mounted
      if (mounted) {
        // Extract clean error message
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }

        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFDA3633), // GitHub red
            duration: const Duration(
                seconds: 5), // Longer duration for error messages
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry the onboarding completion
                _completeOnboarding();
              },
            ),
          ),
        );
      }
    } finally {
      // Only update state if widget is still mounted
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
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextPage,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_currentPage == 2 ? 'Complete' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to participate in open source',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 48),
          _buildRoleCard(
            role: UserRole.contributor,
            title: 'Contributor',
            description: 'I want to contribute to open source projects',
            icon: Icons.code,
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.maintainer,
            title: 'Maintainer',
            description: 'I have projects that need contributors',
            icon: Icons.people,
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

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
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
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'Tell us about yourself',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Help others get to know you better',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 48),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your full name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio (Optional)',
              hintText: 'Tell us about yourself...',
            ),
            maxLines: 3,
            maxLength: 200,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _githubController,
            decoration: const InputDecoration(
              labelText: 'GitHub URL (Optional)',
              hintText: 'https://github.com/username',
              prefixIcon: Icon(Icons.link),
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select up to 5 programming languages or technologies',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Selected: ${_selectedSkills.length}/5',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
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
                    label: Text(skill),
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
