<div align="center">
  <img src="assets/images/logo.png" alt="GitAlong Logo" width="120" height="120" style="border-radius: 20px"/>
  <h1>GitAlong</h1>
  <p><strong>A developer matching app for finding collaborators.</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.29%2B-02569B?logo=flutter" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-3.7%2B-0175C2?logo=dart" alt="Dart"/>
    <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase"/>
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </p>
</div>

---

## Overview

GitAlong is a Flutter app for discovering other developers, matching based on shared interests, and chatting after a match. Authentication and realtime messaging are backed by Supabase, with sign-in via GitHub OAuth.

## Features

- GitHub sign-in (OAuth via Supabase)
- Profile discovery and swipe-based matching
- Match list
- Realtime chat (Supabase Realtime)

## Project structure

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

## Tech stack

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

## Getting started

### Prerequisites

- Flutter `>=3.29.0`
- Dart `>=3.7.0`
- A [Supabase](https://supabase.com) project
- A [GitHub OAuth App](https://github.com/settings/developers)

### Clone

```bash
git clone https://github.com/sreevallabh04/gitalong.git
cd gitalong
```

### Install dependencies

```bash
flutter pub get
```

### Configure environment

```bash
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
GITHUB_CLIENT_ID=your_github_oauth_client_id
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Notes:
- This app uses the OAuth + PKCE flow through Supabase. Do not ship a GitHub client secret inside a mobile app.

### Supabase setup

1. Create a new [Supabase project](https://supabase.com/dashboard)
2. Go to **SQL Editor** and run `supabase_schema.sql` from this repo
3. Go to **Authentication → Providers → GitHub** and enable it:
   - **Client ID**: your GitHub OAuth App client ID
   - **Client Secret**: your GitHub OAuth App client secret
4. Go to **Authentication → URL Configuration**:
   - Add `app.gitalong://login-callback/` to **Redirect URLs**

### GitHub OAuth App setup

1. Go to [GitHub Developer Settings](https://github.com/settings/developers) → **OAuth Apps**
2. Create a new OAuth App:
   - **Homepage URL**: your project homepage (or repository URL)
   - **Authorization callback URL**: `https://your-project-id.supabase.co/auth/v1/callback`

### Run

```bash
flutter run
```

## Database schema

All tables use `snake_case` column names (standard Postgres convention). Run `supabase_schema.sql` in your Supabase SQL Editor to create:

| Table | Purpose |
|---|---|
| `users` | User profiles synced from GitHub OAuth |
| `swipes` | Swipe actions (like / dislike / super_like) |
| `matches` | Mutual matches between users |
| `messages` | Real-time chat messages |
| `github_cache` | Cached GitHub stats for recommendations |

## Security notes

- `.env` is **gitignored** — never committed
- All API keys go in `.env` only
- Supabase Row Level Security (RLS) is enabled on all tables
- GitHub OAuth uses PKCE (no client secret embedded in the app)

## Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

## Tests

```bash
flutter test
```

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push the branch: `git push origin feature/my-feature`
5. Open a Pull Request

## License

MIT © [sreevallabh04](https://github.com/sreevallabh04)
