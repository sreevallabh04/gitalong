#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  AppLogger.logger.i('🔥 GitAlong Firebase Configuration Setup');
  AppLogger.logger.i('=' * 50);

  try {
    // Check prerequisites
    await checkPrerequisites();

    // Show current configuration
    await showCurrentConfiguration();

    // Check Firebase configuration files
    await checkFirebaseFiles();

    // Show next steps
    await showNextSteps();

    // Optionally run flutterfire configure
    await runFlutterfireConfigure();
  } catch (e) {
    AppLogger.logger.e('❌ Setup script failed: $e');
    exit(1);
  }
}

Future<void> checkPrerequisites() async {
  AppLogger.logger.i('\n📋 Checking Prerequisites...');

  // Check Flutter
  final flutterResult = await Process.run('flutter', ['--version']);
  if (flutterResult.exitCode == 0) {
    AppLogger.logger.i('✅ Flutter: Installed');
  } else {
    AppLogger.logger.e('❌ Flutter: Not found in PATH');
    exit(1);
  }

  // Check Firebase CLI
  final firebaseResult = await Process.run('firebase', ['--version'])
      .catchError((_) => ProcessResult(0, 1, '', 'Firebase CLI not found'));

  if (firebaseResult.exitCode == 0) {
    AppLogger.logger.i('✅ Firebase CLI: Available');
  } else {
    AppLogger.logger.e('❌ Firebase CLI: Not installed');
    AppLogger.logger.i('   Install: npm install -g firebase-tools');
    AppLogger.logger.i('   Then run: firebase login');
  }

  // Check FlutterFire CLI
  final flutterfireResult = await Process.run('flutterfire', ['--version'])
      .catchError((_) => ProcessResult(0, 1, '', 'FlutterFire CLI not found'));

  if (flutterfireResult.exitCode == 0) {
    AppLogger.logger.i('✅ FlutterFire CLI: Available');
  } else {
    AppLogger.logger.e('❌ FlutterFire CLI: Not installed');
    AppLogger.logger.i('   Install: dart pub global activate flutterfire_cli');
  }
}

Future<void> showCurrentConfiguration() async {
  AppLogger.logger.i('\n🔍 Current Configuration:');

  // Get package name from Android manifest
  final packageName = await getPackageName();
  AppLogger.logger.i('📦 Package Name: $packageName');

  // Get SHA-1 fingerprint
  final sha1 = await getSha1Fingerprint();
  AppLogger.logger.i('🔑 Debug SHA-1: $sha1');
}

Future<String> getPackageName() async {
  try {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (manifestFile.existsSync()) {
      final content = await manifestFile.readAsString();
      final packageMatch = RegExp(r'package="([^"]+)"').firstMatch(content);
      return packageMatch?.group(1) ?? 'com.example.gitalong';
    }
  } catch (e) {
    AppLogger.logger.w('⚠️ Could not read package name: $e');
  }
  return 'com.example.gitalong';
}

Future<String> getSha1Fingerprint() async {
  try {
    // Try different locations for debug keystore
    final List<String> keystorePaths = [
      '${Platform.environment['HOME']}/.android/debug.keystore',
      '${Platform.environment['USERPROFILE']}\\.android\\debug.keystore',
    ];

    for (final keystorePath in keystorePaths) {
      final keystoreFile = File(keystorePath);
      if (keystoreFile.existsSync()) {
        final result = await Process.run('keytool', [
          '-list',
          '-v',
          '-alias',
          'androiddebugkey',
          '-keystore',
          keystorePath,
          '-storepass',
          'android',
          '-keypass',
          'android'
        ]);

        if (result.exitCode == 0) {
          final sha1Match =
              RegExp(r'SHA1: ([A-F0-9:]+)').firstMatch(result.stdout);
          if (sha1Match != null) {
            return sha1Match.group(1)!;
          }
        }
      }
    }
  } catch (e) {
    AppLogger.logger.w('⚠️ Could not get SHA-1 fingerprint: $e');
  }

  return 'Not found (run: keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore)';
}

Future<void> checkFirebaseFiles() async {
  AppLogger.logger.i('\n📁 Firebase Configuration Files:');

  // Check google-services.json
  final googleServicesFile = File('android/app/google-services.json');
  if (googleServicesFile.existsSync()) {
    final content = await googleServicesFile.readAsString();
    if (content.contains('your-') || content.contains('placeholder')) {
      AppLogger.logger.e('❌ google-services.json: Contains placeholder values');
    } else {
      AppLogger.logger.i('✅ google-services.json: Appears to be configured');
    }
  } else {
    AppLogger.logger.e('❌ google-services.json: Not found');
  }

  // Check firebase_options.dart
  final firebaseOptionsFile = File('lib/firebase_options.dart');
  if (firebaseOptionsFile.existsSync()) {
    final content = await firebaseOptionsFile.readAsString();
    if (content.contains('your-') || content.contains('abcd1234')) {
      AppLogger.logger
          .e('❌ firebase_options.dart: Contains placeholder values');
    } else {
      AppLogger.logger.i('✅ firebase_options.dart: Appears to be configured');
    }
  } else {
    AppLogger.logger.e('❌ firebase_options.dart: Not found');
  }
}

Future<void> showNextSteps() async {
  AppLogger.logger.i('\n🚀 Next Steps for Production Deployment:');
  AppLogger.logger.i('');

  AppLogger.logger.i('1. 🔥 Create Firebase Project:');
  AppLogger.logger.i('   • Go to https://console.firebase.google.com/');
  AppLogger.logger
      .i('   • Create a new project or use existing "gitalong-c8075"');
  AppLogger.logger.i('   • Enable Google Analytics (recommended)');
  AppLogger.logger.i('');

  AppLogger.logger.i('2. 📱 Add Android App to Firebase:');
  AppLogger.logger.i('   • Click "Add app" → Android');
  final packageName = await getPackageName();
  AppLogger.logger.i('   • Package name: $packageName');
  AppLogger.logger.i('   • App nickname: GitAlong Android');
  final sha1 = await getSha1Fingerprint();
  AppLogger.logger.i('   • Debug SHA-1 certificate: $sha1');
  AppLogger.logger.i('');

  AppLogger.logger.i('3. 🔐 Enable Authentication:');
  AppLogger.logger.i('   • Go to Authentication → Sign-in method');
  AppLogger.logger.i('   • Enable Google provider');
  AppLogger.logger.i('   • Set project support email');
  AppLogger.logger.i('');

  AppLogger.logger.i('4. 🗄️  Create Firestore Database:');
  AppLogger.logger.i('   • Go to Firestore Database');
  AppLogger.logger.i('   • Click "Create database"');
  AppLogger.logger.i('   • Start in test mode for development');
  AppLogger.logger.i('   • Choose location: us-central1 (recommended)');
  AppLogger.logger.i('');

  AppLogger.logger.i('5. 📥 Download Configuration:');
  AppLogger.logger
      .i('   • Download google-services.json from Firebase console');
  AppLogger.logger.i('   • Replace android/app/google-services.json');
  AppLogger.logger.i('');

  AppLogger.logger.i('6. 🔄 Update Firebase Options:');
  AppLogger.logger.i('   • Run: dart pub global activate flutterfire_cli');
  AppLogger.logger
      .i('   • Run: flutterfire configure --project=gitalong-c8075');
  AppLogger.logger.i('');

  AppLogger.logger.i('7. 🧪 Test the Configuration:');
  AppLogger.logger.i('   • Run: flutter clean');
  AppLogger.logger.i('   • Run: flutter pub get');
  AppLogger.logger.i('   • Run: flutter run');
  AppLogger.logger.i('   • Try Google Sign-In - should work without errors');
  AppLogger.logger.i('');

  AppLogger.logger.i('8. 🔒 For Production Release:');
  AppLogger.logger.i('   • Generate release keystore');
  AppLogger.logger.i('   • Get release SHA-1 fingerprint');
  AppLogger.logger.i('   • Add release SHA-1 to Firebase console');
  AppLogger.logger.i('   • Configure Firestore security rules');
  AppLogger.logger.i('');

  AppLogger.logger
      .i('📖 For detailed instructions, see: FIREBASE_SETUP_GUIDE.md');
  AppLogger.logger.i('');
}

Future<void> runFlutterfireConfigure() async {
  AppLogger.logger
      .i('🤔 Would you like to run flutterfire configure now? (y/N)');
  final input = stdin.readLineSync()?.toLowerCase() ?? 'n';

  if (input == 'y' || input == 'yes') {
    AppLogger.logger.i('\n🔄 Running flutterfire configure...');
    try {
      final result = await Process.run(
          'flutterfire', ['configure', '--project=gitalong-c8075']);

      if (result.exitCode == 0) {
        AppLogger.logger.i('✅ Configuration complete!');
        AppLogger.logger.i('Run "flutter run" to test the setup.');
      } else {
        AppLogger.logger.e('❌ Configuration failed:');
        AppLogger.logger.e(result.stderr);
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error running flutterfire configure: $e');
      AppLogger.logger.i(
          'You can run it manually later: flutterfire configure --project=gitalong-c8075');
    }
  }
}

// Mock logger for the script
class AppLogger {
  static final logger = _MockLogger();
}

class _MockLogger {
  // ignore: avoid_print
  void i(String message) => print(message);
  // ignore: avoid_print
  void e(String message) => print(message);
  // ignore: avoid_print
  void w(String message) => print(message);
}
