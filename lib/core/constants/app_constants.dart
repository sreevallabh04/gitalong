import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'GitAlong';
  static const String appDescription = 'Find your perfect open source match';
  static const String appTagline = 'Connect • Collaborate • Create';
  static const String appVersion = '1.0.0';

  // URLs
  static const String privacyPolicyUrl = 'https://gitalong.dev/privacy';
  static const String termsOfServiceUrl = 'https://gitalong.dev/terms';
  static const String supportUrl = 'https://gitalong.dev/support';
  static const String githubUrl = 'https://github.com/gitalong/app';

  // API Configuration
  static const int apiTimeoutDuration = 30; // seconds
  static const int retryAttempts = 3;
  static const int cacheValidityDuration = 24; // hours

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double defaultBorderRadius = 16.0;
  static const double largeBorderRadius = 24.0;
  static const double smallBorderRadius = 8.0;

  // Animation Durations
  static const int shortAnimationDuration = 200; // ms
  static const int normalAnimationDuration = 300; // ms
  static const int longAnimationDuration = 500; // ms
  static const int splashDuration = 3000; // ms

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Constraints
  static const int maxImageSizeMB = 5;
  static const int maxVideoSizeMB = 50;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];

  // User Constraints
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxBioLength = 500;
  static const int maxNameLength = 100;
  static const int maxSkillsCount = 10;

  // Swipe Configuration
  static const double swipeThreshold = 0.3;
  static const int maxSwipesPerDay = 100;
  static const int undoTimeLimit = 5; // seconds

  // Messaging
  static const int maxMessageLength = 1000;
  static const int maxMessagesPerMinute = 10;

  // Cache Keys
  static const String userProfileCacheKey = 'user_profile';
  static const String matchesCacheKey = 'matches';
  static const String messagesCacheKey = 'messages';
  static const String settingsCacheKey = 'settings';

  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themePreferenceKey = 'theme_preference';
  static const String languagePreferenceKey = 'language_preference';
  static const String notificationPreferenceKey = 'notification_preference';

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Please check your internet connection.';
  static const String authErrorMessage =
      'Authentication failed. Please sign in again.';
  static const String permissionErrorMessage =
      'Permission required to continue.';

  // Success Messages
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String accountCreatedMessage = 'Account created successfully!';
  static const String passwordResetMessage = 'Password reset email sent!';
  static const String settingsSavedMessage = 'Settings saved successfully!';
}

class AppColors {
  // Primary Palette
  static const primaryNeon = Color(0xFF00F5FF); // Cyan neon
  static const secondaryNeon = Color(0xFF9D4EDD); // Purple neon
  static const accentNeon = Color(0xFF00FF41); // Green neon
  static const warningNeon = Color(0xFFFFAB00); // Orange neon
  static const errorNeon = Color(0xFFFF453A); // Red neon

  // Base Colors
  static const darkBase = Color(0xFF0A0A0F); // Almost black
  static const surfaceDark = Color(0xFF1A1A2E); // Dark blue surface
  static const surfaceGlass = Color(0xFF16213E); // Glass surface
  static const surfaceLight = Color(0xFF2A2A3E); // Light surface

  // Text Colors
  static const textPrimary = Color(0xFFE8EAED); // Light text
  static const textSecondary = Color(0xFFB3B3B3); // Muted text
  static const textTertiary = Color(0xFF808080); // Disabled text

  // Semantic Colors
  static const success = Color(0xFF00FF41);
  static const warning = Color(0xFFFFAB00);
  static const error = Color(0xFFFF453A);
  static const info = Color(0xFF00F5FF);

  // Gradient Colors
  static const gradientPrimary = LinearGradient(
    colors: [primaryNeon, secondaryNeon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSecondary = LinearGradient(
    colors: [secondaryNeon, accentNeon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBackground = RadialGradient(
    center: Alignment.topRight,
    radius: 1.5,
    colors: [
      Color.fromRGBO(0, 245, 255, 0.15),
      Color.fromRGBO(157, 78, 221, 0.1),
      darkBase,
    ],
  );
}

class AppSizes {
  // Screen Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1200;
  static const double desktopMaxWidth = 1920;

  // Component Sizes
  static const double buttonHeight = 56;
  static const double inputHeight = 56;
  static const double appBarHeight = 64;
  static const double bottomNavHeight = 80;
  static const double cardMinHeight = 120;
  static const double avatarSize = 40;
  static const double largeAvatarSize = 100;

  // Icon Sizes
  static const double smallIcon = 16;
  static const double mediumIcon = 24;
  static const double largeIcon = 32;
  static const double extraLargeIcon = 48;

  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRegex {
  static final email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final password = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$',
  );
  static final githubUrl = RegExp(r'^https://github\.com/[a-zA-Z0-9._-]+/?$');
  static final url = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
  static final phoneNumber = RegExp(r'^\+?[1-9]\d{1,14}$');
}
