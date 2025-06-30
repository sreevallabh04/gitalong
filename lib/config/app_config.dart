import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

enum Environment { development, staging, production }

class AppConfig {
  static late Environment environment;
  static late DeviceInfoPlugin deviceInfo;
  static late SharedPreferences preferences;

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.gitalong.dev';
      case Environment.staging:
        return 'https://staging-api.gitalong.dev';
      case Environment.production:
        return 'https://api.gitalong.dev';
    }
  }

  // WebSocket Configuration
  static String get wsBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'wss://dev-ws.gitalong.dev';
      case Environment.staging:
        return 'wss://staging-ws.gitalong.dev';
      case Environment.production:
        return 'wss://ws.gitalong.dev';
    }
  }

  // Feature Flags
  static bool get enableAnalytics =>
      !kDebugMode && environment == Environment.production;
  static bool get enableCrashlytics => !kDebugMode;
  static bool get enablePerformanceMonitoring => !kDebugMode;
  static bool get enableDebugLogging =>
      kDebugMode || environment == Environment.development;
  static bool get enableDevicePreview =>
      kDebugMode && environment == Environment.development;

  // App Information
  static String get appName => environment.name;
  static String get packageName => 'com.example.app';
  static String get version => '1.0.0+1';
  static String get buildNumber => '1';
  static String get appVersion => '$version+$buildNumber';

  // Cache Configuration
  static Duration get cacheTimeout =>
      const Duration(hours: AppConstants.cacheValidityDuration);
  static int get maxCacheSize => 100 * 1024 * 1024; // 100 MB

  // Network Configuration
  static Duration get apiTimeout =>
      const Duration(seconds: AppConstants.apiTimeoutDuration);
  static int get maxRetryAttempts => AppConstants.retryAttempts;

  // Security Configuration
  static bool get useSecureStorage => true;
  static bool get enableBiometrics => true;
  static Duration get sessionTimeout => const Duration(hours: 24);

  static Future<void> initialize() async {
    try {
      // Initialize environment
      environment = _getEnvironment();

      // Initialize device info
      deviceInfo = DeviceInfoPlugin();

      // Initialize shared preferences
      preferences = await SharedPreferences.getInstance();

      if (kDebugMode) {
        print(
          '✅ App Config initialized - Environment: ${environment.name}, Version: $appVersion',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize app config: $e');
      }
      rethrow;
    }
  }

  static Environment _getEnvironment() {
    if (kDebugMode) {
      return Environment.development;
    }

    // You can add more sophisticated environment detection here
    // For example, based on build flavors or environment variables
    const String envString = String.fromEnvironment('ENVIRONMENT');

    switch (envString.toLowerCase()) {
      case 'development':
      case 'dev':
        return Environment.development;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'production':
      case 'prod':
      default:
        return Environment.production;
    }
  }

  // Device Information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'manufacturer': androidInfo.manufacturer,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return {
          'platform': 'Web',
          'browserName': webInfo.browserName.name,
          'userAgent': webInfo.userAgent,
        };
      }

      return {'platform': 'Unknown'};
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to get device info: $e');
      }
      return {'platform': 'Unknown'};
    }
  }

  // User Preferences
  static bool getPreference(String key, {bool defaultValue = false}) {
    return preferences.getBool(key) ?? defaultValue;
  }

  static Future<void> setPreference(String key, bool value) async {
    await preferences.setBool(key, value);
  }

  static String getStringPreference(String key, {String defaultValue = ''}) {
    return preferences.getString(key) ?? defaultValue;
  }

  static Future<void> setStringPreference(String key, String value) async {
    await preferences.setString(key, value);
  }

  static int getIntPreference(String key, {int defaultValue = 0}) {
    return preferences.getInt(key) ?? defaultValue;
  }

  static Future<void> setIntPreference(String key, int value) async {
    await preferences.setInt(key, value);
  }

  static double getDoublePreference(String key, {double defaultValue = 0.0}) {
    return preferences.getDouble(key) ?? defaultValue;
  }

  static Future<void> setDoublePreference(String key, double value) async {
    await preferences.setDouble(key, value);
  }

  static Future<void> clearPreferences() async {
    await preferences.clear();
  }

  // App State
  static bool get isFirstRun {
    return !getPreference('has_run_before');
  }

  static Future<void> markFirstRunComplete() async {
    await setPreference('has_run_before', true);
  }

  static bool get isOnboardingComplete {
    return getPreference(AppConstants.onboardingCompletedKey);
  }

  static Future<void> markOnboardingComplete() async {
    await setPreference(AppConstants.onboardingCompletedKey, true);
  }

  // Debug utilities
  static Map<String, dynamic> getDebugInfo() {
    return {
      'environment': environment.name,
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'apiBaseUrl': apiBaseUrl,
      'wsBaseUrl': wsBaseUrl,
      'enableAnalytics': enableAnalytics,
      'enableCrashlytics': enableCrashlytics,
      'enableDebugLogging': enableDebugLogging,
      'isFirstRun': isFirstRun,
      'isOnboardingComplete': isOnboardingComplete,
    };
  }
}
