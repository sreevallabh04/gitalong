# 🚀 GitAlong - Open Source Matchmaking App

A beautiful Tinder-style Flutter app that connects open source contributors with exciting projects! Built with Flutter, Supabase, and modern UI/UX principles.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green?logo=supabase)
![Dart](https://img.shields.io/badge/Dart-Language-blue?logo=dart)

## ✨ Features

### 🎨 **Beautiful UI**
- Modern gradient design with smooth animations
- Tab-based authentication (Sign In / Sign Up)
- Intuitive onboarding flow
- Dark theme optimized

### 🔐 **Authentication**
- Email/password authentication via Supabase
- Secure password reset functionality
- Form validation and error handling
- Persistent login state

### 🎯 **Core App Structure**
- **Splash Screen** - Animated app loading
- **Authentication** - Login/Signup with beautiful forms
- **Onboarding** - Role selection and profile setup
- **Main Navigation** - Discover, Messages, Saved, Profile
- **Swipe Interface** - Tinder-style matching (ready for implementation)

### 🏗️ **Architecture**
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **UI Framework**: Flutter with Material Design 3
- **Database**: Comprehensive schema with RLS policies

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio or VS Code
- Supabase account

### 1. Clone and Setup
```bash
git clone <your-repo>
cd Gitalong
flutter pub get
```

### 2. Supabase Setup

#### A. Create Project
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create new project
3. Copy your project URL and anon key

#### B. Configure Flutter
Update `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  // ...
}
```

#### C. Setup Database
1. Go to your Supabase project → SQL Editor
2. Copy the contents of `supabase_setup.sql`
3. Run the script to create all tables, policies, and functions

### 3. Run the App
```bash
flutter run
```

## 🗄️ Database Schema

The app includes a comprehensive database setup:

### Core Tables
- **users** - User profiles (extends auth.users)
- **projects** - Open source projects 
- **swipes** - User swipe actions
- **matches** - Successful matches
- **messages** - Chat messages
- **badges** - User achievements
- **contributions** - Contribution tracking
- **saved_projects** - Bookmarked projects

### Security Features
- ✅ Row Level Security (RLS) enabled
- ✅ Secure access policies
- ✅ User data protection
- ✅ Real-time subscriptions

### Performance Optimizations
- ✅ Database indexes for fast queries
- ✅ Optimized conversation queries
- ✅ Automatic timestamp updates

## 🎯 Current Implementation Status

### ✅ Completed
- [x] Project structure and dependencies
- [x] Beautiful authentication screens
- [x] Supabase integration
- [x] Database schema and security
- [x] User registration and login
- [x] Onboarding flow (partial)
- [x] Navigation structure
- [x] State management setup

### 🚧 Ready for Implementation
- [ ] Swipe interface with project/user cards
- [ ] Matching algorithm
- [ ] Real-time messaging
- [ ] User profile management
- [ ] Project creation and management
- [ ] Search and filters
- [ ] Notifications
- [ ] Advanced matching preferences

## 🔧 Development

### Project Structure
```
lib/
├── config/          # Supabase configuration
├── models/          # Data models
├── providers/       # Riverpod state providers
├── screens/         # UI screens
│   ├── auth/        # Login/signup
│   ├── home/        # Main app screens
│   └── onboarding/  # User setup flow
├── services/        # Business logic
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

### Key Services
- **AuthService** - Authentication and user management
- **SwipeService** - Matching logic
- **MessagingService** - Real-time chat

## 🎨 Design System

### Colors
- Primary: Material 3 dynamic colors
- Gradients: Smooth primary/secondary blends
- Cards: Elevated surfaces with shadows

### Typography
- Google Fonts integration
- Hierarchical text styles
- Accessibility-focused sizing

### Components
- Custom form fields with validation
- Animated buttons and transitions
- Modern card designs

## 🔒 Security

### Authentication
- Email/password with strong validation
- Secure password reset flow
- Session management

### Database Security
- Row Level Security (RLS) policies
- User-specific data access
- Secure API endpoints
- Real-time subscriptions with auth

## 📱 Testing

### Run Tests
```bash
flutter test
```

### Build for Release
```bash
flutter build apk --release
flutter build ios --release
```

## 🤝 Contributing

The app structure is ready for collaborative development:

1. **UI Implementation** - Complete the swipe interface
2. **Backend Logic** - Implement matching algorithms  
3. **Features** - Add messaging, profiles, search
4. **Testing** - Write comprehensive tests
5. **Deployment** - Set up CI/CD pipelines

## 📞 Support

For setup issues or questions:
1. Check the Supabase console for connection issues
2. Verify database tables are created correctly
3. Ensure authentication is properly configured
4. Check Flutter doctor for environment issues

## 🚀 Next Steps

1. **Complete the onboarding flow** with skills selection
2. **Implement swipe interface** with project/user cards
3. **Add real-time messaging** using Supabase subscriptions
4. **Build matching algorithm** based on skills and interests
5. **Add user profile management** with image uploads
6. **Implement project creation** for maintainers

---

**Happy Coding! 🎉** 

*GitAlong - Where open source contributors and maintainers find their perfect match!*
