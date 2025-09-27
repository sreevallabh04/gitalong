import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// User profile screen
class ProfileScreen extends StatelessWidget {
  /// Creates the profile screen
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO(profile): Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context),
            SizedBox(height: 24.h),

            // Stats
            _buildStats(context),
            SizedBox(height: 24.h),

            // Menu Items
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50.r,
            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 50.sp,
              color: const Color(0xFF6366F1),
            ),
          ),
          SizedBox(height: 16.h),

          // Name and Username
          Text(
            'John Doe',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            '@johndoe',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),

          // Bio
          Text(
            'Full-stack developer passionate about building amazing user experiences.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(context, 'Projects', '24')),
          Container(width: 1, height: 40.h, color: Colors.grey[300]),
          Expanded(child: _buildStatItem(context, 'Matches', '156')),
          Container(width: 1, height: 40.h, color: Colors.grey[300]),
          Expanded(child: _buildStatItem(context, 'Stars', '1.2k')),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6366F1),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      MenuItem(
        icon: Icons.edit,
        title: 'Edit Profile',
        subtitle: 'Update your information',
        onTap: () {},
      ),
      MenuItem(
        icon: Icons.favorite,
        title: 'Liked Projects',
        subtitle: 'View your liked projects',
        onTap: () {},
      ),
      MenuItem(
        icon: Icons.people,
        title: 'Connections',
        subtitle: 'Manage your connections',
        onTap: () {},
      ),
      MenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage notification settings',
        onTap: () {},
      ),
      MenuItem(
        icon: Icons.help,
        title: 'Help & Support',
        subtitle: 'Get help and support',
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children:
            menuItems.map((item) {
              final isLast = item == menuItems.last;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFF6366F1),
                        size: 24.sp,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(height: 1, indent: 72.w, color: Colors.grey[200]),
                ],
              );
            }).toList(),
      ),
    );
  }
}

/// Menu item for profile settings
class MenuItem {
  /// Icon for the menu item
  final IconData icon;

  /// Title of the menu item
  final String title;

  /// Subtitle of the menu item
  final String subtitle;

  /// Callback when the menu item is tapped
  final VoidCallback onTap;

  /// Creates a menu item
  MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
