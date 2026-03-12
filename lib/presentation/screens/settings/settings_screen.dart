import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(PhosphorIconsRegular.user, size: 24.sp),
            title: const Text('Edit Profile'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () => context.push(RoutePaths.editProfile),
          ),

          const Divider(),

          // Preferences
          _SectionHeader(title: 'Preferences'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return SwitchListTile(
                secondary: Icon(PhosphorIconsRegular.moon, size: 24.sp),
                title: const Text('Dark Mode'),
                value: mode == ThemeMode.dark ||
                    (mode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark),
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
              );
            },
          ),

          const Divider(),

          // About
          _SectionHeader(title: 'About'),
          ListTile(
            leading: Icon(PhosphorIconsRegular.info, size: 24.sp),
            title: const Text('About GitAlong'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('GitAlong'),
                  content: const Text(
                      'Find your perfect open-source companion.\nVersion 1.0.0'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(PhosphorIconsRegular.fileText, size: 24.sp),
            title: const Text('Terms of Service'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () => context.push(RoutePaths.termsOfService),
          ),
          ListTile(
            leading: Icon(PhosphorIconsRegular.lock, size: 24.sp),
            title: const Text('Privacy Policy'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () => context.push(RoutePaths.privacyPolicy),
          ),

          const Divider(),

          // Danger zone
          ListTile(
            leading: Icon(
              PhosphorIconsRegular.signOut,
              size: 24.sp,
              color: Colors.red,
            ),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmSignOut(context),
          ),
          ListTile(
            leading: Icon(
              PhosphorIconsRegular.trash,
              size: 24.sp,
              color: Colors.red[900],
            ),
            title: Text('Delete Account',
                style: TextStyle(color: Colors.red[900])),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.read<AuthBloc>().add(SignOutEvent());
            },
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Account',
            style: TextStyle(color: Colors.red)),
        content: const Text(
            'Are you sure you want to permanently delete your account? '
            'This action cannot be undone and will delete all your data, '
            'matches, and messages.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.read<AuthBloc>().add(DeleteAccountEvent());
            },
            child: const Text('Delete Account',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        title,
        style: AppTextStyles.labelLarge(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
