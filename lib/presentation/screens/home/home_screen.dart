import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/notifications_listener.dart';
import '../../../core/utils/feedback_service.dart';
import '../swipe/swipe_screen.dart';
import '../matches/matches_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    SwipeScreen(),
    MatchesScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final scaffold = Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          FeedbackService.onTabChange();
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.cards, size: 24.sp),
            selectedIcon: Icon(PhosphorIconsFill.cards, size: 24.sp),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.heart, size: 24.sp),
            selectedIcon: Icon(PhosphorIconsFill.heart, size: 24.sp),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.chatCircle, size: 24.sp),
            selectedIcon: Icon(PhosphorIconsFill.chatCircle, size: 24.sp),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.user, size: 24.sp),
            selectedIcon: Icon(PhosphorIconsFill.user, size: 24.sp),
            label: 'Profile',
          ),
        ],
      ),
    );
    if (userId != null) {
      return NotificationsListener(userId: userId, child: scaffold);
    }
    return scaffold;
  }
}

