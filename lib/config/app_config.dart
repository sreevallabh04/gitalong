import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../core/utils/logger.dart';

/// Application configuration for different environments
class AppConfig {
  static late String _environment;
  static late String _version;
  static late String _buildNumber;
  static late String _platformVersion;
  static late String _deviceModel;
  static late String _deviceId;

  // App configuration
  static String get environment => _environment;
  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get platformVersion => _platformVersion;
  static String get deviceModel => _deviceModel;
  static String get deviceId => _deviceId;

  // Environment checks
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  static bool get isStaging => _environment == 'staging';

  // API endpoints based on environment
  static String get baseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.gitalong.app';
      case 'staging':
        return 'https://staging-api.gitalong.app';
      default:
        return 'https://dev-api.gitalong.app';
    }
  }

  static Future<void> initialize() async {
    try {
      AppLogger.logger.i('🔧 Initializing App Configuration...');

      // Set environment based on build mode
      if (kDebugMode) {
        _environment = 'development';
      } else if (kProfileMode) {
        _environment = 'staging';
      } else {
        _environment = 'production';
      }

      // App version info (you might want to get this from package_info_plus)
      _version = '1.0.0';
      _buildNumber = '1';

      // Get device information
      await _getDeviceInfo();

      AppLogger.logger.i('✅ App Configuration initialized successfully');
      AppLogger.logger.d('📋 Configuration Details:');
      AppLogger.logger.d('   🌍 Environment: $_environment');
      AppLogger.logger.d('   📱 Version: $_version ($_buildNumber)');
      AppLogger.logger.d('   🔧 Platform: $_platformVersion');
      AppLogger.logger.d('   📟 Device: $_deviceModel');
      AppLogger.logger.d('   🆔 Device ID: ${_deviceId.substring(0, 8)}...');
      AppLogger.logger.d('   🌐 API Base URL: $baseUrl');
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        '❌ Failed to initialize app config',
        error: e,
        stackTrace: stackTrace,
      );

      // Set fallback values
      _environment = 'development';
      _version = '1.0.0';
      _buildNumber = '1';
      _platformVersion = 'Unknown';
      _deviceModel = 'Unknown';
      _deviceId = 'unknown-device';
    }
  }

  static Future<void> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        _platformVersion = 'Android ${androidInfo.version.release}';
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        _deviceId = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _platformVersion = 'iOS ${iosInfo.systemVersion}';
        _deviceModel = iosInfo.model;
        _deviceId = iosInfo.identifierForVendor ?? 'unknown-ios-device';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        _platformVersion = 'Windows ${windowsInfo.displayVersion}';
        _deviceModel = windowsInfo.computerName;
        _deviceId = windowsInfo.deviceId;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macosInfo = await deviceInfo.macOsInfo;
        _platformVersion = 'macOS ${macosInfo.osRelease}';
        _deviceModel = macosInfo.model;
        _deviceId = macosInfo.systemGUID ?? 'unknown-macos-device';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        _platformVersion = '${linuxInfo.name} ${linuxInfo.version}';
        _deviceModel = linuxInfo.prettyName;
        _deviceId = linuxInfo.machineId ?? 'unknown-linux-device';
      } else {
        // Web or unknown platform
        _platformVersion = 'Web/Unknown';
        _deviceModel = 'Web Browser';
        _deviceId = 'web-device';
      }
    } catch (e) {
      AppLogger.logger.w('⚠️ Failed to get device info: $e');
      // Set fallback values
      _platformVersion = 'Unknown Platform';
      _deviceModel = 'Unknown Device';
      _deviceId = 'unknown-device-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Configuration constants
  static const int requestTimeoutSeconds = 30;
  static const bool enableAnalytics = true;

  // Feature flags
  static bool get enableGoogleSignIn => true;
  static bool get enableAppleSignIn =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  static bool get enableBiometricAuth => !kIsWeb;

  // Environment detection
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;

  // App Information
  static const String appName = 'GitAlong';
  static const String appVersion = '1.0.0';

  // API Configuration
  static String get mlBackendUrl {
    if (isDebug) {
      return 'http://localhost:8000'; // Local development
    } else if (isProfile) {
      return 'https://api-staging.gitalong.dev'; // Staging environment
    } else {
      return 'https://api.gitalong.dev'; // Production environment
    }
  }

  static String get githubApiUrl => 'https://api.github.com';

  // Firebase Configuration
  static String get firestoreUrl => 'https://firestore.googleapis.com';

  // Feature Flags
  static bool get enableMLMatching => true;
  static bool get enableAdvancedAnalytics => true;
  static bool get enableCrashReporting => !isDebug;
  static bool get enableDetailedLogging => isDebug;

  // ML Configuration
  static int get maxRecommendations => 20;
  static int get minRecommendationsThreshold => 3;
  static Duration get mlCacheTimeout => const Duration(minutes: 15);

  // Network Configuration
  static Duration get networkTimeout => const Duration(seconds: 30);
  static Duration get connectionTimeout => const Duration(seconds: 10);
  static int get maxRetryAttempts => 3;

  // Cache Configuration
  static int get maxCacheSize => 100; // MB
  static Duration get cacheTimeout => const Duration(hours: 24);

  // UI Configuration
  static double get cardSwipeThreshold => 0.3;
  static Duration get animationDuration => const Duration(milliseconds: 300);
  static int get maxSkillsSelection => 10;

  // Security Configuration
  static Duration get sessionTimeout => const Duration(hours: 24);
  static int get maxLoginAttempts => 5;

  // Analytics Configuration
  static bool get enableUserAnalytics => !isDebug;
  static bool get enablePerformanceMonitoring => true;
  static Duration get analyticsFlushInterval => const Duration(minutes: 5);

  // Development Configuration
  static bool get enableDevicePreview => isDebug;
  static bool get enableInspector => isDebug;
  static bool get enableDebugBanner => isDebug;
}
