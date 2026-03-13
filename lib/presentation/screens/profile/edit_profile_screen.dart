import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

/// Edit profile screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _languagesCtrl;
  late final TextEditingController _interestsCtrl;

  late ProfileBloc _profileBloc;
  UserEntity? _originalUser;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _companyCtrl = TextEditingController();
    _websiteCtrl = TextEditingController();
    _languagesCtrl = TextEditingController();
    _interestsCtrl = TextEditingController();

    _profileBloc = getIt<ProfileBloc>()..add(LoadProfileEvent());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _companyCtrl.dispose();
    _websiteCtrl.dispose();
    _languagesCtrl.dispose();
    _interestsCtrl.dispose();
    _profileBloc.close();
    super.dispose();
  }

  void _populateFields(UserEntity user) {
    if (_originalUser != null) return;
    _originalUser = user;
    _nameCtrl.text = user.name ?? '';
    _bioCtrl.text = user.bio ?? '';
    _locationCtrl.text = user.location ?? '';
    _companyCtrl.text = user.company ?? '';
    _websiteCtrl.text = user.websiteUrl ?? '';
    _languagesCtrl.text = user.languages.join(', ');
    _interestsCtrl.text = user.interests.join(', ');
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    if (_originalUser == null) return;

    final languages = _languagesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final interests = _interestsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = _originalUser!.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      location:
          _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      company:
          _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      websiteUrl:
          _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
      languages: languages,
      interests: interests,
    );

    _profileBloc.add(UpdateProfileEvent(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && _originalUser != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated!')),
            );
            context.pop();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
          if (state is ProfileLoaded) {
            _populateFields(state.user);
          }
        },
        builder: (context, state) {
          final isSaving = state is ProfileUpdating;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTextStyles.labelLarge(AppColors.primary),
                        ),
                ),
              ],
            ),
            body: state is ProfileLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Display Name'),
                          _buildField(
                            controller: _nameCtrl,
                            hint: 'Your full name',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Name is required';
                              }
                              if (v.trim().length > 100) {
                                return 'Name must be under 100 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel('Bio'),
                          _buildField(
                            controller: _bioCtrl,
                            hint: 'Tell developers about yourself...',
                            maxLines: 3,
                            validator: (v) {
                              if (v != null && v.length > 500) {
                                return 'Bio must be under 500 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel('Location'),
                          _buildField(
                            controller: _locationCtrl,
                            hint: 'City, Country',
                            validator: (v) {
                              if (v != null && v.length > 100) {
                                return 'Location must be under 100 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel('Company'),
                          _buildField(
                            controller: _companyCtrl,
                            hint: 'Where do you work?',
                            validator: (v) {
                              if (v != null && v.length > 100) {
                                return 'Company must be under 100 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel('Website'),
                          _buildField(
                            controller: _websiteCtrl,
                            hint: 'https://yoursite.com',
                            keyboardType: TextInputType.url,
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                final uri = Uri.tryParse(v.trim());
                                if (uri == null || !uri.hasScheme) {
                                  return 'Enter a valid URL (e.g. https://...)';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel('Languages'),
                          _buildField(
                            controller: _languagesCtrl,
                            hint: 'Dart, Python, TypeScript...',
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Comma-separated list',
                            style: AppTextStyles.bodySmall(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildLabel('Interests'),
                          _buildField(
                            controller: _interestsCtrl,
                            hint: 'Open Source, AI, Mobile...',
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Comma-separated list',
                            style: AppTextStyles.bodySmall(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isSaving ? null : _save,
                              child: isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.titleSmall(
          Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
