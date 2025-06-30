# 🚀 GitAlong

**Connect • Collaborate • Create**

A modern Flutter application that matches open source projects with passionate contributors using a Tinder-like swipe interface. Built with Firebase, clean architecture, and production-ready practices.

---

## 📱 Features

- 🔥 **Smart Matching**: Swipe through curated open source projects
- 🔐 **Multi-Auth**: Google Sign-In, Apple Sign-In, and Email/Password
- 💬 **Real-time Chat**: Instant messaging with project maintainers  
- 👤 **Rich Profiles**: Showcase skills, GitHub integration, and project history
- 🎨 **Modern UI**: Glassmorphic design with neon accents and smooth animations
- 📊 **Analytics**: Track contributions and project engagement

---

## 🏗️ Architecture

- **Clean Architecture** with separation of concerns
- **Riverpod** for state management
- **Firebase** for backend services (Auth, Firestore, Storage)
- **Repository Pattern** with interfaces
- **Comprehensive Error Handling** and logging
- **Production-Ready** configuration

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Firebase account

### 1. Clone & Setup

```bash
git clone https://github.com/your-org/gitalong.git
cd gitalong
flutter pub get
```

### 2. Firebase Configuration

**⚠️ IMPORTANT**: This app requires proper Firebase configuration to work.

**Current Status**: The app uses placeholder Firebase configuration files. Google Sign-In will fail with `DEVELOPER_ERROR (Code 10)` until properly configured.

#### Option A: Automated Setup (Recommended)

```bash
dart run scripts/setup_firebase.dart
```

#### Option B: Manual Setup

1. See detailed instructions: **[FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)**
2. Your debug SHA-1 fingerprint: `F9:38:05:08:14:4E:ED:79:17:3E:6E:45:F2:06:38:3B:C5:F8:09:39`
3. Package name: `com.example.gitalong`

### 3. Run the App

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔧 Development

### Current State

✅ **Working Features:**
- Firebase initialization with comprehensive logging
- Email/Password authentication  
- Clean architecture implementation
- Modern UI with animations
- Error handling and validation
- Comprehensive logging system

⚠️ **Requires Configuration:**
- Google Sign-In (needs real Firebase config)
- Firestore database setup
- Production security rules

### Testing

```bash
# Run tests
flutter test

# Check for issues
flutter analyze

# Check dependencies
flutter pub deps
```

### Building

```bash
# Debug build
flutter build apk --debug

# Release build (requires proper keystore)
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── config/          # App and Firebase configuration
├── core/            # Core utilities, constants, themes
├── models/          # Data models and entities
├── providers/       # Riverpod state providers
├── screens/         # UI screens and pages
├── services/        # Business logic and API calls
├── widgets/         # Reusable UI components
└── main.dart        # App entry point

scripts/
└── setup_firebase.dart  # Automated Firebase setup

docs/
└── FIREBASE_SETUP_GUIDE.md  # Detailed setup instructions
```

---

## 🔒 Production Deployment

### Security Checklist

- [ ] Replace placeholder Firebase configuration
- [ ] Configure Firestore security rules
- [ ] Generate production keystore
- [ ] Add release SHA-1 to Firebase
- [ ] Set up app signing in Play Console
- [ ] Configure OAuth consent screen
- [ ] Enable required Firebase services

### Performance

- **Clean Architecture** for maintainability
- **Lazy Loading** of Firebase services
- **Efficient State Management** with Riverpod
- **Image Optimization** and caching
- **Network Request** optimization

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

### Common Issues

**Google Sign-In fails with "DEVELOPER_ERROR"**
- ✅ **Solution**: Run `dart run scripts/setup_firebase.dart` or follow [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)

**App crashes on startup**
- ✅ **Solution**: Ensure Firebase is properly initialized

**Build fails**
- ✅ **Solution**: Run `flutter clean && flutter pub get`

### Getting Help

- 📖 **Documentation**: [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-org/gitalong/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/gitalong/discussions)

---

**Made with ❤️ for the open source community**
