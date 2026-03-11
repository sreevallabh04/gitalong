import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(PhosphorIconsRegular.user, size: 24.sp),
            title: const Text('Edit Profile'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () {
               _showComingSoon(context, 'Edit Profile');
            },
          ),
          ListTile(
            leading: Icon(PhosphorIconsRegular.bell, size: 24.sp),
            title: const Text('Notifications'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () {
               _showComingSoon(context, 'Notifications Settings');
            },
          ),
          
          const Divider(),
          
          // Preferences Section
          _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            secondary: Icon(PhosphorIconsRegular.moon, size: 24.sp),
            title: const Text('Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
                // Feature mock 
                _showComingSoon(context, 'Dark Mode Toggle');
            },
          ),
          
          const Divider(),
          
          // About Section
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
                   content: const Text('Find your perfect open-source companion.\nVersion 1.0.0'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))
                   ]
                 )
               );
            },
          ),
          ListTile(
            leading: Icon(PhosphorIconsRegular.fileText, size: 24.sp),
            title: const Text('Terms of Service'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () {
               _showComingSoon(context, 'Terms of Service');
            },
          ),
          ListTile(
            leading: Icon(PhosphorIconsRegular.lock, size: 24.sp),
            title: const Text('Privacy Policy'),
            trailing: Icon(PhosphorIconsRegular.caretRight, size: 20.sp),
            onTap: () {
               _showComingSoon(context, 'Privacy Policy');
            },
          ),
          
          const Divider(),
          
          // Sign Out
          ListTile(
            leading: Icon(
              PhosphorIconsRegular.signOut,
              size: 24.sp,
              color: Colors.red,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Actual Sign Out implementation 
              showDialog(
                context: context,
                builder: (BuildContext c) {
                  return AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(c).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(c).pop();
                          context.read<AuthBloc>().add(SignOutEvent());
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Section header widget
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



