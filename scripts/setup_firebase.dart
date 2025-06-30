import 'dart:io';

void main() async {
  print('🔥 GitAlong Firebase Configuration Setup');
  print('=' * 50);

  await checkPrerequisites();
  await displayConfiguration();
  await promptNextSteps();
}

Future<void> checkPrerequisites() async {
  print('\n📋 Checking Prerequisites...');

  // Check if Flutter is installed
  final flutterResult = await Process.run('flutter', ['--version']);
  if (flutterResult.exitCode == 0) {
    print('✅ Flutter: Installed');
  } else {
    print('❌ Flutter: Not found in PATH');
    exit(1);
  }

  // Check if Firebase CLI is available
  try {
    final firebaseResult = await Process.run('firebase', ['--version']);
    if (firebaseResult.exitCode == 0) {
      print('✅ Firebase CLI: Available');
    } else {
      print(
          '⚠️  Firebase CLI: Not found - install with: npm install -g firebase-tools');
    }
  } catch (e) {
    print(
        '⚠️  Firebase CLI: Not found - install with: npm install -g firebase-tools');
  }

  // Check if FlutterFire CLI is available
  try {
    final flutterfireResult = await Process.run('flutterfire', ['--version']);
    if (flutterfireResult.exitCode == 0) {
      print('✅ FlutterFire CLI: Available');
    } else {
      print(
          '⚠️  FlutterFire CLI: Not found - install with: dart pub global activate flutterfire_cli');
    }
  } catch (e) {
    print(
        '⚠️  FlutterFire CLI: Not found - install with: dart pub global activate flutterfire_cli');
  }
}

Future<void> displayConfiguration() async {
  print('\n🔍 Current Configuration:');

  // Read current package name
  final packageName = await getPackageName();
  print('📦 Package Name: $packageName');

  // Read current SHA-1 fingerprint
  final sha1 = await getSha1Fingerprint();
  print('🔑 Debug SHA-1: $sha1');

  // Check Firebase configuration files
  await checkFirebaseFiles();
}

Future<String> getPackageName() async {
  try {
    final file = File('android/app/build.gradle');
    if (await file.exists()) {
      final content = await file.readAsString();
      final match = RegExp(r'applicationId\s+"([^"]+)"').firstMatch(content);
      return match?.group(1) ?? 'Not found';
    }
  } catch (e) {
    // Ignore error
  }
  return 'Not found';
}

Future<String> getSha1Fingerprint() async {
  try {
    final result = await Process.run(
      'keytool',
      [
        '-list',
        '-v',
        '-alias',
        'androiddebugkey',
        '-keystore',
        Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\.android\\debug.keystore'
            : '${Platform.environment['HOME']}/.android/debug.keystore',
        '-storepass',
        'android',
        '-keypass',
        'android'
      ],
    );

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      final match = RegExp(r'SHA1:\s*([A-F0-9:]+)').firstMatch(output);
      return match?.group(1) ?? 'Not found';
    }
  } catch (e) {
    // Try alternative method using gradlew
    try {
      final result = await Process.run(
        Platform.isWindows ? '.\\gradlew.bat' : './gradlew',
        ['signingReport'],
        workingDirectory: 'android',
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp(r'SHA1:\s*([A-F0-9:]+)').firstMatch(output);
        return match?.group(1) ?? 'Not found';
      }
    } catch (e2) {
      // Ignore error
    }
  }
  return 'Not found';
}

Future<void> checkFirebaseFiles() async {
  print('\n📁 Firebase Configuration Files:');

  // Check google-services.json
  final googleServicesFile = File('android/app/google-services.json');
  if (await googleServicesFile.exists()) {
    final content = await googleServicesFile.readAsString();
    if (content.contains('your-android-api-key') ||
        content.contains('123456789')) {
      print('❌ google-services.json: Contains placeholder values');
    } else {
      print('✅ google-services.json: Appears to be configured');
    }
  } else {
    print('❌ google-services.json: Not found');
  }

  // Check firebase_options.dart
  final firebaseOptionsFile = File('lib/firebase_options.dart');
  if (await firebaseOptionsFile.exists()) {
    final content = await firebaseOptionsFile.readAsString();
    if (content.contains('your-android-api-key') ||
        content.contains('your-web-api-key')) {
      print('❌ firebase_options.dart: Contains placeholder values');
    } else {
      print('✅ firebase_options.dart: Appears to be configured');
    }
  } else {
    print('❌ firebase_options.dart: Not found');
  }
}

Future<void> promptNextSteps() async {
  print('\n🚀 Next Steps for Production Deployment:');
  print('');

  print('1. 🔥 Create Firebase Project:');
  print('   • Go to https://console.firebase.google.com/');
  print('   • Create a new project or use existing "gitalong-c8075"');
  print('   • Enable Google Analytics (recommended)');
  print('');

  print('2. 📱 Add Android App to Firebase:');
  print('   • Click "Add app" → Android');
  final packageName = await getPackageName();
  print('   • Package name: $packageName');
  print('   • App nickname: GitAlong Android');
  final sha1 = await getSha1Fingerprint();
  print('   • Debug SHA-1 certificate: $sha1');
  print('');

  print('3. 🔐 Enable Authentication:');
  print('   • Go to Authentication → Sign-in method');
  print('   • Enable Google provider');
  print('   • Set project support email');
  print('');

  print('4. 🗄️  Create Firestore Database:');
  print('   • Go to Firestore Database');
  print('   • Click "Create database"');
  print('   • Start in test mode for development');
  print('   • Choose location: us-central1 (recommended)');
  print('');

  print('5. 📥 Download Configuration:');
  print('   • Download google-services.json from Firebase console');
  print('   • Replace android/app/google-services.json');
  print('');

  print('6. 🔄 Update Firebase Options:');
  print('   • Run: dart pub global activate flutterfire_cli');
  print('   • Run: flutterfire configure --project=gitalong-c8075');
  print('');

  print('7. 🧪 Test the Configuration:');
  print('   • Run: flutter clean');
  print('   • Run: flutter pub get');
  print('   • Run: flutter run');
  print('   • Try Google Sign-In - should work without errors');
  print('');

  print('8. 🔒 For Production Release:');
  print('   • Generate release keystore');
  print('   • Get release SHA-1 fingerprint');
  print('   • Add release SHA-1 to Firebase console');
  print('   • Configure Firestore security rules');
  print('');

  print('📖 For detailed instructions, see: FIREBASE_SETUP_GUIDE.md');
  print('');

  stdout.write('Would you like to run flutterfire configure now? (y/n): ');
  final input = stdin.readLineSync();

  if (input?.toLowerCase() == 'y' || input?.toLowerCase() == 'yes') {
    print('\n🔄 Running flutterfire configure...');
    try {
      final result = await Process.run('flutterfire', ['configure']);
      if (result.exitCode == 0) {
        print('✅ Configuration complete!');
        print('Run "flutter run" to test the setup.');
      } else {
        print('❌ Configuration failed:');
        print(result.stderr);
      }
    } catch (e) {
      print('❌ Error running flutterfire configure: $e');
      print(
          'Make sure FlutterFire CLI is installed: dart pub global activate flutterfire_cli');
    }
  }
}
