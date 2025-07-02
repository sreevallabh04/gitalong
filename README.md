# GitAlong - Find Your Perfect Open Source Match

<div align="center">
  <img src="assets/icons/app_icon.jpg" alt="GitAlong App Icon" width="120" height="120" style="border-radius: 20px;">
  
  <p><em>Created by Sreevallabh Kakarala</em></p>
</div>

GitAlong is a Flutter application that connects developers with open source projects through a Tinder-like interface. Find projects that match your skills, interests, and availability.

## 🚀 Production-Ready Features

### ✅ Authentication System
- **Firebase Authentication** - Fully configured and production-ready
- **Google Sign-In** - Complete integration with proper error handling
- **Apple Sign-In** - Available on iOS/macOS platforms
- **Email/Password** - Traditional authentication with validation
- **Comprehensive Logging** - Production-grade logging system
- **Error Handling** - Robust error management and user feedback

### 🔧 Technical Architecture
- **State Management** - Flutter Riverpod with proper provider architecture
- **Local Storage** - Hive for efficient local data management
- **Responsive Design** - Flutter ScreenUtil for multi-device support
- **Modern UI** - Glassmorphism effects and smooth animations
- **Error Recovery** - Graceful error handling with user-friendly messaging

## 📱 Quick Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase CLI
- Git

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd Gitalong

# Install dependencies
flutter pub get

# Run the setup script for Firebase configuration
dart scripts/setup_firebase.dart

# Run the app
flutter run
```

## 🔥 Firebase Configuration

The app is configured to work with Firebase project `gitalong-c8075`. The authentication system is production-ready with:

- ✅ **API Keys**: Properly configured for all platforms
- ✅ **Google Sign-In**: Full integration with error handling
- ✅ **Firestore**: Database connectivity and validation
- ✅ **Error Logging**: Comprehensive logging for debugging

### For Development
The app will work immediately after `flutter pub get` with the included Firebase configuration. Google Sign-In requires proper SHA-1 fingerprint setup for full functionality.

### For Production Deployment
1. Run the setup script: `dart scripts/setup_firebase.dart`
2. Follow the detailed instructions provided
3. Update SHA-1 fingerprints in Firebase console
4. Test authentication flows thoroughly

## 📋 Project Structure

```
lib/
├── config/           # App and Firebase configuration
├── core/            # Core utilities (theme, constants, utils)
├── models/          # Data models
├── providers/       # State management (Riverpod)
├── screens/         # UI screens
├── services/        # Business logic and API services
└── widgets/         # Reusable UI components
```

## 🔐 Authentication Features

### Sign-In Methods
- **Google Sign-In**: One-tap authentication with Google accounts
- **Apple Sign-In**: Seamless authentication on iOS/macOS
- **Email/Password**: Traditional authentication with validation
- **Password Reset**: Email-based password recovery

### Security Features
- Session management with automatic refresh
- Secure token storage
- Biometric authentication support (when available)
- Comprehensive error handling and logging

### User Experience
- Smooth onboarding flow
- Profile creation and management
- Persistent authentication state
- Graceful error recovery

## 🚨 Troubleshooting

### Common Issues

**Google Sign-In Not Working**
```bash
# Check Firebase configuration
dart scripts/setup_firebase.dart

# Verify SHA-1 fingerprint is added to Firebase console
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

**Firebase Initialization Errors**
- Ensure internet connectivity
- Check Firebase project status
- Verify API keys are not placeholder values
- Review logs for specific error details

**Build Errors**
```bash
flutter clean
flutter pub get
flutter run
```

## 📊 Logging and Debugging

The app includes comprehensive logging:
- **Authentication flows** - Track sign-in/sign-out processes
- **Firebase operations** - Monitor database and auth operations
- **Navigation events** - Debug screen transitions
- **Error tracking** - Capture and report errors
- **Performance metrics** - Monitor app performance

Logs are visible in debug mode and can be configured for production monitoring.

## 🛠️ Development

### Running the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

### Code Quality
- Comprehensive error handling
- Type-safe state management
- Responsive design patterns
- Modern Flutter practices
- Production-ready architecture

## 📚 Documentation

- [Firebase Setup Guide](FIREBASE_SETUP_GUIDE.md) - Detailed Firebase configuration
- [Fixes Implemented](FIXES_IMPLEMENTED.md) - Recent improvements and bug fixes

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Author**: Sreevallabh Kakarala

## 🔗 Links

- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)

---

**Status**: ✅ Production Ready | 🔐 Authentication Complete | 🚀 Ready to Deploy
