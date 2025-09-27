# GitAlong - Tinder for Developers

GitAlong is a Flutter application that connects developers through their GitHub projects. Think Tinder for developers, but focused on meaningful collaborations and project discovery.

## 🚀 Features

- **Swipe & Match**: Tinder-style interface for discovering developers and projects
- **GitHub Integration**: Seamless OAuth authentication with GitHub
- **Real-time Chat**: Connect with matched developers through in-app messaging
- **Project Discovery**: Find trending and recommended projects
- **Clean Architecture**: Modular, scalable, and testable codebase
- **Responsive Design**: Adaptive UI across all screen sizes
- **Dark/Light Mode**: Beautiful theme system with system preference support

## 🛠️ Tech Stack

- **Framework**: Flutter 3.29+
- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: get_it with injectable
- **Navigation**: GoRouter
- **Responsive Design**: flutter_screenutil
- **Animations**: flutter_animate, Lottie
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics)
- **API Integration**: GitHub API, Dio
- **Local Storage**: Hive, flutter_secure_storage

## 📱 Screenshots

*Screenshots will be added after UI implementation*

## 🏗️ Architecture

The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                 # Core functionality
│   ├── di/              # Dependency injection
│   ├── router/          # Navigation
│   └── theme/           # App theming
├── data/                # Data layer
│   ├── datasources/     # API and local data sources
│   ├── models/          # Data models
│   └── repositories/    # Repository implementations
├── domain/              # Domain layer
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic
└── presentation/        # Presentation layer
    ├── screens/         # UI screens
    ├── widgets/         # Reusable widgets
    └── bloc/           # State management
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.29 or higher
- Dart 3.7 or higher
- Android Studio / VS Code
- Firebase project setup
- GitHub OAuth app

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/gitalong.git
   cd gitalong
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure GitHub OAuth**
   - Create a GitHub OAuth app
   - Update `.env` file with your GitHub client credentials

5. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# GitHub OAuth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_API_KEY=your_firebase_api_key

# App Configuration
APP_NAME=GitAlong
APP_VERSION=1.0.0
DEBUG_MODE=true
```

### Firebase Setup

1. Create a new Firebase project
2. Enable Authentication (GitHub provider)
3. Create Firestore database
4. Enable Cloud Storage
5. Configure Analytics and Crashlytics

### GitHub OAuth Setup

1. Go to GitHub Settings > Developer settings > OAuth Apps
2. Create a new OAuth App
3. Set Authorization callback URL: `https://your-firebase-project-id.firebaseapp.com/__/auth/handler`
4. Copy Client ID and Client Secret to `.env` file

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `go_router` - Navigation
- `flutter_screenutil` - Responsive design
- `dio` - HTTP client
- `firebase_core` - Firebase integration

### UI Dependencies
- `flutter_animate` - Animations
- `lottie` - Lottie animations
- `card_swiper` - Swipe cards
- `cached_network_image` - Image caching
- `google_fonts` - Typography

### Data Dependencies
- `hive` - Local database
- `flutter_secure_storage` - Secure storage
- `json_annotation` - JSON serialization
- `freezed` - Immutable classes

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 🚀 Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact the development team
- Check the documentation

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- GitHub for API access
- All contributors and testers

---

**Built with ❤️ by the GitAlong team**
