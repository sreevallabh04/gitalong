import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  /// Creates the settings screen
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSettingsSection(
            context,
            title: 'Account',
            items: [
              SettingsItem(
                icon: Icons.person,
                title: 'Profile Settings',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.security,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            context,
            title: 'Preferences',
            items: [
              SettingsItem(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                trailing: Switch(value: false, onChanged: (value) {}),
              ),
              SettingsItem(
                icon: Icons.language,
                title: 'Language',
                trailing: const Text('English'),
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSettingsSection(
            context,
            title: 'Support',
            items: [
              SettingsItem(
                icon: Icons.help,
                title: 'Help Center',
                onTap: () {},
              ),
              SettingsItem(
                icon: Icons.feedback,
                title: 'Send Feedback',
                onTap: () {},
              ),
              SettingsItem(icon: Icons.info, title: 'About', onTap: () {}),
            ],
          ),
          SizedBox(height: 24.h),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<SettingsItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
          ...items.map((item) {
            final isLast = item == items.last;
            return Column(
              children: [
                ListTile(
                  leading: Icon(item.icon, color: const Color(0xFF6366F1)),
                  title: Text(item.title),
                  trailing: item.trailing ?? const Icon(Icons.chevron_right),
                  onTap: item.onTap,
                ),
                if (!isLast)
                  Divider(height: 1, indent: 72.w, color: Colors.grey[200]),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: TextButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO(settings): Implement logout
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}

/// Settings item for configuration options
class SettingsItem {
  /// Icon for the settings item
  final IconData icon;

  /// Title of the settings item
  final String title;

  /// Trailing widget for the settings item
  final Widget? trailing;

  /// Callback when the settings item is tapped
  final VoidCallback? onTap;

  /// Creates a settings item
  SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });
}
