<div align="center">
  <img src="assets/images/logo.png" alt="GitAlong Logo" width="120" height="120" style="border-radius: 20px"/>
  <h1>GitAlong</h1>
  <p><strong>Tinder for Developers — swipe, match, and collaborate.</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.29%2B-02569B?logo=flutter" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-3.7%2B-0175C2?logo=dart" alt="Dart"/>
    <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase"/>
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </p>
</div>

---

## ✨ What is GitAlong?

GitAlong is a developer-matching app built with Flutter. Sign in with your GitHub account, discover developers who share your tech interests, swipe right to connect, and chat in real-time — all powered by Supabase.

## 📸 Screenshots

| Login | Discover | Matches | Chat |
|---|---|---|---|
| _GitHub OAuth_ | _Swipe cards_ | _Your matches_ | _Real-time chat_ |

## 🏗️ Architecture

Clean Architecture with strict layer separation:

```
lib/
├── core/                   # Cross-cutting concerns
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency injection (get_it + injectable)
│   ├── router/             # Navigation (GoRouter)
│   ├── theme/              # Colors, text styles, app theme
│   └── utils/              # Logger, helpers
│
├── data/                   # Data layer
│   ├── models/             # JSON-serializable models (json_annotation)
│   ├── repositories/       # Repository implementations (Supabase)
│   └── services/           # GitHub API, Recommendation engine
│
├── domain/                 # Business logic layer (pure Dart)
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository abstractions
│   └── usecases/           # Use cases (one per action)
│
└── presentation/           # UI layer
    ├── bloc/               # BLoC state management
    ├── screens/            # Full-page screens
    └── widgets/            # Reusable components
```

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter 3.29+ |
| Language | Dart 3.7+ |
| State Management | flutter_bloc |
| Dependency Injection | get_it + injectable |
| Navigation | go_router |
| Backend | Supabase (Auth, Database, Realtime) |
| Auth | GitHub OAuth (PKCE flow) |
| Deep Linking | app_links |
| HTTP | Dio + http |
| Local Storage | Hive + flutter_secure_storage |
| UI | flutter_screenutil, flutter_animate, lottie |
| Icons | phosphor_flutter |

## 🚀 Getting Started

### Prerequisites

- Flutter `>=3.29.0`
- Dart `>=3.7.0`
- A [Supabase](https://supabase.com) project
- A [GitHub OAuth App](https://github.com/settings/developers)

### 1. Clone the repo

```bash
git clone https://github.com/sreevallabh04/gitalong.git
cd gitalong
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up environment variables

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
GITHUB_CLIENT_ID=your_github_oauth_client_id
GITHUB_CLIENT_SECRET=your_github_oauth_client_secret
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Set up Supabase

1. Create a new [Supabase project](https://supabase.com/dashboard)
2. Go to **SQL Editor** and run `supabase_schema.sql` from this repo
3. Go to **Authentication → Providers → GitHub** and enable it:
   - **Client ID**: your GitHub OAuth App client ID
   - **Client Secret**: your GitHub OAuth App client secret
4. Go to **Authentication → URL Configuration**:
   - Add `app.gitalong://login-callback/` to **Redirect URLs**

### 5. Set up GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers) → **OAuth Apps**
2. Create a new OAuth App:
   - **Homepage URL**: `https://www.gitalong.app`
   - **Authorization callback URL**: `https://your-project-id.supabase.co/auth/v1/callback`

### 6. Run the app

```bash
flutter run
```

## 🗄️ Database Schema

All tables use `snake_case` column names (standard Postgres convention). Run `supabase_schema.sql` in your Supabase SQL Editor to create:

| Table | Purpose |
|---|---|
| `users` | User profiles synced from GitHub OAuth |
| `swipes` | Swipe actions (like / dislike / super_like) |
| `matches` | Mutual matches between users |
| `messages` | Real-time chat messages |
| `github_cache` | Cached GitHub stats for recommendations |

## 🔐 Security

- `.env` is **gitignored** — never committed
- All API keys go in `.env` only
- Supabase Row Level Security (RLS) is enabled on all tables
- GitHub OAuth uses PKCE flow (no client secret exposed on mobile)

## 📦 Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

## 🧪 Running Tests

```bash
flutter test
```

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push the branch: `git push origin feature/my-feature`
5. Open a Pull Request

## 📄 License

MIT © [sreevallabh04](https://github.com/sreevallabh04)
