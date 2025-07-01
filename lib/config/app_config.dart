import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../core/utils/logger.dart';

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
  static const int maxRetryAttempts = 3;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Feature flags
  static bool get enableGoogleSignIn => true;
  static bool get enableAppleSignIn =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  static bool get enableBiometricAuth => !kIsWeb;
}
