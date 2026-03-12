import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart' as app_auth;
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

const List<String> _availableInterests = [
  'Open Source',
  'AI / ML',
  'Web Dev',
  'Mobile Dev',
  'Backend',
  'DevOps',
  'Data Science',
  'Game Dev',
  'Security',
  'Cloud',
  'Blockchain',
  'IoT',
  'UI / UX',
  'Embedded Systems',
  'AR / VR',
];

const List<String> _availableLanguages = [
  'Dart',
  'Python',
  'JavaScript',
  'TypeScript',
  'Rust',
  'Go',
  'Java',
  'Kotlin',
  'Swift',
  'C++',
  'C#',
  'Ruby',
  'PHP',
  'Scala',
  'Elixir',
  'Haskell',
  'Lua',
  'R',
  'Shell',
  'SQL',
];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedLanguages = {};
  late ProfileBloc _profileBloc;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>()..add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  void _prefillLanguages(List<String> detected) {
    if (_selectedLanguages.isEmpty && detected.isNotEmpty) {
      setState(() => _selectedLanguages.addAll(detected));
    }
  }

  bool get _canContinue =>
      _selectedInterests.isNotEmpty && _selectedLanguages.isNotEmpty;

  void _save() {
    if (!_canContinue) return;
    HapticFeedback.mediumImpact();

    final authState = context.read<AuthBloc>().state;
    if (authState is! app_auth.AuthAuthenticated) return;

    setState(() => _saving = true);

    final updated = authState.user.copyWith(
      interests: _selectedInterests.toList(),
      languages: _selectedLanguages.toList(),
    );

    _profileBloc.add(UpdateProfileEvent(updated));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _prefillLanguages(state.user.languages);
            if (_saving) {
              context.read<AuthBloc>().add(AuthCheckRequested());
              context.go(RoutePaths.home);
            }
          }
          if (state is ProfileError) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 32.h),
                        Text(
                          'Set up your profile',
                          style: AppTextStyles.headlineMedium(colors.onSurface),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Help us find the best developer matches for you.',
                          style: AppTextStyles.bodyLarge(
                              colors.onSurfaceVariant),
                        ),

                        SizedBox(height: 32.h),

                        // Interests section
                        Text(
                          'What are you interested in?',
                          style: AppTextStyles.titleMedium(colors.onSurface),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Select at least one',
                          style: AppTextStyles.bodySmall(
                              colors.onSurfaceVariant),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _availableInterests
                              .map((interest) => _SelectableChip(
                                    label: interest,
                                    selected:
                                        _selectedInterests.contains(interest),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        if (_selectedInterests
                                            .contains(interest)) {
                                          _selectedInterests.remove(interest);
                                        } else {
                                          _selectedInterests.add(interest);
                                        }
                                      });
                                    },
                                  ))
                              .toList(),
                        ),

                        SizedBox(height: 32.h),

                        // Languages section
                        Text(
                          'Languages you work with',
                          style: AppTextStyles.titleMedium(colors.onSurface),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Select at least one (pre-filled from your GitHub)',
                          style: AppTextStyles.bodySmall(
                              colors.onSurfaceVariant),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _availableLanguages
                              .map((lang) => _SelectableChip(
                                    label: lang,
                                    selected:
                                        _selectedLanguages.contains(lang),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        if (_selectedLanguages.contains(lang)) {
                                          _selectedLanguages.remove(lang);
                                        } else {
                                          _selectedLanguages.add(lang);
                                        }
                                      });
                                    },
                                  ))
                              .toList(),
                        ),

                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),

                // Bottom bar
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      top: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: FilledButton(
                        onPressed: _canContinue && !_saving ? _save : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: _saving
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: AppTextStyles.titleMedium(Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            selected
                ? AppColors.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
